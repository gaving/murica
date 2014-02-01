class Board
  constructor: (@score) ->
    @prompt()

  prompt: ->
    bigbox = humane.create
      baseCls: "humane-bigbox"
      timeout: 0
      clickToClose: true
    alertify.set labels:
      ok: "Show Scores!"
      cancel: "Start Again"
    alertify.prompt "Your score is #{@score}!<br /><br />What is your name?", ((e, str) =>
      if e
        alertify.set labels:
          ok: "Close"
        @save(str)
      else
        @show()
    ), Faker.Name.findName()

  save: (name) ->
    score = new app.Score({name: name, score:@score})
    score.save()
    @show()

  show: ->
    new app.BoardView()
