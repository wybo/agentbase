# ### Agents

# Class Agents is a subclass of BreedSet which stores instances of Agent or 
# Breeds, which are subclasses of Agent
class ABM.Agents extends ABM.BreedSet
  # Constructor creates the empty BreedSet instance and installs
  # the agentClass (breed) variable shared by all the Agents in this set.
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with
    @useSprites = false

  # Have agents cache the links with them as a node.
  # Optimizes Agent a.myLinks method. Call before any agents created.
  cacheLinks: -> @agentClass::cacheLinks = true # all agents, not individual breeds

  # Use sprites rather than drawing
  setUseSprites: (@useSprites = true) ->
  
  # Filter to return all instances of this breed. Note: if used by
  # the mainSet, returns just the agents that are not subclassed breeds.
  in: (array) -> @asSet (o for o in array when o.breed is @)

  # Factory: create num new agents stored in this agentset. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  create: (num, init = ->) -> # returns array of new agents too
    ((o) -> init(o); o) @add new @agentClass for i in [1..num] by 1 # too tricky?
    # TODO refactor!

  # Remove all agents from set via agent.die()
  # Note call in reverse order to optimize list restructuring.
  clear: -> @last().die() while @any(); null # tricky, each die modifies list
  
  # Return an agentset of agents within the patch array
  inPatches: (patches) ->
    array = []
    array.push patch.agentsHere()... for patch in patches # concat measured slower
    if @mainSet? then @in array else @asSet array
  
  # Return an agentset of agents within the patchRectangle
  inRectangle: (a, dx, dy, meToo = false) ->
    rect = ABM.patches.patchRectangle a.patch, dx, dy, true
    rect = @inPatches rect
    unless meToo
      u.remove rect, a
    rect
  
  # Return the members of this agentset that are within radius distance
  # from me, and within cone radians of my heading using patch topology
  inCone: (a, heading, cone, radius, meToo = false) -> # heading? .. so p ok?
    as = @inRectangle a, radius, radius, true # TODO really needed?
    super a, heading, cone, radius, meToo #as.inCone a, heading, cone, radius, meToo
  
  # Return the members of this agentset that are within radius distance
  # from me, using patch topology
  inRadius: (a, radius, meToo = false)->
    as = @inRectangle a, radius, radius, true
    super a, radius, meToo # as.inRadius a, radius, meToo
