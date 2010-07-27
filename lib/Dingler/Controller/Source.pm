package Dingler::Controller::Source;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use XML::LibXML;

=head1 NAME

Dingler::Controller::Source - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 list

=cut

sub list :Local {
    my ( $self, $c, $letter ) = @_;
    my $xml = $c->config->{svn} . '/database/journals/journals.xml';
    $letter ||= 'A';
    $c->stash(
        letter => $letter,
        xml    => $xml,
    );
    $c->stash->{template} = 'source-list.xsl';
    $c->forward('Dingler::View::XSLT');
    my $xsl = $c->res->body;
    utf8::decode($xsl);
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
    $c->stash(
        template => 'source/list.tt',
    );
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 AUTHOR

Frank Wiegand

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
