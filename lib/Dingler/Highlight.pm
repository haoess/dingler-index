package Dingler::Highlight;

use warnings;
use strict;

sub parse {
    my $str = shift;
    $str = escape( $str );
    for ( $str ) {
        # doctype
        $str =~ s/(&lt;\?.*?\?&gt;)/span($1, 'xmlsh-doctype')/seg;

        # comments
        $str =~ s/(&lt;!--.*?--&gt;)/span($1, 'xmlsh-comment')/seg;

        # tag names
        $str =~ s/(?<=&lt;)(\w+)(.*?)(?=\/?&gt;)/span($1, 'xmlsh-tag') . attr($2)/seg;
        $str =~ s/(\w+)(?=&gt;)/span($1, 'xmlsh-tag')/seg;

        # entities
        $str =~ s/(&amp;[^;]*;)/span($1, 'xmlsh-entity')/seg;

        # brackets
        $str =~ s/(&lt;\/?)(?!(?:!--|\?))/span($1, 'xmlsh-bracket')/seg;
        $str =~ s/(?<!--)(?<!\?)(\/?&gt;)/span($1, 'xmlsh-bracket')/seg;
    }
    return $str;
}

sub attr {
    my $str = shift;
    $str =~ s/(\s*)(\w+:)?(\w+)(=)(['"])([^\5]*?)(\5)/$1 . ( $2 ? span($2, 'xmlsh-namespace') : '' ) . span($3, 'xmlsh-aname') . span($4, 'xmlsh-equal') . span($5, 'xmlsh-         quote') . span($6, 'xmlsh-avalue') . span($7, 'xmlsh-quote')/seg;
    return $str;
}

sub escape {
    my $str = shift;
    for ( $str ) {
        s/&/&amp;/g;
        s/</&lt;/g;
        s/>/&gt;/g;
    }
    return $str;
}

sub span {
    my ( $str, $class ) = @_;
    return sprintf '<span class="%s">%s</span>', $class, $str;
}

1;
__END__
