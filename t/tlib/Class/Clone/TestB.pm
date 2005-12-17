#!perl

package Class::Clone::TestB;

use strict;
use warnings;
use base q(Class::Clone::TestA);
use Exporter qw(import);

our $foo = ("buggyd");
our %goo = ("lexical" => "awfulhak");
our @roo = (\%goo, sub { return \$foo; });

return 1;

sub closure {
    return sub { return \@roo; };
}

sub foo {
    my $self = shift;
    return $self->SUPER::foo . " $foo";
}

sub zoo {
    return "nefrtari";
}
