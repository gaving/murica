/*global $ */
/*jshint unused:false */
var app = app || {};
var ENTER_KEY = 13;

$(function () {
  'use strict';

  var view = new app.AppView();
  var socket = io.connect();

  socket.on('connect', function (client) {
    socket.request('/state', {}, function (states) {

      var colours = [
        '#B02B2C', '#D15600', '#C79810', '#73880A',
        '#6BBA70', '#3F4C6B', '#356AA0', '#D01F3C'
      ];

      var infoWindow;

      _.each(states, function(state) {
        var pts = [];
        _.each(state.point, function(point) {
          pts.push(new google.maps.LatLng(point.lat, point.lng));
        });

        var poly = new google.maps.Polygon({
          paths: pts,
          strokeColor: "#36393D",
          strokeOpacity: 0.8,
          strokeWeight: 1,
          fillColor: _.sample(colours),
          fillOpacity: 0.35,
          map: view.map
        });

        google.maps.event.addListener(poly, 'click', function (event) {
          if (infoWindow) {
            infoWindow.close();
          }
          infoWindow = new google.maps.InfoWindow({
            map: view.map,
            position:event.latLng,
            content: state.name
          });
          infoWindow.open(view.map);
        });
        google.maps.event.addListener(poly,"mouseover",function(){
          this.setOptions({strokeOpacity: 1.0, fillOpacity: 1.0});
        }); 
        google.maps.event.addListener(poly,"mouseout",function(){
          this.setOptions({strokeOpacity: 0.8, fillOpacity: 0.35});
        });
      });
    });

    socket.on('message', function (message) {
      // think we want to disconnect the 'state' route now and have our own
      // custom one
      var model = message.data;
      view.places.add({
        title: model.name,
        lat: model.lat,
        lng: model.lng
      });
    });
  });

  window.socket = socket;
});
