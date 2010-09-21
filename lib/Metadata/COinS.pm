package Metadata::COinS;

use warnings;
use strict;

use URI::Escape;

my %basic = (
    'ctx_ver'     => 'Z39.88-2004',
    'rfr_id'      => 'info:sid/dingler.culture.hu-berlin.de:coins-generator',
    'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:journal', # XXX
);

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub set {
    my $self = shift;
    my ( $key, $val ) = @_;
    $self->{$key} = $val;
    return $self,
}

sub span {
    my $self = shift;
    return sprintf '<span class="Z3988" title="%s"></span>', $self->title;
}

sub title {
    my $self = shift;
    return
        join( '&amp;', map { "$_=" . uri_escape_utf8($basic{$_}) } sort keys %basic )
      . '&amp;'
      . join( '&amp;', map { "rft.$_=" . uri_escape_utf8($self->{$_}) } sort keys %$self );
}

1;
__END__
