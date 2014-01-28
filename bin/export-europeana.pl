#!/usr/bin/perl

use warnings;
use strict;

use utf8;
use lib 'lib';

use Dingler::Util;
use DBI;
use XML::LibXML;

my $xmlrep = '/home/fw/src/kuwi/dingler';
my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', 'fw', 'dingler', { pg_server_prepare => 1, RaiseError => 1, pg_enable_utf8 => 1 } ) or die $DBI::errstr;

my $TEI = <<"EOT";
<?xml version="1.0" encoding="utf-8"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <title type="main">Dingler-Online | Das digitalisierte Polytechnische Journal</title>
        <title type="sub">Band %d, Jahrgang %d</title>
        <title type="sub">%s</title>
      </titleStmt>
      <publicationStmt>
        <publisher>Humboldt-Universität</publisher>
        <pubPlace>Berlin</pubPlace>
        <date when="2012"/>
        <idno type="URL">http://dingler.culture.hu-berlin.de/article/%s/%s</idno>
        <availability status="free">
          <p>Distributed under the <ref target="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</ref>.</p>
        </availability>
      </publicationStmt>
      <seriesStmt>
        <title level="j">Dingler-Online | Das digitalisierte Polytechnische Journal</title>
        <respStmt>
          <resp>Projektträger:</resp>
          <name xml:id="HU">Humboldt-Universität zu Berlin</name>
        </respStmt>
        <respStmt>
          <resp>in Kooperation mit:</resp>
          <name>Sächsische Landesbibliothek &#x2013; Staats- und Universitätsbibliothek Dresden</name>
        </respStmt>
        <respStmt>
          <resp>gefördert durch:</resp>
          <name>Deutsche Forschungsgemeinschaft</name>
        </respStmt>
        <respStmt>
          <resp>Volltextdigitalisierung durch:</resp>
          <name xml:id="Editura">Editura GmbH &amp; Co.KG, Berlin</name>
        </respStmt>
      </seriesStmt>
      <sourceDesc>
        <biblFull>
          <titleStmt>
            <title>%s</title>
            <author>%s</author>
          </titleStmt>
          <publicationStmt>            
            <date type="first">%d</date>
          </publicationStmt>
          <seriesStmt>
            <title level="j" type="main">Polytechnisches Journal</title>
            <idno type="volume">%d</idno>
            <idno type="page">%d-%d</idno>
          </seriesStmt>
        </biblFull>
        %s
      </sourceDesc>
    </fileDesc>
    <encodingDesc>
      <projectDesc>
        <p>Optical character recognition and basic TEI encoding by Editura GmbH &amp; Co.KG, Berlin
          2009-2012.</p>
      </projectDesc>
      <editorialDecl>
        <hyphenation eol="hard">
          <p>All soft end-of-line hyphenation has been removed.</p>
        </hyphenation>
        <normalization method="silent">
          <p>No text-decoration elements were captured, such as decorated capital letters at the beginning of
            chapters or text-separators.</p>
          <p>All references to printed sheets were captured.</p>
        </normalization>
        <correction method="markup">
          <p>As far as possible all errata-lists printed in the journal have been realised, using the element
            <gi scheme="TEI">orig</gi> to mark the original text and <gi scheme="TEI">corr</gi> to mark
            the correction given in the errata-list.</p>
        </correction>
        <quotation marks="all">
          <p>All passages set off by quotation marks were marked by the element <gi scheme="TEI">q</gi>
            including the quotation mark inside the tag. In case of repeating quotation marks in front of
            each line, only the first and the last quotation mark was obtained. And the element <gi
              scheme="TEI">q</gi>'s \@type-attribute was set to the value &#x201C;preline&#x201D;.</p>
        </quotation>
      </editorialDecl>
    </encodingDesc>
  </teiHeader>
  %s
</TEI>
EOT

my $sth = $dbh->prepare('SELECT * FROM article ORDER BY id');
my $author_sth = $dbh->prepare('SELECT * FROM personref pr, person p WHERE pr.ref = ? AND pr.id = p.id');
my $journal_sth = $dbh->prepare('SELECT * FROM journal j, article a WHERE a.journal = j.id AND a.uid = ?');

$sth->execute;
while ( my $article = $sth->fetchrow_hashref ) {
    my $xml = xml( $article->{journal}, $article->{id} );
    my @authors = authors( $article->{uid}, $article->{type} );
    my $authors = join "\n", map { "<name>$_</name>" } @authors;

    $journal_sth->execute( $article->{uid} );
    my $journal = $journal_sth->fetchrow_hashref;
    my $biblStruct = biblStruct( $article->{journal} );

    my $out = sprintf $TEI,
                $journal->{volume}, $journal->{year}, $article->{title},
                $article->{journal}, $article->{id},
                $article->{title}, $authors,
                $journal->{year},
                $journal->{volume}, $article->{pagestart}, $article->{pageend},
                $biblStruct,
                $xml;

    open ( my $outfh, '>:utf8', "/tmp/europeana/" . $article->{id} . ".xml" ) or die $!;
    print $outfh $out;
    close $outfh or die $!;
}

#################################

sub biblStruct {
    my $journal = shift;
    my ($xml) = glob $xmlrep . "/" . $journal . "/*Z.xml";
    
    my $parser = XML::LibXML->new;
    $parser->expand_entities(0);
    
    my $xmldoc; eval { $xmldoc = $parser->parse_file( $xml ); 1 };
    my $xpc = XML::LibXML::XPathContext->new( $xmldoc ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
    my $snippet = $xpc->findnodes( "//tei:sourceDesc/tei:biblStruct" )->shift->toString;
    $snippet =~ s{ ref="&journals;#jour"}{}g;
    return $snippet;
}

sub xml {
    my ( $journal, $id ) = @_;
    my ($xml) = glob $xmlrep . "/" . $journal . "/*Z.xml";

    my $parser = XML::LibXML->new;
    $parser->expand_entities(0);

    my $xmldoc; eval { $xmldoc = $parser->parse_file( $xml ); 1 };
    my $xpc = XML::LibXML::XPathContext->new( $xmldoc ) or die $!;
    $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
    my $snippet = $xpc->findnodes( "//*[\@xml:id='$id']" )->shift->toString;

    for ( $snippet ) {
        s{ ref="[^"]+"}{}g;
        s{ target="[^"]+"}{}g;
        s{<bibl type="[^"]+">}{<bibl>}g;
        s{<date\b([^>]*)type="[^"]+"([^>]*)>}{<date$1$2>}g;
        s{&z[^;]+;}{}g;
    }

    return $snippet;
}

sub authors {
    my ( $id, $type ) = @_;
    my @authors;

    $author_sth->execute( $id );
    while ( my $row = $author_sth->fetchrow_hashref ) {
        next unless $row->{role} eq 'author' or
                    $row->{role} eq 'translator' or
                    ($row->{role} eq 'patent_app' && $type eq 'art_patent') or # only if no author
                    $row->{role} eq 'author_orig';
        push @authors, sprintf( "%s, %s", $row->{surname}, $row->{forename} );
    }
    push @authors, 'Anonymus' if !@authors;
    return @authors;
}
