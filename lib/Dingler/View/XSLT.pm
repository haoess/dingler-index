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
                    elsif ( $target =~ /\A#(ar[0-9]{6})\z/ ) {
                        my $rs = Dingler->model('Dingler::Article')->find({ id => $1 });
                        return sprintf 'article/%s/%s', $rs->get_column('journal'), $rs->id;
                    }
                },
            },
            {
                uri => 'urn:catalyst',
                name => 'ext_ent',
                subref => sub {
                    my $ent = shift;
                    return "http://www.culture.hu-berlin.de/dingler_static/sonderzeichen/$ent.png";
                }
            },
            {
                uri => 'urn:catalyst',
                name => 'personarticles',
                subref => sub {
                    my $id = shift;
                    my $rs = Dingler->model('Dingler::Person')->search({
                        id => $id,
                    });
                    my $out = '';
                    if ( $rs->count ) {
                        $out = '<h3>Fundstellen im »Polytechnischen Journal«</h3><ul style="margin-top:0">';
                        while ( my $person = $rs->next ) {
                            $out .= sprintf '<li><a href="article/%s/%s">%s</a> <span class="small">(Jg.&nbsp;%s, Bd.&nbsp;%s, Nr.&nbsp;%s, S.&nbsp;%s)</span></li>',
                                    $person->ref->journal->id,
                                    $person->ref->id,
                                    $person->ref->title,
                                    $person->ref->journal->year,
                                    $person->ref->journal->volume,
                                    $person->ref->number,
                                    $person->ref->pagestart eq $person->ref->pageend ? $person->ref->pagestart
                                                                                     : $person->ref->pagestart.'&ndash;'.$person->ref->pageend;
                        }
                        $out .= '</ul>';
                    }
                    return $out;
                },
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
