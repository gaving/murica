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
      new Board(@score)

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
