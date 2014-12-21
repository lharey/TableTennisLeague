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
    }

    $scope.showRound = function(number) {
        $scope.round = $scope.rounds[number];
        $scope.round_number = number;
        angular.element('#roundModal').modal('show');
    }

    $scope.updateRoundDates = function(round_num, type, data) {
        console.log('updateRoundDates',round_num,type,data);
        var params = (type == 'start') ? { start_date: data } : { end_date: data };

        $http.put('/tabletennis/schedule/' + round_num, params).success(function(data) {
            console.log('success',data);
            $scope.setData(data);
        });
    }

    $scope.updateScore = function(id, params) {
        console.log('updateScore',id,params);

        $http.put('/tabletennis/game/' + id, params).success(function(data) {
            console.log('success',data);
            $scope.setData(data);
        });
    }
});
