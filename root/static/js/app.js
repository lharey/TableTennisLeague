'use strict';

/* App Module */

var tableTennisApp = angular.module('tableTennisApp', [
    'ngRoute',
    'ngSanitize',
    'tabletennisControllers'
]);

tableTennisApp.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/tabletennis', {
        templateUrl: 'partials/league.html',
        controller: 'LeagueCtrl'
    }).
    otherwise({
        redirectTo: '/tabletennis'
    });
}]);
