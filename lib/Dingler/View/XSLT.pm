package Dingler::View::XSLT;
use parent 'Catalyst::View::XSLT';

use utf8;

use warnings;
use strict;

__PACKAGE__->config(
    INCLUDE_PATH => [
        Dingler->path_to( 'root', 'xslt' ),
    ],
    TEMPLATE_EXTENSION => '.xsl',
    LibXSLT => {
        register_function => [
            {
                uri => 'urn:catalyst',
                name => 'uml',
                subref => sub {
                    my $str = shift || '';
                    for ($str) {
                        s/a\x{0364}/ä/g;
                        s/o\x{0364}/ö/g;
                        s/u\x{0364}/ü/g;
                        s/\s+/ /g;
                    }
                    return $str;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'personref',
                subref => sub {
                    my $str = shift;
                    $str =~ /#(\w+)\z/;
                    return $1 ? $1 : $str;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'faclink',
                subref => sub {
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
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'art2jour',
                subref => sub {
                    my $article = shift;
                    my $doc = XML::LibXML->new
                                         ->parse_file( Dingler->path_to('var', 'volumes.xml')->stringify )
                              or die $!;
                    my $xpc = XML::LibXML::XPathContext->new( $doc ) or die $!;
                    my $ret = $xpc->find( "//article[id='$article']/ancestor::*/file" );
                    return $ret;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'art2title',
                subref => sub {
                    my $article = shift;
                    my $doc = XML::LibXML->new
                                         ->parse_file( Dingler->path_to('var', 'volumes.xml')->stringify )
                              or die $!;
                    my $xpc = XML::LibXML::XPathContext->new( $doc ) or die $!;
                    my $ret = $xpc->findvalue( "//article[id='$article']/title" );
                    return $ret;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'replace',
                subref => sub {
                    my ($str, $pattern, $replacement) = @_;
                    $str =~ s/$pattern/$replacement/g;
                    return $str;
                }
            },
        ],
    },
#    DUMP_CONFIG => 1,
);

1;
__END__

=head1 NAME

Dingler::View::XSLT - XSLT View Component

=head1 SYNOPSIS

L<Dingler>

=head1 DESCRIPTION

Catalyst XSLT View.

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
