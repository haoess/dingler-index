package Dingler::Schema::Result::PatentApp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::PatentApp

=cut

__PACKAGE__->table("patent_app");

=head1 ACCESSORS

=head2 id

  data_type: integer
  default_value: nextval('patent_app_id_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 patent

  data_type: text
  default_value: undef
  is_foreign_key: 1
  is_nullable: 1

=head2 personid

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 name

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    default_value     => \"nextval('patent_app_id_seq'::regclass)",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "patent",
  {
    data_type      => "text",
    default_value  => undef,
    is_foreign_key => 1,
    is_nullable    => 1,
  },
  "personid",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "name",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 patent

Type: belongs_to

Related object: L<Dingler::Schema::Result::Patent>

=cut

__PACKAGE__->belongs_to(
  "patent",
  "Dingler::Schema::Result::Patent",
  { id => "patent" },
  { join_type => "LEFT" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-07-29 21:38:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mJGcmzua1Y3QQEV8oraArw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
