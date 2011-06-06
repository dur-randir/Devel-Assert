use strict;
use Test::More;
use Test::Exception;

use Devel::Assert -all;

eval { require Data::Dumper; 1 } or do {
        plan skip_all => 'No Data::Dumper found - no verbosity';
};

eval { require PadWalker; 1 } or do {
        plan skip_all => 'No PadWalker found - no verbosity';
};

plan tests => 3;

Devel::Assert::set_options(
        hook_terse => sub { $_[1] ? 12 : 13 },
);
Devel::Assert::set_options(
        verbose          => 1,
);
is(assert(0), 12);
Devel::Assert::set_options(
        verbose          => 1,
        hook_verbose => sub { return 14 },
);
is(assert(0), 14);
Devel::Assert::set_options(
        hook_verbose => sub { like($_[0], qr/12 > 13/) },
);
assert(12 > 13);
