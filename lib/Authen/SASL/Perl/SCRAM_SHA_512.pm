
use strict;
use warnings;

package Authen::SASL::Perl::SCRAM_SHA_512;

use parent 'Authen::SASL::SCRAM';

sub _order { 12 }

sub digest {
    return 'SHA-512';
}

1;
