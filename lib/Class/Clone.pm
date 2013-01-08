#!perl

package Class::Clone;

use 5.006;
use strict;
use warnings;
use Symbol::Table;
use B::Deparse;
use Data::Dumper;
use Carp;
use Exporter;
use Clone qw(clone);
use base q(Exporter);

our $VERSION = '0.06';
our @EXPORT_OK = qw(class_clone class_clone_code class_subclass);
our %default_rules = (
    'ARRAY'     =>  'clone',
    'SCALAR'    =>  'clone',
    'HASH'      =>  'clone',
    'CODE'      =>  'clone',
);

return 1;

{
    no strict 'refs';

    sub _copy_ARRAY {
        my($fromvar, $tovar) = @_;
        *{$tovar} = [ @{$fromvar} ];
        return ();
    }

    # this is needed due to a Symbol::Table bug:
    # http://rt.cpan.org/NoAuth/Bug.html?id=16364
    sub _import_SCALAR {
        my($fromvar, $tovar) = @_;
        *{$tovar} = \${$fromvar};
        return ();
    }

    sub _copy_SCALAR {
        my($fromvar, $tovar) = @_;
        *{$tovar} = \"${$fromvar}";
        return ();
    }

    sub _copy_HASH {
        my($fromvar, $tovar) = @_;
        *{$tovar} = { %{$fromvar} };
        return ();
    }

    sub _copy_CODE {
        my($fromvar, $tovar) = @_;
    
        my $from = $fromvar;
        $from =~ s{::([^:]+)$}{}
            or croak "couldn't get a sub name out of $fromvar";
        
        my $sub = $1;

        my $pp = B::Deparse->new;
        my $code = $pp->coderef2text(\&{$fromvar});
        if($code =~ s{package $from;}{}) {
            return("sub $tovar $code");
        } else {
            *{$tovar} = \&{$fromvar};
            return();
        }
    }
    
    sub _clone_CODE { _copy_CODE(@_); }
    
    use strict 'refs';
}

sub _clone_from_to {
    my($from, $to, %rules) = @_;
    
    my(@isa, @code);
    
    my $did;
    
    foreach my $type (qw(ARRAY SCALAR HASH CODE)) {
        next unless $rules{$type};
        
        my $from_syms = Symbol::Table->New($type, $from);
        my $to_syms = Symbol::Table->New($type, $to);

        # Get a list of keys that are currently set.
        # Symbol::Table auto-creates references in keys when you look them up,
        # so we can't check for them on $to_syms directly.
        my %keys;
        map { $keys{$_}++ } keys(%$to_syms);
        
        while(my($k, $v) = each(%$from_syms)) {
            if($type eq 'ARRAY' && $k eq 'ISA') {
                push(@isa, @$v);
                next;
            }
            
            unless(exists $keys{$k}) {
                $did++;
                my($fromvar, $tovar) = (
                    join('::', $from, $k),
                    join('::', $to, $k)
                );
                
                my $method = join('_', '', $rules{$type}, $type);
                if(my $rulemethod = __PACKAGE__->can($method)) {
                    push(@code, $rulemethod->($fromvar, $tovar));
                } elsif($rules{$type} eq 'import') {
                    $to_syms->{$k} = $v;
                } elsif($rules{$type} eq 'clone') {
                    $to_syms->{$k} = clone($v);
                } else {
                    croak "Can't handle $rules{$type} for $type ($fromvar -> $tovar)";
                }
            }
        }
    }
    
    if(@isa) {
        my $to_syms = Symbol::Table->New('ARRAY', $to);
        push(@{$to_syms->{ISA}}, @isa);
    }
    
    return($did, @code);
}

sub class_clone_code {
    my($from, $to, %rules) = @_;

    if(scalar(@_) < 3) {
        %rules = %default_rules;
    }
    
    my $coderule = $rules{CODE};
    $rules{CODE} = undef;
    
    my($did, @newcode) = (_clone_from_to($from, $to, 'CODE' => $coderule));
    
    if($did || grep($_, values %rules)) {
        unshift(@newcode, 
            "package $to; use Class::Clone; BEGIN { my ",
            Data::Dumper->Dump([\%rules], ['*rules']),
            "; Class::Clone::_clone_from_to('$from', '$to', \%rules); }"
        );
        
        return @newcode;
    } else {
        return;
    }
}

sub class_clone {
    my($from, $to, %rules) = @_;
    
    if(my @code = class_clone_code($from, $to, %rules)) {
        {
            no warnings 'redefine';
            eval "@code";
        }

        if($@) {
            croak $@;
        } else {
            return $to;
        }
    } else {
        return;
    }
}

sub class_subclass {
    my($from, $to, %rules) = @_;
    
    if(@_ > 2) {
        class_clone($from, $to, %rules);
    } else {
        class_clone($from, $to, NOTHING => undef);
    }
    
    no strict 'refs';
    @{"$to\::ISA"} = ($from);
    use strict 'refs';
    
    return $to;
}
