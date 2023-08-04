
use strict;
use warnings;

package Authen::SASL::Perl::SCRAM_SHA_256;

use parent 'Authen::SASL::SCRAM';

sub _order { 11 }

sub digest {
    return 'SHA-256';
}

1;
