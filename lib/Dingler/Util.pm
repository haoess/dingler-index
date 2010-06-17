package Dingler::Util;

use warnings;
use strict;

use utf8;

=head1 NAME

Dingler::Util - Some widely used utility functions.

=head1 FUNCTIONS

=head2 uml

=cut

sub uml {
    my $str = shift || '';
    for ($str) {
        s/a\x{0364}/ä/g;
        s/o\x{0364}/ö/g;
        s/u\x{0364}/ü/g;
        s/A\x{0364}/Ä/g;
        s/O\x{0364}/Ö/g;
        s/U\x{0364}/Ü/g;
        s/\s+/ /g;
    }
    return $str;
}

=head2 strip

=cut

sub strip {
    my $str = shift || '';
    for ($str) {
        s/\A\s+//;
        s/\s+\z//;
    }
    return $str;
}

1;
__END__

=head1 SEE ALSO

L<Dingler>

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
