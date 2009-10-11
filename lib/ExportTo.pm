package ExportTo;

use Carp();
use strict;

no strict "refs";

sub import{
  my %hash = $_[0] eq __PACKAGE__ ? @_[1 .. $#_] : @_;
  my $pkg = (caller)[0];
  *{$pkg . '::export_to'} = \&export_to;
  while(my($class, $subs) = each %hash){
    if(ref $subs eq 'HASH'){
      # {subname => \&coderef/subname}
      while(my($sub, $cr_or_name) = each %{$subs}){
        my($cr, $subname) = ref $cr_or_name eq 'CODE' ? ($cr_or_name, undef) : (undef, $cr_or_name);
        my $esub = $class . '::' . $sub;
        $sub  =~ s/\+//g;
        ($esub =~ s/\+//g or ($subname and $subname =~s/\+//g)) ? undef &{$esub} : $class->can($sub) && next;
        if($cr or $cr = $pkg->can($subname)){
          *{$esub} = $cr
        }else{
          Carp::croak($pkg, ' cannot do ' , $subname);
        }
      }
    }else{
      foreach my $sub (@$subs){
        my $esub;
        unless($sub =~ /::/){
          $esub = $class . '::' . $sub;
        }else{
          $sub =~ s{^(.+)::}{};
          $esub = $class . '::' . $sub;
          $pkg = $1;
        }
        $sub  =~ s/\+//g;
        $esub =~ s/\+//g ? undef &{$esub} : $class->can($sub) && next;
        if(my $cr = $pkg->can($sub)){
          *{$esub} = $cr
        }else{
          Carp::croak($pkg, ' cannot do ' , $sub);
        }
      }
    }
  }
}

*{ExportTo::export_to} = \&import;

=head1 NAME

ExportTo - export function/method to namespace

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

 package From;
 
 sub function_1{
   # ...
 }
 
 sub function_2{
   # ...
 }
 
 sub function_3{
   # ...
 }
 
 use ExportTo (NameSpace1 => [qw/function_1 function_2/], NameSpace2 => [qw/function_3/]);

 # Now, function_1 and function_2 are exported to 'NameSpace1' namespace.
 # function_3 is exported to 'NameSpace2' namespace.
 
 # If 'NameSpace1'/'NameSpace2' namespace has same name function/method,
 # such a function/method is not exported and ExportTo croaks.
 # but if you want to override, you can do it as following.
 
 use ExportTo (NameSpace1 => [qw/+function_1 function_2/]);
 
 # if adding + to function/method name,
 # This override function/method which namespace already has with exported funtion/method.
 
 use ExportTo ('+NameSpace' => [qw/function_1 function_2/]);
 
 # if you add + to namespace name, all functions are exported even if namespace already has function/method.

 use ExportTo ('+NameSpace' => {function_ => sub{print 1}, function_2 => 'function_2'});
 
 # if using hashref instead of arrayref, its key is regarded as subroutine name and
 # value is regarded as its coderef/subroutine name. and this subroutine name will be exported.


=head1 DESCRIPTION

This module allow you to export/override subroutine/method to one namespace.
It can be used for mix-in, for extension of modules not using inheritance.

=head1 FUNCTION/METHOD

=over 4

=item export_to

 # example 1 & 2
 export_to(PACKAGE_NAME => [qw/FUNCTION_NAME/]);
 ExportTo->export_to(PACKAGE_NAME => [qw/FUNCTION_NAME/]);
 
 # example 3
 ExportTo->export_to(PACKAGE_NAME => {SUBROUTINE_NAME => sub{ .... }, SUBROUTINE_NAME2 => 'FUNCTION_NAME'});

These are as same as following.

 # example 1 & 2
 use ExportTo(PACKAGE_NAME => [qw/FUNCTION_NAME/]);
 
 # example 3
 use ExportTo(PACKAGE_NAME => {SUBROUTINE_NAME => sub{ .... }, SUBROUTINE_NAME2 => 'FUNCTION_NAME'});

But, 'use' is needed to declare after declaration of function/method.
using 'export_to', you can write anywhere.

=back

=head1 AUTHOR

Ktat, C<< <ktat at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-exportto at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=ExportTo>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ExportTo

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/ExportTo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/ExportTo>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=ExportTo>

=item * Search CPAN

L<http://search.cpan.org/dist/ExportTo>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2006 Ktat, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of ExportTo
