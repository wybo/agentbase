# AgentBase is Free Software (GPL v3 & later), (c) 2014, Wybo Wiersma.

if typeof window == 'undefined'
  code = require "../lib/agentbase.coffee"
  eval 'var ABM = this.ABM = code.ABM'
  isHeadless = true

u = ABM.util

ABM.test = {}

ABM.test.Model = class Model extends ABM.Model
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
    # Diagonal line of agents, left top to right bottom.
    i = @world.min.x
    max = @world.max.x - @world.min.x + 1
    for agent in @agents.create(max)
      agent.moveTo x: i, y: i
      i += 1

  setupCitizens: ->
    if @world.max.x > 15
      i = 10
      j = 10
      for citizen in @citizens.create(10)
        citizen.moveTo x: i, y: j
        i += 1
        if i > 14
          i = 10
          j += 1

  setupLinks: ->
    if @world.max.x > 15
      for [i, j] in [[0, 1], [2, 1], [1, 2], [1, 3], [4, 10]]
        @links.create(@agents[i], @agents[j])

ABM.test.setupModel = (options = {}) ->
  options.model ?= Model
  options.patchSize ?= 20
  options.mapSize ?= 41
  options.isTorus ?= false
  options.isHeadless ?= isHeadless

  model = new options.model({
    patchSize: options.patchSize
    mapSize: options.mapSize
    isTorus: options.isTorus
    hasNeighbors: true # TODO see if needed
    isHeadless: options.isHeadless
  })
  return model
