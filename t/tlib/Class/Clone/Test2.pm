#!perl

package Class::Clone::Test2;
use base q(Class::Clone::Test1);

return 1;

sub foo {
  my $self = shift;
  return $self->SUPER::foo . " klez";
}
