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
        Bohrloches => 'Bohrloch',
        Bohrröhren => 'Bohrröhre',
        Bohrungen => 'Bohrung',
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
        Fadens => 'Faden',
        Farben => 'Farbe',
        Federn => 'Feder',
        Fixsternes => 'Fixstern',
        Fuhrwerke => 'Fuhrwerk',
        Fuhrwerkes => 'Fuhrwerk',
        Gase => 'Gas',
        Gases => 'Gas',
        Gebäuden => 'Gebäude',
        Gefäßes => 'Gefäß',
        Gegenstandes => 'Gegenstand',
        Geschüze => 'Geschüz',
        Geschüzen => 'Geschüz',
        Geschüzes => 'Geschüz',
        Gestänges => 'Gestänge',
        Gewichte => 'Gewicht',
        Gräben => 'Graben',
        Grade => 'Grad',
        Gramme => 'Gramm',
        Gruben => 'Grube',
        Grundsazes => 'Grundsaz',
        Halblöchern => 'Halbloch',
        Hängebrüken => 'Hängebrüke',
        Industrieausstellungen => 'Industrieausstellung',
        Injectors => 'Injector',
        Instrumente => 'Instrument',
        Jahre => 'Jahr',
        Jahren => 'Jahr',
        Kammern => 'Kammer',
        Kanten => 'Kante',
        Kastens => 'Kasten',
        Kautschuks => 'Kautschuk',
        Kessels => 'Kessel',
        Ketten => 'Kette',
        Kettenräder => 'Kettenrad',
        Knöpfe => 'Knopf',
        Knopfes => 'Knopf',
        Kohlen => 'Kohle',
        Konkurrenten => 'Konkurrent',
        Krapps => 'Krapp',
        Kupfers => 'Kupfer',
        Lampen => 'Lampe',
        Leisten => 'Leiste',
        Lichte => 'Licht',
        Lichtes => 'Licht',
        Linien => 'Linie',
        Löcher => 'Loch',
        Locomotiven => 'Locomotive',
        Maaße => 'Maaß',
        Maschinen => 'Maschine',
        Messungen => 'Messung',
        Mittelpunkte => 'Mittelpunkt',
        Möhren => 'Möhre',
        Nägel => 'Nagel',
        Nullpunkte => 'Nullpunkt',
        Öfen => 'Ofen',
        Ofens => 'Ofen',
        Papierstoffes => 'Papierstoff',
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
        Retorten => 'Retorte',
        Ringe => 'Ring',
        Ringes => 'Ring',
        Röhren => 'Röhre',
        Runkelrüben => 'Runkelrübe',
        Rüben => 'Rübe',
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
        Stiche => 'Stich',
        Stifte => 'Stift',
        Stiften => 'Stift',
        Stoffe => 'Stoff',
        Stücke => 'Stück',
        Stückes => 'Stück',
        Stunden => 'Stunde',
        Substanzen => 'Substanz',
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
        Vertheilungsschieber => 'Verteilungsschieber',
        Vertheilungsschiebers => 'Verteilungsschieber',
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
        Wirbels => 'Wirbel',
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
ihm
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
