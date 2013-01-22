# Class Model is the control center for our AgentSets: Patches, Agents and Links.
# Creating new models is done by subclassing class Model and overriding two 
# virtual/abstract methods: `setup()` and `step()`

# The usual alias for **ABM.util**.
u = ABM.util

# ### Class Model

class ABM.Model
  # Constructor: 
  #
  # * create agentsets, install them and ourselves in ABM global namespace
  # * create layers/contexts, install drawing layer in ABM global namespace
  # * setup patch coord transforms for each layer context
  # * intialize various instance variables
  # * call `setup` abstract method
  constructor: (div, pSize, pMinX, pMaxX, pMinY, pMaxY, isTorus=true, topLeft=[10,10]) ->
    ABM.model = @
    @patches = ABM.patches = new ABM.Patches pSize, pMinX, pMaxX, pMinY, pMaxY, isTorus
    @agents = ABM.agents = new ABM.Agents
    @links = ABM.links = new ABM.Links
    
    # Create 4 2D canvas contexts layered on top of each other.
    layers = for i in [0..3] # multi-line array comprehension
      u.createLayer div, topLeft..., @patches.bitWidth(), @patches.bitHeight(), i, "2d"
    # One of the layers is used for drawing only, not an agentset:
    @drawing = ABM.drawing = layers[1]

    # Initialize a patch coord transform for each layer.<br>
    # Note: this is permanent .. there is no ctx.restore() call.<br>
    # To use the original canvas 2D transform temporarily:
    #
    #     ctx.save()
    #     ctx.setTransform(1, 0, 0, 1, 0, 0) # reset to identity
    #       <draw in native coord system>
    #     ctx.restore() # restore back to patch coord system
    for ctx in layers # install permenant (no ctx.restore) patch coordinates
      ctx.save()
      ctx.scale @patches.size, -@patches.size
      ctx.translate -(@patches.minX-.5), -(@patches.maxY+.5); 
    # Create instance variable object with names for each layer
    @contexts =
      patches: layers[0]
      drawing: layers[1]
      links:   layers[2]
      agents:  layers[3]
    # Set a variable in each context with its name 
    v.agentSetName = k for k,v of @contexts
    
    # Initialize instance variables
    @showFPS = true # show fps in console
    @ticks = 1 # initial tick/frame
    @refreshLinks = @refreshAgents = @refreshPatches = true # drawing flags

    # Call the models setup function.
    @setup()

  # Return string name for agentset.  Note this depends on our
  # using a singleton naming convension: foo = new Foo(...)
  agentSetName: (aset) -> aset.constructor.name.toLowerCase()
  # Set the text parameters for an agentset's context.  See ABM.util
  setTextParams: (agentSetName, domFont, align="center", baseline="middle") ->
    agentSetName = @agentSetName(agentSetName) if typeof agentSetName isnt "string"
    u.canvasTextParams @contexts[agentSetName], domFont, align, baseline
  # Set the label parameters for an agentset's context.  See ABM.util
  setLabelParams: (agentSetName, color, xy) ->
    agentSetName = @agentSetName(agentSetName) if typeof agentSetName isnt "string"
    u.canvasLabelParams @contexts[agentSetName], color, xy
  
  # The two abstract methods overridden by subclasses
  setup: ->
  step: ->
  
  # The animation routines. start/stop animation, increment ticks.
  start: ->
    @startMS = Date.now()
    @startTick = @ticks
    @animStop = false
    @animate()
  stop: -> @animStop = true
  animate: => # note fat arrow, animate bound to "this"
    @step()
    @draw()
    @tick() # Note: NL difference, called here not in user's step()
    requestAnimFrame @animate unless @animStop
  tick: ->
    animTicks = @ticks-@startTick
    if @showFPS and (animTicks % 100) is 0 and animTicks isnt 0
      fps = Math.round (animTicks*1000/(Date.now()-@startMS))
      console.log "fps: #{fps} at #{animTicks} ticks"
    @ticks++

  # Two very primitive versions of NL's `breed` commands.
  #
  #     @linkBreeds "spokes rims"
  #     @agentBreeds "embers fires"
  #
  # will create dynamic methods: <br>
  # @spokes() and @rims() which return links with
  # their breed set to either "spokes" or "rims", and <br>
  # @embers() and @fires()
  # which return agents with their breeds set to "embers" or "fires"
  linkBreeds: (s) ->
    for b in s.split(" ")
      @[b] = do(b) =>
       -> @links.breed(b)
  agentBreeds: (s) ->
    for b in s.split(" ")
      @[b] = do(b) =>
       -> @agents.breed(b)

  # call the agentset draw methods if either the first call or
  # their "refresh" flags are set.  The latter are simple optimizations
  # to avoid redrawing the same scene.
  draw: ->
    @patches.draw @contexts.patches  if @refreshPatches or @ticks is 1
    @links.draw   @contexts.links    if @refreshLinks   or @ticks is 1
    @agents.draw  @contexts.agents   if @refreshAgents  or @ticks is 1
  
  # Utility for models to create agentsets from arrays.  Ex:
  #
  #     even = @asSet (a for a in @agents when a.id % 2 is 0)
  #     even.shuffle().getProp("id") # [6, 0, 4, 2, 8]
  asSet: (a) -> # turns an array into an agent set
    ABM.AgentSet.asSet(a)

  # A simple debug aid which places short names in the global name space.
  # Note we avoid using the actual name, such as "patches" because this
  # can cause our modules to mistakenly depend on a global name.
  # See [CoffeeConsole](http://goo.gl/1i7bd) Chrome extension too.
  setRootVars: ->
    ABM.root.ps = @patches
    ABM.root.as = @agents
    ABM.root.ls = @links
    ABM.root.dr = @drawing
    ABM.root.u = ABM.util
    ABM.root.app = @
    ABM.root.cx = @contexts
    ABM.root.cl = (o) -> console.log o
    ABM.root.cla = (array) -> console.log a for a in array
    null
  
