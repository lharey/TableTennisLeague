package TableTennisLeague::Controller::Tabletennis;
use Moose;
use namespace::autoclean;
use DateTime;

use DDP;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

TableTennisLeague::Controller::Tabletennis - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub league : Local : ActionClass('REST') {}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'tabletennis.tt';
    $c->forward( $c->view('TT') );
}

=head2 league_GET

=cut

sub league_GET {
    my ( $self, $c ) = @_;

    my @league_table = map {
        {
            name => $_->player,
            for => $_->for,
            against => $_->against,
            points_diff => $_->points_diff,
            drawn => $_->drawn,
            lost => $_->lost,
            won => $_->won,
            played => $_->played,
            score => $_->score
        }
    } $c->model('DB::League')->search()->all();

    my %rounds;
    foreach my $game ($c->model('DB::Round')->search()->all()) {
        if (!$rounds{$game->round}) {
            my $schedule = $game->schedules->first();
            $rounds{$game->round} = {
                games => [],
                start_date => $schedule->start_date,
                end_date => $schedule->end_date
            };
        }
        my $score1 = $game->score1 || 0;
        my $score2 = $game->score2 || 0;

        push @{$rounds{$game->round}->{games}}, {
            player1 => $game->player1->player,
            player2 => $game->player2->player,
            score1 => $game->score1,
            score1 => $game->score2,
            winner => ($score1 > $score2) ? $game->player1->player
                      : ($score2 > $score1) ? $game->player2->player
                      : undef
        };
    }

    my $today = DateTime->today()->ymd('-');
    my $current_round = $c->model('DB::Schedule')->search({
        start_date =>  { '>=' => $today },
        end_date => { '<=' => $today }
    })->first();

    $self->status_ok(
        $c,
        entity => {
            league_table => \@league_table,
            rounds => \%rounds,
            round_total => scalar keys %rounds,
            current_round => ($current_round) ? $current_round->round : 1
        }
    );
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
