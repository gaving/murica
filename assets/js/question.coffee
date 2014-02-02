class Question
  constructor: (@states) ->
    @states = _.shuffle(@states)
    @score = 0
    @attempts = 0
    @sounds = {}

    @sounds['murica'] = new Howl(
      loop: true
      urls:["media/murica.mp3"]
    ).play()

    for sound in ['correct', 'wrong']
      @sounds[sound] = (new Howl(urls:["media/#{sound}#{i}.wav"]) for i in [1..5])

    @sounds['empire'] = new Howl(urls:["media/empire.mp3" ])
    @ask()

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

  check: (state) ->
    if state.name is @question
      _.sample(@sounds['correct']).play()
      alertify.success "You got it!"
      @score += 3 if @attempts < 1
      @score += 2 if @attempts is 2
      @score += 1 if @attempts is 3

      if state.name is "New York"
        @sounds['murica'].stop()
        @sounds['empire'].play()
      @ask()
    else
      _.sample(@sounds['wrong']).play()
      alertify.error "Nope!"
      @attempts++
