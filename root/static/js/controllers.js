'use strict';

/* Controllers */

var tabletennisControllers = angular.module('tabletennisControllers', []);

tabletennisControllers.controller('LeagueCtrl', function ($scope, $http) {
    $('#sign-up div.alert').hide();

    $http.get('/tabletennis/league').success(function(data) {
        $scope.setData(data);
    });

    $scope.setData = function(data) {
        $scope.league = data.league_table;
        $scope.round_total = data.round_total;
        $scope.rounds = data.rounds;
        $scope.roundButtons = [];
        for (var i=1; i <= $scope.round_total; i++) {
            $scope.roundButtons.push(i);
        }
        $scope.current_round = data.current_round;
        $scope.admin_user = data.admin_user;
        $scope.admin_email = data.admin_email;
        $scope.season_number = parseInt(data.season_number);
    }

    $scope.showRound = function(number) {
        $scope.round = $scope.rounds[number];
        var start = $scope.round.start_date;

        $scope.round_number = number;
        angular.element('#roundModal').modal('show');
    }

    $scope.pageScroll = function(event) {
        var $anchor = $(event.currentTarget);
        $('html, body').stop().animate({
            scrollTop: $($anchor.attr('href')).offset().top
        }, 1500, 'easeInOutExpo');
    }

    $scope.updateRoundDates = function(round_num, type, data) {
        var re = /^\d{4}-\d{2}-\d{2}$/;

        if (!$scope.admin_user) {
            return 'Only admin users can amend the dates';
        }
        else if (!data.match(re)) {
            return "Format YYYY-MM-DD";
        }
        else {
            var params = (type == 'start') ? { start_date: data } : { end_date: data };

            $http.put('/tabletennis/schedule/' + round_num, params).success(function(data) {
                $scope.setData(data);
            });
        }
    }

    $scope.updateScore = function(id,params) {
        var score = (params.score1) ? params.score1 : params.score2;
        var valid = (score <=3 ) ? 1 : 0;
        for (var i=0; i < $scope.round.games.length; i++) {
            var round = $scope.round.games[i];
            if (round.id == id) {
                var opponent_score = (params.score1) ? round.score2 : round.score1;
                var total = score + opponent_score;
                if (total > 3) {
                    valid = 0;
                    break;
                }
            }
        }

        if (valid) {
            return $http.put('/tabletennis/game/' + id, params).
                success(function(data) {
                    $scope.setData(data);
                    $scope.showRound($scope.round_number);
                    return 1;
                }).
                error(function(data,status,headers) {
                    console.log('error',data,data.error,status,headers);
                    return data.error;
                });
        }
        else {
            return "Match should only be 3 games in total";
        }
    }

    $scope.showPlayer = function(name) {
        $http.get('/tabletennis/player/' + name).success(function(data) {
           $scope.player = {
                name: name,
                games: data
           };
           angular.element('#playerModal').modal('show');
        });
    }

    $scope.signUp = function() {
        $('#sign-up div.alert').hide();
        var next_season = $scope.season_number + 1;
        console.log('next_season',next_season);
        var params = {
            name: $('#signup_form #name').val(),
            email: $('#signup_form #email').val()
        };

        $http.post('/tabletennis/signup/' + next_season, params).
            success(function() {
                $('#signup_form')[0].reset();
                $('#sign-up div.alert-success').show();
            }).
            error(function(data,status,headers) {
                console.log('error',data,data.error,status,headers);
                $('#sign-up div.alert-danger strong').html(data.error);
                $('#sign-up div.alert-danger').show();
            });
    }
});
