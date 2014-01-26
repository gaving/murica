/*global $ */
/*jshint unused:false */
var app = app || {};
var ENTER_KEY = 13;

$(function () {
  'use strict';
  new app.AppView();

  (function (io) {
    var socket = io.connect();

    socket.on('connect', function socketConnected() {
      socket.request('/state', {}, function (states) {
        console.log(states);
      });

      socket.on('message', function messageReceived(message) {
        console.log('New message received :: ', message);
      });
    });

    window.socket = socket;
  })(window.io);
});
