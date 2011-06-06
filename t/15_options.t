use strict;
use Test::More;
use Test::Exception tests => 6;

lives_ok { eval q/use Devel::Assert; 1/ or die $@ };
lives_ok { eval q/use Devel::Assert -verbose; 1/ or die $@ };
lives_ok { eval q/use Devel::Assert 0, -verbose; 1/ or die $@ };
lives_ok { eval q/use Devel::Assert -verbose, 0; 1/ or die $@ };
dies_ok { eval q/use Devel::Assert 0, 0; 1/ or die $@ };
dies_ok { eval q/use Devel::Assert 0, -verbose, 1; 1/ or die $@ };
