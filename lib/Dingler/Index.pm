package Dingler::Index;
use Moose;

use utf8;

use Roman;
use Memoize;
memoize('grundform');

has 'text' => (
    isa => 'Str',
    is  => 'rw',
);

my %stop = map { chomp; $_ => 1 } <DATA>;

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
        next if Roman::isroman( $word );
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
        Brüken => 'Brüke',
        Canales => 'Canal',
        Cylindern => 'Cylinder',
        Dächer => 'Dach',
        Dämpfe => 'Dampf',
        Dampfes => 'Dampf',
        Dampfmaschinen => 'Dampfmaschine',
        Dekels => 'Dekel',
        Draths => 'Drath',
        Druckrohrs => 'Druckrohr',
        Druke => 'Druk',
        Eisenbahnen => 'Eisenbahn',
        Ellipsen => 'Ellipse',
        Enden => 'Ende',
        Explosionen => 'Explosion',
        Farben => 'Farbe',
        Federn => 'Feder',
        Fixsternes => 'Fixstern',
        Fuhrwerke => 'Fuhrwerk',
        Fuhrwerkes => 'Fuhrwerk',
        Gase => 'Gas',
        Gases => 'Gas',
        Grade => 'Grad',
        Gebäuden => 'Gebäude',
        Gefäßes => 'Gefäß',
        Gegenstandes => 'Gegenstand',
        Geschüze => 'Geschüz',
        Geschüzen => 'Geschüz',
        Geschüzes => 'Geschüz',
        Gewichte => 'Gewicht',
        Gräben => 'Graben',
        Grundsazes => 'Grundsaz',
        Halblöchern => 'Halbloch',
        Hängebrüken => 'Hängebrüke',
        Industrieausstellungen => 'Industrieausstellung',
        Instrumente => 'Instrument',
        Jahre => 'Jahr',
        Jahren => 'Jahr',
        Kastens => 'Kasten',
        Kautschuks => 'Kautschuk',
        Kessels => 'Kessel',
        Ketten => 'Kette',
        Kettenräder => 'Kettenrad',
        Knöpfe => 'Knopf',
        Knopfes => 'Knopf',
        Konkurrenten => 'Konkurrent',
        Krapps => 'Krapp',
        Kupfers => 'Kupfer',
        Lampen => 'Lampe',
        Leisten => 'Leiste',
        Linien => 'Linie',
        Löcher => 'Loch',
        Maaße => 'Maaß',
        Maschinen => 'Maschine',
        Messungen => 'Messung',
        Mittelpunkte => 'Mittelpunkt',
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
        Platten => 'Platte',
        Punkte => 'Punkt',
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
        Schwierigkeiten => 'Schwierigkeit',
        Schwingungen => 'Schwingung',
        Seile => 'Seil',
        Seiten => 'Seite',
        Stechrollen => 'Stechrolle',
        Stellräder => 'Stellrad',
        Sternes => 'Stern',
        Steuerungen => 'Steuerung',
        Stifte => 'Stift',
        Stiften => 'Stift',
        Stücke => 'Stück',
        Stückes => 'Stück',
        Stunden => 'Stunde',
        Systeme => 'System',
        Teleskope => 'Teleskop',
        Teleskopes => 'Teleskop',
        Theile => 'Theil',
        Thores => 'Thor',
        Tons => 'Ton',
        Unzen => 'Unze',
        Ventile => 'Ventil',
        Veränderungen => 'Veränderung',
        Verbesserungen => 'Verbesserung',
        Verhältniße => 'Verhältniß',
        Versuche => 'Versuch',
        Vibrationen => 'Vibration',
        Viereke => 'Vierek',
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
allein
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
dieß
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
hinten
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
