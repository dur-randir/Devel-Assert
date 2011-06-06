use strict;
use Test::More;
use Test::Exception;

eval { require Data::Dumper; 1 } or do {
	plan skip_all => 'No Data::Dumper found - no verbosity';
};

eval { require PadWalker; 1 } or do {
	plan skip_all => 'No PadWalker found - no verbosity';
};

plan tests => 6;

use Devel::Assert -verbose, -all;

my $z = 12;
sub x{
	our $y = 13;
	assert($z > $y);
}

dies_ok{ x() };
my $message = $@;
like($message, qr/Assertion ' \$z > \$y ' failed/);
like($message, qr/\$z = 12;/);
like($message, qr/\$y = 13;/);

sub z{ assert(0) }
dies_ok{ z() };
my $message = $@;
like($message, qr/variables\.\.\.none found/);
