package Dingler::Controller::Journal;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Dingler::Controller::Journal - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $journal ) = @_;

    $c->forward('article_list', [$journal]);

    $c->stash(
        template => 'article/list.tt',
    );
}

=head2 article_list

=cut

sub article_list :Private {
    my ($self, $c, $journal) = @_;

    $c->stash->{template} = 'article-list.xsl';
    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;
    $c->stash->{journal} = $journal;
    $c->forward('Dingler::View::XSLT');

    my $xsl = $c->res->body;
    utf8::decode $xsl;
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
}

=head2 preface

=cut

sub preface :Local {
    my ( $self, $c, $journal ) = @_;

    $c->stash->{template} = 'preface.xsl';
    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;
    $c->stash->{journal} = $journal;
    $c->forward('Dingler::View::XSLT');

    my $xsl = $c->res->body;
    utf8::decode $xsl;
    $c->stash( xsl => $xsl );
    $c->res->body( undef );

    $c->stash(
        template => 'article/view.tt',
    );
}

=head2 register

=cut

sub register :Local {
    my ( $self, $c, $journal ) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-register'
    });

    $c->stash->{journal} = $journal;
    my $xsl = $cache->get( $journal );
    if ( not defined $xsl ) {
        $c->stash->{template} = 'register.xsl';
        my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
        $c->stash->{xml} = $xml;
        $c->forward('Dingler::View::XSLT');

        my $xsl = $c->res->body;
        utf8::decode $xsl;
        $cache->set( $journal, $xsl );
    }

    $c->stash( xsl => $xsl );
    $c->res->body( undef );

    $c->stash(
        template => 'article/view.tt',
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
