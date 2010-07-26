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
                    my ($node, $char) = @_;
                    if ( $char eq '~' && "$node" !~ /\A[a-z]/i ) {
                        return $node;
                    }
                    elsif ( index("$node", $char) == 0 ) {
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
                    my ($journal, $page) = $target =~ /#(.*)_pb(.*)/;
                    return unless $journal && $page;
                    my $rs = Dingler->model('Dingler::Article')->search(
                        {
                            journal => $journal,
                            $page   => { -between => [ \'pagestart::int', \'pageend::int' ] },
                        },
                    );
                    if ( $rs->count ) {
                        return sprintf 'article/%s/%s#pb%s', $rs->first->get_column('journal'), $rs->first->id, $page;
                    }
                    else {
                        return;
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
