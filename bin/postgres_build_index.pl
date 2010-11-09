#!/usr/bin/perl

binmode( STDOUT, ':utf8' );

use warnings;
use strict;

use utf8;
use lib 'lib';
use Dingler::Util;
use DBI;
use XML::LibXML;

my $teins = 'http://www.tei-c.org/ns/1.0';

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', 'fw', 'dingler', { pg_server_prepare => 1, PrintError => 0 } ) or die $DBI::errstr;

my $sth_journal = $dbh->prepare( 'INSERT INTO journal(id, volume, barcode, year, facsimile) VALUES (?, ?, ?, ?, ?)' );
my $sth_article = $dbh->prepare( 'INSERT INTO article(id, parent, journal, type, subtype, volume, number, title, pagestart, pageend, facsimile, front, content, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
my $sth_figure = $dbh->prepare( 'INSERT INTO figure (article, ref, reftype) VALUES (?, ?, ?)' );
my $sth_footnote = $dbh->prepare( 'INSERT INTO footnote (n, article, content) VALUES (?, ?, ?)' );

JOURNAL:
  foreach my $journal ( @ARGV ) {
    debug( "Processing $journal ...\n" );
    my $xml; eval { $xml = XML::LibXML->new->parse_file( $journal ); 1 };
    if ( $@ ) {
        debug( $@ );
        next JOURNAL;
    }
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', $teins );

    my ($jid)   = $journal =~ /(pj[0-9]{3})/;
    my $year    = $xpc->find( '//tei:imprint/tei:date' );
    my $volume  = $xpc->find( '//tei:imprint/tei:biblScope' );
    my $barcode = $xpc->find( '//tei:sourceDesc//tei:idno' );
    my $j_facsimile = Dingler::Util::faclink($barcode);

    $sth_journal->execute( $jid, $volume, $barcode, $year, $j_facsimile );

    my $pos = 1;
    foreach my $article ( $xpc->findnodes('//tei:text[@type="art_undef" or @type="art_patent" or @type="art_miscellanea" or @type="art_patents" or @type="art_literature"]') ) {
        my $data = prepare_article( $article, $xpc );
        $sth_article->execute(
            $data->{id},      undef,              $jid,           $data->{type},      undef,
            $volume,          $data->{number},    $data->{title}, $data->{pagestart},
            $data->{pageend}, $data->{facsimile}, $data->{front}, $data->{content},
            $pos
        );
        my $last_id = $dbh->last_insert_id( undef, undef, undef, undef, { sequence => 'article_uid_seq' } );

        if ( $data->{type} eq 'art_miscellanea' ) {
            my $miscpos = 1;
            foreach my $misc ( $xpc->findnodes('//tei:text[@xml:id="' . $data->{id} . '"]//tei:div[@type="misc_undef" or @type="misc_patents"]') ) {
                my $miscid  = $xpc->find( '@xml:id', $misc );
                my $type    = $xpc->find( '@type', $misc );
                my ($title) = $xpc->findnodes( 'tei:head', $misc );

                # eliminate possible notes
                my @notes = $xpc->findnodes('tei:note', $title);
                $title->removeChild($_) for @notes;

                $title = Dingler::Util::uml( normalize( defined $title ? $title->to_literal : '[ohne Titel]') );
                my $pagestart    = $xpc->find( 'preceding::tei:pb[1]/@n', $misc );
                my $pageend      = $xpc->find( 'following::*[1]/preceding::tei:pb[1]/@n', $misc );
                my $mi_facsimile = $xpc->find( 'preceding::tei:pb[1]/@facs', $misc );
                $mi_facsimile = Dingler::Util::faclink($mi_facsimile."");

                my $content      = Dingler::Util::uml( normalize($misc->to_literal) );
                $sth_article->execute( $miscid, $last_id, $jid, $type, undef, $volume, '', $title, $pagestart, $pageend, $mi_facsimile, undef, $content, $miscpos );
                my $ins_id = $dbh->last_insert_id( undef, undef, undef, undef, { sequence => 'article_uid_seq' } );

                foreach my $fn ( $xpc->findnodes('//*[@xml:id="' . $miscid . '"]//tei:note') ) {
                    my $n = $xpc->find('@n', $fn);
                    my $content = Dingler::Util::uml( normalize( $fn->to_literal ) );
                    $sth_footnote->execute( $n, $ins_id, $content );
                }
                $miscpos++;
            }
        }

        # links to tabulars
        foreach my $figure ( $xpc->findnodes('.//tei:ref[starts-with(@target, "#tab")]', $article) ) {
            my ($ref) = $xpc->find('@target', $figure) =~ /^#(.+)/;
            $sth_figure->execute( $last_id, $ref, 'tabular' );
        }

        # links to figures on tabulars
        foreach my $figure ( $xpc->findnodes('.//tei:ref[starts-with(@target, "image_markup/")]', $article) ) {
            my ($ref) = $xpc->find('@target', $figure) =~ /#(fig.+)/;
            $sth_figure->execute( $last_id, $ref, 'figure' );
        }

        # <ref target="#tx..."
        foreach my $figure ( $xpc->findnodes('.//tei:ref[starts-with(@target, "#tx")]', $article) ) {
            my ($ref) = $xpc->find('@target', $figure) =~ /#(.+)/;
            $sth_figure->execute( $last_id, $ref, 'inline' );
        }
        # <figure xml:id="tx..."
        foreach my $figure ( $xpc->findnodes('.//tei:figure[starts-with(@xml:id, "tx")]', $article) ) {
            my $ref = $xpc->find('@xml:id', $figure)."";
            $sth_figure->execute( $last_id, $ref, 'inline' );
        }

        if ( $data->{type} ne 'art_miscellanea' ) {
            foreach my $fn ( $xpc->findnodes('.//tei:note', $article) ) {
                my $n = $xpc->find('@n', $fn);
                my $content = Dingler::Util::uml( normalize( $fn->to_literal ) );
                $sth_footnote->execute( $n, $last_id, $content );
            }
        }
        $pos++;
    }
    debug( '-'x30, "\n" );
}

$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '464', 'ar002043' );
$dbh->do( 'UPDATE article SET pagestart = ? WHERE id = ?', undef, '382', 'ar003069' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '362', 'ar008041' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '244', 'mi075045_9' );
$dbh->do( 'UPDATE article SET pagestart = ? WHERE id = ?', undef, '244', 'mi075045_10' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '434', 'ar077109' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '376', 'ar088095' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '234', 'mi093065_4' );
$dbh->do( 'UPDATE article SET pagestart = ? WHERE id = ?', undef, '234', 'mi093065_5' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '348', 'ar100062' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '356', 'ar104079' );
$dbh->do( 'UPDATE article SET pageend = ? WHERE id = ?', undef, '294', 'ar132085' );

$dbh->disconnect;

sub prepare_article {
    my ( $article, $xpc ) = @_;
    my $id     = $xpc->find( '@xml:id', $article );
    my $type   = $xpc->find( '@type', $article ) . "";
    my $subtype = $xpc->find( '@subtype', $article ) . "";

    my ($number) = $xpc->findnodes( 'tei:front/tei:titlePart[@type="number"]', $article );
    my @choices = $xpc->findnodes( 'tei:choice', $number );
    foreach my $choice ( @choices ) {
        my @origs = $xpc->findnodes( 'tei:orig', $choice );
        $choice->removeChild($_) for @origs;
    }
    $number = $number ? $number->to_literal : '';

    my ($title) = $xpc->findnodes( 'tei:front/tei:titlePart[@type="column"]', $article );
    @choices = $xpc->findnodes( 'tei:choice', $title );
    foreach my $choice ( @choices ) {
        my @origs = $xpc->findnodes('tei:orig', $choice);
        $choice->removeChild($_) for @origs;
    }
    $title = Dingler::Util::uml( normalize($title->to_literal) );

    my $front = $xpc->find( 'tei:front', $article );
    $front = Dingler::Util::uml( normalize($front->to_literal) );

    my $pagestart = $xpc->find( 'tei:front/tei:pb[1]/@n', $article ) || $xpc->find( 'preceding::tei:pb[1]/@n', $article );
    my $pageend = $xpc->find( 'following::*[1]/preceding::tei:pb[1]/@n', $article);

    my $facsimile = $xpc->find( 'tei:front/tei:pb[1]/@facs', $article) || $xpc->find( 'preceding::tei:pb[1]/@facs', $article );
    $facsimile = Dingler::Util::faclink($facsimile);

    my $body = $xpc->find( 'tei:body', $article );
    $body = Dingler::Util::uml( normalize($body->to_literal) );

    return {
        id        => $id,
        type      => $type,
        subtype   => $subtype,
        number    => $number,
        title     => $title,
        pagestart => $pagestart,
        pageend   => $pageend,
        facsimile => $facsimile,
        front     => $front,
        content   => ($type eq 'art_miscellanea' ? '' : $body),
    };
}

sub normalize {
    my $str = shift || '';
    for ($str) {
        s/\A\s+//;
        s/\s+\z//;
        s/\s+/ /g;
    }
    return $str;
}

sub idonly {
    my $id = shift;
    $id =~ s/.*#//;
    if ( !$id || $id.'' eq 'pers' ) {
        return '-';
    }
    else {
        return $id;
    }
}

sub debug {
    print STDERR @_;
}
