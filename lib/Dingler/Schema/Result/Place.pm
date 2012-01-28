use utf8;
package Dingler::Schema::Result::Place;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Dingler::Schema::Result::Place

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

=head1 TABLE: C<place>

=cut

__PACKAGE__->table("place");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'place_id_seq'

=head2 plid

  data_type: 'text'
  is_nullable: 1

=head2 place

  data_type: 'text'
  is_nullable: 1

=head2 latitude

  data_type: 'real'
  is_nullable: 1

=head2 longitude

  data_type: 'real'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "place_id_seq",
  },
  "plid",
  { data_type => "text", is_nullable => 1 },
  "place",
  { data_type => "text", is_nullable => 1 },
  "latitude",
  { data_type => "real", is_nullable => 1 },
  "longitude",
  { data_type => "real", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07015 @ 2012-01-25 13:04:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CQonSNVXKnNDOV+tVpMvsw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
