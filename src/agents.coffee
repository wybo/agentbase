# ### Agents

# Class Agents is a subclass of Set which stores instances of Agent or 
# Breeds, which are subclasses of Agent
class ABM.Agents extends ABM.Set
  # Constructor creates the empty Set instance and installs
  # the agentClass (breed) variable shared by all the Agents in this set.
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with
    @useSprites = false

  # Use sprites rather than drawing
  setUseSprites: (@useSprites = true) ->
  
  # Filter to return all instances of this breed. Note: if used by
  # the mainSet, returns just the agents that are not subclassed breeds.
  in: (agents) ->
    array = []

    for agent in agents
      if agent.breed is @
        array.push agent

    @asSet array

  # Factory: create num new agents stored in this agentset. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  create: (num, initialize = ->) -> # returns array of new agents too
    ((o) -> initialize(o); o) @add new @agentClass for i in [1..num] by 1 # too tricky?
    # TODO refactor!

  # Remove all agents from set via agent.die()
  # Note call in reverse order to optimize list restructuring.
  clear: ->
    @last().die() while @any()
    null # tricky, each die modifies list
  
  # Return the members of this agentset that are neighbors of agent
  # using patch topology
  neighboring: (agent, rangeOptions) ->
    array = agent.neighbors(rangeOptions)
    @in array
