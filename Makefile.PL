use 5.010;
use ExtUtils::MakeMaker;

system 'pod2text lib/Devel/Assert.pod > README';

WriteMakefile(
    NAME            => 'Devel::Assert',
    VERSION_FROM    => 'lib/Devel/Assert.pm',
    AUTHOR          => ['Sergey Aleynikov <randir@cpan.org>'],
    PREREQ_PM       => {
        'Devel::StackTrace' => 0,
        'PadWalker'         => 0,
        'Data::Printer'     => 0,
    },
    TEST_REQUIRES   => {
        'Test::More'        => 0,
        'Test::Exception'   => 0,
    },
    META_MERGE      => {
        resources     => {
            repository  => 'https://github.com/dur-randir/Devel-Assert',
        },
    },
    ABSTRACT_FROM   => 'lib/Devel/Assert.pod',
    LICENSE         => 'mit',
    MIN_PERL_VERSION=> 5.010,
);

