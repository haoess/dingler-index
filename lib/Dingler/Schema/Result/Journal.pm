package Dingler::Schema::Result::Journal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Journal

=cut

__PACKAGE__->table("journal");

=head1 ACCESSORS

=head2 id

  data_type: text
  default_value: undef
  is_nullable: 0

=head2 volume

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 year

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 facsimile

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", default_value => undef, is_nullable => 0 },
  "volume",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "year",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "facsimile",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "Dingler::Schema::Result::Article",
  { "foreign.journal" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-06-22 12:00:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+JlGoFyNr+uTlmshYXik+w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
