code = require "../lib/agentscript.coffee"

@ABM = ABM = code.ABM

@Model = class Model extends ABM.Model
  setup: ->
    @preSetup()
    @setupBreeds()
    @setupPatches()
    @setupAgents()
    @setupCitizens()
    @setupLinks()

  preSetup: ->
    # Can be set to prepare things

  setupBreeds: ->
    @agentBreeds ["citizens"]

  setupPatches: ->
    @patches.create()

  setupAgents: ->
    i = -20
    for agent in @agents.create(41)
      agent.moveTo x: i, y: i
      i += 1

  setupCitizens: ->
    i = 10
    j = 10
    for citizen in @citizens.create(10)
      citizen.moveTo x: i, y: j
      i += 1
      if i > 14
        i = 10
        j += 1

  setupLinks: ->
    for [i, j] in [[0, 1], [2, 1], [1, 2], [1, 3], [4, 10]]
      @links.create(@agents[i], @agents[j])

@setupModel = (options = {}) ->
  options.torus ?= false
  options.model ?= @Model

  model = new options.model({
    patchSize: 20,
    mapSize: 40,
    isTorus: options.torus,
    hasNeighbors: true
  })
  return model
