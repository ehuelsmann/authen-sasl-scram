
use strict;
use warnings;

use Feature::Compat::Try;

package Authen::SASL::SCRAM;

use Authen::SASL;

use parent qw(Authen::SASL::Perl);

use Authen::SCRAM::Client;
use Authen::SCRAM::Server;

my %secflags = (
  noplaintext => 1,
  noanonymous => 1,
);

sub _secflags {
  shift;
  scalar grep { $secflags{$_} } @_;
}


sub client_start {
    my $self = shift;

    $self->{need_step} = 2;
    $self->{error}     = undef;

    my $user = $self->_call('user');
    return $self->set_error( 'Username is required' )
        unless defined $user;

    my $pass = $self->_call('pass');
    return $self->set_error( 'Password is required' )
        unless defined $pass;

    $self->{_client}   = Authen::SCRAM::Client->new(
        username => $user,
        password => $pass,
        );

    return $self->{_client}->first_msg();
}

sub client_step {
    my $self = shift;
    my $challenge = shift;

    $self->{state}--;
    if ($self->{state} == 1) {
        try {
            return $self->{_client}->final_msg( $challenge );
        }
        catch ($e) {
            return $self->set_error( 'Challenge failed (step 1)' );
        }
    }
    else {
        try {
            return $self->{_client}->validate( $challenge );
        }
        catch ($e) {
            return $self->set_error( 'Response failed (step 2)' );
        }
    }
}

sub mechanism {
    my $self = shift;
    return 'SCRAM-' . $self->digest;
}


sub server_start {
    my $self = shift;
    my $client_first = shift;

    $self->{need_step} = 1;
    $self->{_server}   = Authen::SCRAM::Server->new(
        credential_cb => $self->callback('getsecret')
        );

    try {
        return $self->{_server}->first_msg( $client_first );
    }
    catch ($e) {
        return $self->set_error( 'Client initiation failed' );
    }
}

sub server_step {
    my $self = shift;
    my $client_final = shift;

    $self->{need_step}--;
    try {
        my $rv = $self->{_server}->final_msg( $client_final );
        $self->property( 'authname', $self->{_server}->authorization_id );
        return $rv;
    }
    catch ($e) {
        return $self->set_error( 'Client finalization failed' );
    }
}



1;
