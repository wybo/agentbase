# A *very* simple shapes module for drawing
# [NetLogo-like](http://ccl.northwestern.edu/netlogo/docs/) agents.
u = ABM.util # alias for util module

ABM.shapes = s = # s alias below for ABM.shapes
  # Each shape is a named object with two members: 
  # a boolean "rotate" and a drawing procedure.
  # The shape is used in the following context with a color set
  # and a transform such that the shape should be drawn in a -.5 to .5 square
  #
  #     ctx.save()
  #     ctx.fillStyle = u.colorStr @color
  #     ctx.translate @x, @y; ctx.scale @size, @size;
  #     ctx.rotate @heading if shape.rotate
  #     ctx.beginPath()
  #     shape.draw(ctx)
  #     ctx.closePath()
  #     ctx.fill()
  #     ctx.restore()
  #
  # The list of current shapes, via `ABM.shapes.names()` below, is:
  #
  #     ["default", "triangle", "arrow", "bug", "pyramid", 
  #      "circle", "square", "pentagon", "ring", "person"]
  #
  
  default:
    rotate: true
    draw: (c) -> s.poly c, [[.5,0],[-.5,-.5],[-.25,0],[-.5,.5]]
  triangle:
    rotate: true
    draw: (c) -> s.poly c, [[.5,0],[-.5,-.4],[-.5,.4]]
  arrow:
    rotate: true
    draw: (c) -> s.poly c, [[.5,0],[0,.5],[0,.2],[-.5,.2],[-.5,-.2],[0,-.2],[0,-.5]]
  bug:
    rotate: true
    draw: (c) ->
      PI = Math.PI
      c.strokeStyle = c.fillStyle; c.lineWidth = .05
      c.moveTo .4,.225; c.lineTo .2,0; c.lineTo .4, -.225
      c.stroke()
      c.beginPath()
      c.arc .12,0,.13,0,2*PI; c.arc -.05,0,.13,0,2*PI; c.arc -.27,0,.2,0,2*PI
  pyramid:
    rotate: false
    draw: (c) -> s.poly c, [[0,.5],[-.433,-.25],[.433,-.25]]
  circle:
    rotate: false
    draw: (c) -> c.arc 0,0,.5,0,2*Math.PI
  square:
    rotate: false
    draw: (c) -> c.fillRect -.5,-.5,1,1
  pentagon:
    rotate: false
    draw: (c) -> s.poly c, [[0,.45],[-.45,.1],[-.3,-.45],[.3,-.45],[.45,.1]]
  ring:
    rotate: false
    draw: (c) ->
      c.arc 0,0,.5,0,2*Math.PI,true;c.closePath();c.arc 0,0,.3,0,2*Math.PI,false
  person:
    rotate: false
    draw: (c) ->
      s.poly c, [  [.15,.2],[.3,0],[.125,-.1],[.125,.05],
      [.1,-.15],[.25,-.5],[.05,-.5],[0,-.25],
      [-.05,-.5],[-.25,-.5],[-.1,-.15],[-.125,.05],
      [-.125,-.1],[-.3,0],[-.15,.2]  ]
      c.closePath(); c.arc 0,.35,.15,0,2*Math.PI
  # Return a list of the available shapes, see above.
  names: ->
    (name for own name, val of @ when !ABM.util.isFunction val)
  # Add your own shape. Will be included in names list.  Usage:
  #
  #     ABM.shapes.add "test", true, (c) -> # bowtie/hourglass
  #       ABM.shapes.poly c, [[-.5,-.5],[.5,.5],[-.5,.5],[.5,-.5]]
  add: (name, rotate, draw) -> @[name] = {rotate,draw}
  # A simple polygon utility:  c is the 2D context, and a is an array of 2D points.
  # c.closePath() and c.fill() will be called by the calling agent, see initial 
  # discription of drawing context.  It is used in adding a new shape above.
  poly: (c, a) ->
    for p, i in a 
      if i is 0 then c.moveTo p[0], p[1] else c.lineTo p[0], p[1]
    null
  
  # Create an image ctx of a shape by drawing it into a small canvas.
  # Used to implement agent sprites.
  shapeToCtx: (name, color, scale) ->
    shape = @[name]
    can = document.createElement 'canvas'
    can.width = can.height = scale
    ctx = can.getContext "2d"
    ctx.scale scale, scale
    ctx.translate .5, .5
    ctx.fillStyle = u.colorStr color
    ctx.beginPath()
    shape.draw ctx
    ctx.closePath()
    ctx.fill()
    ctx
    

