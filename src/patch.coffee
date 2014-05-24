# ### Patch
  
# Class Patch instances represent a rectangle on a grid.  They hold variables
# that are in the patches the agents live on.  The set of all patches (ABM.patches)
# is the world on which the agents live and the model runs.
class ABM.Patch
  # Constructor & Class Variables:
  # * id:          unique identifier, promoted by agentset create() factory method
  # * breed:       the agentset this agent belongs to
  # * x, y:        position on the patch grid, in patch coordinates
  # * color:       the color of the patch as an RGBA array, A optional.
  # * hidden:      whether or not to draw this patch
  # * label:       text for the patch
  # * labelColor:  the color of my label text
  # * labelOffset: the x, y offset of my label from my x, y location
  # * neighbors:   adjacent neighbors: n: 8 patches, n4: N, E, S, W patches
  # * neighbors4: 
  # * pRectangle:  cached rect for performance
  #
  # Patches may not need their neighbors, thus we use a default
  # of none.  n and n4 are promoted by the Patches agent set 
  # if world.neighbors is true, the default.

  id: null              # unique id, promoted by agentset create factory method
  breed: null           # set by the agentSet owning this patch
  x: null               # The patch position in the patch grid
  y: null
  neighbors: null       # The neighbors, n: 8, n4: 4. null OK if model doesn't need them.
  neighbors4: null
  color: [0, 0, 0]      # The patch color
  hidden: false         # draw me?
  label: null           # text for the patch
  labelColor: [0, 0, 0] # text color
  labelOffset: [0, 0]   # text offset from the patch center
  pRectangle: null      # Performance: cached rect of neighborhood larger than n.
  
  # New Patch: Just set x, y. Neighbors set by Patches constructor if needed.
  constructor: (@x, @y) ->

  # Return a string representation of the patch.
  toString: -> "{id:#{@id} xy:#{[@x, @y]} c:#{@color}}"

  # Set patch color to `c` scaled by `fraction`. Usage:
  #
  #     patch.fractionOfColor patch.color, .8 # reduce patch color by .8
  #     patch.fractionOfColor @foodColor, patch.foodPheromone # ants model
  #
  # Promotes color if currently using the default.
  fractionOfColor: (color, fraction) ->
    @color = u.clone @color unless @.hasOwnProperty("color")
    u.fractionOfColor color, fraction, @color
  
  # Draw the patch and its text label if there is one.
  draw: (context) ->
    context.fillStyle = u.colorString @color
    context.fillRect @x - .5, @y - .5, 1, 1
    if @label? # REMIND: should be 2nd pass.
      [x, y] = @breed.patchXYtoPixelXY @x, @y
      u.contextDrawText context, @label, x + @labelOffset[0], y + @labelOffset[1],
        @labelColor
  
  # Return an array of the agents on this patch.
  # If patches.cacheAgentsHere has created an @agents instance
  # variable for the patches, agents will add/remove themselves
  # as they move from patch to patch.
  agentsHere: ->
    @agents ? (a for a in ABM.agents when a.p is @)
  # TODO refactor

  empty: ->
    u.empty @agentsHere() # TODO from array

  # Returns true if this patch is on the edge of the grid.
  isOnEdge: ->
    @x is @breed.minX or @x is @breed.maxX or \
    @y is @breed.minY or @y is @breed.maxY
  
  # Factory: Create num new agents on this patch. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  sprout: (number = 1, breed = ABM.agents, init = ->) ->
    console.log("sprouting")
    console.log(number)
    breed.create number, (agent) => # fat arrow so that @ = this patch
      agent.setXY @x, @y
      init(agent)
      agent
