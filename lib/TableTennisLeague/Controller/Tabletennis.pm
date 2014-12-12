package TableTennisLeague::Controller::Tabletennis;
use Moose;
use namespace::autoclean;

use DDP;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TableTennisLeague::Controller::Tabletennis - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my @league = $c->model('DB::League')->search()->all();
    p @league;

    $c->stash->{template} = 'tabletennis.tt';
    $c->forward( $c->view('TT') );
}



=encoding utf8

=head1 AUTHOR

Lisa Hare,,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
