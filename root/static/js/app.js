'use strict';

/* App Module */

var tableTennisApp = angular.module('tableTennisApp', [
    'ngRoute',
    'ngSanitize',
    'xeditable',
    'tabletennisControllers'
]);

tableTennisApp.run(function(editableOptions, editableThemes) {
    editableThemes.bs3.inputClass = 'input-sm';
    editableThemes.bs3.buttonsClass = 'btn-sm';
    editableOptions.theme = 'bs3';
});

tableTennisApp.config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/tabletennis', {
        templateUrl: 'partials/league.html',
        controller: 'LeagueCtrl'
    }).
    otherwise({
        redirectTo: '/tabletennis'
    });
}]);
