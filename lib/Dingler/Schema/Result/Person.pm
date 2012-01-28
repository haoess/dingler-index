use utf8;
package Dingler::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dingler::Schema::Result::Person

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<person>

=cut

__PACKAGE__->table("person");

=head1 ACCESSORS

=head2 uid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'person_uid_seq'

=head2 id

  data_type: 'text'
  is_nullable: 1

=head2 rolename

  data_type: 'text'
  is_nullable: 1

=head2 addname

  data_type: 'text'
  is_nullable: 1

=head2 forename

  data_type: 'text'
  is_nullable: 1

=head2 namelink

  data_type: 'text'
  is_nullable: 1

=head2 surname

  data_type: 'text'
  is_nullable: 1

=head2 pnd

  data_type: 'text'
  is_nullable: 1

=head2 viaf

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "uid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "person_uid_seq",
  },
  "id",
  { data_type => "text", is_nullable => 1 },
  "rolename",
  { data_type => "text", is_nullable => 1 },
  "addname",
  { data_type => "text", is_nullable => 1 },
  "forename",
  { data_type => "text", is_nullable => 1 },
  "namelink",
  { data_type => "text", is_nullable => 1 },
  "surname",
  { data_type => "text", is_nullable => 1 },
  "pnd",
  { data_type => "text", is_nullable => 1 },
  "viaf",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</uid>

=back

=cut

__PACKAGE__->set_primary_key("uid");

=head1 UNIQUE CONSTRAINTS

=head2 C<person_id_key>

=over 4

=item * L</id>

=back

=cut

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
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-01-25 13:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MJtsMtOcflIaOG8yWgk3Ew


# You can replace this text with custom content, and it will be preserved on regeneration
1;
