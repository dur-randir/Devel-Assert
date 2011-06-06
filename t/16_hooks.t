use strict;
use Test::More;
use Test::Exception tests => 2;

use Devel::Assert -all;

Devel::Assert::set_options(
	hook_terse => sub { return 11 },
);
is(assert(0), 11);

Devel::Assert::set_options(
	hook_terse => sub { $_[1] ? 12 : 13 },
);
is(assert(0), 13);

