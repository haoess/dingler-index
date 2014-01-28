#!/usr/bin/perl

use warnings;
use strict;

use utf8;
use DBI;
use File::Path qw(make_path);
use Template;
use XML::LibXML;

binmode( STDOUT, ':utf8' );

my $teins = 'http://www.tei-c.org/ns/1.0';

my $dbh = DBI->connect( 'dbi:Pg:dbname=dingler', 'fw', 'dingler', { pg_server_prepare => 1, PrintError => 0 } ) or die $DBI::errstr;

my $sth = $dbh->prepare( "SELECT a.id, a.journal, a.type, a.subtype, a.pagestart, a.pageend, j.barcode FROM article a, journal j WHERE a.journal = j.id AND a.id LIKE 'mi%'  ORDER BY a.id" );
$sth->execute or die $DBI::errstr;

my $template = do { local $/; <DATA> };

while ( my $r = $sth->fetchrow_hashref ) {
    my $id = $r->{id};
    my $journal = sprintf "/home/fw/src/kuwi/dingler/%s/%s.xml", $r->{journal}, $r->{barcode};

    print "extracting $id from $journal ...\n";

    my $xml; eval { $xml = XML::LibXML->new->parse_file( $journal ); 1 };
    die $@ if $@;

    my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
    $xpc->registerNs( 'tei', $teins );

    my ($article) = $xpc->findnodes( "//*[\@xml:id='$id']" );
    my $code;
    eval { $code = $article->toString; 1 };
    next if $@;

    my %m; # meta data
    $m{article_type} = $r->{type};

    # Haupttitel
    if ( $r->{type} eq 'misc_undef' ) {
        my ($title_main) = $xpc->findnodes( "//*[\@xml:id='$id']//tei:head", $article );
        $m{title_main} = $title_main ? normalize( $title_main->textContent ) : '[Ohne Titel]';
    }
    else {
        my ($title_main) = $xpc->findnodes( "//*[\@xml:id='$id']//tei:titlePart[\@type='main']", $article );
        $m{title_main} = normalize( $title_main->textContent );
    }

    # Untertitel
    my @title_sub;
    foreach my $title_sub ( $xpc->findnodes( "//*[\@xml:id='$id']//tei:titlePart[\@type='sub']", $article ) ) {
        push @{ $m{title_sub} }, normalize( $title_sub->textContent );
    }

    # Haupttitel der Zeitschrift
    my ($journal_title) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title' );
    $m{journal_title} = normalize( $journal_title->textContent );

    # Untertitel der Zeitschrift
    # Jahrgang
    my ($journal_volume) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date' );
    $m{journal_volume} = normalize( $journal_volume->textContent );

    # Heft
    my ($journal_issue) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:biblScope[@type="volume"]' );
    $m{journal_issue} = normalize( $journal_issue->textContent );

    # Herausgeber
    my ($journal_editor) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:editor' );
    $m{journal_editor} = $journal_editor ? normalize( $journal_editor->textContent ) : undef;

    # Seitenangabe
    if ( $r->{pagestart} eq $r->{pageend} ) {
        $m{pages} = sprintf "S. %s", $r->{pagestart};
    }
    else {
        $m{pages} = sprintf "S. %s-%s", $r->{pagestart}, $r->{pageend};
    }

    # Autor -- entfällt
    # Druckort
    my ($pubplace) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace' );
    $m{pubplace} = normalize( $pubplace->textContent );

    # Jahr
    my ($pubdate) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:date' );
    $m{pubdate} = normalize( $pubdate->textContent );

    # Verlag
    my ($publisher) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:publisher' );
    $m{publisher} = normalize( $publisher->textContent );

    # Bibliothek
    my ($lib) = $xpc->findnodes( '//tei:sourceDesc/tei:biblStruct/tei:monogr/tei:imprint/tei:note' );
    $m{lib} = normalize( $lib->textContent );

    # Signatur
    $m{signature} = $r->{barcode};

    # Link in Katalog
    $m{link} = sprintf "http://dingler.culture.hu-berlin.de/article/%s/%s", $r->{journal}, $r->{id};

    # Kurztitel
    if ( $m{journal_editor} ) {
        $m{bibfull} = sprintf "%s In: %s (Hg. %s), Jg. %s/%s, %s. %s, %s.", $m{title_main}, $m{journal_title}, $m{journal_editor}, $m{journal_volume}, $m{journal_issue}, $m{pages}, $m{pubplace}, $m{pubdate};
    }
    else {
        $m{bibfull} = sprintf "%s In: %s, Jg. %s/%s, %s. %s, %s.", $m{title_main}, $m{journal_title}, $m{journal_volume}, $m{journal_issue}, $m{pages}, $m{pubplace}, $m{pubdate};
    }

    my $outfile = sprintf '/home/fw/dingler-articles/%s.orig.xml', $id;
    my $t = Template->new;
    $t->process( \$template, { m => \%m, code => $code }, $outfile ) || die $t->error;

#    last;
}

sub debug {
    print STDERR @_;
}

sub normalize {
    my $str = shift || '';
    for ( $str ) {
        s/\s+/ /g;
        s/^\s*|\s*$//g;
    }
    return $str;
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" schematypens="http://relaxng.org/ns/structure/1.0"?>
<TEI xmlns="http://www.tei-c.org/ns/1.0">
<teiHeader>
  <fileDesc>
    <titleStmt>
      <title type="main">[% m.title_main | xml %]</title>
      [% FOREACH st IN m.title_sub -%]
      <title type="sub">[% st | xml %]</title>
      [%- END %]
      <editor>
        <orgName>Dingler Online - Das digitalisierte Polytechnische Journal</orgName>
      </editor>
      <respStmt>
        <resp>Projektträger</resp>
        <persName ref="http://d-nb.info/gnd/5067292-7">Humboldt-Universität zu Berlin</persName>
      </respStmt>
      <respStmt>
        <resp>Projektleitung Humboldt-Universität</resp>
        <persName ref="http://d-nb.info/gnd/141535091">Prof. Dr. Christian Kassung</persName>
      </respStmt>
      <respStmt>
        <resp>Wissenschaftlicher Mitarbeiter Humboldt-Universität</resp>
        <persName>Marius Hug</persName>
      </respStmt>
      <respStmt>
        <resp>Projektkoordination</resp>
        <persName>Deborah Zehnder</persName>
      </respStmt>
      <respStmt>
        <resp>Studentische Hilfskräfte</resp>
        <persName>Laura Luzardo</persName>
        <persName>Una Schäfer</persName>
        <persName>Antonia Bechmann</persName>
        <persName>Diana Daniel</persName>
      </respStmt>
      <respStmt>
        <resp>Programmierung</resp>
        <persName>Frank Wiegand</persName>
      </respStmt>
      <respStmt>
        <resp>Kooperationspartner Bibliothek</resp>
        <orgName ref="http://d-nb.info/gnd/5165770-3">Sächsische Landesbibliothek – Staats- und Universitätsbibliothek Dresden</orgName>
      </respStmt>
      <respStmt>
        <resp>Projektkoordination Bibliothek</resp>
        <persName>Marc Rohrmüller</persName>
      </respStmt>
      <respStmt>
        <resp>Projektförderung</resp>
        <orgName ref="http://d-nb.info/gnd/2007744-0">Deutsche Forschungsgemeinschaft</orgName>
      </respStmt>
      <respStmt>
        <resp>Volltextdigitalisierung</resp>
        <orgName>Editura GmbH &amp; Co. KG, Berlin</orgName>
      </respStmt>
      <respStmt>
        <resp>Projektkoordination und Basic Encoding nach den Richtlinien der TEI für die Editura GmbH &amp; Co. KG</resp>
        <name>Martina Gödel</name>
      </respStmt>
      <respStmt>
        <resp>Langfristige Bereitstellung</resp>
        <orgName ref="http://www.clarin-d.de">CLARIN-D</orgName>
      </respStmt>
    </titleStmt>
    <editionStmt>
      <edition>Vollständig digitalisierte Ausgabe</edition>
    </editionStmt>
    <publicationStmt>
      <pubPlace>Berlin</pubPlace>
      <date type="publication">2013-01-29</date>
      <publisher>
        <orgName>Deutsches Textarchiv</orgName>
        <email>wiegand@bbaw.de</email>
      </publisher>
      <availability>
        <licence target="http://creativecommons.org/licenses/by-nc-sa/3.0/de/">
          <p>Die Textdigitalisate des Polytechnischen Journals stehen unter der Lizenz Creative Commons by-nc-sa 3.0.</p>
        </licence>
      </availability>
      <idno type="URL">[% m.link | xml %]</idno>
    </publicationStmt>
    <sourceDesc>
      <bibl>[% m.bibfull | xml %]</bibl>
      <biblFull>
        <titleStmt>
          <title level="a" type="main">[% m.title_main | xml %]</title>
          [%- FOREACH st IN m.title_sub -%]
          <title level="a" type="sub">[% st | xml %]</title>
          [%- END -%]
          [% IF m.journal_editor %]<editor>
            <persName>[% m.journal_editor | xml %]</persName>
          </editor>[% END %]
        </titleStmt>
        <editionStmt>
            <edition n="1"/>
        </editionStmt>
        <publicationStmt>
          <pubPlace>[% m.pubplace | xml %]</pubPlace>
          <date type="publication">[% m.pubdate | xml %]</date>
          <publisher>
            <name>[% m.publisher | xml %]</name>
          </publisher>
        </publicationStmt>
        <seriesStmt>
          <title level="j" type="main">[% m.journal_title | xml %]</title>
          <biblScope type="volume">[% m.journal_volume | xml %]</biblScope>
          <biblScope type="issue">[% m.journal_issue | xml %]</biblScope>
          <biblScope type="pages">[% m.pages | xml %]</biblScope>
        </seriesStmt>
      </biblFull>
      <msDesc>
        <msIdentifier>
          <repository>SLUB Dresden</repository>
          <idno type="shelfmark">[% m.sig | xml %]</idno>
        </msIdentifier>
      </msDesc>
    </sourceDesc>
  </fileDesc>
  <encodingDesc>
    <p>Es gelten die Transkriptions- und Auszeichnungsrichtlinien des Projekts „Dingler Online - Das digitalisierte Polytechnische Journal“.</p>
  </encodingDesc>
  <profileDesc>
    <langUsage>
      <language ident="deu">deutsch</language>
    </langUsage>
  </profileDesc>
</teiHeader>
[% IF m.article_type == 'misc_undef' %]
<text><body>[% code %]</body></text>
[% ELSE %]
[% code %]
[% END %]
</TEI>
