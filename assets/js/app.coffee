app = app or {}
$ ->
  'use strict'
  view = new app.AppView()

  sound = null
  bigbox = humane.create
    baseCls: "humane-bigbox"
    timeout: 0
    clickToClose: true
  bigbox.error = bigbox.spawn(addnCls: "humane-bigbox-error")
  bigbox.error "Guess the state!<br /><br />1st attempt = 3 pts<br />2nd attempt = 2 pts<br />3rd attempt = 1 point<br /><br />Click to start!", =>
    howl = new Howl(urls:["media/murica.mp3"])
    sound = howl.play()
    @go()

  class Question
    constructor: (@states) ->
      @states = _.shuffle(@states)
      @score = 0
      @attempts = 0

    ask: ->
      @question = _.first(@states)?.name
      @states = _.rest(@states)
      @attempts = 0

      $('article.alertify-log-show').click()

      if @question
        alertify.log "Where is #{@question}?", "", 0
      else
        alertify.success "All done!"
        bigbox = humane.create
          baseCls: "humane-bigbox"
          timeout: 0
          clickToClose: true
        bigbox.error = bigbox.spawn(addnCls: "humane-bigbox-error")
        #bigbox.log("Your score is #{@score}!")
        alertify.prompt "Your score is #{@score}!<br /><br />What is your name?", ((e, str) ->
          console.log "save the name and score" if e
        ), Faker.Name.findName()

    current: ->
      @question

    check: (state) ->
      if state.name is @current()
        alertify.success "You got it!"
        @score += 3 if @attempts < 1
        @score += 2 if @attempts is 2
        @score += 1 if @attempts is 3

        if state.name is "New York"
          sound.stop() if sound
          sound = new Howl(urls:["media/empire.mp3" ]).play()
        new Howl(urls:["media/correct" + _.sample(_.range(1,6)) + ".wav"]).play()
        @next()
      else
        alertify.error "Nope!"
        @attempts++
        new Howl(urls:["media/wrong" + _.sample(_.range(1,6)) + ".wav"]).play()

    next: (meters) ->
      @ask()

  $("div.mute").on 'click', ->
    $(this).toggleClass('muted')
    Howler.mute() if $(this).hasClass('muted')
    Howler.unmute() if not $(this).hasClass('muted')

  @go = ->
    socket = io.connect()
    socket.on 'connect', (client) ->
      socket.request '/state', {}, (states) ->

        # damn you Hawaii
        states = _.without(states, _.findWhere(states, {name: 'Hawaii'}))
        states = _.first(states, 1)

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

  #window.socket = socket
