/*global Backbone, jQuery, _, ENTER_KEY */
var app = app || {};

(function ($) {
  'use strict';

  app.AppView = Backbone.View.extend({
    el: '#map',

    events: {
    },

    initialize: function () {

      var places = new Backbone.GoogleMaps.LocationCollection([
        {
        title: "Walker Art Center",
        lat: 44.9796635,
        lng: -93.2748776
      },
      {
        title: "Science Museum of Minnesota",
        lat: 44.9429618,
        lng: -93.0981016
      }
      ]);

      var map = new google.maps.Map($('#map')[0], {
        center: new google.maps.LatLng(40.0000000, -100.0000000),
        zoom: 4,
        mapTypeId: google.maps.MapTypeId.TERRAIN,
        disableDefaultUI: true,
        disableDoubleClickZoom: true,
        draggable: false
      });

      var styles = [
      {
        featureType: "all",
        elementType: "labels",
        stylers: [
          { visibility: "off" }
        ]
      }
      ];

      map.setOptions({styles: styles});

      var markerCollectionView = new Backbone.GoogleMaps.MarkerCollectionView({
        collection: places,
        map: map
      });
      markerCollectionView.render();
    },

    render: function () {
    }
  });
})(jQuery);
