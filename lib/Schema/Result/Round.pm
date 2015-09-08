use utf8;
package Schema::Result::Round;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Round

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<rounds>

=cut

__PACKAGE__->table("rounds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 round

  data_type: 'int'
  is_nullable: 0

=head2 player1

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 player2

  data_type: 'text'
  is_foreign_key: 1
  is_nullable: 0

=head2 score1

  data_type: 'int'
  default_value: 0
  is_nullable: 1

=head2 score2

  data_type: 'int'
  default_value: 0
  is_nullable: 1

=head2 winner

  data_type: 'text'
  is_nullable: 1

=head2 season_number

  data_type: 'int'
  default_value: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "round",
  { data_type => "int", is_nullable => 0 },
  "player1",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "player2",
  { data_type => "text", is_foreign_key => 1, is_nullable => 0 },
  "score1",
  { data_type => "int", default_value => 0, is_nullable => 1 },
  "score2",
  { data_type => "int", default_value => 0, is_nullable => 1 },
  "winner",
  { data_type => "text", is_nullable => 1 },
  "season_number",
  { data_type => "int", default_value => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 player1

Type: belongs_to

Related object: L<Schema::Result::League>

=cut

__PACKAGE__->belongs_to(
  "player1",
  "Schema::Result::League",
  { player => "player1" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 player2

Type: belongs_to

Related object: L<Schema::Result::League>

=cut

__PACKAGE__->belongs_to(
  "player2",
  "Schema::Result::League",
  { player => "player2" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 schedules

Type: has_many

Related object: L<Schema::Result::Schedule>

=cut

__PACKAGE__->has_many(
  "schedules",
  "Schema::Result::Schedule",
  { "foreign.round" => "self.round" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-07-28 09:20:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:j5hhxg0PF6O3wU+66IuX7w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
