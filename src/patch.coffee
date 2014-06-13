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
  # * pRectangle:  cached rect for performance

  id: null              # unique id, promoted by agentset create factory method
  breed: null           # set by the agentSet owning this patch
  x: null               # The patch position in the patch grid
  y: null
  color: [0, 0, 0]      # The patch color
  hidden: false         # draw me?
  label: null           # text for the patch
  labelColor: [0, 0, 0] # text color
  labelOffset: [0, 0]   # text offset from the patch center
  pRectangle: null      # Performance: cached rect of neighborhood larger than n.
  neighborsCache: {}    # Access through neighbors()
  
  # New Patch: Just set x, y.
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
    breed.create number, (agent) => # fat arrow so that @ = this patch
      agent.setXY @x, @y
      init(agent)
      agent

  # Get neighbors for patch
  neighbors: (rangeOptions) ->
    rangeOptions ?= 1
    neighbors = @neighborsCache[range]
    if not neighbors?
      if rangeOptions.diamond?
        range = rangeOptions.diamond
        neighbors = @breed.patchRectangleNullPadded @, range, range, true
        diamond = []
        counter = 0
        row = 0
        column = -1
        span = range * 2 + 1
        for neighbor in neighbors
          row = counter % span
          if row == 0
            column += 1
          distanceColumn = Math.abs(column - range)
          distanceRow = Math.abs(row - range)
          if distanceRow + distanceColumn <= range and distanceRow + distanceColumn != 0
            diamond.push neighbor
          counter += 1
        u.remove(diamond, null)
        neighbors = @breed.asSet diamond
      else
        neighbors = @breed.patchRectangle @, rangeOptions, rangeOptions

      @neighborsCache[rangeOptions] = neighbors
    return neighbors
