use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'KossyTraining',
    VERSION_FROM  => 'lib/KossyTraining.pm',
    PREREQ_PM     => {
        'Kossy' =>  '0.19',
    },
    MIN_PERL_VERSION => '5.008001'
);

