code = require "../lib/agentscript.coffee"

@ABM = ABM = code.ABM

class Model extends ABM.Model
  setup: ->
    @patches.create()
    i = - 20
    for agent in @agents.create(41)
      agent.moveTo x: i, y: i
      i += 1

@setupModel = (options = {}) ->
  options.torus ?= false

  model = new Model({
    patchSize: 20,
    mapSize: 40,
    isTorus: options.torus,
    hasNeighbors: true
  })
  return model
