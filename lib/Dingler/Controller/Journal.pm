package Dingler::Controller::Journal;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Text::Wrap;

=head1 NAME

Dingler::Controller::Journal - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 view

=cut

sub view :Local {
    my ( $self, $c ) = @_;
    my $vol = $c->req->params->{v};
    my $journal = $c->model('Dingler::Journal')->find({ volume => $vol });
    if ( $journal ) {
        $c->forward('index', [$journal->id]);
    }
    else {
        $c->detach('/default');
    }
}

=head2 index

=cut

sub index :Path :Args(1) {
    my ( $self, $c, $journal ) = @_;

    my $item = $c->model('Dingler::Journal')->find( $journal );
    $c->detach('/default') if !$item;

    $c->forward('article_list', [$journal]);
    $c->forward('cloud', [$journal]);

    my $tabulars = $c->model('Dingler::Figure')->search(
        {
            'article.journal' => $journal,
            'me.reftype'      => 'tabular',
        },
        {
            select => 'ref',
            join => 'article',
            group_by => 'me.ref',
            order_by => 'ref',
        }
    );

    $c->stash(
        item     => $item,
        journal  => $journal,
        tabulars => $tabulars,
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

=head2 cloud

=cut

sub cloud :Local {
    my ( $self, $c, $journal ) = @_;

    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash->{xml} = $xml;
    $c->stash->{template} = 'journal-plain.xsl';
    $c->forward('Dingler::View::XSLT');
    my $plain = $c->res->body;
    $c->res->body( undef );

    my $index = Dingler::Index->new({ text => $plain });
    my %words = %{ $index->words };
    my $cloud = HTML::TagCloud->new( levels => 30 );
    while ( my ($key, $value) = each %words ) {
        $cloud->add( $key, undef, $value );
    }
    $c->stash(
        cloud => $cloud,
    );
}

=head2 plain

Text-only version of an article.

TODO:
    * caching
    * better wrapping

=cut

sub plain :Local {
    my ( $self, $c, $journal ) = @_;

    my ($xml) = glob $c->config->{svn} . "/$journal/*Z.xml";
    $c->stash(
        xml      => $xml,
        template => 'journal-plain.xsl',
    );
    $c->forward('Dingler::View::XSLT');
    my $body = $c->res->body;
    utf8::decode( $body );
    $body = Dingler::Util::uml2( $body );
    $body = join "\n\n", map { wrap '', '', $_ } split /\n\n/, $body;
    $body =~ s/^\s+//g;
    $c->res->body( $body );
    $c->res->content_type( 'text/plain' );
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
        preface    => 1,
        journal_rs => $c->model('Dingler::Journal')->find($journal),
        template   => 'article/view.tt',
        title      => 'Vorbericht',
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

        $xsl = $c->res->body;
        utf8::decode $xsl;
        $c->res->body( undef );
        $cache->set( $journal, $xsl );
    }

    $c->stash( xsl => $xsl );

    $c->stash(
        register   => 1,
        journal_rs => $c->model('Dingler::Journal')->find($journal),
        template   => 'article/view.tt',
        title      => 'Register',
    );
}

=head2 page

=cut

sub page :Local {
    my ( $self, $c, $vol ) = @_;
    
    my $page = $c->req->params->{p} || 1;
    if ( $vol !~ /\Apj[0-9]{3}\z/ or $page !~ /\A[0-9]+\z/ ) {
        $c->detach( '/default' );
    }

    my $xml = sprintf "/home/fw/dingler-pages/%s/%04d.xml", $vol, $page;
    if ( !-e $xml ) {
        $c->detach( '/default' );
    }

    my $journal = $c->model('Dingler::Journal')->find($vol);

    $c->stash(
        journal  => $vol,
        template => 'page.xsl',
        xml      => $xml,
    );
    $c->forward('Dingler::View::XSLT');
    my $xsl = $c->res->body;
    utf8::decode( $xsl );
    $c->res->body( undef );
    $c->stash(
        facs     => sprintf( "http://www.polytechnischesjournal.de/fileadmin/data/%s/%s_tif/jpegs/%08d.tif.medium.jpg", $journal->barcode, $journal->barcode, $page ),
        page     => $page,
        pages    => [
            map { /([0-9]+)\.xml$/; $1 }
            glob sprintf( '/home/fw/dingler-pages/%s/*.xml', $vol )
        ],
        xsl      => $xsl,
        volume   => $journal->volume,
        template => 'journal/page.tt',
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
