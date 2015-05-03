use strict;
use Test::Exception tests => 5;

use Devel::Assert 'on';
use Test::Exception;

throws_ok{ assert(0) } qr/failed/;

no Devel::Assert;
lives_ok{ assert(1) };
lives_ok{ assert(0) };

use Devel::Assert 'on';
throws_ok{ assert(0) } qr/failed/;
lives_ok{ eval 'assert(0); 1' or die $@ };
