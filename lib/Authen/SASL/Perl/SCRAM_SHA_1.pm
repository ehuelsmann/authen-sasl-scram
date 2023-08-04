
use strict;
use warnings;

package Authen::SASL::Perl::SCRAM_SHA_1;

use parent 'Authen::SASL::SCRAM';


sub _order { 10 }

sub digest {
    return 'SHA-1';
}

1;
