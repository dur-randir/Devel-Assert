use strict;
use Test::More;
use Test::Exception tests => 5;

lives_ok { eval q/use Devel::Assert 1, -verbose; 1/ or die $@ };
lives_ok { eval q/use Devel::Assert -verbose, 1; 1/ or die $@ };
lives_ok { eval q/use Devel::Assert -verbose, -all; 1/ or die $@ };
lives_ok { eval q/use Devel::Assert -all, -verbose; 1/ or die $@ };
dies_ok { eval q/use Devel::Assert -all, -all; 1/ or die $@ };
