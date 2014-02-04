_.templateSettings =
  interpolate: /\{\{(.+?)\}\}/g

app = app or {}
$ ->
  'use strict'
  view = new app.AppView()

  $('div.mute').on 'click', ->
    $(this).toggleClass('muted')
    Howler.mute() if $(this).hasClass('muted')
    Howler.unmute() if not $(this).hasClass('muted')

  bigbox = humane.create
    baseCls: 'humane-bigbox'
    timeout: 0
    clickToClose: true

  bigbox.error = bigbox.spawn(addnCls: 'humane-bigbox-error')
  bigbox.error 'Guess the state!<br /><br />1st attempt = 3 pts<br />2nd attempt = 2 pts<br />3rd attempt = 1 point<br /><br />Click to start!', =>
    @go()

  @go = ->
    socket = io.connect()
    socket.on 'connect', (client) ->
      socket.request '/state', {}, (states) ->

        # damn you Hawaii
        #states = _.without(states, _.findWhere(states, {name: 'Hawaii'}))
        states = [_.findWhere(states, {name: 'New York'})]
        #states = _.first(states, 1)
        #states = [_.sample(states)]

        colours = [
          '#B02B2C', '#D15600', '#C79810', '#73880A',
          '#6BBA70', '#3F4C6B', '#356AA0', '#D01F3C'
        ]

        infoWindow = null

        question = new Question states
        alertify.set(delay: 1000)

        key 'space', ->
          question.ask()

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

    window.socket = socket
