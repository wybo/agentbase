# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Model is the control center for our Sets: Patches, Agents and Links.
#
# Creating new models is done by subclassing class Model and overriding two
# virtual/abstract methods: `setup()` and `step()`
#
class ABM.Model
  # Class variable for layers parameters.
  #
  # Can be added to by programmer to modify/create layers, **before**
  # starting your own model.
  #
  contextsInit: { # Experimental: image:   {z: 15, context: "img"}
    patches:   {z: 10, context: "2d"}
    drawing:   {z: 20, context: "2d"}
    links:     {z: 30, context: "2d"}
    agents:    {z: 40, context: "2d"}
    spotlight: {z: 50, context: "2d"}
  }

  # Constructor:
  #
  # * create agentsets, install them in the models' namespace
  # * create layers/contexts
  # * setup patch coordinate transforms for each layer context
  # * intialize various instance variables
  # * calls `setup` abstract method
  #
  constructor: (options) ->
    div = options.div
    isHeadless = options.isHeadless = options.isHeadless or not div?
    @setWorld options

    @contexts = {}

    unless isHeadless
      (@div = document.getElementById(div)).setAttribute 'style',
        "position:relative; width:#{@world.pxWidth}px; height:#{@world.pxHeight}px"

      # Create 2D canvas contexts layered on top of each other.
      # Initialize a patch coordinate transform for each layer.
      #
      # Note: this transform is permanent .. there isn't the usual context.restore().
      # To use the original canvas 2D transform temporarily:
      #
      #     u.setIdentity context
      #       <draw in native coordinate system>
      #     context.restore() # restore patch coordinate system
      for own key, value of @contextsInit
        @contexts[key] = context = u.createLayer @div, @world.pxWidth,
          @world.pxHeight, value.z, value.context
        if context.canvas?
          @setContextTransform context
        if context.canvas?
          context.canvas.style.pointerEvents = 'none'
        u.elementTextParams context, "10px sans-serif", "center", "middle"

      # One of the layers is used for drawing only, not an agentset:
      @drawing = @contexts.drawing
      @drawing.clear = =>
        u.clearContext @drawing

      # Setup spotlight layer, also not an agentset:
      @contexts.spotlight.globalCompositeOperation = "xor"

    # Subclasses the classes so they can be modified for this model if needed.
    # Also gives the classes a 'model' attribute that references this model.
    #
    # Going this route rather than class cloning because cloning does not
    # work well for Array subclasses, and because conceptually they
    # are subclasses for this model, not clones.
    @Patches = @extendWithModel(@Patches)
    @Patch = @extendWithModel(@Patch)
    @Agents = @extendWithModel(@Agents)
    @Agent = @extendWithModel(@Agent)
    @Links = @extendWithModel(@Links)
    @Link = @extendWithModel(@Link)
    @Set = @extendWithModel(@Set)
    @Animator = @extendWithModel(@Animator)

    @animator = new @Animator
    # Set drawing controls.  Default to drawing each agentset.
    # Optimization: If any of these is set to false, the associated
    # agentset is drawn only once, remaining static after that.
    @refreshLinks = @refreshAgents = @refreshPatches = true

    # Initialize agentsets.
    @patches = new @Patches @Patch, "patches"
    @agents = new @Agents @Agent, "agents"
    @links = new @Links @Link, "links"

    # Initialize model global resources
    @modelReady = false
    @globalNames = null
    @globalNames = u.ownKeys @
    @globalNames.set = false
    @startup()

    u.waitOnFiles =>
      @modelReady = true
      @setup()
      @globals() unless @globalNames.set

  # Initialize/reset world parameters.
  #
  setWorld: (options) ->
    defaults = {
      isHeadless: false, # Part of model because also excludes UI
      Agents: ABM.Agents, Agent: ABM.Agent, Links: ABM.Links, Link: ABM.Link,
      Patches: ABM.Patches, Patch: ABM.Patch, Set: ABM.Set,
      Animator: ABM.Animator}

    worldDefaults = {
      patchSize: 13, mapSize: 32, isTorus: false, min: null, max: null}

    for own key, value of defaults
      options[key] ?= value

    for own key, value of worldDefaults
      options[key] ?= value

    @world = {}

    for own key, value of options
      if typeof worldDefaults[key] isnt 'undefined'
        @world[key] = value
      else
        @[key] = value

    halfDiameter = @world.mapSize / 2
    shift = 0
    @world.mapSize = null # not passed on, because optional
    if Math.floor(halfDiameter) != halfDiameter
      halfDiameter = Math.floor(halfDiameter)
    else
      shift = 1

    @world.min ?= {x: -1 * halfDiameter + shift, y: -1 * halfDiameter + shift}
    @world.max ?= {x: halfDiameter, y: halfDiameter}

    @world.width = @world.max.x - @world.min.x + 1
    @world.height = @world.max.y - @world.min.y + 1
    @world.pxWidth = @world.width * @world.patchSize
    @world.pxHeight = @world.height * @world.patchSize
    @world.minCoordinate = {x: @world.min.x - .5, y: @world.min.y - .5}
    @world.maxCoordinate = {x: @world.max.x + .5, y: @world.max.y + .5}

  setContextTransform: (context) ->
    context.canvas.width = @world.pxWidth
    context.canvas.height = @world.pxHeight
    context.save()
    context.scale @world.patchSize, -@world.patchSize
    context.translate -(@world.minCoordinate.x), -(@world.maxCoordinate.y)

  globals: (globalNames) ->
    if globalNames?
      @globalNames = globalNames
      @globalNames.set = true
    else
      @globalNames = u.ownKeys(@).removeItems @globalNames

  # Add this model to a class's prototype. This is used in
  # the model constructor to create Patch/Patches, Agent/Agents,
  # and Link/Links classes with a built-in reference to their model.
  #
  extendWithModel: (original) ->
    model = @
    class extendedClass extends original
      @model: model
      model: model
      constructor: ->
        super
    return extendedClass

  # ### Optimizations

  # TODO consider whether to keep.

  # Draw patches using scaled image of colors. Note anti-aliasing may
  # occur if browser does not support imageSmoothingEnabled or
  # equivalent.
  #
  setFastPatches: -> @patches.usePixels()

  # Patches are all the same static default color, just "clear" entire
  # canvas.  Don't use if patch breeds have different colors.
  #
  setMonochromePatches: -> @patches.monochrome = true

  # ### User model creation

  # A user's model is made by subclassing Model and over-riding
  # startup and setup. `super` need not be called.
  #
  # Initialize model resources (images, files) here.
  # Uses util.waitOn so can be be async.
  #
  startup: -> # called by constructor

  # Initialize your model variables and defaults here.
  #
  # If async used, make sure step/draw are aware of possible missing
  # data.
  #
  setup: ->

  # Update/step your model here.
  #
  # Called each step of the animation.
  #
  step: ->

  # ### Animation and reset methods

  # Start the animation.
  #
  start: ->
    u.waitOn (=> @modelReady), (=> @animator.start())
    @isRunning = true
    @

  # Stop the animation.
  #
  stop: ->
    @animator.stop()
    @isRunning = false
    @

  # Stop the animation if it is running, start it if it isn't.
  #
  toggle: ->
    if @isRunning
      @stop()
    else
      @start()

  # Animate once by `step(); draw()`. For UI and debugging from console.
  # Will advance the ticks/draws counters.
  #
  once: ->
    unless @animator.stopped
      @stop()
    @animator.once()
    @

  # Stop and reset the model.
  #
  reset: ->
    @animator.reset() # stop & reset ticks/steps counters
    @isRunning = false

    @resetContexts()

    @patches = new @Patches @Patch, "patches"
    @agents = new @Agents @Agent, "agents"
    @links = new @Links @Link, "links"

    # setup reset, possibly null out entries?
    u.shapes.spriteSheets.length = 0

    @setup()

  # Stop and reset the model, then start it again
  #
  restart: ->
    @reset()
    @start()

  # Destroys the model.
  #
  destroy: ->
    # can be improved
    @stop()
    @agents = @patches = @links = null
    @resetContexts()

  # ### Reset helper methods.

  resetContexts: ->
    # clear/resize before agentsets
    for key, value of @contexts
      if value.canvas?
        value.restore()
        @setContextTransform value

  # Call the agentset draw methods if either the first draw call or
  # their "refresh" flags are set. The latter are simple optimizations
  # to avoid redrawing the same static scene. Called by animator.
  #
  draw: (force = @animator.stopped) ->
    if force or @refreshPatches or @animator.draws is 1
      @patches.draw @contexts.patches
    if force or @refreshLinks or @animator.draws is 1
      @links.draw @contexts.links
    if force or @refreshAgents  or @animator.draws is 1
      @agents.draw @contexts.agents
    if @spotlightAgent?
      @drawSpotlight @spotlightAgent.position, @contexts.spotlight

  # Creates a spotlight effect on an agent, so we can follow it
  # throughout the model.
  #
  # Usage:
  #
  #     @setSpotlight breed.sample()
  #
  # To draw one of a random breed. Remove spotlight by passing `null`.
  #
  setSpotlight: (@spotlightAgent) ->
    console.log @spotlightAgent
    unless @spotlightAgent?
      u.clearContext @contexts.spotlight

  # Draws the spotlight.
  #
  drawSpotlight: (position, context) ->
    u.clearContext context
    u.fillContext context, [0, 0, 0, 0.6]
    context.beginPath()
    context.arc position.x, position.y, 3, 0, 2 * Math.PI, false
    context.fill()

  # ### Breeds

  # Three breed commands:
  #
  #     @patchBreeds ["streets", "buildings"]
  #     @agentBreeds ["embers", "fires"]
  #     @linkBreeds ["spokes", "rims"]
  #
  # will create 6 BreedSets:
  #
  #     @streets and @buildings
  #     @embers and @fires
  #     @spokes and @rims
  #
  # These BreedSets' `create` methods create subclasses of Agent/Link.
  # Use of <breed>.setDefault methods work as for agents/links,
  # creating default values for the breed set:
  #
  #     @embers.setDefault "color", [255, 0, 0]
  #
  # ..will set the default color for just the embers.
  #
  createBreeds: (list, type, agentClass, breedSet) ->
    breeds = []
    breeds.classes = {}
    breeds.sets = {}

    resetType = false

    for string in list
      if string is type
        @[type] = new breedSet agentClass, string
      else
        className = string.charAt(0).toUpperCase() + string.substr(1)
        breedClass = class @[className] extends agentClass
        breed = @[string] = # add @<breed> to local scope
          new breedSet breedClass, string, agentClass::breed # create subset agentSet

        breeds.push breed
        breeds.sets[string] = breed
        breeds.classes["#{string}Class"] = breedClass

    @[type].breeds = breeds

  patchBreeds: (list) ->
    @createBreeds list, 'patches', @Patch, @Patches

  agentBreeds: (list) ->
    @createBreeds list, 'agents', @Agent, @Agents

  linkBreeds: (list) ->
    @createBreeds list, 'links', @Link, @Links
