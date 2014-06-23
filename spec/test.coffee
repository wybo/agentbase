code = require "../lib/agentscript.coffee"

@ABM = ABM = code.ABM

class Model extends ABM.Model
  setup: ->
    @patches.create()
    i = - 20
    for agent in @agents.create(41)
      agent.setXY i, i
      i += 1

@setupModel = (options = {}) ->
  options.torus ?= false

  mapRadius = 20
  model = new Model({
    size: 20,
    minX: -1 * mapRadius,
    maxX: mapRadius,
    minY: -1 * mapRadius,
    maxY: mapRadius,
    isTorus: options.torus,
    hasNeighbors: true
  })
  return model
