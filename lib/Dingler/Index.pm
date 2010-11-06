package Dingler::Index;
use Moose;

use utf8;

use Memoize;
memoize('grundform');

has 'text' => (
    isa => 'Str',
    is  => 'rw',
);

my %stop = map { utf8::encode $_; chomp; $_ => 1 } <DATA>;

sub words {
    my $self = shift;
    my $text = $self->text;
    utf8::decode($text);
    for ( $text ) {
        s/\s+/ /;
    }
    my %words;
    foreach my $word ( split /[\s,.=–:\d();?×<>\/]+/, $text ) {
        next unless $word =~ /\A[A-Z]/;
        next if length $word < 3;
        for ( $word ) {
            s/\AAe/Ä/;
            s/\AOe/Ö/;
            s/\AUe/Ü/;
            s/a\x{0364}/ä/g;
            s/o\x{0364}/ö/g;
            s/u\x{0364}/ü/g;
            s/A\x{0364}/Ä/g;
            s/O\x{0364}/Ö/g;
            s/U\x{0364}/Ü/g;
            s/&#x2010;/-/g;
        }
        next if $stop{lc $word};
        my $gf = grundform( $word );
        $words{$gf}++;
    }
    return \%words;
}

sub grundform {
    my $word = shift;
    my %list = (
        Abbildungen => 'Abbildung',
        Achsen => 'Achse',
        Arme => 'Arm',
        Atmosphären => 'Atmosphäre',
        Baches => 'Bach',
        Bahnen => 'Bahn',
        Bedingungen => 'Bedingung',
        Bienen => 'Biene',
        Bilder => 'Bild',
        Bleche => 'Blech',
        Blechen => 'Blech',
        Canales => 'Canal',
        Cylindern => 'Cylinder',
        Dächer => 'Dach',
        Dämpfe => 'Dampf',
        Dampfes => 'Dampf',
        Dampfmaschinen => 'Dampfmaschine',
        Draths => 'Drath',
        Druckrohrs => 'Druckrohr',
        Eisenbahnen => 'Eisenbahn',
        Enden => 'Ende',
        Explosionen => 'Explosion',
        Farben => 'Farbe',
        Fixsternes => 'Fixstern',
        Gase => 'Gas',
        Grade => 'Grad',
        Gebäuden => 'Gebäude',
        Gegenstandes => 'Gegenstand',
        Gewichte => 'Gewicht',
        Gräben => 'Graben',
        Grundsazes => 'Grundsaz',
        Halblöchern => 'Halbloch',
        Industrieausstellungen => 'Industrieausstellung',
        Instrumente => 'Instrument',
        Jahre => 'Jahr',
        Jahren => 'Jahr',
        Kautschuks => 'Kautschuk',
        Kessels => 'Kessel',
        Ketten => 'Kette',
        Kettenräder => 'Kettenrad',
        Konkurrenten => 'Konkurrent',
        Krapps => 'Krapp',
        Kupfers => 'Kupfer',
        Leisten => 'Leiste',
        Löcher => 'Loch',
        Maaße => 'Maaß',
        Maschinen => 'Maschine',
        Messungen => 'Messung',
        Möhren => 'Möhre',
        Nägel => 'Nagel',
        Nullpunkte => 'Nullpunkt',
        Öfen => 'Ofen',
        Ofens => 'Ofen',
        Pfannen => 'Pfanne',
        Pfeile => 'Pfeil',
        Pfeiles => 'Pfeil',
        Pflanzenfasern => 'Pflanzenfaser',
        Planeten => 'Planet',
        Rades => 'Rad',
        Räder => 'Rad',
        Ränder => 'Rand',
        Raupen => 'Raupe',
        Reflectoren => 'Reflector',
        Reflectors => 'Reflector',
        Reperaturen => 'Reperatur',
        Ringe => 'Ring',
        Ringes => 'Ring',
        Röhren => 'Röhre',
        Salzes => 'Salz',
        Salzpfannen => 'Salzpfanne',
        Säulen => 'Säule',
        Schiebers => 'Schieber',
        Schrauben => 'Schraube',
        Seile => 'Seil',
        Seiten => 'Seite',
        Stechrollen => 'Stechrolle',
        Stellräder => 'Stellrad',
        Sternes => 'Stern',
        Steuerungen => 'Steuerung',
        Stifte => 'Stift',
        Stiften => 'Stift',
        Stunden => 'Stunde',
        Teleskope => 'Teleskop',
        Teleskopes => 'Teleskop',
        Theile => 'Theil',
        Thores => 'Thor',
        Unzen => 'Unze',
        Ventile => 'Ventil',
        Verbesserungen => 'Verbesserung',
        Verhältniße => 'Verhältniß',
        Versuche => 'Versuch',
        Volum => 'Volumen',
        Vortheile => 'Vortheil',
        Walzen => 'Walze',
        Wänden => 'Wand',
        Wasserdämpfe => 'Wasserdampf',
        Wassers => 'Wasser',
        Werth => 'Wert',
        Wiener => 'Wien',
        Wiesen => 'Wiese',
        Zinkes => 'Zink',
        Zuckerrohres => 'Zuckerrohr',
        Zuckers => 'Zucker',
        Zusaz => 'Zusatz',
        Zwecke => 'Zweck',
        Zwecken => 'Zweck',
    );
    $word =~ s/'s\z//;
    return exists $list{$word} ? $list{$word} : $word;
}

__PACKAGE__->meta->make_immutable;

1;
__DATA__
aber
als
also
am
auch
auf
aus
bei
bis
dabei
das
daß
dec
dem
den
der
des
die
diese
dieser
dieses
durch
ein
eine
einem
einen
einer
eines
er
es
etwas
fig
für
gegen
hat
hrn
hier
ich
in
indem
irgend
ist
jeder
kann
man
mehr
mit
nach
nicht
noch
nun
nur
oder
sein
seine
seiner
sehr
sich
sie
so
tab
über
um
und
von
wenn
werden
welche
welcher
welches
wie
wird
wodurch
zu
zum
