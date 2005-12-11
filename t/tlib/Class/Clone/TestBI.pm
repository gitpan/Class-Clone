#!perl

package Class::Clone::TestBI;

use strict;
use warnings;

our @goo = "juggler";
our $moo = "path";

return 1;

sub goo {
    my $self = shift;
    return $self->SUPER::goo . " @goo";
}

sub foo {
    return "ether";
}

sub moo {
    return "enturbulator";
}
