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
        s/&#x2010;/-/g;
        s/\s+/ /g;
    }
    return $str;
}

sub uml2 {
    my $str = shift || '';
    for ($str) {
        s/a\x{0364}/ä/g;
        s/o\x{0364}/ö/g;
        s/u\x{0364}/ü/g;
        s/A\x{0364}/Ä/g;
        s/O\x{0364}/Ö/g;
        s/U\x{0364}/Ü/g;
        s/&#x2010;/-/g;
        s/\n( *\S[^\n]*)\n/ $1 /g;
        s/[ \t]+/ /g;
        s/^[ \t]+//gm;
        s/\n\n\n\n+/\n\n\n/g;
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
    my $target;
    if ( $figure =~ /\A#(.*)/ ) {
        $target = $1;
    }
    elsif ( $figure =~ /image_markup\/(tab\d+)\.xml/ ) {
        $target = $1;
    }
    my $ret = sprintf 'http://dingler.culture-hu-berlin.de/dingler_static/%s/image_markup/%s_wv_%s.jpg', $journal, $target, $target;
    return $ret;
}

sub fullname {
    my $person = shift;
    my $ret = sprintf '%s, %s', $person->surname, $person->forename;
    return $ret;
}

sub personarticles {
    my ( $id, @skip ) = @_;
    my $rs = Dingler->model('Dingler::Personref')->search(
        {
            'me.id'  => $id,
            'me.ref' => { -not_in => [ @skip ] },
        },
        {
            prefetch => [ { 'ref' => 'journal' } ],
        },
    );
    my $out = '';
    if ( $rs->count ) {
        $out = '<h2>Fundstellen im Polytechnischen Journal</h2><ul style="margin-top:0">';
        my $i = 0;
        while ( my $person = $rs->next ) {
            last if $i == 10;
            $out .= sprintf '<li><a href="article/%s/%s">%s</a> <span class="small">(Jg.&nbsp;%s, Bd.&nbsp;%s, Nr.&nbsp;%s, S.&nbsp;%s)</span></li>',
                    $person->ref->journal->id,
                    $person->ref->id,
                    $person->ref->title,
                    $person->ref->journal->year,
                    $person->ref->journal->volume,
                    $person->ref->number,
                    $person->ref->pagestart eq $person->ref->pageend ? $person->ref->pagestart
                                                                     : $person->ref->pagestart.'&ndash;'.$person->ref->pageend;
            $i++;
        }
        $out .= '</ul>';
        $out .= sprintf '<h2><a href="person/view/%s">weitere Informationen &hellip;</a></h2>', $id if @skip;
    }
    return $out;
};

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
