app = app or {}
ENTER_KEY = 13
$ ->
  'use strict'
  view = new app.AppView()

  sound = new Howl(urls: [ "murica.mp3" ]).play()

  socket = io.connect()
  socket.on 'connect', (client) ->
    socket.request '/state', {}, (states) ->
      colours = [
        '#B02B2C', '#D15600', '#C79810', '#73880A',
        '#6BBA70', '#3F4C6B', '#356AA0', '#D01F3C'
      ]

      infoWindow = null
      question = _.sample(states).name
      alertify.log "Where is #{question}?", "", 0
      alertify.set(delay: 1000)

      markerBounds = new google.maps.LatLngBounds()

      _.each states, (state) ->
        pts = []
        _.each state.point, (point) ->
          pts.push new google.maps.LatLng(point.lat, point.lng)
          markerBounds.extend(new google.maps.LatLng(point.lat, point.lng))

        poly = new google.maps.Polygon
          paths: pts
          strokeColor: '#36393D'
          strokeOpacity: 0.8
          strokeWeight: 1
          fillColor: _.sample(colours)
          fillOpacity: 0.35
          map: view.map

        google.maps.event.addListener poly, 'click', (event) ->
          infoWindow.close()  if infoWindow
          infoWindow = new google.maps.InfoWindow
            map: view.map
            position: event.latLng
            content: state.name
          #infoWindow.open view.map

          #screenfull.request()
          #view.map.fitBounds(markerBounds)

          #$('article.alertify-log').text(state.name)
          #alertify.log "yeahhh"

          alertify.success "You got it!" if state.name is question
          alertify.error "Nope!" if state.name isnt question
          if state.name is "New York"
            sound.stop()
            sound = new Howl(urls: [ "empire.mp3" ]).play() 

        google.maps.event.addListener poly, 'mouseover', ->
          @setOptions
            strokeOpacity: 1.0
            fillOpacity: 1.0

        google.maps.event.addListener poly, 'mouseout', ->
          infoWindow.close()  if infoWindow
          @setOptions
            strokeOpacity: 0.8
            fillOpacity: 0.35

      #$(document).on screenfull.raw.fullscreenchange, ->
        #if (screenfull.isFullscreen)
          #view.map.fitBounds(markerBounds)
          #view.map.setZoom(4)
        #else
          #view.map.setCenter(new google.maps.LatLng(39.5000000, -98.3500000))
          #view.map.setZoom(3)

    socket.on 'message', (message) ->
      model = message.data
      view.places.add
        title: model.name
        lat: model.lat
        lng: model.lng

  window.socket = socket
