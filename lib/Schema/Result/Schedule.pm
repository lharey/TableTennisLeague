use utf8;
package Schema::Result::Schedule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Schema::Result::Schedule

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

=head1 TABLE: C<schedule>

=cut

__PACKAGE__->table("schedule");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 round

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 start_date

  data_type: 'text'
  is_nullable: 1

=head2 end_date

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
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "start_date",
  { data_type => "text", is_nullable => 1 },
  "end_date",
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

=head2 round

Type: belongs_to

Related object: L<Schema::Result::Round>

=cut

__PACKAGE__->belongs_to(
  "round",
  "Schema::Result::Round",
  { round => "round" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07040 @ 2015-07-28 09:20:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fXDCNxYOPXh7ypmkcd4ckg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
