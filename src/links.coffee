# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Links is a subclass of BreedSet which stores instances of Link.
#
class ABM.Links extends ABM.BreedSet
  # Constructor: super creates the empty Set instance and installs the
  # agentClass (breed) variable shared by all the Links in this set.
  #
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with

  # Factory: Add 1 or more links from the from agent to the to
  # agent(s) which can be a single agent or an array of agents. The
  # optional init proc is called on the new link after inserting in
  # the agentSet.
  #
  # Returns array of new links.
  #
  create: (from, toAgentOrAgents, initialize = ->) ->
    if u.isArray(toAgentOrAgents)
      toAgents = toAgentOrAgents
    else
      toAgents = [toAgentOrAgents]

    for to in toAgents
      object = new @agentClass from, to
      @push object
      initialize(object)

    @

  # Remove all links from set via link.die()
  #
  clear: ->
    while @any()
      @last().die()

    # Called in reverse order to optimize list restructuring.

    null # tricky, each die modifies list

  # Return all the nodes in this agentset, with duplicates included.
  # If 4 links have the same endpoint, it will appear 4 times.
  #
  nodesWithDups: ->
    set = new @model.Set

    for link in @
      set.push link.from, link.to

    set

  # Returns all the nodes in this agentset with duplicates removed.
  #
  nodes: ->
    @nodesWithDups().uniq()
