package Dingler::Controller::Person;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Person - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(2) {
    my ( $self, $c, $person, $article ) = @_;

    my $xml = $c->config->{svn} . '/database/persons/persons.xml';
    $c->stash->{xml} = $xml;
    $c->stash->{template} = 'person.xsl';
    $c->stash(
        article => $article,
        person  => $person,
        ptrs    => $c->path_to( 'var', 'ptrs.xml' )->stringify,
    );
    $c->forward('Dingler::View::XSLT');
    my $xsl = $c->res->body;
    utf8::decode($xsl);
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
    $c->stash(
        template => 'person/view.tt',
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
