#!perl

package Class::Clone::TestY;

use strict;
use warnings;
use Exporter;
use Class::Clone::TestX;
use base qw(Class::Clone::TestX Exporter);

our @EXPORT_OK = qw(zoo);

return 1;

sub zoo {
    my $self = shift;
    return $self->SUPER::zoo;
}
