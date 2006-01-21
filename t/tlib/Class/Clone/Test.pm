#!perl

package Class::Clone::Test;

use strict;
use warnings;
use Test::More;
use Exporter;
use base q(Exporter);

use Class::Clone::TestB;
use Class::Clone::Test2;
use Class::Clone::TestBI;
use Class::Clone::TestX;
use Class::Clone::TestY;
use Class::Clone::TestZ;

use_ok('Class::Clone', 'class_clone', 'class_subclass');
our @EXPORT = qw(class_clone class_subclass);

return 1;
