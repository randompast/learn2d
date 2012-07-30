Level = require './level'

class SceneGraph
  constructor: (@game) ->
    @entities = []
    @level = new Level('test')

  addEntity: (entity) ->
    @entities.push entity
    @game.entityAdded(entity)

  getEntities: ->
    @entities

  setLevel: (level) ->
    @level = level
  getLevel: ->
    @level

module.exports = SceneGraph