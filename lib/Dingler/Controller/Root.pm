package Dingler::Controller::Root;
use Moose;
use namespace::autoclean;

use Cache::FileCache;
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

    $c->stash->{ journal_number } = sub {
        my $file = shift;
        $file =~ /(\d+)/;
        return $1 ? sprintf( "%d", $1 ) : '';
    };

    $c->stash->{ figure_to_markup } = sub {
        my $str = shift;
        # http://www.culture.hu-berlin.de/dingler_static/pj044/image_markup/tab044493_wv_tab044493.jpg
        #   =>
        # /pj044/image_markup/tab044493.html
        $str =~ s{.*/(pj\d{3}/image_markup/\w+)_wv_.*\z}{@{[ $c->req->base ]}$1.html};
        return $str;
    };

    return 1;
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    my $journals = $c->model('Dingler::Journal')->search({}, { order_by => 'year, volume' });
    $c->stash(
        journals    => $journals,
        template    => 'start.tt',
    );
    $c->forward('stats');
}

=head2 stats

=cut

sub stats :Private {
    my ( $self, $c ) = @_;

    my $cache = Cache::FileCache->new({
        cache_root => $c->path_to( 'var', 'cache' )."",
        namespace  => 'dingler-stats'
    });

    my $stats = $cache->get('stats');
    if ( not defined $stats ) {
        my $articles    = $c->model('Dingler::Article')->search({ type => 'art_undef' })->count;
        my $patentdescs = $c->model('Dingler::Article')->search({ type => 'art_patent' })->count;
        my $patentlists = $c->model('Dingler::Article')->search({ -or => [ type => ['art_patents', 'misc_patents'] ] })->count;
        my $miscs       = $c->model('Dingler::Article')->search({ type => 'misc_undef' })->count;
        my $tables      = $c->model('Dingler::Figure')->search( undef, { group_by => ['url'] } )->count;

        # count persons
        my $xml = XML::LibXML->new->parse_file( $c->config->{svn} . '/database/persons/persons.xml' );
        my $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
        my $persons = $xpc->findnodes('//tei:person')->size;

        # count sources
        $xml = XML::LibXML->new->parse_file( $c->config->{svn} . '/database/journals/journals.xml' );
        $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
        $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
        my $sources = $xpc->findnodes('//tei:bibl')->size;

        # count patents
        my $patents = 0;
      JOURNAL:
        foreach my $journal ( glob $c->config->{svn} . '/*/*Z.xml' ) {
            eval { $xml = XML::LibXML->new->parse_file( $journal ); 1 };
            next JOURNAL if $@;
            $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
            $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
            $patents += $xpc->findnodes('//tei:div[@type="patent"]')->size;
        }

        # count characters
        my $chars = $c->model('Dingler::Article')->search( undef, {
            'select' => [ { sum => \'LENGTH(content) + LENGTH(front)' } ],
            as       => 'chars',
        } )->first->get_column('chars');

        # count figures
        my $figures = 0;
      IMAGE_MARKUP:
        foreach my $imt ( glob $c->config->{svn} . '/*/image_markup/*.xml' ) {
            eval { $xml = XML::LibXML->new->parse_file( $imt ); 1 };
            next IMAGE_MARKUP if $@;
            $xpc = XML::LibXML::XPathContext->new( $xml ) or die $!;
            $xpc->registerNs( 'tei', 'http://www.tei-c.org/ns/1.0' );
            $figures += $xpc->findnodes('/tei:TEI/tei:text/tei:body/tei:div/tei:div')->size;
        }

        $cache->set( articles    => $articles );
        $cache->set( patentdescs => $patentdescs );
        $cache->set( patentlists => $patentlists );
        $cache->set( miscs       => $miscs );
        $cache->set( chars       => $chars );
        $cache->set( tables      => $tables );
        $cache->set( figures     => $figures );
        $cache->set( persons     => $persons );
        $cache->set( sources     => $sources );
        $cache->set( patents     => $patents );
        $cache->set( stats       => 1 );
    }

    $c->stash(
        articles    => $cache->get('articles'),
        patentdescs => $cache->get('patentdescs'),
        patentlists => $cache->get('patentlists'),
        miscs       => $cache->get('miscs'),
        chars       => $cache->get('chars'),
        tables      => $cache->get('tables'),
        figures     => $cache->get('figures'),
        persons     => $cache->get('persons'),
        sources     => $cache->get('sources'),
        patents     => $cache->get('patents'),
    );
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
