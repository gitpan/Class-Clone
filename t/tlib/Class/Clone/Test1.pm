#!perl

package Class::Clone::Test1;

use strict;
use warnings;

our $foo = "gozer";

return 1;

sub new {
    my $class = shift;
    bless { @_ }, $class;
}

sub goo {
    return "jingle";
}

sub foo {
    return "$foo";
}
