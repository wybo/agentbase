# Instances of the agentClass are created by the `create` factory
# method of the BreedSet.
#
# It is a subclass of `ABM.Set` and is the base class for `Patches`,
# `Agents`, and `Links`. A Set keeps track of all its created agent
# instances. It also provides, much like the ABM.Array class, some
# agent-related methods shared by all subclasses.
#
# A model contains three BreedSets:
#
# * `patches`: the model's "world" grid
# * `agents`: the model's agents living on the patches
# * `links`: the network links connecting agent pairs
#
# See NetLogo [documentation](http://ccl.northwestern.edu/netlogo/docs/)
# for explanation of the overall semantics of Agent Based Modeling
# used by Sets as well as Patches, Agents, and Links.
#
# Because we are an array subset, @[i] == this[i] == agentset[i]

class ABM.BreedSet extends ABM.Set
  # ### Constructor and add/remove agents.
  
  # Create an empty `Set` and initialize the `ID` counter for push().
  # If mainSet is supplied, the new agentset is a sub-array of mainSet.
  # This sub-array feature is how breeds are managed, see class `Model`.
  #
  constructor: (agentClass, name, mainSet) ->
    super(0) # doesn't yield empty array if already instances in the mainSet
    @agentClass = agentClass
    @name = name
    @mainSet = mainSet
    unless @mainSet?
      # Do not set breeds & ID if I'm a subset
      @breeds = []
      @ID = 0
    @agentClass::breed = @ # let the breed know I'm it's agentSet

  # Abstract method used by subclasses to create and add their instances.
  #
  create: ->

  # Keeps a copy of push for our use.
  # 
  _push: @::push

  # Pushes an agent to the list. Only used by agentset factory
  # methods. Adds the `id` property to all agents and increments it.
  #
  # Returns the object for chaining.
  #
  # By "agent" we mean an instance of `Patch`, `Agent` and `Link` and their breeds.
  #
  push: (object...) ->
    if object.length > 1
      for item in object
        @push item
    else
      object = object[0]
      @_push object

      if @mainSet?
        @mainSet.push object
      else
        if object.id?
          if object.breed? and object.breed.name is not @name
            object.id = @ID++
        else
          object.id = @ID++

    object

  # Remove an agent from the agentset, returning the agentset.
  # Note this does not change delete id or change the set's ID, thus
  # an agentset can have gaps in terms of their id's. 
  #
  #     AS.remove(AS[3]) # [{id: 0, x: 0, y: 1}, {id: 1, x: 8, y: 0},
  #                         {id: 2, x: 6, y: 4}, {id: 4, x: 1, y: 1}] 
  remove: (object) ->
    if @mainSet?
      @mainSet.remove object
    u.array.remove @, object
    @

  pop: () ->
    object = @last()
    @remove(object)
    object

  # Move an agent from its BreedSet to be in this BreedSet.
  #
  setBreed: (agent) ->
    agent.breed.remove agent
    @push agent
    proto = agent.__proto__ = @agentClass.prototype
    delete agent[key] for own key, value of agent when proto[key]?
    agent
