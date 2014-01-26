/*global $ */
/*jshint unused:false */
var app = app || {};
var ENTER_KEY = 13;

$(function () {
  'use strict';

  var main = new app.AppView();
  var socket = io.connect();

  socket.on('connect', function (client) {

    socket.request('/state', {}, function (states) {
      _.each(states, function(state) {
        var pts = [];
        _.each(state.point, function(point) {
          pts.push(new google.maps.LatLng(point.lat, point.lng));
        });
        var poly = new google.maps.Polygon({
          paths: pts,
          strokeColor: "#FF0000",
          strokeOpacity: 0.8,
          strokeWeight: 3,
          fillColor: state.colour,
          fillOpacity: 0.35
        });

        poly.setMap(main.map);
      });
    });

    socket.on('message', function (message) {
      // think we want to disconnect the 'state' route now and have our own
      // custom one
      var model = message.data;
      main.places.add({
        title: model.name,
        lat: model.lat,
        lng: model.lng
      });
    });
  });

  window.socket = socket;
});
