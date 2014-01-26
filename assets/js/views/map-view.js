/*global Backbone, jQuery, _, ENTER_KEY */
var app = app || {};

(function ($) {
  'use strict';

  app.AppView = Backbone.View.extend({
    el: '#map',

    events: {
    },

    initialize: function () {

      this.Location = Backbone.GoogleMaps.Location.extend({
        idAttribute: 'title',
        defaults: {
          lat: 45,
          lng: -93
        }
      });

      this.LocationCollection = Backbone.GoogleMaps.LocationCollection.extend({
        model: this.Location
      });

      this.MarkerCollectionView = Backbone.GoogleMaps.MarkerCollectionView.extend({
        addChild: function(model) {
          console.log("ho", model);
          Backbone.GoogleMaps.MarkerCollectionView.prototype.addChild.apply(this, arguments);
        }
      });


      var places = [
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
      ];

      this.places = new this.LocationCollection(places);

      var map = new google.maps.Map($('#map')[0], {
        center: new google.maps.LatLng(39.5000000, -98.3500000),
        zoom: 4,
        mapTypeId: google.maps.MapTypeId.TERRAIN,
        disableDefaultUI: true,
        disableDoubleClickZoom: true,
        draggable: false,
        styles : [{
          featureType: "all",
          elementType: "labels",
          stylers: [
            { visibility: "off" }
          ]
        }]
      });

      this.places.add({
        title: 'State Capitol Building',
        lat: 44.9543075,
        lng: -93.102222
      });

      var markerCollectionView = new this.MarkerCollectionView({
        collection: this.places,
        map: map
      });

      markerCollectionView.render();
    },

    render: function () {
    }
  });
})(jQuery);
