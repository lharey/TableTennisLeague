package TableTennisLeague::Controller::Tabletennis;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'Catalyst::Controller::REST'; }

with 'TableTennisLeague::Role::AuditLog';

=head1 NAME

TableTennisLeague::Controller::Tabletennis - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub league : Local : ActionClass('REST') {}

sub schedule : Local : ActionClass('REST') {}

sub game : Local : ActionClass('REST') {}

sub player : Local : ActionClass('REST') {}

sub signup : Local : ActionClass('REST') {}

sub history : Local : ActionClass('REST') {}

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

    my $season_number = $c->request->param('season_number') || $c->config->{season_number};

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
        {
            season_number => $season_number
        },
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
    foreach my $game ($c->model('DB::Round')->search({
        'me.season_number' => $season_number,
        'player1.season_number' => $season_number,
        'player2.season_number' => $season_number
    },{prefetch => ['player1','player2']})->all()) {
        if (!$rounds{$game->round}) {
            my $schedule = $game->search_related('schedules',{
                season_number => $season_number
            })->first();
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
            winner => $game->winner
        };
    }

    my $today = DateTime->today()->ymd('-');

    my $current_round = $c->model('DB::Schedule')->search({
        start_date =>  { '<=' => $today },
        end_date => { '>=' => $today },
        'me.season_number' => $season_number,
        'round.season_number' => $season_number
    },{ prefetch => 'round' })->first();

    # The previous season winners
    my @history;
    my $last_season = $season_number -1;
    if ($last_season) {
        foreach my $num (1..$last_season) {
            my $row = $c->model('DB::League')->search(
                {
                    season_number => $num
                },
                {
                    order_by => [
                        {-desc => 'score'},
                        {-desc => 'points_diff'},
                        {-desc => 'played'},
                        {-asc => 'player'}
                    ]
                }
            )->first();
            push @history, {
                number => $num,
                winner => $row->player
            };
        }
    }

    $self->status_ok(
        $c,
        entity => {
            league_table => \@league_table,
            rounds => \%rounds,
            round_total => scalar keys %rounds,
            current_round => ($current_round) ? $current_round->round->round : undef,
            admin_user => ($c->config->{admin_ip} eq $c->req->address) ? 1 : 0,
            admin_email => $c->config->{admin_email},
            season_number => $season_number,
            history => \@history,
            old_seasons => $c->config->{old_seasons}
        }
    );
}

=head2 schedule_PUT

=cut

sub schedule_PUT {
    my ( $self, $c, $round_number ) = @_;

    my $data = $c->req->data;

    my $season_number = $data->{season_number} || $c->config->{season_number};

    my $params;
    if ($data->{start_date}) {
        $params->{start_date} = $data->{start_date};
    }

    if ($data->{end_date}) {
        $params->{end_date} = $data->{end_date};
    }

    my $round = $c->model('DB::Schedule')->search({
        round => $round_number,
        season_number => $season_number
    })->first();

    eval { $round->update($params); };

    if ($@) {
        $self->status_bad_request(
           $c,
           message => "Error $@!"
        );
    }
    else {
        $self->audit($c);
        $self->league_GET($c);
    }
}

=head2 game_PUT

=cut

sub game_PUT {
    my ( $self, $c, $id ) = @_;

    my $data = $c->req->data;

    my $season_number = $data->{season_number} || $c->config->{season_number};

    my $game = $c->model('DB::Round')->find({id => $id});

    if ($game && !$game->winner) {
        my $params;
        if ($data->{player1}) {
            $params->{score1} = $data->{score1};
        }
        if ($data->{player2}) {
            $params->{score2} = $data->{score2};
        }

        my $success = eval {
            $c->model('DB')->txn_do(
                sub {
                    $game->update($params);

                    # Now if the game is complete, update the league table
                    if (!$game->winner && ($game->score1 + $game->score2) == 3) {
                        my $player1 = $c->model('DB::League')->search({
                            player => $game->player1->player,
                            season_number => $season_number
                        })->first();

                        my $params1 = {
                            for => $player1->for + $game->score1,
                            against => $player1->against + $game->score2,
                            played => $player1->played + 1
                        };

                        my $player2 = $c->model('DB::League')->search({
                            player => $game->player2->player,
                            season_number => $season_number
                        })->first();

                        my $params2 = {
                            for => $player2->for + $game->score2,
                            against => $player2->against + $game->score1,
                            played => $player2->played + 1
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

                        my $winner = ($game->score1 > $game->score2) ? $player1->player
                                                                     : ($game->score2 > $game->score1 )
                                                                     ? $player2->player
                                                                     : 'draw';

                        $player1->update($params1);
                        $player2->update($params2);
                        $game->update({winner => $winner});

                        $c->stash->{email} = {
                            to      => $c->config->{admin_email},
                            from    => $c->config->{email_from},
                            subject => 'TableTennis League Score Update Round ' . $game->round,
                            body    => sprintf("Round %d\n\n%s %d V %d %s",
                                            $game->round,
                                            $game->player1->player,
                                            $game->score1,
                                            $game->score2,
                                            $game->player2->player)
                        };

                        eval {$c->forward( $c->view('Email') ); };
                    }

                    return 1;
                }
            );
        };

        if ($@) {
            $self->status_bad_request(
               $c,
               message => "Error $@!"
            );
        }
        else {
            $self->audit($c);

            $self->league_GET($c);
        }
    }
    else {
        $self->status_not_found(
           $c,
           message => ($game->winner) ? "Unable to update. Game already has a winner"
                                      : "Game with id $id does not exist!",
        );
    }
}

=head2 player_GET

=cut

sub player_GET {
    my ( $self, $c, $name ) = @_;

    my $season_number = $c->request->param('season_number') || $c->config->{season_number};

    my @games;
    foreach my $game ($c->model('DB::Round')->search(
        {
            -or => [
                player1 => $name,
                player2 => $name
            ],
            season_number => $season_number
        },
        {
            order_by => 'round'
        }
    )) {
        my $score;
        my $opponent;
        my $opponent_score;
        if ($game->player1->player eq $name) {
            $score = $game->score1;
            $opponent = $game->player2;
            $opponent_score = $game->score2;
        }
        else {
            $score = $game->score2;
            $opponent = $game->player1;
            $opponent_score = $game->score1;
        }

        push @games, {
            round => $game->round,
            opponent => $opponent->player,
            opponent_score => $opponent_score,
            player_score => $score,
            winner => $game->winner
        };
    }

    $self->status_ok(
        $c,
        entity => \@games
    );

}

=head2 signup_POST

=cut

sub signup_POST {
    my ( $self, $c, $season_number ) = @_;

    my $data = $c->req->data;

    if (!$data->{name} || !$data->{email}) {
        $self->status_bad_request(
           $c,
           message => "Must supply name and email"
        );
    }
    else {
        my $signup = $c->model('DB::Signup')->find({
            season_number => $season_number,
            email => $data->{email}
        });

        if ($signup) {
            $self->status_bad_request(
               $c,
               message => "You have already signed up for Season $season_number"
            );
        }
        else {
            my $signup = eval {
                $c->model('DB::Signup')->create({
                    player => $data->{name},
                    season_number => $season_number,
                    email => $data->{email}
                });
            };

            if ($@) {
                $self->status_bad_request(
                   $c,
                   message => "Error $@!"
                );
            }
            else {
                $self->status_ok(
                    $c,
                    entity => []
                );
            }
        }
    }
}

=head2 history_GET

=cut

sub history_GET {
    my ( $self, $c, $season_number ) = @_;

    if (!$season_number) {
        $self->status_bad_request(
           $c,
           message => "Must provide season number"
        );
    }
    else {
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
            {
                season_number => $season_number
            },
            {
                order_by => [
                    {-desc => 'score'},
                    {-desc => 'points_diff'},
                    {-desc => 'played'},
                    {-asc => 'player'}
                ]
            }
        )->all();

        $self->status_ok(
            $c,
            entity => { league => \@league_table }
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
