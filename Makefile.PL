use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Class::Clone',
    VERSION_FROM      => 'lib/Class/Clone.pm', # finds $VERSION
    PREREQ_PM         => {
        'Symbol::Table'     =>  1.01,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Class/Clone.pod', # retrieve abstract from module
       AUTHOR         => 'Tyler MacDonald <japh@crackerjack.net>') : ()),
);
