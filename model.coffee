# Class Model is the control center for our AgentSets: Patches, Agents and Links.

# The usual alias for **ABM.util**.
u = ABM.util

# ### Class Model

class ABM.Model
  constructor: (div, pSize, pMinX, pMaxX, pMinY, pMaxY, isTorus=true) ->
    ABM.model = @
    @patches = ABM.patches = new ABM.Patches pSize, pMinX, pMaxX, pMinY, pMaxY, isTorus
    @agents = ABM.agents = new ABM.Agents
    @links = ABM.links = new ABM.Links
    @debug = true # mainly fps in console
    @ticks = 1
    @refreshLinks = @refreshAgents = @refreshPatches = true
    @layers = for i in [0..3] # multi-line array comprehension
      u.createLayer div, 10, 10, @patches.bitWidth(), @patches.bitHeight(), i, "2d"
    for ctx in @layers # install permenant (no ctx.restore) patch coordinates
      ctx.save()
      ctx.scale @patches.size, -@patches.size
      ctx.translate -(@patches.minX-.5), -(@patches.maxY+.5); 
    @drawing = ABM.drawing = @layers[1]
    @contexts = # remind: make layers local?
      patches: @layers[0]
      drawing: @layers[1]
      agents: @layers[2]
      links: @layers[3]
    v.agentSetName = k for k,v of @contexts
    @setup()

  agentSetName: (aset) ->
    if aset is @patches then return "patches"
    else if aset is @agents then return "agents"
    else if aset is @links then return "links"
    else if aset is @drawing then return "drawing"
    null # Catch errors, return null
    
  setTextParams: (agentSetName, domFont, align="center", baseline="middle") ->
    agentSetName = @agentSetName(agentSetName) if typeof agentSetName isnt "string"
    u.canvasTextParams @contexts[agentSetName], domFont, align, baseline
  setLabelParams: (agentSetName, color, xy) ->
    agentSetName = @agentSetName(agentSetName) if typeof agentSetName isnt "string"
    u.canvasLabelParams @contexts[agentSetName], color, xy
    
  setup: ->
  step: ->
    
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
    if @debug and (animTicks % 100) is 0 and animTicks isnt 0
      fps = Math.round (animTicks*1000/(Date.now()-@startMS))
      console.log "#{animTicks}: #{fps}"
    @ticks++

  linkBreeds: (s) ->
    for b in s.split(" ")
      @[b] = do(b) =>
       -> @links.breed(b)
  agentBreeds: (s) ->
    for b in s.split(" ")
      @[b] = do(b) =>
       -> @agents.breed(b)
  # setDefaultBreedShape: (breed, shape) ->
  #   @[breed].defaultShape = shape
    
  draw: ->
    @patches.draw @layers[0] if @refreshPatches or @ticks is 1
    @links.draw @layers[2]   if @refreshLinks or @ticks is 1
    @agents.draw @layers[3]  if @refreshAgents or @ticks is 1
  
  setRootVars: -> # for debugging, avoid std names, confuses existing code
    ABM.root.ps = @patches
    ABM.root.as = @agents
    ABM.root.ls = @links
    ABM.root.dr = @drawing
    ABM.root.u = ABM.util
    ABM.root.app = @
    ABM.root.co = @contexts #ctx object/hash
    ABM.root.ca = @layers   # ctx array
  
  # observer:
  asSet: (a) -> # turns an array into an agent set
    ABM.AgentSet.asSet(a)
