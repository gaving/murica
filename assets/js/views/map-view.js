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
          Backbone.GoogleMaps.MarkerCollectionView.prototype.addChild.apply(this, arguments);
        }
      });

      this.places = new this.LocationCollection([]);

      this.map = new google.maps.Map($('#map')[0], {
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

      this.markerView = new this.MarkerCollectionView({
        collection: this.places,
        map: this.map
      });
    },

    render: function () {
      markerView.render();
    }
  });
})(jQuery);
