# ### Link
  
# Class Link connects two agent endpoints for graph modeling.
class ABM.Link
  # Constructor initializes instance variables:
  #
  # * id:         unique identifier, promoted by agentset create() factory method
  # * breed:      the agentset this agent belongs to
  # * end1, end2: two agents being connected
  # * color:      defaults to light gray
  # * thickness:  thickness in pixels of the link, default 2
  # * label:      a text label drawn on my instances
  # * labelColor: the color of my label text
  # * labelOffset:the x, y offset of my label from my x, y location
  # * hidden:     whether or not to draw this link

  id: null               # unique id, promoted by agentset create factory method
  breed: null            # my agentSet, set by the agentSet owning me
  end1:null; end2:null   # My two endpoints, using agents. Promoted by ctor
  color: [130, 130, 130] # my color
  thickness: 2           # my thickness in pixels, default to 2
  hidden: false          # draw me?
  label: null            # my text
  labelColor: [0, 0, 0]  # its color
  labelOffset: [0, 0]    # its offset from my midpoint
  constructor: (@end1, @end2) ->
    if @end1.links?
      @end1.links.push @
      @end2.links.push @
      
  # Draw a line between the two endpoints.  Draws "around" the
  # torus if appropriate using two lines. As with Agent.draw,
  # is called with patch coordinate transform installed.
  draw: (context) ->
    context.save()
    context.strokeStyle = u.colorString @color
    context.lineWidth = ABM.patches.fromBits @thickness
    context.beginPath()
    if !ABM.patches.isTorus
      context.moveTo @end1.x, @end1.y
      context.lineTo @end2.x, @end2.y
    else
      pt = @end1.closestTorusPoint @end2
      context.moveTo @end1.x, @end1.y
      context.lineTo pt...
      if pt[0] isnt @end2.x or pt[1] isnt @end2.y
        pt = @end2.closestTorusPoint @end1
        context.moveTo @end2.x, @end2.y
        context.lineTo pt...
    context.closePath()
    context.stroke()
    context.restore()
    if @label?
      x0 = u.linearInterpolate @end1.x, @end2.x, .5
      y0 = u.linearInterpolate @end1.y, @end2.y, .5
      [x, y] = ABM.patches.patchXYtoPixelXY x0, y0
      u.contextDrawText context, @label, x + @labelOffset[0], y + @labelOffset[1], @labelColor
  
  # Remove this link from the agent set
  die: ->
    @breed.remove @
    u.remove @end1.links, @ if @end1.links?
    u.remove @end2.links, @ if @end2.links?
    null
  
  # Return the two endpoints of this link
  bothEnds: -> [@end1, @end2]
  
  # Return the distance between the endpoints with the current topology.
  length: -> @end1.distance @end2
  
  # Return the other end of the link, given an endpoint agent.
  # Assumes the given input *is* one of the link endpoint pairs!
  otherEnd: (a) -> if @end1 is a then @end2 else @end1
