define [
  'cs!api/trigger'
  'cs!api/player'

  'cs!modules/default/system'

  'cs!modules/player/movement'
], ->
  Trigger = require 'api/trigger'
  Player = require 'api/player'

  # all modules loaded up front for now
  modules =
    default:
      System: require 'cs!modules/default/system'
    player:
      Movement: require 'cs!modules/player/movement'

  class ScriptingEngine
    constructor: (@input, @sceneGraph, @network) ->
      @initialized = false

      @trigger = new Trigger(@network)
      @player = new Player(@sceneGraph)

    addClientModule: (module) ->
      if typeof module.onMouseDown is 'function'
        @mouseDownListeners.push module.onMouseDown.bind(module)

    loop: (timeDelta) ->
      if @initialized
        # Pre-scripting networking
        player = @sceneGraph.getPlayer()

        @network.beforeScripting player

      if @input.isMouseDown()
        if not @mouseDown
          @mouseDown = true
          @callMouseDownListeners()
      else
        @mouseDown = false

      if @initialized
        # Post-scripting networking
        @network.afterScripting player

    reset: (type) ->
      @initialized = true

      @mouseDownListeners = []
      @keyDownListeners = []

      @moduleList = []
      for key, Module of modules[type]
        @moduleList.push new Module
          trigger: @trigger
          player: @player

      for module in @moduleList
        @addClientModule(module)

    callMouseDownListeners: ->
      for listener in @mouseDownListeners
        listener.call(
          null,
          x: @input.getMouseX()
          y: @input.getMouseY()
        )
