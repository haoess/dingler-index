package DinglerWeb::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DinglerWeb::Schema::Result::Event

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'event_id_seq'

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 startyear

  data_type: 'integer'
  is_nullable: 1

=head2 startmonth

  data_type: 'integer'
  is_nullable: 1

=head2 startday

  data_type: 'integer'
  is_nullable: 1

=head2 endyear

  data_type: 'integer'
  is_nullable: 1

=head2 endmonth

  data_type: 'integer'
  is_nullable: 1

=head2 endday

  data_type: 'integer'
  is_nullable: 1

=head2 link

  data_type: 'text'
  is_nullable: 1

=head2 image

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "event_id_seq",
  },
  "title",
  { data_type => "text", is_nullable => 1 },
  "startyear",
  { data_type => "integer", is_nullable => 1 },
  "startmonth",
  { data_type => "integer", is_nullable => 1 },
  "startday",
  { data_type => "integer", is_nullable => 1 },
  "endyear",
  { data_type => "integer", is_nullable => 1 },
  "endmonth",
  { data_type => "integer", is_nullable => 1 },
  "endday",
  { data_type => "integer", is_nullable => 1 },
  "link",
  { data_type => "text", is_nullable => 1 },
  "image",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 event_categories

Type: has_many

Related object: L<DinglerWeb::Schema::Result::EventCategory>

=cut

__PACKAGE__->has_many(
  "event_categories",
  "DinglerWeb::Schema::Result::EventCategory",
  { "foreign.event" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-18 22:28:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:APSG4e22e6GtItpwAAvdmw

__PACKAGE__->many_to_many( categories => 'event_categories', 'category' );

sub start {
    my $self = shift;
    my $out = '';

    if ( $self->startyear ) {
        $out .= $self->startyear;
    }
    else {
        return $out;
    }

    if ( $self->startmonth ) {
        $out .= sprintf "-%02d", $self->startmonth;
    }
    else {
        return $out;
    }
    if ( $self->startday ) {
        $out .= sprintf "-%02d", $self->startday;
    }
    return $out;
}

sub end {
    my $self = shift;
    my $out = '';

    if ( $self->endyear ) {
        $out .= $self->endyear;
    }
    else {
        return $out;
    }

    if ( $self->endmonth ) {
        $out .= sprintf "-%02d", $self->endmonth;
    }
    else {
        return $out;
    }
    if ( $self->endday ) {
        $out .= sprintf "-%02d", $self->endday;
    }
    return $out;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
