package Dingler::Schema::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Article

=cut

__PACKAGE__->table("article");

=head1 ACCESSORS

=head2 id

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 journal

  data_type: text
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 volume

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 number

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 title

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 pagestart

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 pageend

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 facsimile

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 content

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 position

  data_type: integer
  default_value: undef
  is_nullable: 1

=head2 tsv

  data_type: tsvector
  default_value: undef
  is_nullable: 1
  size: undef

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "journal",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "type",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "volume",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "number",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "title",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "pagestart",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "pageend",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "facsimile",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "content",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "position",
  { data_type => "integer", default_value => undef, is_nullable => 1 },
  "tsv",
  {
    data_type => "tsvector",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 journal

Type: belongs_to

Related object: L<Dingler::Schema::Result::Journal>

=cut

__PACKAGE__->belongs_to(
  "journal",
  "Dingler::Schema::Result::Journal",
  { id => "journal" },
  { join_type => "LEFT" },
);

=head2 figures

Type: has_many

Related object: L<Dingler::Schema::Result::Figure>

=cut

__PACKAGE__->has_many(
  "figures",
  "Dingler::Schema::Result::Figure",
  { "foreign.article" => "self.id" },
);

=head2 people

Type: has_many

Related object: L<Dingler::Schema::Result::Person>

=cut

__PACKAGE__->has_many(
  "people",
  "Dingler::Schema::Result::Person",
  { "foreign.ref" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-06-22 12:10:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A4jarCNHLGvGgVE2zpI54A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
