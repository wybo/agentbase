# Class Model is the control center for our AgentSets: Patches, Agents and Links.
# Creating new models is done by subclassing class Model and overriding two 
# virtual/abstract methods: `setup()` and `step()`

# The usual alias for **ABM.util**.
u = ABM.util

# Because not all models have the same amimator requirements, we build a class
# for customization by the programmer.  See these URLs for more info:
#
# * [JavaScript timers doc](https://developer.mozilla.org/en-US/docs/JavaScript/Timers)
# * [Using timers & requestAnimFrame together](http://goo.gl/ymEEX)
# * [John Resig on timers](http://goo.gl/9Q3q)
# * [jsFiddle setTimeout vs rAF](http://jsfiddle.net/calpo/H7EEE/)
# * [Timeout tutorial](http://javascript.info/tutorial/settimeout-setinterval)
# * [Events and timing in depth](http://javascript.info/tutorial/events-and-timing-depth)
class ABM.Animator
  constructor: (@model, @rate=30, @multiStep=false) -> # rate/multiStep arbitrary hint to animate()
    @ticks = @draws = 0
    @animHandle = @timerHandle = @intervalHandle = null
    @animStop = true
  setRate: (@rate, @multiStep=false) -> @reset()
  start: ->
    if not @animStop then return # avoid multiple animates
    @reset()
    @animStop = false
    @animate()
  reset: ->
    @startMS = @now()
    @startTick = @ticks
    @startDraw = @draws
  stop: ->
    @animStop = true
    if @animHandle? then cancelAnimFrame @animHandle
    if @timeoutHandle? then clearTimeout @timeoutHandle
    if @intervalHandle? then clearInterval @intervalHandle
    @animHandle = @timerHandle = @intervalHandle = null
  step: -> @ticks++; @model.step()
  draw: -> @draws++; @model.draw()
  once: -> @step(); @draw() # Take one step .. debugging
  now: -> (performance ? Date).now()
  ms: -> @now()-@startMS
  ticksPerSec: -> if (elapsed = @ticks-@startTick) is 0 then 0 else Math.round elapsed*1000/@ms()
  drawsPerSec: -> if (elapsed = @draws-@startDraw) is 0 then 0 else Math.round elapsed*1000/@ms()
  toString: -> "ticks: #{@ticks}, draws: #{@draws}, rate: #{@rate} #{@ticksPerSec()}/#{@drawsPerSec()}"
  animateSteps: =>
    @step()
    @timeoutHandle = setTimeout @animateSteps, 10 unless @animStop
  animateDraws: =>
    if @drawsPerSec() <= @rate
      @step() if not @multiStep
      @draw()
    @animHandle = requestAnimFrame @animateDraws unless @animStop
  animate: ->
    if @multiStep
      @animateSteps()
    @animateDraws()

# ### Class Model

class ABM.Model  
  # Constructor: 
  #
  # * create agentsets, install them and ourselves in ABM global namespace
  # * create layers/contexts, install drawing layer in ABM global namespace
  # * setup patch coord transforms for each layer context
  # * intialize various instance variables
  # * call `setup` abstract method
  
  # Class variable for layers parameters. 
  # Can be added to by programmer to modify/create layers.
  contextsInit: {
    patches:   {z:0, ctx:"2d"}
    drawing:   {z:1, ctx:"2d"}
    links:     {z:2, ctx:"2d"}
    agents:    {z:3, ctx:"2d"}
    spotlight: {z:4, ctx:"2d"}
  }
  constructor: (
    div, size, minX, maxX, minY, maxY,
    torus=true, neighbors=true
  ) ->
    ABM.model = @
    @contexts = ABM.contexts = {}
    
    # Create 2D canvas contexts layered on top of each other.<br>
    # Initialize a patch coord transform for each layer.<br>
    # Note: this is permanent .. there is no ctx.restore() call.<br>
    # To use the original canvas 2D transform temporarily:
    #
    #     ctx.save()
    #     ctx.setTransform(1, 0, 0, 1, 0, 0) # reset to identity
    #       <draw in native coord system>
    #     ctx.restore() # restore back to patch coord system
    
    for own k,v of @contextsInit
      @contexts[k] = ctx =
        u.createLayer div, size*(maxX-minX+1), size*(maxY-minY+1), v.z, v.ctx
      ctx.save()
      ctx.scale size, -size
      ctx.translate -(minX-.5), -(maxY+.5)
      ctx.agentSetName = k # Set a variable in each context with its name

    # Initialize agentsets.
    @patches = ABM.patches = \
      new ABM.Patches size,minX,maxX,minY,maxY,torus,neighbors
    @agents = ABM.agents = new ABM.Agents ABM.Agent, "agents"
    @links = ABM.links = new ABM.Links ABM.Link, "links"
    # One of the layers is used for drawing only, not an agentset:
    @drawing = ABM.drawing = @contexts.drawing
    # Setup spotlight layer, also not an agentset:
    @contexts.spotlight.globalCompositeOperation = "xor"

    # Initialize instance variables
    @anim = new ABM.Animator(@)
    @refreshLinks = @refreshAgents = @refreshPatches = true # drawing flags
    @fastPatches = false
    
    # Call the models setup function.
    @setup()
    
    # Postprocesssing after setup
    if @agents.useSprites
      @agents.setDefaultSprite() if ABM.Agent::color?
      for a in @agents when not a.hasOwnProperty "sprite"
        if a.hasOwnProperty "color" or a.hasOwnProperty "shape" or a.hasOwnProperty "size"
          a.sprite = ABM.shapes.shapeToImage a.shape, a.color, a.size*@patches.size
    

#### Optimizations:

  # Modelers "tune" their model by adjusting flags:<br>
  # `@refreshLinks, @refreshAgents, @refreshPatches`<br>
  # and by the following methods:

  # Draw patches using scaled image of colors. Note anti-aliasing may occur
  # if browser does not support imageSmoothingEnabled or equivalent.
  setFastPatches: ->
    ctx = @contexts.patches
    ctx.imageSmoothingEnabled = false
    ctx.mozImageSmoothingEnabled = false
    ctx.webkitImageSmoothingEnabled = false
    ctx.save() # revert to native 2D transform
    ctx.setTransform 1, 0, 0, 1, 0, 0
    @patches.drawWithPixels = true

  # Have agents use images (sprites) rather than drawing for agents.
  setAgentsUseSprites: ->
    @agents.setUseSprites(true)
    
  # Have patches cache the agents currently on them.
  # Optimizes Patch p.agentsHere method
  setCacheAgentsHere: ->
    p.agents = [] for p in @patches
    a.p.agents.push a for a in @agents
  
  # Have agents cache the links with them as a node.
  # Optimizes Agent a.myLinks method
  setCacheMyLinks: ->
    @links.cacheAgentLinks = true
    a.links = [] for a in @agents # not needed if called b4 any agents & links made
    (l.end1.links.push l; l.end2.links.push l) for l in @links
  
  # Have patches cache the given patchRect.
  # Optimizes patchRect, inRadius and inCone
  setCachePatchRects: (radius, meToo=false) ->
    for p in @patches
      p.pRect = @patches.patchRect p, radius, radius, meToo
      p.pRect.radius = radius
      p.pRect.meToo = meToo
  
  # Ask agents to cache their color strings.
  # This is a temporary optimization and will likely change.
  setAgentStaticColors: ->
    @agents.setStaticColors(true)

#### Text Utilities:

  # Return context name for agentset
  agentSetCtxName: (aset) ->
    aset = aset.mainSet if aset.mainSet? # breeds->mainSet
    aset.constructor.name.toLowerCase()
  # Set the text parameters for an agentset's context.  See ABM.util<br>
  # `agentSetName` can be a key in @contexts or an agentset itself
  setTextParams: (agentSetName, domFont, align="center", baseline="middle") ->
    agentSetName = @agentSetCtxName(agentSetName) if typeof agentSetName isnt "string"
    u.error "setTextParams: #{@agentSetName} not fount." if not @contexts[agentSetName]?
    u.ctxTextParams @contexts[agentSetName], domFont, align, baseline
  setLabelParams: (agentSetName, color, xy) ->
    agentSetName = @agentSetCtxName(agentSetName) if typeof agentSetName isnt "string"
    u.error "setLabelParams: #{@agentSetName} not fount." if not @contexts[agentSetName]?
    u.ctxLabelParams @contexts[agentSetName], color, xy
  
#### User Model Creation
# A user's model is made by subclassing Model and over-riding these
# two abstract methods. `super` need not be called.

  # Initialize your model here
  setup: -> # called at the end of model creation
  # Update/step your model here
  step: -> # called each step of the animation
  # Start/stop the animation
  start: -> @anim.start()
  stop: -> @anim.stop()
  # Animate once by `step(); draw()`. For debugging from console.
  once: -> @anim.once() 

#### Animation. 

# Call the agentset draw methods if either the first draw call or
# their "refresh" flags are set.  The latter are simple optimizations
# to avoid redrawing the same static scene. Called by animator.
  draw: ->
    @patches.draw @contexts.patches  if @refreshPatches or @anim.draws is 1
    @links.draw   @contexts.links    if @refreshLinks   or @anim.draws is 1
    @agents.draw  @contexts.agents   if @refreshAgents  or @anim.draws is 1
    @drawSpotlight @spotlightAgent, @contexts.spotlight  if @spotlightAgent?

# Creates a spotlight effect on an agent, so we can follow it throughout the model.
# Use:
#
#     @setSpotliight breed.oneOf()
#
# to draw one of a random breed. Remove spotlight by passing `null`
  setSpotlight: (@spotlightAgent) ->
    u.clearCtx @contexts.spotlight if not @spotlightAgent?

  drawSpotlight: (agent, ctx) ->
    u.clearCtx ctx
    u.fillCtx ctx, [0,0,0,0.6]
    ctx.beginPath()
    ctx.arc agent.x, agent.y, 3, 0, 2*Math.PI, false
    ctx.fill()


#### Breeds
# Two versions of NL's `breed` commands.
#
#     @agentBreeds "embers fires"
#     @linkBreeds "spokes rims"
#
# will create 4 agentSets: 
#
#     @embers and @fires
#     @spokes and @rims 
#
# These agentset's `create` method create subclasses of Agent/Link.
# Use of <breed>.setDefault methods work as for agents/links, creating default
# values for the breed set:
#
#     @embers.setDefaultColor [255,0,0]
#
# ..will set the default color for just the embers.

  createBreeds: (s, breedClass, breedSet) ->
    breeds = []; breeds.classes = {}; breeds.sets = {}
    for b in s.split(" ")
      c = class Breed extends breedClass
      c::name = b
      @[b] = new breedSet c, b, breedClass::breed # add @<breed> to local scope
      breeds.push @[b]
      breeds.sets[b] = @[b]
      breeds.classes["#{b}Class"] = c
    breeds
  agentBreeds: (s) -> ABM.agentBreeds = @createBreeds s, ABM.Agent, ABM.Agents
  linkBreeds: (s) -> ABM.linkBreeds = @createBreeds s, ABM.Link, ABM.Links
  
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
    ABM.root.p0 = @patches[0]
    ABM.root.as = @agents
    ABM.root.a0 = @agents[0]
    ABM.root.ls = @links
    ABM.root.l0 = @links[0]
    ABM.root.dr = @drawing
    ABM.root.u  = u
    ABM.root.sh = ABM.shapes
    ABM.root.app = @
    ABM.root.cx = @contexts
    ABM.root.ab = ABM.agentBreeds
    ABM.root.lb = ABM.linkBreeds
    ABM.root.an = @anim
    null
  
