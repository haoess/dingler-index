use utf8;
package Dingler::Schema::Result::Personref;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dingler::Schema::Result::Personref

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

=head1 TABLE: C<personref>

=cut

__PACKAGE__->table("personref");

=head1 ACCESSORS

=head2 id

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 ref

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "ref",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=item * L</ref>

=item * L</role>

=back

=cut

__PACKAGE__->set_primary_key("id", "ref", "role");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<Dingler::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to("id", "Dingler::Schema::Result::Person", { id => "id" }, {});

=head2 ref

Type: belongs_to

Related object: L<Dingler::Schema::Result::Article>

=cut

__PACKAGE__->belongs_to("ref", "Dingler::Schema::Result::Article", { uid => "ref" }, {});


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-01-25 13:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zOAd4qwOOM47IoXofXtIxw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
