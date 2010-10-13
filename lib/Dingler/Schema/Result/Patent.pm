package Dingler::Schema::Result::Patent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Patent

=cut

__PACKAGE__->table("patent");

=head1 ACCESSORS

=head2 id

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 article

  data_type: integer
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 subtype

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 date

  data_type: date
  default_value: undef
  is_nullable: 1

=head2 xml

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 content

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "article",
  {
    data_type      => "integer",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "subtype",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "date",
  { data_type => "date", default_value => undef, is_nullable => 1 },
  "xml",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "content",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 article

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to(
  "article",
  "Dingler::Schema::Result::Article",
  { uid => "article" },
  { join_type => "LEFT" },
);

=head2 patent_apps

Type: has_many

Related object: L<Dingler::Schema::Result::PatentApp>

=cut

__PACKAGE__->has_many(
  "patent_apps",
  "Dingler::Schema::Result::PatentApp",
  { "foreign.patent" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-10-12 19:45:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NcK/VopaB0w+YmC/7mTX3Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
