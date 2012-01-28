use utf8;
package Dingler::Schema::Result::PatentApp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dingler::Schema::Result::PatentApp

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

=head1 TABLE: C<patent_app>

=cut

__PACKAGE__->table("patent_app");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'patent_app_id_seq'

=head2 patent

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 1

=head2 personid

  data_type: 'text'
  is_nullable: 1

=head2 name

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "patent_app_id_seq",
  },
  "patent",
  { data_type => "text", is_foreign_key => 1, is_nullable => 1 },
  "personid",
  { data_type => "text", is_nullable => 1 },
  "name",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

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


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-01-25 13:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5wHh9G/ctKyqF+TBG7sBIA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
