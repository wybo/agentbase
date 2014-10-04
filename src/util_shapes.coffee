# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# A *very* simple shapes module for drawing
# [NetLogo-like](http://ccl.northwestern.edu/netlogo/docs/) agents.

# Each shape is a named object with two members:
# a boolean rotate and a draw procedure and two optional
# properties: image for images, and shortcut for a transform-less version of draw.
# The shape is used in the following context with a color set
# and a transform such that the shape should be drawn in a -.5 to .5 square
#
#     context.save()
#     context.fillStyle = u.colorString color
#     context.translate x, y; context.scale size, size;
#     context.rotate heading if shape.rotate
#     context.beginPath(); shape.draw(context); context.closePath()
#     context.fill()
#     context.restore()
#
# The list of current shapes, via `u.shapes.names()` below, is:
#
#     ["default", "triangle", "arrow", "bug", "pyramid",
#       "circle", "square", "pentagon", "ring", "cup", "person"]
#
# @mixin # for codo doc generator
ABM.util.shapes =
  # A simple polygon utility: c is the 2D context, and a is an array
  # of 2D points; c.closePath() and c.fill() will be called by the
  # calling agent, see initial discription of drawing context. It is
  # used in adding a new shape above.
  #
  polygon: (context, array) ->
    for position, i in array
      if i is 0
        context.moveTo position[0], position[1]
      else
        context.lineTo position[0], position[1]

    null

  # Centered drawing primitives: centered on x, y with a given
  # width/height size. Useful for shortcuts.
  #
  centered_circle: (context, x, y, size) ->
    # centered circle
    context.arc x, y, size / 2, 0, 2 * Math.PI

  # Centered counter clockwise circle.
  #
  counter_centered_circle: (context, x, y, size) ->
    context.arc x, y, size / 2, 0, 2 * Math.PI, true

  # Centered image.
  #
  centered_image: (context, x, y, size, image) ->
    context.scale 1, -1
    context.drawImage image, x - size / 2, y - size / 2, size, size
    context.scale 1, -1

  # Centered square.
  #
  centered_square: (context, x, y, size) ->
    context.fillRect x - size / 2, y - size / 2, size, size

  # An async util for delayed drawing of images into sprite slots.
  #
  fillSlot: (slot, image) ->
    slot.context.save()
    slot.context.scale 1, -1
    slot.context.drawImage image, slot.x, -(slot.y + slot.spriteSize), slot.spriteSize, slot.spriteSize
    slot.context.restore()

  # The spritesheet data, indexed by spriteSize.
  #
  spriteSheets: new ABM.Array

  # The module returns the following object:
  #
  default:
    rotate: true
    draw: (context) ->
      u.shapes.polygon context, [[.5, 0], [-.5, -.5], [-.25, 0], [-.5, .5]]

  triangle:
    rotate: true
    draw: (context) ->
      u.shapes.polygon context, [[.5, 0], [-.5, -.4], [-.5, .4]]

  arrow:
    rotate: true
    draw: (context) ->
      u.shapes.polygon context, [[.5, 0], [0, .5], [0, .2], [-.5, .2], [-.5, -.2], [0, -.2], [0, -.5]]

  bug:
    rotate: true
    draw: (context) ->
      context.strokeStyle = context.fillStyle
      context.lineWidth = .05
      u.shapes.polygon context, [[.4, .225], [.2, 0], [.4, -.225]]
      context.stroke()
      context.beginPath()
      u.shapes.centered_circle context, .12, 0, .26
      u.shapes.centered_circle context, -.05, 0, .26
      u.shapes.centered_circle context, -.27, 0, .4

  pyramid:
    rotate: false
    draw: (context) ->
      u.shapes.polygon context, [[0, .5], [-.433, -.25], [.433, -.25]]

  circle: # Note: NetLogo's dot is simply circle with a small size
    shortcut: (context, x, y, size) ->
      context.beginPath()
      u.shapes.centered_circle context, x, y, size
      context.closePath()
      context.fill()
    rotate: false
    draw: (context) ->
      u.shapes.centered_circle context, 0, 0, 1 # c.arc 0, 0,.5, 0, 2 * Math.PI

  square:
    shortcut: (context, x, y, size) ->
      u.shapes.centered_square context, x, y, size
    rotate: false
    draw: (context) ->
      u.shapes.centered_square context, 0, 0, 1 #c.fillRect -.5, -.5, 1 , 1

  pentagon:
    rotate: false
    draw: (context) ->
      u.shapes.polygon context, [[0, .45], [-.45, .1], [-.3, -.45], [.3, -.45], [.45, .1]]

  ring:
    rotate: false
    draw: (context) ->
      u.shapes.centered_circle context, 0, 0, 1
      context.closePath()
      u.shapes.counter_centered_circle context, 0, 0, .6

  filledRing:
    rotate: false
    draw: (context) ->
      u.shapes.centered_circle(context, 0, 0, 1)
      tempStyle = context.fillStyle # save fill style
      context.fillStyle = context.strokeStyle # use stroke style for larger circle
      context.fill()
      context.fillStyle = tempStyle
      context.beginPath()
      u.shapes.centered_circle(context, 0, 0, 0.8)

  person:
    rotate: false
    draw: (context) ->
      u.shapes.polygon context, [
        [.15, .2], [.3, 0], [.125, -.1], [.125, .05], [.1, -.15], [.25, -.5],
        [.05, -.5], [0, -.25], [-.05, -.5], [-.25, -.5], [-.1, -.15],
        [-.125, .05], [-.125, -.1], [-.3, 0], [-.15, .2]
      ]
      context.closePath()
      u.shapes.centered_circle context, 0, .35, .30

  # Return a list of the available shapes, see above.
  names: ->
    array = new ABM.Array
    for own name, value of @
      if value.rotate? and value.draw?
        array.push name
    array

  # Add your own shape. Will be included in names list.
  #
  # Usage:
  #
  #     u.shapes.add "test", true, (c) -> # bowtie/hourglass
  #       u.shapes.polygon c, [[-.5, -.5], [.5, .5], [-.5, .5], [.5, -.5]]
  #
  # Note: an image that is not rotated automatically gets a shortcut.
  #
  add: (name, rotate, draw, shortcut) -> # draw can be an image, shortcut defaults to null
    if u.isFunction draw
      shape = {rotate, draw}
    else
      shape = {rotate, image:draw, draw:(context) ->
        @centered_image context, .5, .5, 1, @image}

    @[name] = shape

    if shortcut? # can override image default shortcut if needed
      shape.shortcut = shortcut
    else if shape.image? and not shape.rotate
      shape.shortcut = (context, x, y, size) ->
        @centered_image context, x, y, size, @image

  # Two draw procedures, one for shapes, the other for sprites made
  # from shapes.
  #
  draw: (context, shape, x, y, size, rad, color, strokeColor) ->
    if shape.shortcut?
      unless shape.image?
        context.fillStyle = u.colorString color
      shape.shortcut context, x, y, size
    else
      context.save()
      context.translate x, y
      context.scale size, size if size isnt 1
      context.rotate rad if rad isnt 0
      if shape.image? # is an image, not a path function
        shape.draw context
      else
        context.fillStyle = u.colorString color
        if strokeColor
          context.strokeStyle = u.colorStr strokeColor
          context.lineWidth = 0.05
        context.save()
        context.beginPath()
        shape.draw context
        context.closePath()
        context.restore()
        context.fill()
        context.stroke() if strokeColor

      context.restore()
    shape

  drawSprite: (context, slot, x, y, size, radians) ->
    if radians is 0
      context.drawImage slot.context.canvas, slot.x, slot.y, slot.spriteSize,
        slot.spriteSize, x - size / 2, y - size / 2, size, size
    else
      context.save()
      context.translate x, y # see http://goo.gl/VUlhY for drawing centered rotated images
      context.rotate radians
      context.drawImage slot.context.canvas, slot.x, slot.y, slot.spriteSize,
        slot.spriteSize, -size / 2, -size / 2, size, size
      context.restore()
    slot

  # Convert a shape to a sprite by allocating a sprite sheet "slot"
  # and drawing the shape to fit it. Return existing sprite if
  # duplicate.
  #
  shapeToSprite: (name, color, size, strokeColor) ->
    spriteSize = Math.ceil size
    strokePadding = 4
    slotSize = spriteSize + strokePadding
    shape = @[name]
    if shape.image?
      index = name
    else
      index = "#{name}-#{u.colorString(color)}"
    context = @spriteSheets[slotSize]

    # Create sheet for this bit size if it does not yet exist
    unless context?
      @spriteSheets[slotSize] = context = u.createContext slotSize * 10, slotSize
      context.nextX = 0
      context.nextY = 0
      context.index = {}

    # Return matching sprite if index match found
    return foundSlot if (foundSlot = context.index[index])?

    # Extend the sheet if we're out of space
    if slotSize * context.nextX is context.canvas.width
      u.resizeContext context, context.canvas.width, context.canvas.height + slotSize
      context.nextX = 0
      context.nextY++

    # Create the sprite "slot" object and install in index object
    x =  slotSize * context.nextX + strokePadding / 2
    y =  slotSize * context.nextY + strokePadding / 2
    slot = {context, x, y, size, spriteSize, name, color, strokeColor, index}
    context.index[index] = slot

    # Draw the shape into the sprite slot
    if shape.image? # is an image, not a path function
      if shape.image.height isnt 0
        @fillSlot(slot, shape.image)
      else
        shape.image.onload = ->
          @fillSlot(slot, shape.image)
    else
      context.save()
      context.translate (context.nextX + 0.5) * (slotSize),
        (context.nextY + 0.5) * (slotSize)
      context.scale spriteSize, spriteSize
      context.fillStyle = u.colorString color

      if strokeColor
        context.strokeStyle = u.colorString strokeColor
        context.lineWidth = 0.05

      context.save()
      context.beginPath()
      shape.draw context
      context.closePath()
      context.restore()
      context.fill()

      if strokeColor
        context.stroke()

      context.restore()

    context.nextX++

    slot

# Dummy class for codo doc generator.
#
# @include ABM.util.shapes
class ABM.Util.Shapes
