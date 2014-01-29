app = app or {}
ENTER_KEY = 13
$ ->
  'use strict'
  view = new app.AppView()

  howl = new Howl(urls:["media/murica.mp3"])
  sound = howl.play()

  class Question
    constructor: (@states) ->
      @states = _.shuffle(@states)

    ask: ->
      @question = _.first(@states)?.name
      @states = _.rest(@states)

      $('article.alertify-log-show').click()

      if @question
        alertify.log "Where is #{@question}?", "", 0
      else
        alertify.success "All done!"

    current: ->
      @question

    check: (state) ->
      if state.name is @current()
        alertify.success "You got it!"

        if state.name is "New York"
          sound.stop()
          sound = new Howl(urls:["media/empire.mp3" ]).play()
        new Howl(urls:["media/correct" + _.sample(_.range(1,6)) + ".wav"]).play()
        @next()
      else
        alertify.error "Nope!"
        new Howl(urls:["media/wrong" + _.sample(_.range(1,6)) + ".wav"]).play()

    next: (meters) ->
      @ask()

  $("div.mute").on 'click', ->
    $(this).toggleClass('muted')
    Howler.mute() if $(this).hasClass('muted')
    Howler.unmute() if not $(this).hasClass('muted')

  socket = io.connect()
  socket.on 'connect', (client) ->
    socket.request '/state', {}, (states) ->

      # damn you Hawaii
      states = _.without(states, _.findWhere(states, {name: 'Hawaii'}))

      colours = [
        '#B02B2C', '#D15600', '#C79810', '#73880A',
        '#6BBA70', '#3F4C6B', '#356AA0', '#D01F3C'
      ]

      infoWindow = null

      question = new Question states
      question.ask()
      alertify.set(delay: 1000)

      key 'space', ->
        question.next()

      _.each states, (state) ->
        pts = []
        _.each state.point, (point) ->
          pts.push new google.maps.LatLng(point.lat, point.lng)

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

          question.check(state)

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

    #socket.on 'message', (message) ->
      #model = message.data
      #view.places.add
        #title: model.name
        #lat: model.lat
        #lng: model.lng

  window.socket = socket
