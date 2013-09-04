# DataSet is an addon for managing data arrays.  The datasets do not need
# to be the same size as the patch sets.  Rather they have multiple methods
# for sampling and creating new datasets of any width/height.  They also cam
# set patch variables resampled to the patch width/height.
# Several utilities are provided for creating datasets from Image and
# XmlHTTPRequest inputs, and for drawing into the patch drawing layer.

u = ABM.util
class ABM.DataSet
  # Static members:
  
  # Create a new dataset from patch variable "name"
  @patchDataSet: (name) ->
    ps = ABM.patches
    new DataSet ps.numX, ps.numY, (p[name] for p in ps)
  
  # Create a new dataset from an image. If `gray` is true, uses only 
  # (high order) R byte.  If not, creates either a 24 bit integer (alpha false)
  # or a 32 bit integer (alpha true).
  # Create dataset from image file name. Async.
  @importImageDataSet: (name, gray = false, alpha = false, f) ->
    ds = new DataSet() # empty data set
    u.importImage name, (img) =>
      @imageDataSet img, gray, alpha, ds
      f(ds) if f?
    ds # async: ds will be empty until importImage finishes
  # Create dataset from existing image.  Not async, useful with importImage
  @imageDataSet: (img, gray = false, alpha = false, ds = new DataSet()) ->
    ctx = u.imageToCtx img #; ds.ctx = ctx .. useful?
    id = u.ctxToImageData ctx
    ta = id.data; jsdata = []
    for i in [0...ta.length] by 4
      if gray
        jsdata.push ta[i]
      else
        if alpha
        then jsdata.push ta[i]<<24 | ta[i+1]<<16 | ta[i+2]<<8 | ta[i+3]
        else jsdata.push ta[i]<<16 | ta[i+1]<<8 | ta[i+2]
    ds.reset ctx.canvas.width, ctx.canvas.height, jsdata
  
  # GIS helper: import a .asc file as dataset. Async
  @importAscDataSet: (name, f) ->
    ds = new DataSet() # empty data set
    u.xhrLoadFile name, "text", (response) =>
      @ascDataSet response, ds
      f(ds) if f?
    ds # async: ds will be empty until importImage finishes
  # Create a .asc file from string. Not async, useful with xhrLoadFile
  @ascDataSet: (str, ds = new DataSet()) ->
    textData = str.split "\n"; gisData = {}; gisData.data = []
    for i in [0..5]
      keyVal = textData[i].split /\s+/
      gisData[keyVal[0].toLowerCase()] = parseFloat keyVal[1]
    for i in [0...gisData.nrows] by 1
      nums = textData[6+i].trim().split(" ")
      nums[i] = parseFloat nums[i] for i in [0...nums.length]
      gisData.data = gisData.data.concat nums
    ds.reset gisData.ncols, gisData.nrows, gisData.data

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
  # Check that x,y are valid coords (floats), from top-left of data set.
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
  setPatchVar: (name) ->
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
        
