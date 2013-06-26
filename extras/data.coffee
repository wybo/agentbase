class ABM.DataSet
  # Static members
  @patchDataSet: (name) ->
    ps = ABM.patches
    new DataSet ps.numX, ps.numY, (p[name] for p in ps)
  @imageDataSet: (name, gray = false) ->
    ds = new DataSet() # empty data set
    u.importImage name, (img) ->
      window.img = img # DEBUG
      ctx = u.imageToCtx img; ds.ctx = ctx
      window.id = id = u.ctxToImageData ctx # DEBUG
      ta = id.data; jsdata = [] # could be ds.data!
      for i in [0...ta.length] by 4
        if gray
          jsdata.push ta[i]
        else
          jsdata.push ta[i]<<16 | ta[i+1]<<8 | ta[i+2]
      ds.reset ctx.canvas.width, ctx.canvas.height, jsdata
    ds

  # 2D Dataset: width/height and an array with length = width*height
  constructor: (width=0, height=0, data=[]) -> @reset width, height, data
  reset: (@width, @height, @data) ->
    if data.length isnt width*height
      u.error """DataSet: data array length error:
      data.length: #{@data.length} width: #{@width} height: #{@height}
      """
  # x,y are floats, from top-left of data set.
  checkXY: (x,y) ->
    # u.error "x,y out of range" if not ((0<=x<=@width-1) and (0<=y<=@height-1))
    u.error "x,y out of range: #{x},#{y}" if not (0<=x<=@width-1 and 0<=y<=@height-1)
  nearest: (x,y) -> 
    # @checkXY x,y; x = Math.round x; y = Math.round y; @data[x + y*@height]
    @getXY Math.round(x), Math.round(y)
  bilinear: (x,y) -> # http://en.wikipedia.org/wiki/Bilinear_interpolation
    @checkXY x,y
    x0=Math.floor x; y0=Math.floor y; i=@toIndex x0,y0; w=@width
    # If x is width-1, x0 is windth-1, x is 0, dx is 1
    x=x-x0; y=y-y0; dx=1-x; dy=1-y
    # fij is 0 if beyond data array; undefined -> 0
    # if fij wrap on x, x is 0, dx is 1; return f00*dy+f01*y, linear on y
    f00=@data[i]; f01=@data[i+w] ? 0; f10=@data[++i] ? 0; f11=@data[i+w] ? 0
    f00*dx*dy + f10*x*dy + f01*dx*y + f11*x*y
  toIndex: (x,y) -> x + y*@width
  toXY: (i) -> [i % @width, Math.floor i/@width]
  getXY: (x,y) -> @checkXY x,y; @data[@toIndex x,y]
  setXY: (x,y,num) -> @checkXY x,y; @data[@toIndex x,y] = num
  toString: (fixed = false, p=2)->
    s = "width: #{@width} height: #{@height} data:"
    data = if fixed then u.aToFixed @data, p else @data
    s += "\n" + "#{i}: #{data.slice i*@width, (i+1)*@width}" for i in [0...@height]
    s
  toImage: (gray = true)->
    ctx = u.createCtx @width, @height
    idata = ctx.getImageData(0, 0, @width, @height); ta = idata.data
    # norm = u.normalize @data, .9999 + if gray then 255 else Math.pow 2,24
    norm = u.normalize @data, 0, Math.pow(2, if gray then 8 else 24) - 0.000001
    window.norm = norm # DEBUG
    for num, i in norm
      j=4*i; ta[j+3] = 255
      if gray
        ta[j] = ta[j+1] = ta[j+2] = Math.floor num
      else
        ta[j]=num>>>16; ta[j+1]=(num>>8)&0xff; ta[j+2]=num&0xff
    window.ta = u.typedToJS ta # DEBUG
    ctx.putImageData idata, 0, 0
    ctx.canvas
  samplePatchXY: (px,py) ->
    # console.log [px,py]
    w = ABM.world
    px = px-w.minX+.5; py = w.maxY+.5-py # convert to top-left offsets
    # px *= w.size*@width/w.width; py *= w.size*@height/w.height # scale
    px *= @width/w.numX; py *= @height/w.numY # scale
    # console.log [px,py]
    @nearest px, py # REMIND: bilinear?
  setPatchVar: (name) -> # REMIND: faster to resample and set?
    p[name] = @samplePatchXY p.x, p.y for p in ABM.patches
  resample: (width,height) ->
    return @ if width is @width and height is @height # REMIND: return new dataset?
    data = []; xScale = (@width-1)/(width-1); yScale = (@height-1)/(height-1)
    downSample = (xScale >= 1) or (yScale >= 1)
    console.log [width, height, xScale, yScale, downSample] # DEBUG
    for y in [0...height] by 1
      for x in [0...width] by 1
        xs=x*xScale; ys=y*yScale
        s = if downSample then @nearest xs,ys else @bilinear xs,ys
        data.push s
    console.log [x,y,width,height,data,xs,ys] # DEBUG
    new DataSet width, height, data
  neighborhood: (x,y,array=[]) -> # return 3x3 neighborhood
    array.length = 0 # in case user supplied an array
    for dy in [-1..1]
      for dx in [-1..1]
        x0=u.clamp x+dx, 0, @width-1
        y0=u.clamp y+dy, 0, @height-1
        array.push @data[@toIndex x0, y0]
    array
  convolve: (kernel) -> # Factory: return new convolved dataset
    array = []; n = []
    for y in [0...@height] by 1
      for x in [0...@width] by 1
        @neighborhood x,y,n
        # v=0; v+=k*n[i] for k,i in kernel; array.push v
        array.push u.aSum(u.aPairMul(kernel, n))
    new DataSet @width, @height, array
  subset: (x, y, width, height) ->
    u.error "subSet: params out of range" if x+width>@width or y+height>@height
    data = []
    for j in [y...y+height] by 1
      for i in [x...x+width] by 1
        data.push @getXY i,j
    new DataSet width, height, data
        
