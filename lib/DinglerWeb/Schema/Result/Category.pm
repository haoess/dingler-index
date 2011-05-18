package DinglerWeb::Schema::Result::Category;

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

DinglerWeb::Schema::Result::Category

=cut

__PACKAGE__->table("category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'category_id_seq'

=head2 name

  data_type: 'text'
  is_nullable: 1

=head2 color

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "category_id_seq",
  },
  "name",
  { data_type => "text", is_nullable => 1 },
  "color",
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
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-05-18 22:28:08
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OHthI8WnjTpaocFwcqB/Lg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
