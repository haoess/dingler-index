package Dingler::Controller::Root;
use Moose;
use namespace::autoclean;

use XML::Simple;

BEGIN { extends 'Catalyst::Controller' }

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
__PACKAGE__->config(namespace => '');

=head1 NAME

Dingler::Controller::Root - Root Controller for Dingler

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 auto

=cut

my $journal_xml;
my $journal_map;

sub auto :Private {
    my ($self, $c) = @_;
    $c->stash(
        base => $c->req->base,
        requri => $c->req->uri,
    );

    $c->stash->{volumes} = [
        map { s/@{[$c->config->{svn}]}\///; $_ }
        grep { $_ !~ 'pj000' }
        glob $c->config->{svn} . '/pj*'
    ];
    
    if ( !$journal_xml ) {
        my $volumes_file = $c->path_to( 'var', 'volumes.xml' )->stringify;
        open( my $fh, '<', $volumes_file ) or die $!;
        $journal_xml = do { local $/, <$fh> };
        $journal_map = XMLin( $journal_xml )->{journal};
    }
    $c->stash->{journal_map} = $journal_map;

    $c->stash->{ journal_number } = sub {
        my $file = shift;
        foreach my $entry ( @{$c->stash->{journal_map}} ) {
            if ( $entry->{file} eq $file ) {
                return $entry->{volume};
            }
        }
        return '';
    };

    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('journal_list');
    $c->stash(
        template => 'start.tt',
    );
}

=head2 journal_list

=cut

sub journal_list :Private {
    my ($self, $c) = @_;
    
    $c->stash->{template} = 'journal-list.xsl';
    $c->stash->{xml} = $journal_xml;
    $c->forward('Dingler::View::XSLT');
    my $xsl = $c->res->body;
    utf8::decode $xsl;
    $c->stash( xsl => $xsl );
    $c->res->body( undef );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

=cut

sub end :Private {
    my ($self, $c) = @_;
    return 1 if $c->response->status =~ /^(?:3\d\d)|(?:204)$/;
    return 1 if $c->response->body || $c->stash->{_output};

    if ( !defined $c->res->output || (!$c->res->output && $c->res->output ne '0') ) {
        my $view = $c->stash->{view} || 'TT';
        $c->forward( $c->view($view) );
        $c->fillform( $c->stash->{form} ) if $c->stash->{form};
    }
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
