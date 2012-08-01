define [
  'uuid'

  'cs!util'

  'cs!api/trigger'
  'cs!api/player'
  'cs!api/timer'
  'cs!api/input'

  'cs!modules/default/system'

  'cs!modules/player/movement'

  'cs!modules/sound/soundblaster'
], ->
  uuid = require 'uuid'

  util = require 'util'

  Trigger = require 'api/trigger'
  Player = require 'api/player'
  Timer = require 'api/timer'
  InputApi = require 'api/input'

  # all modules loaded up front for now
  modules =
    default:
      System: require 'cs!modules/default/system'
    player:
      Movement: require 'cs!modules/player/movement'
    sound:
      SoundBlaster: require 'cs!modules/sound/soundblaster'
      #soundManager.sounds.aSound.play()
      
  class ScriptingEngine
    constructor: (@input, @sceneGraph, @network) ->
      @initialized = false

      @triggerApi = new Trigger(@network)
      @playerApi = new Player(@sceneGraph)
      @timerApi = new Timer()
      @inputApi = new InputApi(@input)

    addClientModule: (module) ->
      if typeof module.onCreated is 'function'
        @timerCheck module, module.onCreated.bind(module)
      if typeof module.onMouseDown is 'function'
        @mouseDownListeners.push (coords) =>
          @timerCheck module, module.onMouseDown.bind(module, coords)

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

      for key, val of @timerCallbacks
        clearTimeout val
      @timerCallbacks = {}

      @moduleList = []
      for key, Module of modules[type]
        scriptModule = new Module
          trigger: @triggerApi
          player: @playerApi
          timer: @timerApi
          util: util
          input: @inputApi
        scriptModule.id = uuid.v1()
        @moduleList.push scriptModule

      for module in @moduleList
        @addClientModule(module)

      undefined

    callMouseDownListeners: ->
      for listener in @mouseDownListeners
        listener
          x: @input.getMouseX()
          y: @input.getMouseY()

    timerCheck: (module, callback) ->
      @timerApi.delay = 0
      callback()
      if @timerApi.delay isnt 0
        if typeof module.onTimer is 'function'
          clearTimeout @timerCallbacks[module.id]
          @timerCallbacks[module.id] = setTimeout(
            @timerCheck.bind(this, module, module.onTimer.bind(module))
            @timerApi.delay
          )
        @timerApi.delay = 0
