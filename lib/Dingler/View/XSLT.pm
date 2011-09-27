package Dingler::View::XSLT;
use parent 'Catalyst::View::XSLT';

use utf8;

use warnings;
use strict;

use Dingler::Util;

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
                subref => \&Dingler::Util::uml,
            },
            {
                uri => 'urn:catalyst',
                name => 'persondate',
                subref => sub {
                    my $date = $_[0]."";
                    use DateTime::Format::Strptime;
                    my $dt;
                    if ( $dt = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d', locale => 'de_DE' )->parse_datetime( $date ) ) {
                        return $dt->strftime('%e. %B %Y');
                    }
                    elsif ( $dt = DateTime::Format::Strptime->new( pattern => '%Y-%m' )->parse_datetime( $date ) ) {
                        return $dt->strftime('%B %Y');
                    }
                    elsif ( $dt = DateTime::Format::Strptime->new( pattern => '%Y' )->parse_datetime( $date ) ) {
                        return $dt->strftime('%Y');
                    }
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'starts-with',
                subref => sub {
                    my ( $node, $char ) = @_;
                    my $text = "$node";
                    $text =~ s/\AThe\s// unless $char =~ /t/i;
                    if ( $char eq '~' && $text !~ /\A[a-z]/i ) {
                        return $node;
                    }
                    elsif ( index($text, $char) == 0 ) {
                        return $node;
                    }
                    else {
                        return;
                    }
                }
            },
            {
                uri => 'urn:catalyst',
                name => 'personref',
                subref => sub {
                    my $str = shift;
                    $str =~ /#(\w+)\z/;
                    return $1 ? $1 : '';
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'faclink',
                subref => sub {
                    my $id = shift;
                    # 32258227Z/00000051
                    #  =>
                    # http://www.polytechnischesjournal.de/journal/faksimile/werkansicht/?tx_dlf[recordId]=oai:de:slub-dresden:db:id-32258227Z&tx_dlf[page]=51
                    $id =~ /(\w+)(?:\/(\w+))?/;
                    my $ret = "http://www.polytechnischesjournal.de/journal/faksimile/werkansicht/?tx_dlf[recordId]=oai:de:slub-dresden:db:id-$1";
                    if ( defined $2 ) {
                        $ret .= "&tx_dlf[page]=$2";
                    }
                    return $ret;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'facthumb',
                subref => sub {
                    my $facs = shift;
                    # 32258227Z/00000051
                    #  =>
                    # http://www.polytechnischesjournal.de/fileadmin/data/32258227Z/32258227Z_tif/jpegs/00000051.tif.thumbnail.jpg
                    $facs =~ /(\w+)\/(\w+)/;
                    return sprintf "http://www.polytechnischesjournal.de/fileadmin/data/%s/%s_tif/jpegs/%s.tif.thumbnail.jpg", $1, $1, $2;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'art2jour',
                subref => sub {
                    my $article = shift;
                    my $ar = Dingler->model('Dingler::Article')->find({ id => $article });
                    return $ar->journal->id;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'art2title',
                subref => sub {
                    my $article = shift;
                    my $ar = Dingler->model('Dingler::Article')->find({ id => $article });
                    return $ar->title;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'replace',
                subref => sub {
                    my ($str, $pattern, $replacement) = @_;
                    $str =~ s/$pattern/$replacement/g;
                    return $str;
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'resolveref',
                subref => sub {
                    my $target = shift->to_literal;

                    if ( $target =~ /#(.*)_pb(.*)/ ) {
                        return sprintf 'page/%s/%s', $1, $2;
                    }
                    elsif ( $target =~ /#((?:ar|mi)[0-9]{6}(?:_[0-9]+)?)\z/ ) {
                        my $rs = Dingler->model('Dingler::Article')->find({ id => $1 });
                        if ( !$rs ) {
                            print STDERR "could not resolve $target in catalyst:resolveref\n";
                            return;
                        }
                        return sprintf 'article/%s/%s', $rs->get_column('journal'), $rs->id;
                    }
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'ext_ent',
                subref => sub {
                    my $ent = shift;
                    return "http://dingler.culture.hu-berlin.de/dingler_static/sonderzeichen/$ent.png";
                }
            },
            {
                uri => 'urn:catalyst',
                name => 'rendition',
                subref => sub {
                    my $rend = shift;
                    my @renditions = map { s/^#//; $_ } split / /, $rend;
                    return join ' ', @renditions;
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
