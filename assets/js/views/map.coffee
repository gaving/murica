app = app or {}

(($) ->
  "use strict"
  app.AppView = Backbone.View.extend(
    el: "#map"
    events: {}
    initialize: ->
      @Location = Backbone.GoogleMaps.Location.extend(
        idAttribute: "title"
        defaults:
          lat: 45
          lng: -93
      )
      @LocationCollection = Backbone.GoogleMaps.LocationCollection.extend(model: @Location)
      @MarkerCollectionView = Backbone.GoogleMaps.MarkerCollectionView.extend(addChild: (model) ->
        Backbone.GoogleMaps.MarkerCollectionView::addChild.apply this, arguments
      )
      @places = new @LocationCollection([])
      @map = new google.maps.Map($("#map")[0],
        center: new google.maps.LatLng(39.5000000, -98.3500000)
        zoom: 4
        mapTypeId: google.maps.MapTypeId.TERRAIN
        disableDefaultUI: true
        disableDoubleClickZoom: true
        draggable: false
        styles: [
          featureType: "all"
          elementType: "labels"
          stylers: [ visibility: "off" ]
         ]
      )
      @markerView = new @MarkerCollectionView(
        collection: @places
        map: @map
      )
    render: ->
      markerView.render()
  )
) jQuery
