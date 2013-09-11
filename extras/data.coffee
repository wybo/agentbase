# DataSet is an addon for managing data arrays.
#
# DataSets do not need to be the same size as the patch sets. Rather they have
# methods for sampling and creating new datasets of any width/height.
# They also cam set patch variables resampled to the patch width/height.
# Several utilities are provided for creating datasets from Image and
# XmlHTTPRequest inputs, and for drawing into the patch drawing layer.

# Two specific subclasses are provided for Asc GIS elevation data,
# and an image-as-data class.

u = ABM.util
ABM.DataSet = class DataSet
  # Static members:
  
  # Create a new dataset from patch variable "name"
  @patchDataSet: (name) ->
    new DataSet (ps=ABM.patches).numX, ps.numY, (p[name] for p in ps)
  
  # Create a new dataset from an image file name.
  # Note that datasets can be built in two steps:
  # An empty constructor which then can be completed by an
  # async array, Image or XHR response.
  @importImageDataSet: (name, fmt=3, f) ->
    ds = new ImageDataSet() # empty dataset
    u.importImage name, (img) -> # => not needed
      ds.parse img
      f(ds) if f?
    ds # async: ds will be empty until import finishes
  
  # Create a new dataset from an Asc GIS file.
  # The parse method converts a string into a dataset. Async
  @importAscDataSet: (name, f) ->
    ds = new AscDataSet() # empty dataset
    u.xhrLoadFile name, "text", (response) -> # => not needed
      ds.parse response # complete the empty dataset
      f(ds) if f?
    ds # async: ds will be empty until import finishes

  # 2D Dataset: width/height and an array with length = width*height
  constructor: (width=0, height=0, data=[]) -> @reset width, height, data
  # Reset a dataset to have new width, height and data.  Allows creating
  # an empty dataset and having it filled by another function.
  reset: (@width, @height, @data) ->
    if data.length isnt width*height
      u.error """DataSet: data array length error:
      data.length: #{@data.length} width: #{@width} height: #{@height}
      """
    @
  # Check that x,y are valid coords (floats), from top-left of dataset.
  checkXY: (x,y) ->
    u.error "x,y out of range: #{x},#{y}" if not (0<=x<=@width-1 and 0<=y<=@height-1)
  # Sample dataset using nearest neighbor. x,y floats in range
  nearest: (x,y) -> 
    @getXY Math.round(x), Math.round(y)
  # Sample dataset using bilinear (2D) interpolation. x,y floats in range
  bilinear: (x,y) -> # http://en.wikipedia.org/wiki/Bilinear_interpolation
    @checkXY x,y
    x0=Math.floor x; y0=Math.floor y; i=@toIndex x0,y0; w=@width
    # Edge case: If x is width-1, x0 is width-1, x is 0, dx is 1
    x=x-x0; y=y-y0; dx=1-x; dy=1-y
    # Edge case: fij is 0 if beyond data array; undefined -> 0
    # if fij wrap on x, x is 0, dx is 1; return f00*dy+f01*y, linear on y
    f00=@data[i]; f01=@data[i+w] ? 0; f10=@data[++i] ? 0; f11=@data[i+w] ? 0
    f00*dx*dy + f10*x*dy + f01*dx*y + f11*x*y
  # Convert x,y ints to index into data array
  toIndex: (x,y) -> x + y*@width
  # Convert int index into data array into x,y ints
  toXY: (i) -> [i % @width, Math.floor i/@width]
  # Get data at x,y int offset into data array
  getXY: (x,y) -> @checkXY x,y; @data[@toIndex x,y]
  # Set the data and int x,y coord of data array
  setXY: (x,y,num) -> @checkXY x,y; @data[@toIndex x,y] = num
  # Return a printable string for dataset.
  # If fixed, truncate fraction to p precision
  toString: (fixed = false, p=2)->
    s = "width: #{@width} height: #{@height} data:"
    data = if fixed then u.aToFixed @data, p else @data
    s += "\n" + "#{i}: #{data.slice i*@width, (i+1)*@width}" for i in [0...@height]
    s
  # Convert dataset into an image. Normalize data to be alowable image data
  toImage: (gray = true)->
    ctx = u.createCtx @width, @height
    idata = ctx.getImageData(0, 0, @width, @height); ta = idata.data
    norm = u.normalize @data, 0, Math.pow(2, if gray then 8 else 24) - 0.000001
    for num, i in norm
      j=4*i; ta[j+3] = 255
      if gray
      then ta[j] = ta[j+1] = ta[j+2] = Math.floor num
      else ta[j]=num>>>16; ta[j+1]=(num>>8)&0xff; ta[j+2]=num&0xff
    ctx.putImageData idata, 0, 0
    ctx.canvas
  # Show dataset as image in patch drawing layer, return image
  toDrawing: (gray=true) -> ABM.patches.installDrawing (img=@toImage gray); img
  # Resample dataset to patch width/height and set named patch variable.
  toPatchVar: (name) ->
    ds = @resample ABM.patches.numX, ABM.patches.numY
    p[name] = ds.data[p.id] for p in ABM.patches
  # Resample dataset to new width, height
  resample: (width,height) ->
    return @ if width is @width and height is @height # REMIND: return new dataset?
    data = []; xScale = (@width-1)/(width-1); yScale = (@height-1)/(height-1)
    downSample = (xScale >= 1) or (yScale >= 1)
    for y in [0...height] by 1
      for x in [0...width] by 1
        xs=x*xScale; ys=y*yScale
        s = if downSample then @nearest xs,ys else @bilinear xs,ys
        data.push s
    new DataSet width, height, data
  # Return neighbor values of the given x,y of the dataset
  neighborhood: (x,y,array=[]) -> # return 3x3 neighborhood
    array.length = 0 # in case user supplied an array
    for dy in [-1..1]
      for dx in [-1..1]
        x0=u.clamp x+dx, 0, @width-1
        y0=u.clamp y+dy, 0, @height-1
        array.push @data[@toIndex x0, y0]
    array
  # Return a new dataset of same size convolved with the given kernel 3x3 matrix
  convolve: (kernel) -> # Factory: return new convolved dataset
    array = []; n = []
    for y in [0...@height] by 1
      for x in [0...@width] by 1
        @neighborhood x,y,n
        array.push u.aSum(u.aPairMul(kernel, n))
    new DataSet @width, @height, array
  # Return a subset of the dataset. x,y,width,height integers
  subset: (x, y, width, height) ->
    u.error "subSet: params out of range" if x+width>@width or y+height>@height
    data = []
    for j in [y...y+height] by 1
      for i in [x...x+width] by 1
        data.push @getXY i,j
    new DataSet width, height, data

ABM.AscDataSet = class AscDataSet extends DataSet
  # An .asc GIS file a text file with a header:
  #
  #     ncols 195
  #     nrows 195
  #     xllcorner -84.355652
  #     yllcorner 39.177963
  #     cellsize 0.000093
  #     NODATA_value -9999
  #
  # ..followed by a ncols X nrows matrix of numbers
  
  # Constructor takes a string generally via an xhr request.
  # It can be "empty" .. i.e. needing a second parse() call
  # so that it can be used in an async file operation.
  constructor: (@str="") ->
    super() # start out as an empty dataset
    return if @str.length is 0
    @parse @str
  # Complete an initial, empty dataset object who's string
  # is read via an xhr request.
  parse: (@str) ->
    textData = str.split "\n"; @header = {}; #gisData.data = []
    for i in [0..5]
      keyVal = textData[i].split /\s+/
      @header[keyVal[0].toLowerCase()] = parseFloat keyVal[1]
    for i in [0...@header.nrows] by 1
      nums = textData[6+i].trim().split(" ")
      nums[i] = parseFloat nums[i] for i in [0...nums.length]
      @data = @data.concat nums
    @reset @header.ncols, @header.nrows, @data
  # Create two new datasets, slope and aspect, common in
  # the use of an elevation data set.
  slopeAndAspect: () -> # http://goo.gl/apnur http://goo.gl/x7QYm
    dzdx = @convolve([-1,0,1,-2,0,2,-1,0,1])
    dzdy = @convolve([-1,-2,-1,0,0,0,1,2,1])
    aspect = []; slope = [] #; minX = .01; maxAtan = Math.PI/4
    for y in [0...@height] by 1
      for x in [0...@width] by 1
        gx = dzdx.getXY(x,y); gy = dzdy.getXY(x,y)
        slope.push Math.sqrt gx*gx + gy*gy
        rad = Math.PI/2 + Math.atan2 gy,-gx
        rad += 2*Math.PI if rad < 0
        aspect.push rad
    @slope = new DataSet @width, @height, slope
    @aspect = new DataSet @width, @height, aspect
    [@slope, @aspect]

ABM.ImageDataSet = class ImageDataSet extends DataSet
  # An image-as-data dataset.  The parser takes an image
  # data Uint8Array, enumerates it in 4-byte segments converting
  # the segment into an unsigned 32 bit int dataset entry.
  constructor: (@img, @byteFmt=3) -> # default 24 bit int
    super() # start out as an empty dataset
    return if not @img?
    @parse @img
  # The byte format can be:
  #
  #     int 1-4 or 8,16,24,32: number of bytes/bits of data
  #       std layout: B, GB, RGB, ARGB for 1-4 bytes
  #     array of length 1-4: non-standard layout of RGB bytes
  #       ex: [1,2] -> 16 bits G<<8 | B
  ByteFmts: [[2],[1,2],[0,1,2],[3,0,1,2]]
  checkByteFmt: () ->
    if u.isArray @byteFmt
      if @byteFmt.length>4 or u.aMax(@byteFmt)>3 or u.aMin(@byteFmt)<0
        u.error "bad ImageDataSet byte format array: #{@byteFmt}"
    else
      if @byteFmt not in [1,2,3,4,8,16,24,32]
        u.error "bad ImageDataSet byte/bit format int: #{@byteFmt}"
      @byteFmt = @byteFmt/8 if @byteFmt > 4 # convert bits to bytes
      @byteFmt = @ByteFmts[@byteFmt-1]
  parse: (@img) ->
    @checkByteFmt @byteFmt
    @ctx = u.imageToCtx @img # keep context for possible later use
    ta = u.ctxToImageData(@ctx).data # Uint8 typed array of image data
    for i in [0...ta.length] by 4
      # Note: do not use bitwise operations: keep value positive int
      val = 0; val = val*256 + ta[i+j] for j in @byteFmt
      @data.push val
    @reset @ctx.canvas.width, @ctx.canvas.height, @data
    
