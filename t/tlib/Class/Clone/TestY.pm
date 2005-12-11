#!perl

package Class::Clone::TestY;

use strict;
use warnings;
use Exporter qw(import);
our @EXPORT_OK = qw(zoo);
use base q(Class::Clone::TestX);

return 1;

sub zoo {
    my $self = shift;
    return $self->SUPER::zoo;
}
