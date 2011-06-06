use strict;
use Test::More tests => 8;
use Test::Exception;

package Z;
	sub new{
		bless {}, shift
	}

	sub assert{
		return 12;
	}


package main;
use Devel::Assert;

lives_ok{ is((eval 'Z->assert(0)' or die $@), 12) };

my $z;
lives_ok{ eval '$z = Z->new()' or die $@ };

lives_ok{ is((eval '$z->assert()' or die $@), 12) };
lives_ok{ is((eval '$z->assert' or die $@), 12) };

lives_ok{ eval 'assert => 1' or die $@ };
