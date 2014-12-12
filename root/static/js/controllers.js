'use strict';

/* Controllers */

var tabletennisControllers = angular.module('tabletennisControllers', []);

tabletennisControllers.controller('LeagueCtrl', function ($scope, $http) {
    $http.get('static/data/games.json').success(function(data) {
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
    });

    $scope.showRound = function(number) {
        $scope.round = $scope.rounds[number];
        $scope.round_number = number;
        angular.element('#roundModal').modal('show');
    }
});
