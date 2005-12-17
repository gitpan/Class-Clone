#!/usr/bin/perl

use 5.006;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Class::Clone',
    VERSION_FROM      => 'lib/Class/Clone.pm', # finds $VERSION
    PREREQ_PM         => {
        'Symbol::Table' =>  1.01,
        'B::Deparse'    =>  0.59,
        'Clone'         =>  0.16,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Class/Clone.pod', # retrieve abstract from module
       AUTHOR         => 'Tyler MacDonald <japh@crackerjack.net>') : ()),
);
