
  # Another::Package gets its methods from Some::Package,
  # but to SUPER:: in Another::Pacakge will go to Another::Package::Super,
  package Some::Package::Super;
  sub method {
    my $class = shift;
    return "method";
  }
  
  package Some::Package;
  sub method {
    my $class = shift;
    return $class->SUPER::method . "ical";
  }
  
  package Another::Package::Super;
  sub method {
    return "naut";
  }

  package main;
  use Class::Clone qw(class_clone);
  use Test::More qw(no_plan);

  @Some::Package::ISA = qw(Some::Package::Super);
  class_clone('Some::Package', 'Another::Package');

  @Another::Package::ISA = qw(Another::Package::Super);
  
  is(
    Another::Package->method,
    'nautical',
    "Another::Package's namespace is completely independant of Some::Package"
  );
  