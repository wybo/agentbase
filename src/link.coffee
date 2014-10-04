# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Link connects two agent endpoints for graph modeling.
#
class ABM.Link
  # Unique ID, set by BreedSet create() factory method.
  id: null
  # The BreedSet this agent belongs to.
  breed: null
  # My two endpoints, using agents. The first one.
  from: null
  # The second endpoint.
  to: null
  # The links' color, an RGB array. Defaults to light gray.
  color: [130, 130, 130]
  # Thickness in pixels of the link.
  thickness: 2
  # Whether or not to draw this link.
  hidden: false
  # A text label
  label: null
  # The color of the label text.
  labelColor: [0, 0, 0]
  # The x, y offset of the label.
  labelOffset: {x: 0, y: 0}

  # Initializes instance variables.
  #
  constructor: (@from, @to) ->
    @from.links.push @
    @to.links.push @

  # Remove this link from the agent set.
  #
  die: ->
    @breed.remove @
    @from.links.remove @
    @to.links.remove @
    null

  # Return the two endpoints of this link.
  #
  bothEnds: ->
    new ABM.Array(@from, @to)

  # Return the distance between the endpoints with the current topology.
  #
  length: ->
    @from.distance @to.position

  # Return the other end of the link, given an endpoint agent.
  #
  # Assumes the given input *is* one of the link endpoint pairs!
  #
  otherEnd: (agent) ->
    if @from is agent
      @to
    else
      @from

  # Draw a line between the two endpoints. Draws "around" the
  # torus if appropriate using two lines. As with Agent.draw,
  # is called with patch coordinate transform installed.
  #
  draw: (context) ->
    context.save()
    context.strokeStyle = u.colorString @color
    context.lineWidth = @model.patches.fromBits @thickness
    context.beginPath()

    if !@model.patches.isTorus
      context.moveTo @from.position.x, @from.position.y
      context.lineTo @to.position.x, @to.position.y
    else
      point = u.closestTorusPoint @from.position, @to.position,
        @model.patches.width, @model.patches.height
      context.moveTo @from.position.x, @from.position.y
      context.lineTo point.x, point.y
      if point.x isnt @to.position.x or point.y isnt @to.position.y
        point = u.closestTorusPoint @to.position, @from.position,
          @model.patches.width, @model.patches.height
        context.moveTo @to.position.x, @to.position.y
        context.lineTo point.x, point.y

    context.closePath()
    context.stroke()
    context.restore()

    if @label?
      x0 = u.linearInterpolate @from.position.x, @to.position.x, .5
      y0 = u.linearInterpolate @from.position.y, @to.position.y, .5
      [x, y] = @model.patches.patchXYtoPixelXY x0, y0
      u.contextDrawText context, @label, x + @labelOffset[0], y + @labelOffset[1], @labelColor
