# This documentation uses Jeremy Ashkenas's
# [docco](http://jashkenas.github.com/docco/) which allows
# [markdown](http://daringfireball.net/projects/markdown/syntax).

# Create the namespace **ABM** for our project.
# Note here `this` or `@` == window due to coffeescript wrapper call.
# Thus @ABM is placed in the global scope.
# Plain ABM is set for running tests on the command-line
@ABM = ABM = {}

root = @ # Keep a private copy of global object

# Global shim for not-yet-standard requestAnimationFrame.
# See: [Paul Irish Shim](https://gist.github.com/paulirish/1579671)
do ->
  @requestAnimFrame = @requestAnimationFrame or null
  @cancelAnimFrame = @cancelAnimationFrame or null
  for vendor in ['ms', 'moz', 'webkit', 'o'] when not @requestAnimFrame
    @requestAnimFrame or= @[vendor + 'RequestAnimationFrame']
    @cancelAnimFrame or= @[vendor + 'CancelAnimationFrame']
    @cancelAnimFrame or= @[vendor + 'CancelRequestAnimationFrame']
  @requestAnimFrame or= (callback) -> @setTimeout(callback, 1000 / 60)
  @cancelAnimFrame or= (id) -> @clearTimeout(id)

# Shim for `Array.indexOf` if not implemented.
# Use [es5-shim](https://github.com/kriskowal/es5-shim) if additional shims needed.
Array::indexOf or= (object) ->
  for x, i in @
    return i if x is object
  -1

Array::_sort = Array::sort

# **ABM.util** contains the general utilities for the project. Note that within
# **util** `@` referrs to ABM.util, *not* the global name space as above.
# Alias: u is an alias for ABM.util within the agentscript module (not outside)
#
#      u.clearContext(context) is equivalent to
#      ABM.util.clearContext(context)

ABM.util = u =
  # ### Language extensions
  
  # Shortcut for throwing an error.  Good for debugging:
  #
  #     error("wtf? foo=#{foo}") if fooProblem
  error: (string) ->
    throw new Error string
  
  # Two max/min int numbers. One for 2^53, largest int in float64, other for
  # bitwise ops which are 32 bit. See [discussion](http://goo.gl/WpAzT)
  MaxINT: Math.pow(2, 53)
  MinINT: -Math.pow(2, 53) # -@MaxINT fails, @ not defined yet
  MaxINT32: 0 | 0x7fffffff
  MinINT32: 0 | 0x80000000
  Colors: {
    black: [0, 0, 0], white: [255, 255, 255], gray: [128, 128, 128],
    red: [255, 0, 0], yellow: [255, 255, 0], green: [0, 128, 0],
    blue: [0, 0 ,255], purple: [128, 0, 128], brown: [165, 42, 42]
  }
  
  # Good replacements for Javascript's badly broken`typeof` and `instanceof`
  # See [underscore.coffee](http://goo.gl/L0umK)
  isArray: Array.isArray or (object) ->
    !!(object and obj.concat and object.unshift and not object.callee)

  isFunction: (object) ->
    !!(object and object.constructor and object.call and object.apply)

  isString: (object) ->
    !!(object is '' or (object and object.charCodeAt and object.substr))

  isNumber: (object) ->
    !!(typeof object is "number")
  
  # ### Numeric operations

  # Replace Math.random with a simple seedable generator.
  # See [StackOverflow](http://goo.gl/FafN3z)
  randomSeed: (seed = 123456) ->
    Math.random = ->
      x = Math.sin(seed++) * 10000
      x - Math.floor(x)

  # Return random int in [0, max) or [min, max)
  randomInt: (minmax = 2, max = null) ->
    Math.floor(@randomFloat(minmax, max))

  # Return float in [0, max) or [min, max) or [-r / 2, r / 2)
  randomFloat: (minmax = 1, max = null) ->
    if max is null
      max = minmax
      min = 0
    else
      min = minmax

    min + Math.random() * (max - min)

  # Return float Gaussian normal with given mean, std deviation.
  randomNormal: (mean = 0.0, standardDeviation = 1.0) -> # Box-Muller
    u1 = 1.0 - Math.random()
    u2 = Math.random() # u1 in (0, 1]
    normal = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2)
    normal * standardDeviation + mean

  randomCentered: (r) ->
    @randomFloat -r / 2, r / 2

  onceEvery: (number = 100) ->
    @randomInt(number) is 1

  # Return log number where base is 10, base, e respectively.
  # Note ln: (n) -> Math.log number .. i.e. JS's log is log base e
  log10: (number) ->
    Math.log(number) / Math.LN10

  log2: (number) ->
    @logN number, 2

  logN: (number, base) ->
    Math.log(number) / Math.log(base)

  # Return true [modulo](http://goo.gl/spr24), % is remainder, not mod.
  mod: (number, moduloOf) ->
    ((number % moduloOf) + moduloOf) % moduloOf

  # Return number to be between min, max via modulo
  wrap: (number, min, max) ->
    min + @mod(number - min, max - min)

  # Return number to be between min, max via clamping with min/max
  clamp: (number, min, max) ->
    Math.max(Math.min(number, max), min)

  # Return sign of a number as +/- 1
  sign: (number) ->
    if number < 0
      -1
    else
      1

  # ### Color and angle operations

  # Basic colors from string # TODO make better, so accepts arrays
  colorFromString: (colorName) ->
    color = @Colors[colorName]
    if !@isArray color
      @error "unless you're using basic colors, specify an rgb array [nr, nr, nr]"
    color

  # Return a random RGB or gray color. Array passed to minimize garbage collection
  randomColor: () ->
    color = []
    for i in [0..2]
      color[i] = @randomInt(256)
    color

  # Note: if 2 args passed, assume they're min, max w/ default c
  randomGray: (min = 64, max = 192) ->
    color = []
    random = @randomInt min, max
    for i in [0..2]
      color[i] = random
    color

  # Random color from a colormap set of r, g, b values.
  # Default is one of 125 (5^3) colors
  randomMapColor: (set = [0, 63, 127, 191, 255]) ->
    [@sample(set), @sample(set), @sample(set)]

  randomBrightColor: () ->
    @randomMapColor [0, 127, 255]

  # Return new color, c, by scaling each value of the rgb color max.
  fractionOfColor: (maxColor, fraction, color = []) ->
    color.string = null
    for value, i in maxColor
      color[i] = @clamp(Math.round(value * fraction), 0, 255)
    color

  # lightens color with fraction of 0..255
  brightenColor: (color, fraction) ->
    newColor = []
    for value in color
      newColor.push @clamp(Math.round(value + fraction * 255), 0, 255)
    newColor

  # Return HTML color as used by canvas element. Can include Alpha
  colorString: (color) ->
    if not color.string?
      if color.length is 4 and color[3] > 1
        @error "alpha > 1"
      if color.length is 3
        color.string = "rgb(#{color})"
      else
        color.string = "rgba(#{color})"
    color.string

  # Compare two colors.  Alas, there is no array.Equal operator.
  colorsEqual: (color1, color2) ->
    color1.toString() is color2.toString()

  # Return little/big endian-ness of hardware. 
  # See Mozilla pixel [manipulation article](http://goo.gl/Lxliq)
  isLittleEndian: ->
    # convert 1-int array to typed array
    d32 = new Uint32Array [0x01020304]
    # return true if byte order reversed
    (new Uint8ClampedArray d32.buffer)[0] is 4

  # Convert between degrees and radians.  We/Math package use radians.
  degreesToRadians: (degrees) ->
    degrees * Math.PI / 180

  radiansToDegrees: (radians) ->
    radians * 180 / Math.PI

  # Return angle in (-pi, pi] that added to rad2 = rad1
  # See NetLogo's [subtract-headings](http://goo.gl/CjoHuV) for explanation
  substractRadians: (radians1, radians2) ->
    angle = radians1 - radians2
    PI = Math.PI
    if angle <= -PI
      angle += 2 * PI
    if angle > PI
      angle -= 2 * PI
    angle
  
  # ### Object operations
  
  # Return object's own key or variable values
  ownKeys: (object) ->
    (key for own key, value of object)

  ownVariableKeys: (object) ->
    (key for own key, value of object when not @isFunction value)

  ownValues: (object) ->
    (value for own key, value of object)

  # ### Array operations
  
  # TODO allow user to add these to the Array object

  # Return an array of floating pt numbers as strings at given precision;
  # useful for printing
  toFixed: (array, precision = 2) ->
    newArray = []
    for number in array
      newArray.push number.toFixed precision
    newArray

  # Does the array have any elements? Is the array empty?
  any: (array) ->
    not u.empty(array)

  empty: (array) ->
    array.length is 0

  # Make a copy of the array. Needed when you don't want to modify the given
  # array with mutator methods like sort, splice or your own functions.
  # By giving begin/arguments, retrieve a subset of the array.
  # Works with TypedArrays too.
  clone: (array, begin = null, end = null) ->
    if array.slice?
      method = "slice"
    else
      method = "subarray"

    if begin?
      array[method] begin, end
    else
      array[method] 0

  # Return last element of array.
  # Error if empty.
  last: (array) ->
    @error "last: empty array" if @empty array
    array[array.length - 1]

  # Return random element of array or number random elements of array.
  # Note: array elements presumed unique, i.e. objects or distinct primitives
  # Note: clone, shuffle then first number has poor performance
  sample: (array, numberOrCondition = null, condition = null) ->
    if @isFunction numberOrCondition
      condition = numberOrCondition
    else if numberOrCondition?
      number = Math.floor(numberOrCondition)

    if number?
      newArray = []
      object = true
      while newArray.length < number and object?
        object = @sample(array, condition)
        if object and object not in newArray
          newArray.push object
      return newArray
    else if condition?
      checked = []
      while checked.length < array.length
        object = @sample(array)
        if object and object not in checked
          checked.push object
          if condition(object)
            return object
    else
      if @empty array
        return null
      return array[@randomInt array.length]

  # True if object is in array.
  contains: (array, object) ->
    array.indexOf(object) >= 0

  # Remove an object from an array.
  # Error if object not in array.
  remove: (array, object) ->
    while true
      index = array.indexOf object
      break if index is -1
      array.splice index, 1
    array

  # Remove elements in objects from an array. Binary search if f isnt null.
  # Error if an object not in array.
  removeItems: (array, objects) ->
    for object in objects
      @remove array, object
    array

  # Randomize the elements of this array.
  shuffle: (array) ->
    array.sort -> 0.5 - Math.random()

  # TODO add array functions to Array extension, then allow it to be
  # added to array in user models through an ABM.setup() function
  #
  # Return object when lambda(object) min/max in array. Error if array empty.
  # If f is a string, return element with max value of that property.
  # If "valueToo" then return a 2-array of the element and the value;
  # used for cases where f is costly function.
  # 
  #     array = [{x: 1, y: 2}, {x: 3, y: 4}]
  #     array.min()
  #     # returns {x: 1, y: 2} 5
  #     [min, dist2] = array.min(((o) -> o.x * o.x + o.y * o.y), true)
  #     # returns {x: 3, y: 4}
  min: (array, lambda = @identityFunction, valueToo = false) ->
    @error "min: empty array" if @empty array
    if @isString lambda
      lambda = @propertyFunction lambda
    minValue = Infinity
    minObject = null

    for object in array
      value = lambda(object)
      if value < minValue
        minValue = value
        minObject = object

    if valueToo
      [minObject, minValue]
    else
      minObject

  max: (array, lambda = @identityFunction, valueToo = false) ->
    @error "max: empty array" if @empty array
    if @isString lambda
      lambda = @propertyFunction lambda
    maxValue = -Infinity
    maxObject = null

    for object in array
      value = lambda(object)
      if value > maxValue
        maxValue = value
        maxObject = object

    if valueToo
      [maxObject, maxValue]
    else
      maxObject

  sum: (array, lambda = @identityFunction) ->
    if @isString lambda
      lambda = @propertyFunction lambda

    value = 0
    for object in array
      value += lambda(object)

    value

  average: (array, lambda = @identityFunction) ->
    @sum(array, lambda) / array.length

  median: (array) ->
    if array.sort?
      array = @clone array
    else
      array = @typedToJS array

    middle = (array.length - 1) / 2

    @sort array
    (array[Math.floor(middle)] + array[Math.ceil(middle)]) / 2

  # Return histogram of o when f(o) is a numeric value in array.
  # Histogram interval is bin. Error if array empty.
  # If f is a string, return histogram of that property.
  #
  # In examples below, histogram returns [3, 1, 1, 0, 0, 1]
  #
  #     a = [1, 3, 4, 1, 1, 10]
  #     h = histogram a, 2, (i) -> i
  #     
  #     b = ({id:i} for i in a)
  #     h = histogram b, 2, (o) -> o.id
  #     h = histogram b, 2, "id"
  histogram: (array, binSize = 1, lambda = @identityFunction) ->
    if @isString lambda
      lambda = @propertyFunction lambda
    histogram = []

    for object in array
      integer = Math.floor lambda(object) / binSize
      histogram[integer] or= 0
      histogram[integer] += 1

    for value, integer in histogram when not value?
      histogram[integer] = 0

    histogram

  # Mutator. Sort array of objects in place by the function f.
  # If f is string, f returns property of object.
  # Returns array.
  # Clone first if you want to preserve the original array.
  #
  #     array = [{i: 1}, {i: 5}, {i: -1}, {i: 2}, {i: 2}]
  #     sortBy array, "i"
  #     # array now is [{i: -1}, {i: 1}, {i: 2}, {i: 2}, {i:5}]
  sort: (array, lambda = null) ->
    if @isString lambda # use item[f] if f is string
      lambda = @propertySortFunction lambda

    array._sort lambda

  # Mutator. Removes adjacent dups, by reference, in place from array.
  # Note "by reference" means litteraly same object, not copy. Returns array.
  # Clone first if you want to preserve the original array.
  #
  #     ids = ({id:i} for i in [0..10])
  #     a = (ids[i] for i in [1, 3, 4, 1, 1, 10])
  #     # a is [{id: 1}, {id: 3}, {id: 4}, {id: 1}, {id: 1}, {id: 10}]
  #     b = clone a
  #     sortBy b, "id"
  #     # b is [{id:1}, {id: 1}, {id: 1}, {id: 3}, {id: 4}, {id: 10}]
  #     uniq b
  #     # b now is [{id:1}, {id: 3}, {id: 4}, {id: 10}]
  uniq: (array) ->
    hash = {}

    for index in [0...array.length]
      if hash[array[index]] is true
        array.splice index, 1
      hash[array[index]] = true

    array
  
  # Return a new array composed of the rows of a matrix. I.e. convert
  #
  #     [[1, 2, 3], [4, 5, 6]] to [1, 2, 3, 4, 5, 6]
  flatten: (array) ->
    array.reduce((arrayA, arrayB) ->
      if not u.isArray arrayA
        arrayA = [arrayA]
      arrayA.concat arrayB)
  
  # Return an array with values in [low, high], defaults to [0, 1].
  # Note: to have a half-open interval, [low, high), try high = high - .00009
  normalize: (array, low = 0, high = 1) ->
    min = @min array
    max = @max array
    scale = 1 / (max - min)
    newArray = []
    for number in array
      newArray.push @linearInterpolate(low, high, scale * (number - min))
    newArray

  normalizeInt: (array, low, high) ->
    (Math.round i for i in @normalize array, low, high)

  # Return a Uint8ClampedArray, normalized to [.5, 255.5] then round/clamp to [0, 255]
  # TODO maybe data-specific?
  normalize8: (array) ->
    new Uint8ClampedArray @normalize(array, -.5, 255.5)

  # ### Topology operations
  
  # Return angle in [-pi, pi] radians from point1 to point2
  # [See: Math.atan2](http://goo.gl/JS8DF)
  radiansToward: (point1, point2) ->
    Math.atan2 point2.y - point1.y, point2.x - point1.x

  # Return true if point2 is in cone radians around heading radians from 
  # point1.x, point2.x and within distance radius from point1.x,
  # point2.x.
  # I.e. is point2 in cone/heading/radius from point1?
  inCone: (heading, cone, radius, point1, point2) ->
    if radius < @distance point1, point2
      return false

    angle = @radiansToward point1, point2 # angle from 1 to 2
    cone / 2 >= Math.abs @substractRadians(heading, angle)

  # Return the Euclidean distance between point1 and 2
  distance: (point1, point2) ->
    distanceX = point1.x - point2.x
    distanceY = point1.y - point2.y
    Math.sqrt distanceX * distanceX + distanceY * distanceY
  
  # Return the [torus distance](http://goo.gl/PgJ5N) between two points 
  # point1 (A) and point2 (B):
  #
  #     dx = |point2.x - point1.x|
  #     dy = |point2.y - point1.y|
  #     d = sqrt(min(dx, W - dx)^2 + min(dy, H - dy)^2)
  #
  # Torus note: ABMs often use a Torus topology where the right and left edges
  # fold to meet, and similarly for the top/bottom.
  # For points, this is easily handled with the mod function .. insuring the
  # point is within the rectangle modulo W & H.
  #
  # The relationship *between* points is more difficult.  The relationship between
  # A and B must also include the towards-reflections around A, thus 4 points.
  #
  #          |               |
  #          |      W        |
  #     -----+---------------+-----
  #      B1  |           B   |
  #          |               |  H
  #          |               |
  #          |  A            |
  #     -----+---------------+-----
  #      B3  |           B2  |
  #          |               |
  torusDistance: (point1, point2, width, height) ->
    xDistance = Math.abs point2.x - point1.x
    yDistance = Math.abs point2.y - point1.y
    minX = Math.min xDistance, width - xDistance
    minY = Math.min yDistance, height - yDistance
    Math.sqrt minX * minX + minY * minY

  # Return 4 torus point reflections of point2 around point1
  torus4Points: (point1, point2, width, height) ->
    [xReflected, yReflected] = @torusReflect(point1, point2, width, height)

    [point2, {x: xReflected, y: point2.y},
      {x: point2.x, y: yReflected}, {x: xReflected, y: yReflected}]

  # Return closest of 4 torus points from point1 to 2
  closestTorusPoint: (point1, point2, width, height) ->
    [xReflected, yReflected] = @torusReflect(point1, point2, width, height)

    if Math.abs(xReflected - point1.x) < Math.abs(point2.x - point1.x)
      x = xReflected
    else
      x = point2.x

    if Math.abs(yReflected - point1.y) < Math.abs(point2.y - point1.y)
      y = yReflected
    else
      y = point2.y

    {x: x, y: y}

  # Used in torus4Points
  torusReflect: (point1, point2, width, height) ->
    if point2.x < point1.x
      xReflected = point2.x + width
    else
      xReflected = point2.x - width

    if point2.y < point1.y
      yReflected = point2.y + height
    else
      yReflected = point2.y - height

    [xReflected, yReflected]

  # Return the angle from x1, y1 to x2, y2 on torus using shortest reflection.
  torusRadiansToward: (point1, point2, width, height) ->
    closest = @closestTorusPoint point1, point2, width, height
    @radiansToward point1, closest

  # Return true if point2 is in cone radians around heading radians from 
  # point1.x, point2.x and within distance radius from point1.x, point2.x
  # considering all torus reflections.
  inTorusCone: (heading, cone, radius, point1, point2, width, height) ->
    for point in @torus4Points point1, point2, width, height
      return true if @inCone heading, cone, radius, point1, point
    false

  # ### File I/O

  # Cache of file names used by file imports below
  fileIndex: {}

  # Import an image, executing (async) optional function call(image) on completion
  importImage: (name, call = ->) ->
    image = @fileIndex[name]
    if image?
      if image.isDone
        call(image)
    else
      image = new Image()
      image.isDone = false
      image.crossOrigin = "Anonymous"
      image.onload = ->
        call(image)
        image.isDone = true
      image.src = name
      @fileIndex[name] = image
    image
    
  # Use XMLHttpRequest to fetch data of several types. Data Types: text,
  # arraybuffer, blob, json, document, [See specification](http://goo.gl/y3r3h).
  # method is "GET" or "POST". f is function to call onload, default to no-op.
  xhrLoadFile: (name, method = "GET", type = "text", call = ->) -> # AJAX async request
    xhr = @fileIndex[name]
    if xhr?
      if xhr.isDone
        call(xhr.response)
    else
      xhr = new XMLHttpRequest()
      xhr.isDone = false
      xhr.open method, name # POST mainly for security and large files
      xhr.responseType = type
      xhr.onload = ->
        call(xhr.response)
        xhr.isDone = true
      @fileIndex[name] = xhr
      xhr.send()
    xhr
  
  # Return true if all files are loaded.
  filesLoaded: (files = @fileIndex) ->
    array = (object.isDone for object in (@ownValues files))
    array.reduce ((valueA, valueB) -> valueA and valueB), true

  # Wait for files to be loaded before executing callback call
  waitOnFiles: (call, files = @fileIndex) ->
    @waitOn (=> @filesLoaded files), call

  # Wait for function done() to return true before calling callback f
  waitOn: (done, call) ->
    if done()
      call()
    else
      setTimeout((=> @waitOn(done, call)), 1000)

  # ### Image data operations

  # Make a copy of an image.
  # Note: new image will have the naturalWidth/Height of input image.
  # Should be sync
  cloneImage: (image) ->
    newImage = new Image()
    newImage.src = image.src
    newImage

  # Create a data array from an image's imageData
  # image may be a canvas.
  # The function call = call(imageData, rgbIndex) -> number
  imageToData: (image, call = @pixelByte(0), arrayType = Uint8ClampedArray) ->
    @imageRowsToData image, image.height, call, arrayType

  imageRowsToData: (image, rowsPerSlice, call = @pixelByte(0),
      arrayType = Uint8ClampedArray) ->
    rowsDone = 0
    data = new arrayType image.width * image.height

    while rowsDone < image.height
      rows = Math.min image.height - rowsDone, rowsPerSlice
      context = @imageSliceToContext image, 0, rowsDone, image.width, rows # REMIND: pass context
      idata = @contextToImageData(context).data
      dataStart = rowsDone * image.width
      data[dataStart + i] = call(idata, 4 * i) for i in [0...idata.length / 4] by 1
      rowsDone += rows

    data

  imageSliceToContext: (image, sx, sy, sw, sh, context) ->
    if context?
      context.canvas.width = sw
      context.canvas.height = sh
    else
      context = @createContext sw, sh
    context.drawImage image, sx, sy, sw, sh, 0, 0, sw, sh
    context

  pixelByte: (n) ->
    (byte, i) -> byte[i + n]

  # ### Canvas/Context operations

  # Create a new canvas of given width/height
  createCanvas: (width, height) ->
    canvas = document.createElement 'canvas'
    canvas.width = width
    canvas.height = height
    canvas

  # As above, but returing the context object.
  # Note context.canvas is the canvas for the context, and can be use as an image.
  createContext: (width, height, contextType = "2d") ->
    canvas = @createCanvas width, height
    if contextType is "2d"
      canvas.getContext "2d"
    else
      canvas.getContext("webgl") ? canvas.getContext("experimental-webgl")

  # Return a "layer" 2D/3D rendering context within the specified HTML `<div>`,
  # with the given width/height positioned absolutely at top/left within the div,
  # and with the z-index of z.
  #
  # The z level gives us the capability of buildng a "stack" of coordinated canvases.
  createLayer: (div, width, height, z, context = "2d") -> # a canvas context object
    if context is "img"
      element = context = new Image()
      context.width = width
      context.height = height
    else
      element = (context = @createContext(width, height, context)).canvas
    @insertLayer div, element, width, height, z
    context
  insertLayer: (div, element, w, h, z) ->
    element.setAttribute 'style', # Note: this erases existing style, el.style.position doesnt
    "position:absolute;top:0;left:0;width:#{w};height:#{h};z-index:#{z}"
    div.appendChild(element)

  setContextSmoothing: (context, smoothing) ->
    context.imageSmoothingEnabled = smoothing
    context.mozImageSmoothingEnabled = smoothing
    context.oImageSmoothingEnabled = smoothing
    context.webkitImageSmoothingEnabled = smoothing

  # Install identity transform.  Call context.restore() to revert to previous transform
  setIdentity: (context) ->
    context.save() # revert to native 2D transform
    context.setTransform 1, 0, 0, 1, 0, 0
  
  # Clear the 2D/3D layer to be transparent. Note this [discussion](http://goo.gl/qekXS).
  clearContext: (context) ->
    if context.save? # test for 2D context
      @setIdentity context # context.canvas.width = context.canvas.width not used so as to preserve patch coords
      context.clearRect 0, 0, context.canvas.width, context.canvas.height
      context.restore()
    else # 3D
      context.clearColor 0, 0, 0, 0 # transparent!
      context.clear context.COLOR_BUFFER_BIT | context.DEPTH_BUFFER_BIT

  # Fill the 2D/3D layer with the given color
  fillContext: (context, color) ->
    if context.fillStyle? # test for 2D context
      @setIdentity context
      context.fillStyle = @colorString color
      context.fillRect 0, 0, context.canvas.width, context.canvas.height
      context.restore()
    else # 3D
      context.clearColor color..., 1 # alpha = 1 unless color is rgba
      context.clear context.COLOR_BUFFER_BIT | context.DEPTH_BUFFER_BIT

  # Draw string of the given color at the xy location, in context pixel coords.
  # Use setIdentity .. reset if a transform is being used by caller.
  contextDrawText: (context, string, x, y, color = [0, 0, 0], setIdentity = true) ->
    @setIdentity(context) if setIdentity
    context.fillStyle = @colorString color
    context.fillText(string, x, y)
    if setIdentity
      context.restore()
  # Set the element text align and baseline drawing parameters
  #
  # * font is a HTML/CSS string like: "9px sans-serif"
  # * align is left right center start end
  # * baseline is top hanging middle alphabetic ideographic bottom
  #
  # See [reference](http://goo.gl/AvEAq) for details.
  contextTextParams: (context, font, align = "center", baseline = "middle") ->
    context.font = font
    context.textAlign = align
    context.textBaseline = baseline

  elementTextParams: (element, font, align = "center", baseline = "middle") ->
    element = element.canvas if element.canvas?
    element.style.font = font
    element.style.textAlign = align
    element.style.textBaseline = baseline

  # Convert a canvas to an image, executing fcn f on completion.
  # Generally can skip callback but see [stackoverflow](http://goo.gl/kIk2U)
  # Note: uses toDataURL thus possible cross origin problems.
  # Fix: use context.canvas for programatic imaging.
  contextToDataUrl: (context) -> context.canvas.toDataURL "image/png"

  contextToDataUrlImage: (context, call) ->
    image = new Image()
    if call?
      image.onload = -> call(image)
    image.src = context.canvas.toDataURL "image/png"
    image

  # Convert a context to an imageData object
  contextToImageData: (context) ->
    context.getImageData 0, 0, context.canvas.width, context.canvas.height

  # Draw an image centered at x, y w/ image size dx, dy.
  # See [this tutorial](http://goo.gl/VUlhY).
  drawCenteredImage: (context, image, radians, x, y, dx, dy) ->
    # presume save/restore surrounds this
    context.translate x, y # translate to center
    context.rotate radians
    context.drawImage image, -dx / 2, -dy / 2
  
  # Duplicate a context's image.  Returns the new context, use context.canvas for canvas.
  copyContext: (context) ->
    newContext = @createContext context.canvas.width, context.canvas.height
    newContext.drawImage context.canvas, 0, 0
    newContext

  # Resize a context/canvas and preserve data.
  resizeContext: (context, width, height, scale = false) -> # http://goo.gl/Tp90B
    newContext = @copyContext context
    context.canvas.width = width
    context.canvas.height = height
    context.drawImage newContext.canvas, 0, 0

  # ### Misc / helpers
  
  # Return a linear interpolation between low and high.
  # Scale is in [0 - 1], and the result is in [low, high]
  linearInterpolate: (low, high, scale) ->
    low + (high - low) * scale

  # Return argument unchanged; for primitive arrays or objs sorted by reference
  identityFunction: (object) ->
    object

  # Return a function that returns an object's property.  Property in fcn closure.
  propertyFunction: (property) ->
    (object) -> object[property]

  # Return a function that returns an object's property.  Property in fcn closure.
  propertySortFunction: (property) ->
    (objectA, objectB) ->
      if objectA[property] < objectB[property]
        -1
      else if objectA[property] > objectB[property]
        1
      else
        0

  # Return a JS array given a TypedArray.
  # To create TypedArray from JS array: new Uint8Array(jsa) etc
  typedToJS: (typedArray) ->
    (i for i in typedArray)

# A **Set** is an array, along with a class, agentClass, whose instances
# are the items of the array.  Instances of the class are created
# by the `create` factory method of a Set.
#
# It is a subclass of `Array` and is the base class for
# `Patches`, `Agents`, and `Links`. A Set keeps track of all
# its created instances.  It also provides, much like the **ABM.util**
# module, many methods shared by all subclasses of Set.
#
# ABM contains three agentsets created by class Model:
#
# * `ABM.patches`: the model's "world" grid
# * `ABM.agents`: the model's agents living on the patches
# * `ABM.links`: the network links connecting agent pairs
#
# See NetLogo [documentation](http://ccl.northwestern.edu/netlogo/docs/)
# for explanation of the overall semantics of Agent Based Modeling
# used by Sets as well as Patches, Agents, and Links.
#
# Note: subclassing `Array` can be dangerous and we may have to convert
# to a different style. See Trevor Burnham's [comments](http://goo.gl/Lca8g)
# but thus far we've resolved all related problems.
#
# Because we are an array subset, @[i] == this[i] == agentset[i]

class ABM.Set extends Array
  # ### Static members
  
  # `asSet` is a static wrapper function converting an array of agents into
  # an `Set` .. except for the ID which only impacts the add method.
  # It is primarily used to turn a comprehension into a Set instance
  # which then gains access to all the methods below.  Ex:
  #
  #     evens = (a for a in ABM.agents when a.id % 2 is 0)
  #     ABM.Set.asSet(evens)
  #     randomEven = evens.random()
  @asSet: (a, setType = ABM.Set) ->
    a.__proto__ = setType.prototype ? setType.constructor.prototype # setType.__proto__
    a
  
  # In the examples below, we'll use an array of primitive agent objects
  # with three fields: id, x, y.
  #
  #     AS = for i in [1..5] # long form comprehension
  #       {id:i, x:u.randomInt(10), y:u.randomInt(10)}
  #     ABM.Set.asSet AS # Convert AS to Set in place
  #        [{id: 1, x: 0, y: 1}, {id: 2, x: 8, y: 0}, {id: 3, x: 6, y: 4},
  #         {id: 4, x: 1, y: 3}, {id: 5, x: 1, y: 1}]

  # ### Constructor and add/remove agents.
  
  # Create an empty `Set` and initialize the `ID` counter for add().
  # If mainSet is supplied, the new agentset is a sub-array of mainSet.
  # This sub-array feature is how breeds are managed, see class `Model`
  constructor: (agentClass, name, mainSet) ->
    super(0) # doesn't yield empty array if already instances in the mainSet
    @agentClass = agentClass
    @name = name
    @mainSet = mainSet
    @breeds = [] unless @mainSet?
    @agentClass::breed = @ # let the breed know I'm it's agentSet
    @ownVariables = [] # keep list of user variables
    @ID = 0 unless @mainSet? # Do not set ID if I'm a subset

  # Abstract method used by subclasses to create and add their instances.
  create: ->
    
  # Add an agent to the list.  Only used by agentset factory methods. Adds
  # the `id` property to all agents. Increment `ID`.
  # Returns the object for chaining.
  #
  # By "agent" we mean an instance of `Patch`, `Agent` and `Link` and their breeds
  add: (object) ->
    if @mainSet?
      @mainSet.add object
    else
      object.id = @ID++
    @push object
    object

  # Remove an agent from the agentset, returning the agentset.
  # Note this does not change ID, thus an
  # agentset can have gaps in terms of their id's. 
  #
  #     AS.remove(AS[3]) # [{id: 0, x: 0, y: 1}, {id: 1, x: 8, y: 0},
  #                         {id: 2, x: 6, y: 4}, {id: 4, x: 1, y: 1}] 
  remove: (object) ->
    if @mainSet?
      u.remove @mainSet, object
    u.remove @, object
    @

  # Set the default value of an agent class, return agentset
  setDefault: (name, value) -> @agentClass::[name] = value; @

  # Declare variables of an agent class. 
  # Vars = a string of space separated names or an array of name strings
  # Return agentset.
  own: (vars) -> # maybe not set default if val is null?
    # vars = vars.split(" ") if not u.isArray vars
    # for name in vars#.split(" ") # if not u.isArray vars
    for name in vars.split(" ")
      @setDefault name, null
      @ownVariables.push name
    @

  # Move an agent from its Set/breed to be in this Set/breed.
  # REMIND: match NetLogo sematics in terms of own variables.
  setBreed: (a) -> # change agent a to be in this breed
    u.remove a.breed, a
    @.push a
    proto = a.__proto__ = @agentClass.prototype
    delete a[k] for own k, v of a when proto[k]?
    a

  # Return all agents that are not of the given breeds argument.
  # Breeds is a string of space separated names:
  #   @patches.exclude "roads houses"
  exclude: (breeds) ->
    breeds = breeds.split(" ")
    @asSet (o for o in @ when o.breed.name not in breeds)

  # Floodfill arguments:
  #
  # * aset: initial array of agents, often a single agent: [a]
  # * fCandidate(a, asetLast) -> true if a is elegible to be added to the set
  # * fJoin(a, asetLast) -> adds a to the agentset, usually by setting a variable
  # * fCallback(asetLast, asetNext) -> optional function to be called each iteration of floodfill;
  # if fCallback returns true, the flood is aborted
  # * fNeighbors(a) -> returns the neighbors of this agent
  # * asetLast: the array of the last set of agents to join the flood;
  # gets passed into fJoin, fCandidate, and fCallback
  floodFill: (aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast = []) ->
    floodFunc = @floodFillOnce(aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast)
    floodFunc = floodFunc() while floodFunc

  # Move one step forward in a floodfill. floodFillOnce() returns a function that performs the next step of the flood.
  # This is useful if you want to watch your flood progress as an animation.
  floodFillOnce: (aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast = []) ->
    fJoin p, asetLast for p in aset
    asetNext = []
    for p in aset
      for n in fNeighbors(p) when fCandidate n, aset
        asetNext.push n if asetNext.indexOf(n) < 0
    stopEarly = fCallback and fCallback(aset, asetNext)
    if stopEarly or asetNext.length is 0 then return null
    else return () =>
      @floodFillOnce asetNext, fCandidate, fJoin, fCallback, fNeighbors, aset
  
  # Remove adjacent duplicates, by reference.
  #
  #     as = (AS.random() for i in [1..4]) # 4 random agents w/ dups
  #     ABM.Set.asSet as # [{id: 1, x: 8, y: 0}, {id: 0, x: 0, y: 1},
  #                              {id: 0, x: 0, y: 1}, {id: 2, x: 6, y: 4}]
  #     as.uniq() # [{id: 0, x: 0, y: 1}, {id: 1, x: 8, y: 0}, 
  #                  {id: 2, x: 6, y: 4}]
  uniq: -> u.uniq(@)

  # The static `ABM.Set.asSet` as a method.
  # Used by agentset methods creating new agentsets.
  asSet: (a, setType = @) -> ABM.Set.asSet a, setType # setType = ABM.Set

  # Similar to above but sorted via `id`.
  asOrderedSet: (a) -> @asSet(a).sort("id")

  # Return string representative of agentset.
  toString: -> "[" + (a.toString() for a in @).join(", ") + "]"

  # ### Property Utilities
  # Property access, also useful for debugging<br>
  
  # Return an array of a property of the agentset
  #
  #      AS.getProp "x" # [0, 8, 6, 1, 1]
  getProp: (prop) -> o[prop] for o in @

  # Return an array of agents with the property equal to the given value
  #
  #     AS.getPropWith "x", 1
  #     [{id: 4, x: 1, y: 3},{id: 5, x: 1, y: 1}]
  getPropWith: (prop, value) -> @asSet (o for o in @ when o[prop] is value)

  # Set the property of the agents to a given value.  If value
  # is an array, its values will be used, indexed by agentSet's index.
  # This is generally used via: getProp, modify results, setProp
  #
  #     # increment x for agents with x=1
  #     AS1 = ABM.Set.asSet AS.getPropWith("x", 1)
  #     AS1.setProp "x", 2 # {id: 4, x: 2, y: 3}, {id: 5, x: 2, y: 1}
  #
  # Note this changes the last two objects in the original AS above
  setProp: (prop, value) ->
    if u.isArray value
      o[prop] = value[i] for o, i in @; @
    else
      o[prop] = value for o in @; @
  
  # ### Array Utilities, often from ABM.util

  # Randomize the agentset
  #
  #     AS.shuffle(); AS.getProp "id" # [3, 2, 1, 4, 5] 
  shuffle: -> u.shuffle @

  # Sort the agentset
  #
  sort: (options...) -> u.sort @, options...

  # Make a copy of an agentset, return as new agentset.<br>
  # NOTE: does *not* duplicate the objects, simply creates a new agentset
  # with references to the same agents.  Ex: create a randomized version of AS
  # but without mangling AS itself:
  #
  #     as = AS.clone().shuffle()
  #     AS.getProp "id"  # [1, 2, 3, 4, 5]
  #     as.getProp "id"  # [2, 4, 0, 1, 3]
  clone: -> @asSet u.clone @

  # Return the last agent in the agentset
  #
  #     AS.last().id             # l5
  #     l = AS.last(); p = [l.x, l.y] # [1, 1]
  last: -> u.last @

  # Returns true if the agentset has any agents
  #
  #     AS.any()  # true
  #     AS.getPropWith("x", 99).any() #false
  any: -> u.any @

  # Return an agentset without given agent a
  #
  #     as = AS.clone().other(AS[0])
  #     as.getProp "id"  # [1, 2, 3, 4] 
  other: (a) -> @asSet (o for o in @ when o isnt a) # could clone & remove

  # Return random agent in agentset or an agentset made of n distinct agents.
  sample: (options...) ->
    random = u.sample @, options...
    if random and random.isArray
      @asSet random
    else
      random

  # Return agent when f(o) min/max in agentset. If multiple agents have
  # min/max value, return the first. Error if agentset empty.
  # If f is a string, return element with min/max value of that property.
  # If "valueToo" then return an array of the agent and the value.
  # 
  #     AS.min("x") # {id: 0, x: 0, y: 1}
  #     AS.max((a) -> a.x + a.y, true) # {id: 2, x: 6, y: 4}, 10
  min: (f, valueToo = false) -> u.min @, f, valueToo

  max: (f, valueToo = false) -> u.max @, f, valueToo

  # ### Drawing
  
  # For agentsets whose agents have a `draw` method.
  # Clears the graphics context (transparent), then
  # calls each agent's draw(context) method.
  draw: (context) ->
    u.clearContext(context)
    o.draw(context) for o in @ when not o.hidden
    null
  
  # Show/Hide all of an agentset or breed.
  # To show/hide an individual object, set its prototype: o.hidden = bool
  show: ->
    o.hidden = false for o in @
    @draw(ABM.contexts[@name])

  hide: ->
    o.hidden = true for o in @
    @draw(ABM.contexts[@name])

  # ### Topology
  
  # For ABM.patches & ABM.agents which have x, y. See ABM.util doc.
  #
  # Return all agents in agentset within d distance from given object.
  # By default excludes the given object. Uses linear/torus distance
  # depending on patches.isTorus, and patches width/height if needed.
  inRadius: (point, distance, meToo = false) -> # for any objects w/ x, y
    if ABM.patches.isTorus
      width = ABM.patches.numX
      height = ABM.patches.numY
      @asSet (a for a in @ when \
        u.torusDistance(point, a, width, height) <= distance and (meToo or a isnt point))
    else
      @asSet (a for a in @ when \
        u.distance(point, a) <= distance and (meToo or a isnt point))

  # As above, but also limited to the angle `cone` around
  # a `heading` from object `o`.
  inCone: (point, heading, cone, radius, meToo = false) ->
    rSet = @inRadius point, radius, meToo
    if ABM.patches.isTorus
      width = ABM.patches.numX
      height = ABM.patches.numY
      @asSet (a for a in rSet when \
        (a is point and meToo) or u.inTorusCone(heading, cone, radius, point, a, width, height))
    else
      @asSet (a for a in rSet when \
        (a is point and meToo) or u.inCone(heading, cone, radius, point, a))

  # ### Debugging
  
  # Useful in console.
  # Also see [CoffeeConsole](http://goo.gl/1i7bd) Chrome extension.
  
  # Similar to NetLogo ask & with operators.
  # Allows functions as strings. Use:
  #
  #     AS.getProp("x") # [1, 8, 6, 2, 2]
  #     AS.with("o.x < 5").ask("o.x = o.x + 1")
  #     AS.getProp("x") # [2, 8, 6, 3, 3]
  #
  #     ABM.agents.with("o.id < 100").ask("o.color = [255, 0, 0]")
  ask: (f) ->
    eval("f=function(o){return " + f + ";}") if u.isString f
    f(o) for o in @; @

  with: (f) ->
    eval("f=function(o){return " + f + ";}") if u.isString f
    @asSet (o for o in @ when f(o))

# The example agentset AS used in the code fragments was made like this,
# slightly more useful than shown above due to the toString method.
#
#     class XY
#       constructor: (@x, @y) ->
#       toString: -> "{id: #{@id}, x: #{@x}, y: #{@y}}"
#     @AS = new ABM.Set # @ => global name space
#
# The result of 
#
#     AS.add new XY(u.randomInt(10), u.randomInt(10)) for i in [1..5]
#
# random run, captured so we can reuse.
#
#     AS.add new XY(pt...) for pt in [[0, 1], [8, 0], [6, 4], [1, 3], [1, 1]]

# ### Agent
  
# Class Agent instances represent the dynamic, behavioral element of ABM.
# Each agent knows the patch it is on, and interacts with that and other
# patches, as well as other agents.
class ABM.Agent
  # Constructor & Class Variables:
  #
  # * id:         unique identifier, promoted by agentset create() factory method
  # * breed:      the agentset this agent belongs to
  # * x,y:        position on the patch grid, in patch coordinates, default: 0, 0
  # * size:       size of agent, in patch coords, default: 1
  # * color:      the color of the agent, default: randomColor
  # * shape:      the shape name of the agent, default: "default"
  # * label:      a text label drawn on my instances
  # * labelColor: the color of my label text
  # * labelOffset:the x, y offset of my label from my x, y location
  # * heading:    direction of the agent, in radians, from x-axis
  # * hidden:     whether or not to draw this agent
  # * patch:      patch at current x, y location
  # * penDown:    true if agent pen is drawing
  # * penSize:    size in pixels of the pen, default: 1 pixel
  # * sprite:     an image of the agent if non null
  # * cacheLinks: if true, keep array of links in/out of me
  # * links:      array of links in/out of me.  Only used if @cacheLinks is true
  #
  # These class variables are "defaults" and many are "promoted" to instance variables.
  # To have these be set to a constant for all instances, use breed.setDefault.
  # This can be a huge savings in memory.
  id: null              # unique id, promoted by agentset create factory method
  breed: null           # my agentSet, set by the agentSet owning me
  x: 0                  # my location
  y: 0
  patch: null           # the patch I'm on
  size: 1               # my size in patch coords
  color: null           # default color, overrides random color if set
  shape: "default"      # my shape
  hidden: false         # draw me?
  label: null           # my text
  labelColor: [0, 0, 0] # its color
  labelOffset: [0, 0]   # its offset from my x, y
  penDown: false        # if my pen is down, I draw my path between changes in x, y
  penSize: 1            # the pen thickness in pixels
  heading: null         # the direction I'm pointed in, in radians
  sprite: null          # an image of me for optimized drawing
  cacheLinks: false     # should I keep links to/from me in links array?.
  links: null           # array of links to/from me as an endpoint; init by ctor

  constructor: -> # called by agentSets create factory, not user
    @x = @y = 0
    @patch = ABM.patches.patch @x, @y
    @color = u.randomColor() unless @color? # promote color if default not set
    @heading = u.randomFloat(Math.PI * 2) unless @heading?
    @patch.agents.push @ if @patch.agents? # ABM.patches.cacheAgentsHere
    @links = [] if @cacheLinks

  # Set agent color to `color` scaled by `fraction`. Usage: see patch.fractionOfColor
  fractionOfColor: (color, fraction) ->
    @color = u.clone @color unless @.hasOwnProperty("color")
    u.fractionOfColor color, fraction, @color
  
  # Return a string representation of the agent.
  toString: -> "{id:#{@id} xy:#{u.aToFixed [@x, @y]} c:#{@color} h: #{@heading.toFixed 2}}"
  
  # Place the agent at the given x, y (floats) in patch coords
  # using patch topology (isTorus)
  setXY: (x, y) -> # REMIND GC problem, 2 arrays
    [x0, y0] = [@x, @y] if @penDown
    [@x, @y] = ABM.patches.coord x, y
    oldPatch = @patch
    @patch = ABM.patches.patch @x, @y

    if oldPatch and oldPatch.agents?
      u.remove oldPatch.agents, @

    if @patch.agents?
      @patch.agents.push @

    if @penDown
      drawing = ABM.drawing
      drawing.strokeStyle = u.colorString @color
      drawing.lineWidth = ABM.patches.fromBits @penSize
      drawing.beginPath()
      drawing.moveTo x0, y0
      drawing.lineTo x, y # REMIND: euclidean
      drawing.stroke()

  losePosition: ->
    u.remove @patch.agents, @
    @patch = null
  
  # Place the agent at the given patch/agent location
  moveTo: (patch) -> @setXY patch.x, patch.y
  
  # Move forward (along heading) d units (patch coords),
  # using patch topology (isTorus)
  forward: (d) ->
    @setXY @x + d * Math.cos(@heading), @y + d * Math.sin(@heading)
  
  # Change current heading by radians which can be + (left) or - (right)
  rotate: (radians) ->
    @heading = u.wrap @heading + radians, 0, Math.PI * 2 # returns new h
  
  # Draw the agent, instanciating a sprite if required
  draw: (context) ->
    if @patch is null
      return
    shape = ABM.shapes[@shape]
    radians = if shape.rotate then @heading else 0 # radians
    if @sprite? or @breed.useSprites
      @setSprite() unless @sprite? # lazy evaluation of useSprites
      ABM.shapes.drawSprite context, @sprite, @x, @y, @size, radians
    else
      ABM.shapes.draw context, shape, @x, @y, @size, radians, @color
    if @label?
      [x, y] = ABM.patches.patchXYtoPixelXY @x, @y
      u.contextDrawText context, @label, x + @labelOffset[0], y + @labelOffset[1], @labelColor
  
  # Set an individual agent's sprite, synching its color, shape, size
  setSprite: (sprite)->
    if (sprite)?
      @sprite = sprite
      @color = sprite.color
      @shape = sprite.shape
      @size = sprite.size
    else
      @color = u.randomColor unless @color?
      @sprite = ABM.shapes.shapeToSprite @shape, @color, @size
    
  # Draw the agent on the drawing layer, leaving permanent image.
  stamp: -> @draw ABM.drawing
  
  # Return distance in patch coords from me to given agent/patch
  # using patch topology (isTorus)
  distance: (point) -> # o any object w/ x, y, patch or agent
    if ABM.patches.isTorus
      u.torusDistance @, point, ABM.patches.numX, ABM.patches.numY
    else
      u.distance @, point
  
  # Return the closest torus topology point of given agent/patch 
  # relative to myself. 
  # Used internally to determine how to draw links between two agents.
  # See util.torusPoint.
  closestTorusPoint: (point) ->
    u.closestTorusPoint @, point, ABM.patches.numX, ABM.patches.numY

  # Set my heading towards given agent/patch using patch topology.
  face: (o) -> @heading = @towards o

  # Return heading towards given agent/patch using patch topology.
  towards: (point) ->
    if ABM.patches.isTorus
      u.torusRadiansToward @, point, ABM.patches.numX, ABM.patches.numY
    else
      u.radiansToward @, point
  
  # Returns the neighbours (agents) of this agent
  neighbors: (options...) ->
    array = @breed.asSet []
    if @patch
      for patch in @patch.neighbors(options...)
        for agent in patch.agents
          array.push agent
    array
  
  # Remove myself from the model. Includes removing myself from the
  # agents agentset and removing any links I may have.
  die: ->
    @breed.remove @
    for l in @myLinks()
      l.die()
    if @patch.agents?
      u.remove @patch.agents, @
    null

  # Factory: create num new agents at this agents location. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  hatch: (num = 1, breed = ABM.agents, init = ->) ->
    breed.create num, (a) => # fat arrow so that @ = this agent
      a.setXY @x, @y # for side effects like patches.agentsHere
      a[k] = v for own k, v of @ when k isnt "id"
      init(a) # Important: init called after object inserted in agent set
      a

  # Return the members of the given agentset that are within radius distance 
  # from me, and within cone radians of my heading using patch topology
  inCone: (agentSet, cone, radius, meToo = false) ->
    agentSet.inCone @patch, @heading, cone, radius, meToo # REMIND: @patch vs @?
  
  # Return other end of link from me
  otherEnd: (l) -> if l.end1 is @ then l.end2 else l.end1

  # Return all links linked to me
  myLinks: ->
    @links ? (l for l in ABM.links when (l.end1 is @) or (l.end2 is @))
  
  # Return all agents linked to me.
  linkNeighbors: -> # return all agents linked to me
    @otherEnd l for l in @myLinks()
  
  # Return links where I am the "to" agent in links.create
  myInLinks: ->
    l for l in @myLinks() when l.end2 is @

  # Return other end of myInLinks
  inLinkNeighbors: ->
    l.end1 for l in @myLinks() when l.end2 is @
    
  # Return links where I am the "from" agent in links.create
  myOutLinks: ->
    l for l in @myLinks() when l.end1 is @
  
  # Return other end of myOutinks
  outLinkNeighbors: ->
    l.end2 for l in @myLinks() when l.end1 is @

# ### Agents

# Class Agents is a subclass of Set which stores instances of Agent or 
# Breeds, which are subclasses of Agent
class ABM.Agents extends ABM.Set
  # Constructor creates the empty Set instance and installs
  # the agentClass (breed) variable shared by all the Agents in this set.
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with
    @useSprites = false

  # Have agents cache the links with them as a node.
  # Optimizes Agent a.myLinks method. Call before any agents created.
  cacheLinks: -> @agentClass::cacheLinks = true # all agents, not individual breeds

  # Use sprites rather than drawing
  setUseSprites: (@useSprites = true) ->
  
  # Filter to return all instances of this breed. Note: if used by
  # the mainSet, returns just the agents that are not subclassed breeds.
  in: (array) -> @asSet (o for o in array when o.breed is @)

  # Factory: create num new agents stored in this agentset. The optional init
  # proc is called on the new agent after inserting in its agentSet.
  create: (num, init = ->) -> # returns array of new agents too
    ((o) -> init(o); o) @add new @agentClass for i in [1..num] by 1 # too tricky?
    # TODO refactor!

  # Remove all agents from set via agent.die()
  # Note call in reverse order to optimize list restructuring.
  clear: -> @last().die() while @any(); null # tricky, each die modifies list
  
  # Return an agentset of agents within the patch array
  inPatches: (patches) ->
    array = []
    array.push patch.agentsHere()... for patch in patches # concat measured slower
    if @mainSet? then @in array else @asSet array
  
  # Return an agentset of agents within the patchRectangle
  inRectangle: (a, dx, dy, meToo = false) ->
    rect = ABM.patches.patchRectangle a.patch, dx, dy, true
    rect = @inPatches rect
    unless meToo
      u.remove rect, a
    rect
  
  # Return the members of this agentset that are within radius distance
  # from me, and within cone radians of my heading using patch topology
  inCone: (a, heading, cone, radius, meToo = false) -> # heading? .. so p ok?
    as = @inRectangle a, radius, radius, true # TODO really needed?
    super a, heading, cone, radius, meToo #as.inCone a, heading, cone, radius, meToo
  
  # Return the members of this agentset that are within radius distance
  # from me, using patch topology
  inRadius: (a, radius, meToo = false)->
    as = @inRectangle a, radius, radius, true
    super a, radius, meToo # as.inRadius a, radius, meToo

# Class Model is the control center for our Sets: Patches, Agents and Links.
# Creating new models is done by subclassing class Model and overriding two 
# virtual/abstract methods: `setup()` and `step()`

# ### Animator
  
# Because not all models have the same amimator requirements, we build a class
# for customization by the programmer.  See these URLs for more info:
#
# * [JavaScript timers doc](https://developer.mozilla.org/en-US/docs/JavaScript/Timers)
# * [Using timers & requestAnimFrame together](http://goo.gl/ymEEX)
# * [John Resig on timers](http://goo.gl/9Q3q)
# * [jsFiddle setTimeout vs rAF](http://jsfiddle.net/calpo/H7EEE/)
# * [Timeout tutorial](http://javascript.info/tutorial/settimeout-setinterval)
# * [Events and timing in depth](http://javascript.info/tutorial/events-and-timing-depth)
  
class ABM.Animator
  # Create initial animator for the model, specifying default rate (fps) and multiStep.
  # If multiStep, run the draw() and step() methods separately by draw() using
  # requestAnimFrame and step() using setTimeout.
  constructor: (@model, @rate = 30, @multiStep = model.world.isHeadless) ->
    @isHeadless = model.world.isHeadless
    @reset()

  # Adjust animator.  Call before model.start()
  # in setup() to change default settings
  setRate: (@rate, @multiStep = @isHeadless) -> @resetTimes() # Change rate while running?

  # start/stop model, often used for debugging and resetting model
  start: ->
    return unless @stopped # avoid multiple animates
    @resetTimes()
    @stopped = false
    @animate()

  stop: ->
    @stopped = true
    if @animatorHandle?
      cancelAnimFrame @animatorHandle
    if @timeoutHandle?
      clearTimeout @timeoutHandle
    if @intervalHandle?
      clearInterval @intervalHandle
    @animatorHandle = @timerHandle = @intervalHandle = null

  # Internal util: reset time instance variables
  resetTimes: ->
    @startMS = @now()
    @startTick = @ticks
    @startDraw = @draws

  # Reset used by model.reset when resetting model.
  reset: ->
    @stop()
    @ticks = @draws = 0

  # Two handlers used by animation loop
  step: ->
    @ticks++
    @model.step()

  draw: ->
    @draws++
    @model.draw()

  # step and draw the model once, mainly debugging
  once: ->
    @step()
    @draw()

  # Get current time, with high resolution timer if available
  now: -> (performance ? Date).now()

  # Time in ms since starting animator
  ms: -> @now() - @startMS

  # Get ticks/draws per second. They will differ if multiStep.
  # The "if" is to avoid from ms=0
  ticksPerSec: ->
    elapsed = @ticks - @startTick
    if elapsed is 0
      0
    else
      Math.round elapsed * 1000 / @ms()

  drawsPerSec: ->
    elapsed = @draws - @startDraw
    if elapsed is 0
      0
    else
      Math.round elapsed * 1000 / @ms()

  # Return a status string for debugging and logging performance
  toString: -> 
    "ticks: #{@ticks}, draws: #{@draws}, rate: #{@rate} " +
      "tps/dps: #{@ticksPerSec()}/#{@drawsPerSec()}"

  # Animation via setTimeout and requestAnimFrame
  animateSteps: =>
    @step()
    @timeoutHandle = setTimeout @animateSteps, 10 unless @stopped

  animateDraws: =>
    if @isHeadless # Use rAF when headless wants to be throttled.
      @step() if @ticksPerSec() < @rate
    else if @drawsPerSec() < @rate # throttle drawing to @rate
      @step() unless @multiStep
      @draw()
    @animatorHandle = requestAnimFrame @animateDraws unless @stopped

  animate: ->
    @animateSteps() if @multiStep
    @animateDraws() unless @isHeadless and @multiStep

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

# ### Links
  
# Class Links is a subclass of Set which stores instances of Link
# or subclasses of Link

class ABM.Links extends ABM.Set
  # Constructor: super creates the empty Set instance and installs
  # the agentClass (breed) variable shared by all the Links in this set.
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with

  # Factory: Add 1 or more links from the from agent to the to agent(s) which
  # can be a single agent or an array of agents. The optional init
  # proc is called on the new link after inserting in the agentSet.
  create: (from, to, init = ->) -> # returns array of new links too
    to = [to] unless to.length?
    ((o) -> init(o); o) @add new @agentClass from, a for a in to # too tricky?
  
  # Remove all links from set via link.die()
  # Note call in reverse order to optimize list restructuring.
  clear: -> @last().die() while @any(); null # tricky, each die modifies list

  # Return all the nodes in this agentset, with duplicates
  # included.  If 4 links have the same endpoint, it will
  # appear 4 times.
  allEnds: -> # all link ends, w / dups
    n = @asSet []
    n.push l.end1, l.end2 for l in @
    n

  # Returns all the nodes in this agentset with duplicates removed.
  nodes: -> # allEnds without dups
    @allEnds().uniq()
  
  # Circle Layout: position the agents in the list in an equally
  # spaced circle of the given radius, with the initial agent
  # at the given start angle (default to pi / 2 or "up") and in the
  # +1 or -1 direction (counder clockwise or clockwise) 
  # defaulting to -1 (clockwise).
  layoutCircle: (list, radius, startAngle = Math.PI / 2, direction = -1) ->
    dTheta = 2 * Math.PI / list.length
    for a, i in list
      a.setXY 0, 0
      a.heading = startAngle + direction*dTheta*i
      a.forward radius
    null

# Class Model is the control center for our Sets: Patches, Agents and Links.
# Creating new models is done by subclassing class Model and overriding two 
# virtual/abstract methods: `setup()` and `step()`

# ### Class Model

ABM.models = {} # user space, put your models here

class ABM.Model
  # Class variable for layers parameters. 
  # Can be added to by programmer to modify/create layers, **before** starting your own model.
  # Example:
  # 
  #     v.z++ for k, v of ABM.Model::contextsInit # increase each z value by one
  contextsInit: { # Experimental: image:   {z: 15, context: "img"} 
    patches:   {z: 10, context: "2d"}
    drawing:   {z: 20, context: "2d"}
    links:     {z: 30, context: "2d"}
    agents:    {z: 40, context: "2d"}
    spotlight: {z: 50, context: "2d"}
  }
  # Constructor: 
  #
  # * create agentsets, install them and ourselves in ABM global namespace
  # * create layers/contexts, install drawing layer in ABM global namespace
  # * setup patch coord transforms for each layer context
  # * intialize various instance variables
  # * call `setup` abstract method
  constructor: (divOrOptions, size = 13, minX = -16, maxX = 16, minY = -16,
      maxY = 16, isTorus = false, hasNeighbors = true, isHeadless = false) ->

    ABM.model = @

    if typeof divOrOptions is 'string'
      div = divOrOptions
      @setWorldDeprecated size, minX, maxX, minY, maxY, isTorus, hasNeighbors,
        isHeadless
    else
      div = divOrOptions.div
      isHeadless = divOrOptions.isHeadless = divOrOptions.isHeadless? or not div?
      @setWorld divOrOptions

    @contexts = ABM.contexts = {}

    unless isHeadless
      (@div = document.getElementById(div)).setAttribute 'style',
        "position:relative; width:#{@world.pxWidth}px; height:#{@world.pxHeight}px"

      # * Create 2D canvas contexts layered on top of each other.
      # * Initialize a patch coord transform for each layer.
      # 
      # Note: this transform is permanent .. there isn't the usual context.restore().
      # To use the original canvas 2D transform temporarily:
      #
      #     u.setIdentity context
      #       <draw in native coord system>
      #     context.restore() # restore patch coord system
      for own k, v of @contextsInit
        @contexts[k] = context = u.createLayer @div, @world.pxWidth,
          @world.pxHeight, v.z, v.context
        if context.canvas?
          @setContextTransform context
        if context.canvas?
          context.canvas.style.pointerEvents = 'none'
        u.elementTextParams context, "10px sans-serif", "center", "middle"

      # One of the layers is used for drawing only, not an agentset:
      @drawing = ABM.drawing = @contexts.drawing
      @drawing.clear = => u.clearContext @drawing
      # Setup spotlight layer, also not an agentset:
      @contexts.spotlight.globalCompositeOperation = "xor"

    # if isHeadless
    # # Initialize animator to headless default: 30fps, async  
    # then @animator = new ABM.Animator @, null, true
    # # Initialize animator to default: 30fps, not async
    # else 
    @animator = new ABM.Animator @
    # Set drawing controls.  Default to drawing each agentset.
    # Optimization: If any of these is set to false, the associated
    # agentset is drawn only once, remaining static after that.
    @refreshLinks = @refreshAgents = @refreshPatches = true

    # Initialize agentsets.
    @patchBreeds 'patches'
    @agentBreeds 'agents'
    @linkBreeds 'links'

    # Initialize model global resources
    @debugging = false
    @modelReady = false
    @globalNames = null
    @globalNames = u.ownKeys @
    @globalNames.set = false
    @startup()
    u.waitOnFiles =>
      @modelReady = true
      @setup()
      @globals() unless @globalNames.set

  # Initialize/reset world parameters.
  setWorld: (options) ->
    defaults = {
      size: 13, minX: -16, maxX: 16, minY: -16, maxY: 16, isTorus: false,
      hasNeighbors: true, isHeadless: false
    }

    for own key, value of defaults
      options[key] ?= value

    ABM.world = @world = {}

    for own key, value of options
      @world[key] = value

    @world.numX = @world.maxX - @world.minX + 1
    @world.numY = @world.maxY - @world.minY + 1
    @world.pxWidth = @world.numX * @world.size
    @world.pxHeight = @world.numY * @world.size
    @world.minXcor = @world.minX - .5
    @world.maxXcor = @world.maxX + .5
    @world.minYcor = @world.minY - .5
    @world.maxYcor = @world.maxY + .5

  setWorldDeprecated: (size, minX, maxX, minY, maxY, isTorus, hasNeighbors,
      isHeadless) ->
    numX = maxX - minX + 1
    numY = maxY - minY + 1
    pxWidth = numX * size
    pxHeight = numY * size
    minXcor = minX - .5
    maxXcor = maxX + .5
    minYcor = minY - .5
    maxYcor = maxY + .5
    ABM.world = @world = {
      size, minX, maxX, minY, maxY, minXcor, maxXcor, minYcor, maxYcor, numX,
      numY, pxWidth, pxHeight, isTorus, hasNeighbors, isHeadless
    }

  setContextTransform: (context) ->
    context.canvas.width = @world.pxWidth
    context.canvas.height = @world.pxHeight
    context.save()
    context.scale @world.size, -@world.size
    context.translate -(@world.minXcor), -(@world.maxYcor)

  globals: (globalNames) ->
    if globalNames?
      @globalNames = globalNames
      @globalNames.set = true
    else
      @globalNames = u.removeItems u.ownKeys(@), @globalNames

#### Optimizations:
  
  # Modelers "tune" their model by adjusting flags:<br>
  # `@refreshLinks, @refreshAgents, @refreshPatches`<br>
  # and by the following helper methods:

  # Draw patches using scaled image of colors. Note anti-aliasing may occur
  # if browser does not support imageSmoothingEnabled or equivalent.
  setFastPatches: -> @patches.usePixels()

  # Patches are all the same static default color, just "clear" entire canvas.
  # Don't use if patch breeds have different colors.
  setMonochromePatches: -> @patches.monochrome = true
    
  # Have patches cache the agents currently on them.
  # Optimizes Patch p.agentsHere method
  setCacheAgentsHere: -> @patches.cacheAgentsHere()
  
  # Have agents cache the links with them as a node.
  # Optimizes Agent a.myLinks method
  setCacheMyLinks: -> @agents.cacheLinks()
  
  # Have patches cache the given patchRectangle.
  # Optimizes patchRectangle, inRadius and inCone
  setCachePatchRectangle:(radius, meToo = false) ->
    @patches.cacheRectangle radius, meToo
  
#### User Model Creation
# A user's model is made by subclassing Model and over-riding these
# two abstract methods. `super` need not be called.
  
  # Initialize model resources (images, files) here.  
  # Uses util.waitOn so can be be async.
  startup: -> # called by constructor

  # Initialize your model variables and defaults here.
  # If async used, make sure step/draw are aware of possible missing data.
  setup: ->

  # Update/step your model here
  step: -> # called each step of the animation

#### Animation and Reset methods

# Convenience access to animator:

  # Start/stop the animation
  start: ->
    u.waitOn (=> @modelReady), (=> @animator.start())
    @isRunning = true
    @

  stop: ->
    @animator.stop()
    @isRunning = false
    @

  toggle: ->
    if @isRunning
      @stop()
    else
      @start()

  # Animate once by `step(); draw()`. For UI and debugging from console.
  # Will advance the ticks/draws counters.
  once: ->
    unless @animator.stopped
      @stop()
    @animator.once()
    @

  # Stop and reset the model, restarting if restart is true
#  reset: (restart = false) ->
#    console.log "reset: animator"
#    @animator.reset() # stop & reset ticks/steps counters
#    console.log "reset: contexts"
#    # clear/resize b4 agentsets
#    (v.restore(); @setContextTransform v) for k, v of @contexts when v.canvas?
#    console.log "reset: patches"
#    @patches = ABM.patches = new ABM.Patches ABM.Patch, "patches"
#    console.log "reset: agents"
#    @agents = ABM.agents = new ABM.Agents ABM.Agent, "agents"
#    @links = ABM.links = new ABM.Links ABM.Link, "links"
#    u.s.spriteSheets.length = 0 # possibly null out entries?
#    console.log "reset: setup"
#    @setup()
#    @setRootVars() if @debugging
#    @start() if restart

#### Animation.
  
# Call the agentset draw methods if either the first draw call or
# their "refresh" flags are set.  The latter are simple optimizations
# to avoid redrawing the same static scene. Called by animator.
  draw: (force = @animator.stopped) ->
    if force or @refreshPatches or @animator.draws is 1
      @patches.draw @contexts.patches
    if force or @refreshLinks or @animator.draws is 1
      @links.draw @contexts.links
    if force or @refreshAgents  or @animator.draws is 1
      @agents.draw @contexts.agents
    if @spotlightAgent?
      @drawSpotlight @spotlightAgent, @contexts.spotlight

# Creates a spotlight effect on an agent, so we can follow it
# throughout the model.
# Use:
#
#     @setSpotliight breed.sample()
#
# to draw one of a random breed. Remove spotlight by passing `null`
  setSpotlight: (@spotlightAgent) ->
    u.clearContext @contexts.spotlight unless @spotlightAgent?

  drawSpotlight: (agent, context) ->
    u.clearContext context
    u.fillContext context, [0, 0, 0, 0.6]
    context.beginPath()
    context.arc agent.x, agent.y, 3, 0, 2 * Math.PI, false
    context.fill()

# ### Breeds
  
# Three versions of NL's `breed` commands.
#
#     @patchBreeds "streets buildings"
#     @agentBreeds "embers fires"
#     @linkBreeds "spokes rims"
#
# will create 6 agentSets: 
#
#     @streets and @buildings
#     @embers and @fires
#     @spokes and @rims 
#
# These agentsets' `create` methods create subclasses of Agent/Link.
# Use of <breed>.setDefault methods work as for agents/links, creating default
# values for the breed set:
#
#     @embers.setDefault "color", [255, 0, 0]
#
# ..will set the default color for just the embers. Note: patch breeds are currently
# not usable due to the patches being prebuilt.  Stay tuned.
  
  createBreeds: (list, type, agentClass, breedSet) ->
    if u.isString list
      list = list.split(" ")

    breeds = []
    breeds.classes = {}
    breeds.sets = {}

    resetType = false

    for string in list
      if string is type
        ABM[type] = @[type] = new breedSet agentClass, string
      else
        breedClass = class Breed extends agentClass
        breed = @[string] = # add @<breed> to local scope
          new breedSet breedClass, string, agentClass::breed # create subset agentSet

        breeds.push breed
        breeds.sets[string] = breed
        breeds.classes["#{string}Class"] = breedClass

    @[type].breeds = breeds

  patchBreeds: (list, agentClass = ABM.Patch, breedSet = ABM.Patches) ->
    @createBreeds list, 'patches', agentClass, breedSet

  agentBreeds: (list, agentClass = ABM.Agent, breedSet = ABM.Agents) ->
    @createBreeds list, 'agents', agentClass, breedSet

  linkBreeds: (list, agentClass = ABM.Link, breedSet = ABM.Links) ->
    @createBreeds list, 'links', agentClass, breedSet
  
  # Utility for models to create agentsets from arrays.  Ex:
  #
  #     even = @asSet (a for a in @agents when a.id % 2 is 0)
  #     even.shuffle().getProp("id") # [6, 0, 4, 2, 8]
  asSet: (a, setType = ABM.Set) -> ABM.Set.asSet a, setType

  # A simple debug aid which places short names in the global name space.
  # Note we avoid using the actual name, such as "patches" because this
  # can cause our modules to mistakenly depend on a global name.
  # See [CoffeeConsole](http://goo.gl/1i7bd) Chrome extension too.
  debug: (@debugging = true) ->
    u.waitOn (=> @modelReady), (=> @setRootVars())
    @

  setRootVars: ->
    root.ps  = @patches
    root.p0  = @patches[0]
    root.as  = @agents
    root.a0  = @agents[0]
    root.ls  = @links
    root.l0  = @links[0]
    root.dr  = @drawing
    root.u   = ABM.util
    root.cx  = @contexts
    root.an  = @animator
    root.gl  = @globals
    root.dv  = @div
    root.root= root
    root.app = @

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

# ### Patches
  
# Class Patches is a singleton 2D matrix of Patch instances, each patch 
# representing a 1x1 square in patch coordinates (via 2D coord transforms).
#
# From ABM.world, set in Model:
#
# * size:         pixel h/w of each patch.
# * minX/maxX:    min/max x coord in patch coords
# * minY/maxY:    min/max y coord in patch coords
# * numX/numY:    width/height of grid.
# * isTorus:      true if coord system wraps around at edges
# * isHeadless:   true if not using canvas drawing

class ABM.Patches extends ABM.Set
  # Constructor: super creates the empty Set instance and installs
  # the agentClass (breed) variable shared by all the Patches in this set.
  # Patches are created from top-left to bottom-right to match data sets.
  constructor: -> # agentClass, name, mainSet
    super # call super with all the args I was called with
    @monochrome = false # set to true to optimize patches all default color
    @[key] = value for own key, value of ABM.world # add world items to patches
  
  # Setup patch world from world parameters.
  # Note that this is done as separate method so like other agentsets,
  # patches are started up empty and filled by "create" calls.
  create: -> # TopLeft to BottomRight, exactly as canvas imagedata
    for y in [@maxY..@minY] by -1
      for x in [@minX..@maxX] by 1
        @add new @agentClass x, y
    @setPixels() unless @isHeadless # setup off-page canvas for pixel ops
    @
    
  # Have patches cache the agents currently on them.
  # Optimizes p.agentsHere method.
  # Call before first agent is created.
  cacheAgentsHere: ->
    for patch in @
      patch.agents = []
    null

  # Draw patches using scaled image of colors. Note anti-aliasing may occur
  # if browser does not support smoothing flags.
  usePixels: (@drawWithPixels = true) ->
    context = ABM.contexts.patches
    u.setContextSmoothing context, not @drawWithPixels

  # Optimization: Cache a single set by modeler for use by
  # patchRectangle, inCone, inRectangle, inRadius.
  # Ex: flock demo model's vision rect.
  cacheRectangle: (radius, meToo = false) ->
    for patch in @
      patch.pRectangle = @patchRectangle patch, radius, radius, meToo
      patch.pRectangle.radius = radius #; patch.pRectangle.meToo = meToo
    radius

  # Setup pixels used for `drawScaledPixels` and `importColors`
  # 
  setPixels: ->
    if @size is 1
      @usePixels()
      @pixelsContext = ABM.contexts.patches
    else
      @pixelsContext = u.createContext @numX, @numY

    @pixelsImageData = @pixelsContext.getImageData(0, 0, @numX, @numY)
    @pixelsData = @pixelsImageData.data

    if @pixelsData instanceof Uint8Array # Check for typed arrays
      @pixelsData32 = new Uint32Array @pixelsData.buffer
      @pixelsAreLittleEndian = u.isLittleEndian()
  
  # Draw patches.  Three cases:
  #
  # * Pixels: use pixel manipulation rather than canvas draws
  # * Monochrome: just fill canvas w/ patch default
  # * Otherwise: just draw each patch individually
  draw: (context) ->
    if @monochrome
      u.fillContext context, @agentClass::color
    else if @drawWithPixels
      @drawScaledPixels context
    else
      super context

# #### Patch grid coord system utilities:
  
  # Return the patch id/index given integer x, y in patch coords
  patchIndex: (x, y) -> x - @minX + @numX * (@maxY - y)

  # Return the patch at matrix position x, y where 
  # x & y are both valid integer patch coordinates.
  patchXY: (x, y) -> @[@patchIndex x, y]
  
  # Return x, y float values to be between min/max patch coord values
  clamp: (x, y) ->
    [u.clamp(x, @minXcor, @maxXcor), u.clamp(y, @minYcor, @maxYcor)]
  
  # Return x, y float values to be modulo min/max patch coord values.
  wrap: (x, y) ->
    [u.wrap(x, @minXcor, @maxXcor), u.wrap(y, @minYcor, @maxYcor)]
  
  # Return x, y float values to be between min/max patch values
  # using either clamp/wrap above according to isTorus topology.
  coord: (x, y) -> #returns a valid world coord (real, not int)
    if @isTorus then @wrap x, y else @clamp x, y

  # Return true if on world or torus, false if non-torus and off-world
  isOnWorld: (x, y) ->
    @isTorus or (@minXcor <= x <= @maxXcor and @minYcor <= y <= @maxYcor)

  # Return patch at x, y float values according to topology.
  patch: (x, y) ->
    [x, y] = @coord x, y
    x = u.clamp Math.round(x), @minX, @maxX
    y = u.clamp Math.round(y), @minY, @maxY
    @patchXY x, y
  
  # Return a random valid float x, y point in patch space
  randomPoint: ->
    [u.randomFloat(@minXcor, @maxXcor), u.randomFloat(@minYcor, @maxYcor)]

# #### Patch metrics
  
  # Convert patch measure to pixels
  toBits: (patch) ->
    patch * @size

  # Convert bit measure to patches
  fromBits: (b) -> b / @size

# #### Patch utilities
  
  # Return an array of patches in a rectangle centered on the given 
  # patch `patch`, dx, dy units to the right/left and up/down. 
  # Exclude `patch` unless meToo is true, default false.
  patchRectangle: (patch, dx, dy, meToo = false) ->
    rectangle = @patchRectangleNullPadded(patch, dx, dy, meToo)
    u.remove(rectangle, null)

  patchRectangleNullPadded: (patch, dx, dy, meToo = false) ->
    return patch.pRectangle if patch.pRectangle? and patch.pRectangle.radius is dx
    # and patch.pRectangle.radius is dy
    rectangle = []; # REMIND: optimize if no wrapping, rectangle inside patch boundaries
    for y in [(patch.y - dy)..(patch.y + dy)] by 1 # by 1: perf: avoid bidir JS for loop
      for x in [(patch.x - dx)..(patch.x + dx)] by 1
        nextPatch = null
        if @isTorus
          if x < @minX
            x += @numX
          if x > @maxX
            x -= @numX
          if y < @minY
            y += @numY
          if y > @maxY
            y -= @numY
          nextPatch = @patchXY x, y
        else if x >= @minX and x <= @maxX and
            y >= @minY and y <= @maxY
          nextPatch = @patchXY x, y

        if (meToo or patch isnt nextPatch)
          rectangle.push nextPatch

    @asSet rectangle

  # Draws, or "imports" an image URL into the drawing layer.
  # The image is scaled to fit the drawing layer.
  #
  # This is an async load, see this
  # [new Image()](http://javascript.mfields.org/2011/creating-an-image-in-javascript/)
  # tutorial.  We draw the image into the drawing layer as
  # soon as the onload callback executes.
  importDrawing: (imageSrc, f) ->
    u.importImage imageSrc, (img) => # fat arrow, this context
      @installDrawing img
      f() if f?

  # Direct install image into the given context, not async.
  installDrawing: (img, context = ABM.contexts.drawing) ->
    u.setIdentity context
    context.drawImage img, 0, 0, context.canvas.width, context.canvas.height
    context.restore() # restore patch transform
  
  # Utility function for pixel manipulation.  Given a patch, returns the 
  # native canvas index i into the pixel data.
  # The top-left order simplifies finding pixels in data sets
  pixelByteIndex: (patch) -> 4 * patch.id # Uint8

  pixelWordIndex: (patch) -> patch.id   # Uint32

  # Convert pixel location (top/left offset i.e. mouse) to patch coords (float)
  pixelXYtoPatchXY: (x, y) -> [@minXcor + (x / @size), @maxYcor - (y / @size)]

  # Convert patch coords (float) to pixel location (top/left offset i.e. mouse)
  patchXYtoPixelXY: (x, y) -> [( x - @minXcor) * @size, (@maxYcor - y) * @size]
    
  # Draws, or "imports" an image URL into the patches as their color property.
  # The drawing is scaled to the number of x, y patches, thus one pixel
  # per patch.  The colors are then transferred to the patches.
  # Map is a color map, only for gray for now
  importColors: (imageSrc, f, map) ->
    u.importImage imageSrc, (img) => # fat arrow, this context
      @installColors(img, map)
      f() if f?

  # Direct install image into the patch colors, not async.
  installColors: (img, map) ->
    u.setIdentity @pixelsContext
    @pixelsContext.drawImage img, 0, 0, @numX, @numY # scale if needed
    data = @pixelsContext.getImageData(0, 0, @numX, @numY).data
    for patch in @
      i = @pixelByteIndex patch
      # promote initial default
      patch.color = if map? then map[i] else [data[i++], data[i++], data[i]]
    @pixelsContext.restore() # restore patch transform

  # Draw the patches via pixel manipulation rather than 2D drawRect.
  # See Mozilla pixel [manipulation article](http://goo.gl/Lxliq)
  drawScaledPixels: (context) ->
    # u.setIdentity context & context.restore() only needed if patch size 
    # not 1, pixel ops don't use transform but @size>1 uses
    # a drawimage
    u.setIdentity context if @size isnt 1
    if @pixelsData32? then @drawScaledPixels32 context else @drawScaledPixels8 context
    context.restore() if @size isnt 1

  # The 8-bit version for drawScaledPixels.  Used for systems w/o typed arrays
  drawScaledPixels8: (context) ->
    data = @pixelsData
    for patch in @
      i = @pixelByteIndex patch
      c = patch.color
      if c.length is 4
        a = c[3]
      else
        a = 255
      data[i + j] = c[j] for j in [0..2]
      data[i + 3] = a
    @pixelsContext.putImageData @pixelsImageData, 0, 0
    return if @size is 1
    context.drawImage @pixelsContext.canvas, 0, 0, context.canvas.width, context.canvas.height

  # The 32-bit version of drawScaledPixels, with both little and big endian hardware.
  drawScaledPixels32: (context) ->
    data = @pixelsData32
    for p in @
      i = @pixelWordIndex p
      c = patch.color
      a = if c.length is 4 then c[3] else 255
      if @pixelsAreLittleEndian
      then data[i] = (a << 24) | (c[2] << 16) | (c[1] << 8) | c[0]
      else data[i] = (c[0] << 24) | (c[1] << 16) | (c[2] << 8) | a
    @pixelsContext.putImageData @pixelsImageData, 0, 0
    return if @size is 1
    context.drawImage @pixelsContext.canvas, 0, 0, context.canvas.width, context.canvas.height

  floodFillOnce: (aset, fCandidate, fJoin, fCallback, fNeighbors = ((patch) -> patch.n),
      asetLast = []) ->
    super aset, fCandidate, fJoin, fCallback, fNeighbors, asetLast

  # Diffuse the value of patch variable `patch.v` by distributing `rate` percent
  # of each patch's value of `v` to its neighbors. If a color `c` is given,
  # scale the patch's color to be `patch.v` of `c`. If the patch has
  # less than 8 neighbors, return the extra to the patch.
  diffuse: (v, rate, c) -> # variable name, diffusion rate, max color (optional)
    # zero temp variable if not yet set
    unless @[0]._diffuseNext?
      patch._diffuseNext = 0 for patch in @
    # pass 1: calculate contribution of all patches to themselves and neighbors
    for patch in @
      dv = patch[v] * rate
      dv8 = dv / 8
      nn = patch.neighbors().length
      patch._diffuseNext += patch[v] - dv + (8 - nn) * dv8
      for neighbor in patch.neighbors()
        neighbor._diffuseNext += dv8
    # pass 2: set new value for all patches, zero temp, modify color if c given
    for patch in @
      patch[v] = patch._diffuseNext
      patch._diffuseNext = 0
      if c
        patch.fractionOfColor c, patch[v]
    null # avoid returning copy of @

# A *very* simple shapes module for drawing
# [NetLogo-like](http://ccl.northwestern.edu/netlogo/docs/) agents.

ABM.shapes = ABM.util.s = do ->
  # Each shape is a named object with two members: 
  # a boolean rotate and a draw procedure and two optional
  # properties: img for images, and shortcut for a transform-less version of draw.
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
  # The list of current shapes, via `ABM.shapes.names()` below, is:
  #
  #     ["default", "triangle", "arrow", "bug", "pyramid", 
  #      "circle", "square", "pentagon", "ring", "cup", "person"]
  
  # A simple polygon utility:  c is the 2D context, and a is an array of 2D points.
  # c.closePath() and c.fill() will be called by the calling agent, see initial 
  # discription of drawing context.  It is used in adding a new shape above.
  poly = (c, a) ->
    for p, i in a
      if i is 0 then c.moveTo p[0], p[1] else c.lineTo p[0], p[1]
    null

  # Centered drawing primitives: centered on x,y with a given width/height size.
  # Useful for shortcuts
  circ = (c, x, y, s) -> c.arc x, y, s / 2, 0, 2 * Math.PI # centered circle

  ccirc = (c, x, y, s) -> c.arc x, y, s / 2, 0, 2 * Math.PI, true # centered counter clockwise circle

  cimg = (c, x, y, s, img) ->
    c.scale 1,-1
    c.drawImage img, x - s / 2, y - s / 2, s, s
    c.scale 1,-1 # centered image

  csq = (c, x, y, s) -> c.fillRect x - s / 2, y - s / 2, s, s # centered square
  
  # An async util for delayed drawing of images into sprite slots
  fillSlot = (slot, img) ->
    slot.context.save()
    slot.context.scale 1, -1
    slot.context.drawImage img, slot.x, -(slot.y + slot.bits), slot.bits, slot.bits
    slot.context.restore()

  # The spritesheet data, indexed by bits
  spriteSheets = []
  
  # The module returns the following object:
  default:
    rotate: true
    draw: (c) -> poly c, [[.5, 0], [-.5, -.5], [-.25, 0], [-.5, .5]]

  triangle:
    rotate: true
    draw: (c) -> poly c, [[.5, 0], [-.5, -.4],[-.5, .4]]

  arrow:
    rotate: true
    draw: (c) ->
      poly c, [[.5,0], [0, .5], [0, .2], [-.5, .2], [-.5, -.2], [0, -.2], [0, -.5]]

  bug:
    rotate: true
    draw: (c) ->
      c.strokeStyle = c.fillStyle
      c.lineWidth = .05
      poly c, [[.4, .225], [.2, 0], [.4, -.225]]
      c.stroke()
      c.beginPath()
      circ c, .12, 0, .26
      circ c, -.05, 0, .26
      circ c, -.27, 0, .4

  pyramid:
    rotate: false
    draw: (c) -> poly c, [[0, .5], [-.433, -.25], [.433, -.25]]

  circle: # Note: NetLogo's dot is simply circle with a small size
    shortcut: (c, x, y, s) ->
      c.beginPath()
      circ c, x, y, s
      c.closePath()
      c.fill()
    rotate: false
    draw: (c) -> circ c, 0, 0, 1 # c.arc 0, 0,.5, 0, 2 * Math.PI

  square:
    shortcut: (c, x, y, s) -> csq c, x, y, s
    rotate: false
    draw: (c) -> csq c, 0, 0, 1 #c.fillRect -.5, -.5, 1 , 1

  pentagon:
    rotate: false
    draw: (c) ->
      poly c, [[0, .45], [-.45, .1], [-.3, -.45], [.3, -.45], [.45, .1]]

  ring:
    rotate: false
    draw: (c) ->
      circ c, 0, 0, 1
      c.closePath()
      ccirc c, 0, 0, .6

  person:
    rotate: false
    draw: (c) ->
      poly c, [
        [.15, .2], [.3, 0], [.125, -.1], [.125, .05], [.1, -.15], [.25, -.5],
        [.05, -.5], [0, -.25], [-.05, -.5], [-.25, -.5], [-.1, -.15],
        [-.125, .05], [-.125, -.1], [-.3, 0], [-.15, .2]
      ]
      c.closePath()
      circ c, 0, .35, .30

  # Return a list of the available shapes, see above.
  names: ->
    (name for own name, val of @ when val.rotate? and val.draw?)

  # Add your own shape. Will be included in names list.  Usage:
  #
  #     ABM.shapes.add "test", true, (c) -> # bowtie/hourglass
  #       ABM.shapes.poly c, [[-.5, -.5], [.5, .5], [-.5, .5], [.5, -.5]]
  #
  # Note: an image that is not rotated automatically gets a shortcut. 
  add: (name, rotate, draw, shortcut) -> # draw can be an image, shortcut defaults to null
    if u.isFunction draw
      s = {rotate, draw}
    else
      s = {rotate, img:draw, draw:(c) -> cimg c, .5, .5, 1, @img}

    @[name] = s

    if shortcut? # can override img default shortcut if needed
      s.shortcut = shortcut
    else if s.img? and not s.rotate
      s.shortcut = (c, x, y, s) ->
        cimg c, x, y, s, @img

  # Add local private objects for use by add() and debugging
  poly:poly, circ:circ, ccirc:ccirc, cimg:cimg, csq:csq # export utils for use by add

  spriteSheets:spriteSheets # export spriteSheets for debugging, showing in DOM

  # Two draw procedures, one for shapes, the other for sprites made from shapes.
  draw: (context, shape, x, y, size, rad, color) ->
    if shape.shortcut?
      context.fillStyle = u.colorString color unless shape.img?
      shape.shortcut context, x, y, size
    else
      context.save()
      context.translate x, y
      context.scale size, size if size isnt 1
      context.rotate rad if rad isnt 0
      if shape.img? # is an image, not a path function
        shape.draw context
      else
        context.fillStyle = u.colorString color
        context.beginPath()
        shape.draw context
        context.closePath()
        context.fill()
      context.restore()
    shape

  drawSprite: (context, s, x, y, size, rad) ->
    if rad is 0
      context.drawImage s.context.canvas, s.x, s.y, s.bits, s.bits, x-size / 2,
        y-size / 2, size, size
    else
      context.save()
      context.translate x, y # see http://goo.gl/VUlhY for drawing centered rotated images
      context.rotate rad
      context.drawImage s.context.canvas, s.x, s.y, s.bits, s.bits, -size / 2,
        -size / 2, size, size
      context.restore()
    s

  # Convert a shape to a sprite by allocating a sprite sheet "slot" and drawing
  # the shape to fit it. Return existing sprite if duplicate.
  shapeToSprite: (name, color, size) ->
    bits = Math.ceil ABM.patches.toBits size
    shape = @[name]
    index = if shape.img? then name else "#{name}-#{u.colorString(color)}"
    context = spriteSheets[bits]
    # Create sheet for this bit size if it does not yet exist
    unless context?
      spriteSheets[bits] = context = u.createContext bits * 10, bits
      context.nextX = 0
      context.nextY = 0
      context.index = {}
    # Return matching sprite if index match found
    return foundSlot if (foundSlot = context.index[index])?
    # Extend the sheet if we're out of space
    if bits*context.nextX is context.canvas.width
      u.resizeContext context, context.canvas.width, context.canvas.height + bits
      context.nextX = 0
      context.nextY++
    # Create the sprite "slot" object and install in index object
    x = bits * context.nextX
    y = bits * context.nextY
    slot = {context, x, y, size, bits, name, color, index}
    context.index[index] = slot
    # Draw the shape into the sprite slot
    if (img = shape.img)? # is an image, not a path function
      if img.height isnt 0 then fillSlot(slot, img)
      else img.onload = -> fillSlot(slot, img)
    else
      context.save()
      context.scale bits, bits
      context.translate context.nextX + .5, context.nextY + .5
      context.fillStyle = u.colorString color
      context.beginPath()
      shape.draw context
      context.closePath()
      context.fill()
      context.restore()
    context.nextX++
    slot
