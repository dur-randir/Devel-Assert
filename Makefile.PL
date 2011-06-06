use strict;
use inc::Module::Install;

perl_version '5.008001';
name 'Devel-Assert';

abstract_from 'lib/Devel/Assert.pod';
author 'Sergey Aleynikov <sergey.aleynikov@gmail.com>';
version_from 'lib/Devel/Assert.pm';
license 'perl';

test_requires 'Test::More';
test_requires 'Test::Exception';

requires 'Carp';
requires 'Devel::Declare' => '0.005007';

system 'pod2text lib/Devel/Assert.pod > README';

WriteAll;
