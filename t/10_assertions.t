use strict;
use Test::Exception tests => 4;

package T_one;
use Devel::Assert;
use Test::Exception;

lives_ok{ eval q/assert(0); 1/ or die $@};
lives_ok{ eval q/assert(1); 1/ or die $@};

package T_two;
use Test::Exception;
use Devel::Assert -ok;

lives_ok{ eval q/assert(1); 1/ or die $@};
throws_ok{ eval q/assert(0); 1/ or die $@} qr/Assertion ' 0 ' failed/;
