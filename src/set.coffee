# A **Set** is an array, along with a class, agentClass, whose instances
# are the items of the array.  Instances of the class are created
# by the `create` factory method of a Set.
#
# It is a subclass of `Array` and is the base class for
# `Patches`, `Agents`, and `Links`. A Set keeps track of all
# its created instances.  It also provides, much like the **ABM.util**
# module, many methods shared by all subclasses of Set.
#
# ABM contains three agentsets created by class Model:
#
# * `ABM.patches`: the model's "world" grid
# * `ABM.agents`: the model's agents living on the patches
# * `ABM.links`: the network links connecting agent pairs
#
# See NetLogo [documentation](http://ccl.northwestern.edu/netlogo/docs/)
# for explanation of the overall semantics of Agent Based Modeling
# used by Sets as well as Patches, Agents, and Links.
#
# Note: subclassing `Array` can be dangerous and we may have to convert
# to a different style. See Trevor Burnham's [comments](http://goo.gl/Lca8g)
# but thus far we've resolved all related problems.
#
# Because we are an array subset, @[i] == this[i] == agentset[i]

class ABM.Set extends Array
  # ### Static members
  
  # `asSet` is a static wrapper function converting an array of agents into
  # an `Set` .. except for the ID which only impacts the add method.
  # It is primarily used to turn a comprehension into a Set instance
  # which then gains access to all the methods below.  Ex:
  #
  #     evens = (a for a in ABM.agents when a.id % 2 is 0)
  #     ABM.Set.asSet(evens)
  #     randomEven = evens.random()
  @asSet: (a, setType = ABM.Set) ->
    a.__proto__ = setType.prototype ? setType.constructor.prototype # setType.__proto__
    a
  
  # In the examples below, we'll use an array of primitive agent objects
  # with three fields: id, x, y.
  #
  #     AS = for i in [1..5] # long form comprehension
  #       {id:i, x:u.randomInt(10), y:u.randomInt(10)}
  #     ABM.Set.asSet AS # Convert AS to Set in place
  #        [{id: 1, x: 0, y: 1}, {id: 2, x: 8, y: 0}, {id: 3, x: 6, y: 4},
  #         {id: 4, x: 1, y: 3}, {id: 5, x: 1, y: 1}]

  # ### Constructor and add/remove agents.
  
  # Create an empty `Set` and initialize the `ID` counter for add().
  # If mainSet is supplied, the new agentset is a sub-array of mainSet.
  # This sub-array feature is how breeds are managed, see class `Model`
  constructor: (agentClass, name, mainSet) ->
    super(0) # doesn't yield empty array if already instances in the mainSet
    @agentClass = agentClass
    @name = name
    @mainSet = mainSet
    @breeds = [] unless @mainSet?
    @agentClass::breed = @ # let the breed know I'm it's agentSet
    @ownVariables = [] # keep list of user variables
    @ID = 0 unless @mainSet? # Do not set ID if I'm a subset

  # Abstract method used by subclasses to create and add their instances.
  create: ->
    
  # Add an agent to the list.  Only used by agentset factory methods. Adds
  # the `id` property to all agents. Increment `ID`.
  # Returns the object for chaining.
  #
  # By "agent" we mean an instance of `Patch`, `Agent` and `Link` and their breeds
  add: (object) ->
    if @mainSet?
      @mainSet.add object
    else
      object.id = @ID++
    @push object
    object

  # Remove an agent from the agentset, returning the agentset.
  # Note this does not change ID, thus an
  # agentset can have gaps in terms of their id's. 
  #
  #     AS.remove(AS[3]) # [{id: 0, x: 0, y: 1}, {id: 1, x: 8, y: 0},
  #                         {id: 2, x: 6, y: 4}, {id: 4, x: 1, y: 1}] 
  remove: (object) ->
    if @mainSet?
      u.remove @mainSet, object
    u.remove @, object
    @

  # Set the default value of an agent class, return agentset
  setDefault: (name, value) -> @agentClass::[name] = value; @

  # Declare variables of an agent class. 
  # Vars = a string of space separated names or an array of name strings
  # Return agentset.
  own: (vars) -> # maybe not set default if val is null?
    # vars = vars.split(" ") if not u.isArray vars
    # for name in vars#.split(" ") # if not u.isArray vars
    for name in vars.split(" ")
      @setDefault name, null
      @ownVariables.push name
    @

  # Move an agent from its Set/breed to be in this Set/breed.
  # REMIND: match NetLogo sematics in terms of own variables.
  setBreed: (a) -> # change agent a to be in this breed
    u.remove a.breed, a
    @.push a
    proto = a.__proto__ = @agentClass.prototype
    delete a[k] for own k, v of a when proto[k]?
    a

  # Return all agents that are not of the given breeds argument.
  # Breeds is a string of space separated names:
  #   @patches.exclude "roads houses"
  exclude: (breeds) ->
    breeds = breeds.split(" ")
    @asSet (o for o in @ when o.breed.name not in breeds)

  # Floodfill arguments:
  #
  # * aset: initial array of agents, often a single agent: [a]
  # * fCandidate(a, asetLast) -> true if a is elegible to be added to the set
  # * fJoin(a, asetLast) -> adds a to the agentset, usually by setting a variable
  # * fCallback(asetLast, asetNext) -> optional function to be called each iteration of floodfill;
  # if fCallback returns true, the flood is aborted
  # * fNeighbors(a) -> returns the neighbors of this agent
  # * asetLast: the array of the last set of agents to join the flood;
  # gets passed into fJoin, fCandidate, and fCallback
  floodFill: (aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast = []) ->
    floodFunc = @floodFillOnce(aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast)
    floodFunc = floodFunc() while floodFunc

  # Move one step forward in a floodfill. floodFillOnce() returns a function that performs the next step of the flood.
  # This is useful if you want to watch your flood progress as an animation.
  floodFillOnce: (aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast = []) ->
    fJoin p, asetLast for p in aset
    asetNext = []
    for p in aset
      for n in fNeighbors(p) when fCandidate n, aset
        asetNext.push n if asetNext.indexOf(n) < 0
    stopEarly = fCallback and fCallback(aset, asetNext)
    if stopEarly or asetNext.length is 0 then return null
    else return () =>
      @floodFillOnce asetNext, fCandidate, fJoin, fCallback, fNeighbors, aset
  
  # Remove adjacent duplicates, by reference.
  #
  #     as = (AS.random() for i in [1..4]) # 4 random agents w/ dups
  #     ABM.Set.asSet as # [{id: 1, x: 8, y: 0}, {id: 0, x: 0, y: 1},
  #                              {id: 0, x: 0, y: 1}, {id: 2, x: 6, y: 4}]
  #     as.uniq() # [{id: 0, x: 0, y: 1}, {id: 1, x: 8, y: 0}, 
  #                  {id: 2, x: 6, y: 4}]
  uniq: -> u.uniq(@)

  # The static `ABM.Set.asSet` as a method.
  # Used by agentset methods creating new agentsets.
  asSet: (a, setType = @) -> ABM.Set.asSet a, setType # setType = ABM.Set

  # Similar to above but sorted via `id`.
  asOrderedSet: (a) -> @asSet(a).sort("id")

  # Return string representative of agentset.
  toString: -> "[" + (a.toString() for a in @).join(", ") + "]"

  # ### Property Utilities
  # Property access, also useful for debugging<br>
  
  # Return an array of a property of the agentset
  #
  #      AS.getProp "x" # [0, 8, 6, 1, 1]
  getProp: (prop) -> o[prop] for o in @

  # Return an array of agents with the property equal to the given value
  #
  #     AS.getPropWith "x", 1
  #     [{id: 4, x: 1, y: 3},{id: 5, x: 1, y: 1}]
  getPropWith: (prop, value) -> @asSet (o for o in @ when o[prop] is value)

  # Set the property of the agents to a given value.  If value
  # is an array, its values will be used, indexed by agentSet's index.
  # This is generally used via: getProp, modify results, setProp
  #
  #     # increment x for agents with x=1
  #     AS1 = ABM.Set.asSet AS.getPropWith("x", 1)
  #     AS1.setProp "x", 2 # {id: 4, x: 2, y: 3}, {id: 5, x: 2, y: 1}
  #
  # Note this changes the last two objects in the original AS above
  setProp: (prop, value) ->
    if u.isArray value
      o[prop] = value[i] for o, i in @; @
    else
      o[prop] = value for o in @; @
  
  # ### Array Utilities, often from ABM.util

  # Randomize the agentset
  #
  #     AS.shuffle(); AS.getProp "id" # [3, 2, 1, 4, 5] 
  shuffle: -> u.shuffle @

  # Sort the agentset
  #
  sort: (options...) -> u.sort @, options...

  # Make a copy of an agentset, return as new agentset.<br>
  # NOTE: does *not* duplicate the objects, simply creates a new agentset
  # with references to the same agents.  Ex: create a randomized version of AS
  # but without mangling AS itself:
  #
  #     as = AS.clone().shuffle()
  #     AS.getProp "id"  # [1, 2, 3, 4, 5]
  #     as.getProp "id"  # [2, 4, 0, 1, 3]
  clone: -> @asSet u.clone @

  # Return the last agent in the agentset
  #
  #     AS.last().id             # l5
  #     l = AS.last(); p = [l.x, l.y] # [1, 1]
  last: -> u.last @

  # Returns true if the agentset has any agents
  #
  #     AS.any()  # true
  #     AS.getPropWith("x", 99).any() #false
  any: -> u.any @

  # Return an agentset without given agent a
  #
  #     as = AS.clone().other(AS[0])
  #     as.getProp "id"  # [1, 2, 3, 4] 
  other: (a) -> @asSet (o for o in @ when o isnt a) # could clone & remove

  # Return random agent in agentset or an agentset made of n distinct agents.
  sample: (options...) ->
    random = u.sample @, options...
    if random and random.isArray
      @asSet random
    else
      random

  # Return agent when f(o) min/max in agentset. If multiple agents have
  # min/max value, return the first. Error if agentset empty.
  # If f is a string, return element with min/max value of that property.
  # If "valueToo" then return an array of the agent and the value.
  # 
  #     AS.min("x") # {id: 0, x: 0, y: 1}
  #     AS.max((a) -> a.x + a.y, true) # {id: 2, x: 6, y: 4}, 10
  min: (f, valueToo = false) ->
    u.min @, f, valueToo

  max: (f, valueToo = false) ->
    u.max @, f, valueToo

  # ### Drawing
  
  # For agentsets whose agents have a `draw` method.
  # Clears the graphics context (transparent), then
  # calls each agent's draw(context) method.
  draw: (context) ->
    u.clearContext(context)
    o.draw(context) for o in @ when not o.hidden
    null
  
  # Show/Hide all of an agentset or breed.
  # To show/hide an individual object, set its prototype: o.hidden = bool
  show: ->
    o.hidden = false for o in @
    @draw(ABM.contexts[@name])

  hide: ->
    o.hidden = true for o in @
    @draw(ABM.contexts[@name])

  # ### Debugging
  
  # Useful in console.
  # Also see [CoffeeConsole](http://goo.gl/1i7bd) Chrome extension.
  
  # Similar to NetLogo ask & with operators.
  # Allows functions as strings. Use:
  #
  #     AS.getProp("x") # [1, 8, 6, 2, 2]
  #     AS.with("o.x < 5").ask("o.x = o.x + 1")
  #     AS.getProp("x") # [2, 8, 6, 3, 3]
  #
  #     ABM.agents.with("o.id < 100").ask("o.color = [255, 0, 0]")
  ask: (f) ->
    eval("f=function(o){return " + f + ";}") if u.isString f
    f(o) for o in @; @

  with: (f) ->
    eval("f=function(o){return " + f + ";}") if u.isString f
    @asSet (o for o in @ when f(o))

# The example agentset AS used in the code fragments was made like this,
# slightly more useful than shown above due to the toString method.
#
#     class XY
#       constructor: (@x, @y) ->
#       toString: -> "{id: #{@id}, x: #{@x}, y: #{@y}}"
#     @AS = new ABM.Set # @ => global name space
#
# The result of 
#
#     AS.add new XY(u.randomInt(10), u.randomInt(10)) for i in [1..5]
#
# random run, captured so we can reuse.
#
#     AS.add new XY(pt...) for pt in [[0, 1], [8, 0], [6, 4], [1, 3], [1, 1]]

  # Return all agents within d distance from given object.
  inRadius: (entity1, options) -> # for any objects w/ x, y
    inner = []
    for entity2 in @
      if entity1.distance(entity2) <= options.radius
        inner.push entity2
    @asSet inner
      
  # As above, but also limited to the angle `cone` around
  # a `heading` from entity1
  inCone: (entity1, options) ->
    options.heading ?= entity1.heading
    # if an agent, it will have heading
    inner = []
    for entity2 in @
      if u.inCone(options.heading, options.cone, options.radius,
          entity1, entity2, ABM.patches)
        inner.push entity2
    @asSet inner
