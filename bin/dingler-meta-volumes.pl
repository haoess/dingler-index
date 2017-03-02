#!/usr/bin/perl

use warnings;
use strict;

use utf8;
use Template;
use XML::LibXML;

my $out_dir = '/home/fw/dingler-meta-volumes';

my $ns_uri = 'http://www.tei-c.org/ns/1.0';
my $parser = XML::LibXML->new();
$parser->load_ext_dtd(0);
$parser->expand_entities(0);

my $tt = Template->new;

my $template;
$template .= $_ while <DATA>;

foreach my $file ( glob '/home/fw/src/kuwi/dingler/*/*Z.xml' ) {
    my $journal;
    eval { $journal = $parser->parse_file( $file ); 1 };
    if ( $@ ) {
        print STDERR "could not parse $file: $@\n";
        next;
    }
    my $xpc = XML::LibXML::XPathContext->new( $journal ) or die $!;
    $xpc->registerNs( 'tei', $ns_uri );

    print STDERR "parsing $file ...\n";

    my %d = ();

    $d{title_main}       = $xpc->find( '//tei:biblStruct/tei:monogr/tei:title' )->string_value;
    $d{biblscope_volume} = $xpc->find( '//tei:biblStruct/tei:monogr/tei:imprint/tei:biblScope[@type="volume"]' )->string_value;
    $d{title_sub}        = $xpc->find( '//tei:fileDesc/tei:titleStmt/tei:title[@type="sub"]' )->string_value;
    $d{editor}           = $xpc->find( '//tei:biblStruct/tei:monogr/tei:editor' )->string_value;
    $d{pubplace}         = $xpc->find( '//tei:biblStruct/tei:monogr/tei:imprint/tei:pubPlace' )->string_value;
    $d{pubdate}          = $xpc->find( '//tei:biblStruct/tei:monogr/tei:imprint/tei:date' )->string_value;
    $d{publisher}        = $xpc->find( '//tei:biblStruct/tei:monogr/tei:imprint/tei:publisher' )->string_value;
    $d{barcode}          = $xpc->find( '//tei:biblStruct/tei:monogr/tei:idno' )->string_value;

    $d{bibl} = sprintf '%s: %s. Bd. %s. %s, %s.', $d{editor}, $d{title_main}, $d{biblscope_volume}, $d{pubplace}, $d{pubdate};
    
    $file =~ m{dingler/(.*?)/};
    $d{journal_id} = $1;
    $d{url_web} = sprintf 'http://dingler.culture.hu-berlin.de/journal/%s', $d{journal_id};

    $tt->process( \$template, \%d, \my $out ) or die $tt->error(), "\n";

    open( my $fh, '>', sprintf("%s/%s.cmdi.xml", $out_dir, $d{journal_id}) ) or die $!;
    print $fh $out;
    close $fh or die $!;

    my $oai_template = <<"EOT";
<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
  <dc:identifier>[% url_web | xml %]</dc:identifier>
  <dc:type>Text</dc:type>
  <dc:language>de</dc:language>
  <dc:title>[% title_main | xml %]</dc:title>
  <dc:subject>Gebrauchsliteratur: Zeitschrift</dc:subject>
  <dc:publisher>Deutsches Textarchiv (Dingler)</dc:publisher>
  <dc:rights>Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 3.0 Deutschland" (CC BY-NC-SA 3.0 DE)</dc:rights>
  <dc:source>[% bibl | xml %]</dc:source>
  <dc:date>[% pubdate | xml %]</dc:date>
</oai_dc:dc>
EOT
    $tt->process( \$oai_template, \%d, \my $oai_dc ) or die $tt->error(), "\n";

    open( $fh, '>:utf8', sprintf("%s/%s.oai_dc.xml", $out_dir, $d{journal_id}) ) or die $!;
    print $fh $oai_dc;
    close $fh or die $!;
}

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<CMD xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.clarin.eu/cmd/ http://media.dwds.de/dta/media/schema/cmdi-header.xsd"
     xmlns="http://www.clarin.eu/cmd/"
     CMDVersion="1.1">
  <Header>
    <MdCreator>Deutsches Textarchiv (Dingler)</MdCreator>
    <MdCreationDate>[% USE date; date.format(date.now, '%Y-%m-%d', 'C', 1) %]</MdCreationDate>
    <MdProfile>clarin.eu:cr1:p_1381926654438</MdProfile>
    <MdCollectionDisplayName>Dingler Online</MdCollectionDisplayName>
  </Header>

  <Resources>
    <ResourceProxyList>
      <ResourceProxy id="dingler-[% journal_id | xml %].landing_page">
        <ResourceType>LandingPage</ResourceType>
        <ResourceRef>[% url_web | xml %]</ResourceRef>
      </ResourceProxy>
      <ResourceProxy id="dingler-[% journal_id | xml %].articles">
        <ResourceType mimetype="application/x-gzip">Resource</ResourceType>
        <ResourceRef>http://141.20.150.36/~fw/volumes/[% journal_id | xml %]-articles.tar.gz</ResourceRef>
      </ResourceProxy>
      <ResourceProxy id="dingler-[% journal_id | xml %].search">
        <ResourceType mimetype="application/sru+xml">SearchService</ResourceType>
        <ResourceRef>http://dspin.dwds.de:8088/ddc-sru/dingler/</ResourceRef>
      </ResourceProxy>
    </ResourceProxyList>
    <JournalFileProxyList></JournalFileProxyList>
    <ResourceRelationList>
    </ResourceRelationList>
    <IsPartOfList>
    </IsPartOfList>
  </Resources>

  <Components>
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <title type="main">[% title_main | xml %]</title>
        <title type="volume" n="[% biblscope_volume | xml %]">[% title_sub | xml %]</title>
        <editor>
          <orgName><orgName>Dingler Online - Das digitalisierte Polytechnische Journal</orgName></orgName>
        </editor>
        <respStmt>
          <orgName><orgName>Humboldt-Universität zu Berlin</orgName></orgName>
          <resp>
            <note type="remarkResponsibility">Projektträger</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Kassung</surname>
            <forename>Christian</forename>
            <roleName>Prof. Dr.</roleName>
            <idno><idno type="PND">http://d-nb.info/gnd/141535091</idno></idno>
          </persName>
          <resp>
            <note type="remarkResponsibility">Projektleitung Humboldt-Universität</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Hug</surname>
            <forename>Marius</forename>
          </persName>
          <resp>
            <note type="remarkResponsibility">Wissenschaftlicher Mitarbeiter Humboldt-Universität</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Zehnder</surname>
            <forename>Deborah</forename>
          </persName>
          <resp>
            <note type="remarkResponsibility">Projektkoordination</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Luzardo</surname>
            <forename>Laura</forename>
          </persName>
          <persName>
            <surname>Schäfer</surname>
            <forename>Una</forename>
          </persName>
          <persName>
            <surname>Bechmann</surname>
            <forename>Antonia</forename>
          </persName>
          <persName>
            <surname>Daniel</surname>
            <forename>Diana</forename>
          </persName>
          <resp>
            <note type="remarkResponsibility">Studentische Hilfskräfte</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Wiegand</surname>
            <forename>Frank</forename>
          </persName>
          <resp>
            <note type="remarkResponsibility">Programmierung</note>
          </resp>
        </respStmt>
        <respStmt>
          <orgName><orgName>Sächsische Landesbibliothek – Staats- und Universitätsbibliothek Dresden</orgName></orgName>
          <resp>
            <note type="remarkResponsibility">Kooperationspartner Bibliothek</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Rohrmüller</surname>
            <forename>Marc</forename>
          </persName>
          <resp>
            <note type="remarkResponsibility">Projektkoordination Bibliothek</note>
          </resp>
        </respStmt>
        <respStmt>
          <orgName><orgName>Deutsche Forschungsgemeinschaft</orgName></orgName>
          <resp>
            <note type="remarkResponsibility">Projektförderung</note>
          </resp>
        </respStmt>
        <respStmt>
          <orgName><orgName>Editura GmbH &amp; Co. KG, Berlin</orgName></orgName>
          <resp>
            <note type="remarkResponsibility">Volltextdigitalisierung</note>
          </resp>
        </respStmt>
        <respStmt>
          <persName>
            <surname>Gödel</surname>
            <forename>Martina</forename>
          </persName>
          <resp>
            <note type="remarkResponsibility">Projektkoordination und Basic Encoding nach den Richtlinien der TEI für die Editura GmbH &amp; Co. KG</note>
          </resp>
        </respStmt>
        <respStmt>
          <orgName><orgName>CLARIN-D</orgName></orgName>
          <resp>
            <note type="remarkResponsibility">Langfristige Bereitstellung</note>
          </resp>
        </respStmt>
      </titleStmt>
      <editionStmt>
        <edition>Vollständig digitalisierte Ausgabe</edition>
      </editionStmt>
      <publicationStmt>
        <pubPlace>Berlin</pubPlace>
        <date type="publication">[% USE date; date.format(date.now, '%Y-%m-%d', 'C', 1) %]</date>
        <publisher>
          <email>dta@bbaw.de</email>
          <orgName><orgName role="project">Deutsches Textarchiv (Dingler)</orgName></orgName>
          <orgName><orgName role="hostingInstitution" xml:lang="en">Berlin-Brandenburg Academy of Sciences and Humanities</orgName></orgName>
          <orgName><orgName role="hostingInstitution" xml:lang="de">Berlin-Brandenburgische Akademie der Wissenschaften (BBAW)</orgName></orgName>
          <address>
          <addrLine>Jägerstr. 22/23, 10117 Berlin</addrLine>
          <country>Germany</country>
        </address>
        </publisher>
        <availability>
          <licence target="http://creativecommons.org/licenses/by-nc-sa/3.0/de/">
            <p>Die Textdigitalisate des Polytechnischen Journals stehen unter der Lizenz "Creative Commons Namensnennung - Nicht-kommerziell - Weitergabe unter gleichen Bedingungen 3.0 Deutschland" (CC BY-NC-SA 3.0 DE).</p>
          </licence>
        </availability>
        <idno>
          <idno type="URLWeb">[% url_web | xml %]</idno>
        </idno>
      </publicationStmt>
      <sourceDesc>
        <bibl type="J">[% bibl | xml %]</bibl>
        <biblFull>
          <titleStmt>
            <title type="main">[% title_main | xml %]</title>
            <title type="volume" n="[% biblscope_volume | xml %]" level="m">[% title_sub | xml %]</title>
            <editor>
              <persName>[% editor | xml %]</persName>
            </editor>
          </titleStmt>
          <editionStmt>
            <edition n="1"/>
          </editionStmt>
          <publicationStmt>
            <pubPlace>[% pubplace | xml %]</pubPlace>
            <date type="publication">[% pubdate | xml %]</date>
            <publisher>
              <name>[% publisher | xml %]</name>
            </publisher>
          </publicationStmt>
        </biblFull>
        <msDesc>
          <msIdentifier>
            <repository>SLUB Dresden</repository>
            <idno>
              <idno type="shelfmark">Bibliotheksbarcode: [% barcode | xml %]</idno>
            </idno>
          </msIdentifier>
        </msDesc>
      </sourceDesc>
    </fileDesc>
    <encodingDesc>
      <editorialDecl>
        <p>Es gelten die Transkriptions- und Auszeichnungsrichtlinien des Projekts „Dingler Online - Das digitalisierte Polytechnische Journal“.</p>
      </editorialDecl>
    </encodingDesc>
    <profileDesc>
      <langUsage>
        <language ident="deu">deutsch</language>
      </langUsage>
      <textClass>
        <classCode scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dwds1main">Gebrauchsliteratur</classCode>
        <classCode scheme="http://www.deutschestextarchiv.de/doku/klassifikation#dwds1sub">Zeitschrift</classCode>
        <classCode scheme="http://www.deutschestextarchiv.de/doku/klassifikation#DTACorpus">dingler</classCode>
      </textClass>
    </profileDesc>
  </teiHeader>
  </Components>
</CMD>
