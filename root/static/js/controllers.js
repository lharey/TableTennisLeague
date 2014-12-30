'use strict';

/* Controllers */

var tabletennisControllers = angular.module('tabletennisControllers', []);

tabletennisControllers.controller('LeagueCtrl', function ($scope, $http) {
    $http.get('/tabletennis/league').success(function(data) {
        console.log('data',data);
        $scope.setData(data);
    });

    $scope.setData = function(data) {
        console.log('data',data);
        $scope.league = data.league_table;
        console.log($scope.league);
        $scope.round_total = data.round_total;
        $scope.rounds = data.rounds;
        $scope.roundButtons = [];
        for (var i=1; i <= $scope.round_total; i++) {
            $scope.roundButtons.push(i);
        }
        $scope.current_round = data.current_round;
        $scope.admin_user = data.admin_user;
        $scope.admin_email = data.admin_email;
    }

    $scope.showRound = function(number) {
        $scope.round = $scope.rounds[number];
        var start = $scope.round.start_date;
        if (!$scope.admin_user && number != $scope.current_round && start && moment(start).isAfter(moment().add(7))) {
            return;
        }
        else {
            $scope.round_number = number;
            angular.element('#roundModal').modal('show');
        }
    }

    $scope.updateRoundDates = function(round_num, type, data) {
        console.log('updateRoundDates',round_num,type,data);
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
                    return 1;
                }).
                error(function(data,status,headers) {
                    console.log('error',data,data.error,status,headers);
                    return data.error;
                });

            //if (error) {
            //    return error;
            //}
        }
        else {
            return "Match should only be 3 games in total";
        }
    }
});
