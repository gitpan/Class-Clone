#!perl

use strict;
use warnings;
use Test::More qw(no_plan);
use lib 't/tlib';
use Class::Clone::Test;

my $o;

diag('Basic Cloning');
$o = Class::Clone::TestB->new;
is($o->foo, "gsar buggyd", "starting value of TestB is correct");
$o = Class::Clone::Test2->new;
is($o->foo, "gozer klez", "starting value of Test2 is correct");
is(
    class_clone('Class::Clone::TestB', 'Class::Clone::TestB2'),
    'Class::Clone::TestB2',
    "Cloned TestB into TestB2"
);
$o = Class::Clone::TestB2->new;
is($o->foo, "gsar buggyd", "TestB2 has TestB's value");

diag('Copy does not reference original');
{
 no warnings 'once';
 $Class::Clone::TestB2::foo = "kjo";
}
is($o->foo, "gsar kjo", "TestB2 has a new value");
$o = Class::Clone::TestB->new;
is($o->foo, "gsar buggyd", "TestB still has old value");
is($Class::Clone::TestB::goo{'lexical'}, 'awfulhak', "TestB has goo hash");
is($Class::Clone::TestB2::goo{'lexical'}, 'awfulhak', "TestB2 has copy of goo hash");
$Class::Clone::TestB2::goo{"lexical"} = "aedion";
is($Class::Clone::TestB::goo{'lexical'}, 'awfulhak', "TestB has goo hash");
is($Class::Clone::TestB2::goo{'lexical'}, 'aedion', "TestB2 has it's own goo hash");


diag('Reassignment of @ISA / SUPER:: in new class');
$o = Class::Clone::TestB2->new;
ok(!$o->isa('Class::Clone::Test2'), 'B2 isnt a 2 yet');
is($o->foo, "gsar kjo", "TestB2 has a B value but no 2 value");
{
 no warnings 'once';
 @Class::Clone::TestB2::ISA = qw(Class::Clone::Test2);
}
ok($o->isa('Class::Clone::Test2'), 'B2 has polymorphed into a 2');
is($o->foo, "gozer klez kjo", "TestB2 has a B value and a 2 value");

diag('Merging in a second class');
is($o->goo, "jingle", 'TestB2 has its goo');
is(Class::Clone::TestBI->foo, 'ether', "TestBI's foo method is it's own");
is($o->foo, "gozer klez kjo", "TestB2's foo method is it's composite");
is(
    class_clone('Class::Clone::TestBI', 'Class::Clone::TestB2'),
    'Class::Clone::TestB2',
    'Cloned TestBI into TestB2 successfully'
);
is(Class::Clone::TestBI->foo, 'ether', "TestBI's foo method is still it's own");
is($o->foo, "gozer klez kjo", "TestB2's foo method is still it's composite");
is($o->goo, 'jingle juggler', "TestB2 got goo method from TestBI, but Test2 still gets SUPER::");

diag('Selective Copying');
is(
    class_clone('Class::Clone::Test1', 'Class::Clone::Test1BI'),
    'Class::Clone::Test1BI',
    'Cloned Test1 into Test1BI successfully'
);
$o = Class::Clone::Test1BI->new;
ok(!$o->can('moo'), "Test1BI can't moo yet");
is(Class::Clone::TestBI->moo, "enturbulator", "TestBI has it's moo");
is($Class::Clone::TestBI::moo, "path", "TestBI has it's \$moo");
is(
    class_clone('Class::Clone::TestBI', 'Class::Clone::Test1BI', CODE => 'copy'),
    'Class::Clone::Test1BI',
    'Cloned only code from TestBI into Test1BI successfully'
);
ok($o->can('moo'), "Test1BI can moo thanks to TestBI");
is($o->moo, "enturbulator", "Test1BI has TestBI's moo");
ok(!$Class::Clone::Test1BI::moo, "Test1BI doesn't have TestBI's moo");
is(
    class_clone('Class::Clone::TestBI', 'Class::Clone::Test1BI', SCALAR => 'import'),
    'Class::Clone::Test1BI',
    'Imported only scalars from TestBI into Test1BI successfully'
);
ok(!@Class::Clone::Test1BI::goo, "Test1BI doesn't have TestBI's goo");
is($Class::Clone::Test1BI::moo, "path", "Test1BI has TestBI's moo now");
is(
    class_clone('Class::Clone::TestBI', 'Class::Clone::Test1BI', ARRAY => undef),
    undef,
    'Copied nothing from Test1BI'
);
ok(!@Class::Clone::Test1BI::goo, "Test1BI doesn't have TestBI's goo");
is(
    class_clone('Class::Clone::TestBI', 'Class::Clone::Test1BI', ARRAY => 'import'),
    'Class::Clone::Test1BI',
    'Imported goo from Test1BI'
);
is($Class::Clone::Test1BI::goo[0], "juggler", "Test1BI has goo now");
$Class::Clone::Test1BI::goo[0] = "jho";
is($Class::Clone::TestBI::goo[0], "jho", "TestBI shares goo with Test1BI");

diag('Subclassing');
is(
    class_subclass('Class::Clone::TestX', 'Class::Clone::TestXX'),
    'Class::Clone::TestXX',
    'Subclassed a TestXX Class'
);
is($Class::Clone::TestX::zoo, "fcuk", 'TestX has $zoo');
{
    no warnings 'once';
    ok(!$Class::Clone::TestXX::zoo, 'TestXX has no $zoo');
}
ok(Class::Clone::TestXX->can('zoo'), 'TestXX can zoo');
is(Class::Clone::TestXX->zoo, "fcuk", "TestXX's zoo is in TestX's scope");
is(
    class_subclass(
        'Class::Clone::TestX', 'Class::Clone::TestXXX',
        SCALAR => 'copy'
    ),
    'Class::Clone::TestXXX',
    'Subclassed a TestXXX Class'
);
{
 no warnings 'once';
 is($Class::Clone::TestXXX::zoo, "fcuk", 'TestXXX has $zoo');
}

diag('Implicit referencing');
is(
    class_clone(
        'Class::Clone::TestZ', 'Class::Clone::TestZB',
    ),
    'Class::Clone::TestZB',
    'Copied TestZ into TestZB'
);
ok(\&Class::Clone::TestZB::zoo, 'TestZB has its own reference to zoo');
@Class::Clone::TestZB::ISA = qw(Class::Clone::TestB);
ok(Class::Clone::TestZB->isa('Class::Clone::TestB'), 'Made TestZB a TestB');
is(Class::Clone::TestB->zoo, 'nefrtari', 'TestB has its zoo');
is(Class::Clone::TestZ->zoo, 'fcuk', 'TestZ has its zoo');
is(Class::Clone::TestZB->zoo, 'fcuk', 'TestZBs zoo follows TestZs ISA');


diag('Failure conditions');
eval {
    class_clone(
        'Class::Clone::TestB', 'Class::Clone::Test1BI', HASH => 'invalid'
    )
};
like($@, qr/Can't handle invalid for HASH/, "Invalid imports die");
eval {
    Class::Clone::_copy_CODE("invalid", "TestB1::invalid");
};
like($@, qr/couldn't get a sub name out of invalid/, "Bad subroutine names die");
