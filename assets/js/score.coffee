app = app or {}
$ ->
  app.Score = Backbone.Model.extend(
    urlRoot: '/score'
    defaults:
      name: ""
      score: 0
  )

  app.ScoreList = Backbone.Collection.extend(
    model: app.Score
    url: '/score'
  )

  app.ScoreView = Backbone.View.extend(
    tagName: "li"
    template: _.template($("#score-template").html())
    initialize: ->
      @listenTo(@model, 'change', @render)
    render: ->
      @$el.html @template(@model.toJSON())
      return this
  )

  app.BoardView = Backbone.View.extend(
    el: "#score-list"
    initialize: ->
      @collection = new app.ScoreList()
      @collection.comparator = (model) ->
        model.get('score')

      @listenTo(@collection, 'add', @addOne)
      @listenTo(@collection, 'reset', @addAll)
      @collection.fetch(reset:true)

    addOne: (score) ->
      view = new app.ScoreView(model: score)
      @$el.append view.render().el

    addAll: ->
      @collection.each @addOne, this
      @render()

    render: ->
      alertify.alert @$el.html()
  )
