use strict;
use Test::Exception tests => 1;

use Devel::Assert;
throws_ok{ eval q/assert 0; 1/ or die $@} qr/use assert ONLY as/;
