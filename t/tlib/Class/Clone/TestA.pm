#!perl

package Class::Clone::TestA;

use strict;
use warnings;
use Class::Clone::Test1;
use base q(Class::Clone::Test1);

our $match = qr{\s*gozer\s*};

return 1;

sub foo {
    my $self = shift;
    my $foo = $self->SUPER::foo . " gsar";
    $foo =~ s{$match}{};
    return $foo;
}

sub loo {
    return "chaosdna";
}
