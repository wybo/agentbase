# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Agents is a subclass of BreedSet which creates and stores instances
# of Agent.
#
class ABM.Agents extends ABM.BreedSet
  # Creates the empty Set instance and installs the agentClass (breed)
  # variable shared by all the Agents in this set.
  #
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with
    @useSprites = false

  # Use sprites rather than drawing.
  #
  setUseSprites: (@useSprites = true) ->
    # TODO make default

  # Filter to return all instances of this breed. Note: if used by
  # the mainSet, returns just the agents that are not subclassed breeds.
  #
  in: (agents) ->
    array = []

    for agent in agents
      if agent.breed is @
        array.push agent

    @from array

  # Factory: create num new agents stored in this agentset. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  #
  create: (num, initialize = ->) -> # returns array of new agents too
    for i in [1..num] by 1 # too tricky?
      object = new @agentClass
      @push object
      initialize(object)

    @

  # Remove all agents from set via agent.die()
  #
  clear: ->
    while @any()
      @last().die()

    # Called in reverse order to optimize list restructuring.

    null # tricky, each die modifies list

  # Return the members of this agentset that are neighbors of agent
  # using patch topology.
  #
  neighboring: (agent, rangeOptions) ->
    array = agent.neighbors(rangeOptions)
    @in array

  # Circle Layout: position the agents in the list in an equally
  # spaced circle of the given radius, with the initial agent at the
  # given start angle (default to pi / 2 or "up") and in the +1 or -1
  # direction (counder clockwise or clockwise) defaulting to -1
  # (clockwise).
  #
  formCircle: (radius, startAngle = Math.PI / 2, direction = -1) ->
    dTheta = 2 * Math.PI / @.length

    for agent, i in @
      agent.moveTo x: 0, y: 0
      agent.heading = startAngle + direction * dTheta * i
      agent.forward radius

    null
