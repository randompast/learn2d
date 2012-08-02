define ->
  class Level
    constructor: (@sceneGraph) ->
      Object.defineProperty this, 'name',
        get: @getName
        enumerable: true
        configurable: false

    getName: ->
      @sceneGraph.getPlayerLevel().getName()

    onWall: (x, y, width, height) ->
      levelData = @sceneGraph.getPlayerLevel().getLevelData()
      return false unless levelData

      @sceneGraph.getPlayerLevel().onWall(x, y, width, height)