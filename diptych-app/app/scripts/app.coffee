
require('./app/scripts/lib/module.coffee')


{ Collection, Item } = require('./app/scripts/lib/model.coffee')


App = angular.module('myApp',[ 'myApp.search','templates','ui.router','templates','angular-loading-bar', 'ngAnimate'])

App.config ($stateProvider, $locationProvider, $urlRouterProvider) ->


  $urlRouterProvider.otherwise '/'
  $locationProvider.html5Mode true

  $stateProvider

    .state 'home',
      url: '/',
      templateUrl: 'pages/index.html'





Search = angular.module('myApp.search')

Search.controller 'SearchCtrl', ($scope, $scrapi) ->

  reset = ->
    $scope.status = 'Type a term to begin the search'
    $scope.pilot = null
    $scope.coPilot = null

  do reset

  $scope.next = ->
    $scope.coPilot = $scrapi.collection.nextCoPilot()?.image


  $scope.submit = ->

    do reset

    $scrapi.fetch($scope.term)
      .then (c) ->
        if not c.pilot?
          $scope.status = "No results found for #{$scope.term}"
        else
          $scope.pilot  = c.pilot?.image
          $scope.coPilot = c.coPilot?.image

      .catch (err) ->
        do reset
        $scope.status = err
    


Search.service '$scrapi', ($http,$q) ->

  @collection = new Collection

  @fetch = (term) =>
    $deferred = do $q.defer
    
    $http.get("#{window.location.protocol}//scrapi.org/search/#{term}")
      .success (data) =>
        $deferred.resolve (@collection = new Collection(data.collection?.items or []))
      .error ->
        $deferred.reject 'Error retrieving results'
    return $deferred.promise

  return

App.directive 'fadeIn', ($timeout) ->
    restrict: 'A'
    link: ($scope, $element, attrs) ->
      attrs.$observe 'ngSrc', (src) ->
        do $element.hide
        $element.removeClass 'fade-in'
        

      $element.on 'load', ->
        do $element.show
        $element.addClass 'fade-in'




