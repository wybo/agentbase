
# addEventListener: http://goo.gl/dq0nN
class ABM.Mouse
  constructor: (divName, @callback) ->
    @div = document.getElementById divName
    @lastX=Infinity; @lastY=Infinity
    @start()
  start: -> # Note: multiple calls safe
    @div.addEventListener("mousedown", @handleMouseDown, false)
    document.body.addEventListener("mouseup", @handleMouseUp, false)
    @div.addEventListener("mousemove", @handleMouseMove, false)
    @lastX=@lastY=@x=@y=@pixX=@pixY=NaN; @moved=@down=false
  stop: -> # Note: multiple calls safe
    @div.removeEventListener("mousedown", @handleMouseDown, false)
    document.body.removeEventListener("mouseup", @handleMouseUp, false)
    @div.removeEventListener("mousemove", @handleMouseMove, false)
    @lastX=@lastY=@x=@y=@pixX=@pixY=NaN; @moved=@down=false
  handleMouseDown: (e) => @down=true; @setXY e
  handleMouseUp: => @down=false
  handleMouseMove: (e) => @setXY e
  setXY: (e) ->
    @lastX = @x; @lastY = @y
    @pixX = e.offsetX; @pixY = e.offsetY
    [@x, @y] = ABM.patches.pixelXYtoPatchXY(@pixX,@pixY)
    @moved = (@x isnt @lastX) or (@y isnt @lastY)
    @callback(e) if @callback?
