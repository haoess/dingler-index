#!/usr/bin/perl

binmode( STDOUT, ':utf8' );

use warnings;
use strict;

use utf8;
use lib 'lib';
use Dingler::Util;
use DBI;
use XML::LibXML;

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', 'fw', 'dingler' ) or die $DBI::errstr;

JOURNAL:
  foreach my $journal ( @ARGV ) {
    debug( "Processing $journal ...\n" );
    my $xml; eval { $xml = XML::LibXML->new->parse_file( $journal ); 1 };
    if ( $@ ) {
        debug( $@ );
        next JOURNAL;
    }
    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );

    my ($jid)     = $journal =~ /(pj[0-9]{3})/;
    my $year      = $xpc->find( '//tei:imprint/tei:date' );
    my $volume    = $xpc->find( '//tei:imprint/tei:biblScope' );
    my $facsimile = $xpc->find( '//tei:sourceDesc//tei:idno' );
    my $j_facsimile = Dingler::Util::faclink($facsimile);

    my $sth = $dbh->prepare( 'INSERT INTO journal(id, volume, year, facsimile) VALUES (?, ?, ?, ?)' );
    $sth->execute( $jid, $volume, $year, $j_facsimile );

    my $pos = 1;
    foreach my $article ( $xpc->findnodes('//tei:text[@type="art_undef" or @type="art_patent" or @type="art_miscellanea"]') ) {
        my $data = prepare_article( $article, $xpc );
        $sth = $dbh->prepare( 'INSERT INTO article(id, journal, type, volume, number, title, pagestart, pageend, facsimile, front, content, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
        $sth->execute( $data->{id}, $jid, $data->{type}, $volume, $data->{number}, $data->{title}, $data->{pagestart}, $data->{pageend}, $data->{facsimile}, $data->{front}, $data->{content}, $pos );

        if ( $data->{type} eq 'art_miscellanea' ) {
            my $miscpos = 1;
            foreach my $misc ( $xpc->findnodes('//tei:text[@xml:id="' . $data->{id} . '"]//tei:div[@type="misc_undef"]') ) {
                my $miscid       = $xpc->find( '@xml:id', $misc );
                my $type         = $xpc->find( '@type', $misc );
                my $title        = $xpc->find( 'tei:head', $misc );
                $title = Dingler::Util::uml( normalize($title->to_literal) );
                my $pagestart    = $xpc->find( 'preceding::tei:pb[1]/@n', $misc );
                my $pageend      = $xpc->find( 'following::*[1]/preceding::tei:pb[1]/@n', $misc );
                my $mi_facsimile = $xpc->find( 'preceding::tei:pb[1]/@facs', $misc );
                $mi_facsimile = Dingler::Util::faclink($facsimile);
                my $content      = Dingler::Util::uml( normalize($misc->to_literal) );

                my $sth = $dbh->prepare( 'INSERT INTO article(id, parent, journal, type, volume, number, title, pagestart, pageend, facsimile, content, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)' );
                $sth->execute( $miscid, $data->{id}, $jid, $type, $volume, '', $title, $pagestart, $pageend, $mi_facsimile, $content, $miscpos );
                $miscpos++;
            }
        }

        foreach my $figure ( $xpc->findnodes('.//tei:ref[starts-with(@target, "#tab")]', $article) ) {
            $sth = $dbh->prepare( 'INSERT INTO figure (article, url) VALUES (?, ?)' );
            my $figlink = Dingler::Util::figlink( $xpc->find('@target', $figure), $jid );
            $sth->execute( $data->{id}, $figlink );
        }
        foreach my $author ( $xpc->findnodes('tei:front//tei:persName[@role="author" or @role="author_orig"]', $article) ) {
            $sth = $dbh->prepare( 'INSERT INTO author (person, article) VALUES (?, ?)' );
            my $ref = idonly( $xpc->find('@ref', $author) );
            next if $ref eq '-';
            $sth->execute( $ref, $data->{id} );
        }
        $pos++;
    }

    my %refs;
    foreach my $persname ( $xpc->findnodes('//tei:titlePart[@type="main"]/tei:persName') ) {
        push @{ $refs{ idonly($xpc->find('@ref', $persname)) } }, $xpc->find('ancestor::tei:text[1]/@xml:id', $persname)."";
    }
    foreach my $persname ( $xpc->findnodes('//tei:div[@type="misc_undef"]//tei:head/tei:persName') ) {
        push @{ $refs{ idonly($xpc->find('@ref', $persname)) } }, $xpc->find('ancestor::tei:text[1]/@xml:id', $persname)."";
    }
    while ( my ($k, $v) = each %refs ) {
        next if $k eq '-';
        foreach my $ref ( @$v ) {
            $sth = $dbh->prepare( 'INSERT INTO person (id, ref) VALUES (?, ?)' );
            $sth->execute( $k, $ref );
        }
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

$dbh->disconnect;

sub prepare_article {
    my ( $article, $xpc ) = @_;
    my $id     = $xpc->find( '@xml:id', $article );
    my $type   = $xpc->find( '@type', $article ) . "";
    my $number = $xpc->find( 'tei:front/tei:titlePart[@type="number"]', $article );
    my $title  = $xpc->find( 'tei:front/tei:titlePart[@type="column"]', $article );
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
