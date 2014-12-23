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

sub schedule : Local : ActionClass('REST') {}

sub game : Local : ActionClass('REST') {}

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
    } $c->model('DB::League')->search(
        {},
        {
            order_by => [
                {-desc => 'score'},
                {-desc => 'points_diff'},
                {-desc => 'played'},
                {-asc => 'player'}
            ]
        }
    )->all();

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
            id => $game->id,
            player1 => $game->player1->player,
            player2 => $game->player2->player,
            score1 => $game->score1,
            score2 => $game->score2,
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
            current_round => ($current_round) ? $current_round->round : 1,
            admin_user => ($c->config->{admin_ip} eq $c->req->address) ? 1 : 0
        }
    );
}

=head2 schedule_PUT

=cut

sub schedule_PUT {
    my ( $self, $c, $round_number ) = @_;

    my $data = $c->req->data;

    my $params;
    if ($data->{start_date}) {
        $params->{start_date} = $data->{start_date};
    }

    if ($data->{end_date}) {
        $params->{end_date} = $data->{end_date};
    }

    my $round = $c->model('DB::Schedule')->find({
        round => $round_number
    });

    eval { $round->update($params); };

    if ($@) {
        $self->status_bad_request(
           $c,
           message => "Error $@!"
        );
    }
    else {
        $self->league_GET($c);
    }
}

=head2 game_PUT

=cut

sub game_PUT {
    my ( $self, $c, $id ) = @_;

    my $data = $c->req->data;

    my $game = $c->model('DB::Round')->find({id => $id});

    if ($game) {
        my $params;
        if ($data->{player1}) {
            $params->{score1} = $data->{score1};
        }
        if ($data->{player2}) {
            $params->{score2} = $data->{score2};
        }

        eval {$game->update($params); };

        if ($@) {
            $self->status_bad_request(
                $c,
                message => "Error $@!"
            );
        }
        else {
            # Now if the game is complete, update the league table
            if (($game->score1 + $game->score2) == 3) {
                my $player1 = $game->player1;

                my $params1 = {
                    for => $player1->for + $game->score1,
                    against => $player1->against + $game->score2,
                    played => $player1->played + 1
                };

                my $player2 = $game->player2;

                my $params2 = {
                    for => $player2->for + $game->score2,
                    against => $player2->against + $game->score1,
                    played => $player1->played + 1
                };

                if ($game->score1 > $game->score2) {
                    $params1->{won} = $player1->won + 1;
                    $params1->{score} = $player1->score + 3;
                    $params2->{lost} = $player2->lost + 1;
                }
                elsif ($game->score2 > $game->score1) {
                    $params2->{won} = $player2->won + 1;
                    $params2->{score} = $player2->score + 3;
                    $params1->{lost} = $player1->lost + 1;
                }

                $params1->{points_diff} = $params1->{for} - $params1->{against};
                $params2->{points_diff} = $params2->{for} - $params2->{against};

                eval {
                    $player1->update($params1);
                    $player2->update($params2);
                };
            }

            if ($@) {
                $self->status_bad_request(
                   $c,
                   message => "Error $@!"
                );
            }
            else {
                $self->league_GET($c);
            }
        }
    }
    else {
        $self->status_not_found(
           $c,
           message => "Game with id $id does not exist!",
        );
    }




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
