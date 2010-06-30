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

=head2 faclink

=cut

sub faclink {
    my $id = shift;
    # 32258227Z/00000051
    #  =>
    # http://www.polytechnischesjournal.de/journal/dinger-online/?tx_slubdigitallibrary[ppn]=32258227Z&tx_slubdigitallibrary[image]=51
    $id =~ /(\w+)(?:\/(\w+))?/;
    my $ret = "http://www.polytechnischesjournal.de/journal/dinger-online/?tx_slubdigitallibrary[ppn]=$1";
    if ( defined $2 ) {
        $ret .= "&tx_slubdigitallibrary[image]=$2";
    }
    return $ret;
}

=head2 figlink

=cut

sub figlink {
    my ( $figure, $journal ) = @_;
    my ($target) = $figure =~ /#(.*)/;
    my $ret = sprintf 'http://www.culture.hu-berlin.de/dingler_static/%s/image_markup/%s_wv_%s.jpg', $journal, $target, $target;
    return $ret;
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
