package Dingler::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Dingler::Schema::Result::Person

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 uid

  data_type: integer
  default_value: nextval('person_uid_seq'::regclass)
  is_auto_increment: 1
  is_nullable: 0

=head2 id

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 rolename

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 addname

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 forename

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 namelink

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 surname

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 pnd

  data_type: text
  default_value: undef
  is_nullable: 1

=head2 viaf

  data_type: text
  default_value: undef
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uid",
  {
    data_type         => "integer",
    default_value     => \"nextval('person_uid_seq'::regclass)",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "id",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "rolename",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "addname",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "forename",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "namelink",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "surname",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "pnd",
  { data_type => "text", default_value => undef, is_nullable => 1 },
  "viaf",
  { data_type => "text", default_value => undef, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("uid");
__PACKAGE__->add_unique_constraint("person_id_key", ["id"]);

=head1 RELATIONS

=head2 personrefs

Type: has_many

Related object: L<Dingler::Schema::Result::Personref>

=cut

__PACKAGE__->has_many(
  "personrefs",
  "Dingler::Schema::Result::Personref",
  { "foreign.id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.05003 @ 2010-11-11 22:29:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JWTMPiLQ0XzezLIiRqvi1A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
