use strict;
use Test::Exception tests => 5;

use Devel::Assert -all;

package T_one;
use Devel::Assert;
use Test::Exception;

lives_ok{ eval q/assert(1); 1/ or die $@};
throws_ok{ eval q/assert(0); 1/ or die $@} qr/Assertion ' 0 ' failed/;

package T_two;
use Devel::Assert;
use Test::Exception;

lives_ok{ eval q/assert(1); 1/ or die $@};
no Devel::Assert;
lives_ok{ eval q/assert(1); 1/ or die $@};
use Devel::Assert;
throws_ok{ eval q/assert(0); 1/ or die $@} qr/Assertion ' 0 ' failed/;
