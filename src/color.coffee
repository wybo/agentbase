# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Returns a color based on a given string.
#
class ABM.Color extends ABM.Array
  @COLORS = {
    aliceblue: [240, 248, 255], antiquewhite: [250, 235, 215],
    aqua: [0, 255, 255], aquamarine: [127, 255, 212],
    azure: [240, 255, 255], beige: [245, 245, 220],
    bisque: [255, 228, 196], black: [0, 0, 0],
    blanchedalmond: [255, 235, 205], blue: [0, 0, 255],
    blueviolet: [138, 43, 226], brown: [165, 42, 42],
    burlywood: [222, 184, 135], cadetblue: [95, 158, 160],
    chartreuse: [127, 255, 0], chocolate: [210, 105, 30],
    coral: [255, 127, 80], cornflowerblue: [100, 149, 237],
    cornsilk: [255, 248, 220], crimson: [220, 20, 60],
    cyan: [0, 255, 255], darkblue: [0, 0, 139],
    darkcyan: [0, 139, 139], darkgoldenrod: [184, 134, 11],
    darkgray: [169, 169, 169], darkgreen: [0, 100, 0],
    darkkhaki: [189, 183, 107], darkmagenta: [139, 0, 139],
    darkolivegreen: [85, 107, 47], darkorange: [255, 140, 0],
    darkorchid: [153, 50, 204], darkred: [139, 0, 0],
    darksalmon: [233, 150, 122], darkseagreen: [143, 188, 143],
    darkslateblue: [72, 61, 139], darkslategray: [47, 79, 79],
    darkturquoise: [0, 206, 209], darkviolet: [148, 0, 211],
    deeppink: [255, 20, 147], deepskyblue: [0, 191, 255],
    dimgray: [105, 105, 105], dodgerblue: [30, 144, 255],
    firebrick: [178, 34, 34], floralwhite: [255, 250, 240],
    forestgreen: [34, 139, 34], fuchsia: [255, 0, 255],
    gainsboro: [220, 220, 220], ghostwhite: [248, 248, 255],
    gold: [255, 215, 0], goldenrod: [218, 165, 32],
    gray: [128, 128, 128], green: [0, 128, 0],
    greenyellow: [173, 255, 47], honeydew: [240, 255, 240],
    hotpink: [255, 105, 180], indianred: [205, 92, 92],
    indigo: [75, 0, 130], ivory: [255, 255, 240],
    khaki: [240, 230, 140], lavender: [230, 230, 250],
    lavenderblush: [255, 240, 245], lawngreen: [124, 252, 0],
    lemonchiffon: [255, 250, 205], lightblue: [173, 216, 230],
    lightcoral: [240, 128, 128], lightcyan: [224, 255, 255],
    lightgoldenrodyellow: [250, 250, 210], lightgray: [211, 211, 211],
    lightgreen: [144, 238, 144], lightpink: [255, 182, 193],
    lightsalmon: [255, 160, 122], lightseagreen: [32, 178, 170],
    lightskyblue: [135, 206, 250], lightslategray: [119, 136, 153],
    lightsteelblue: [176, 196, 222], lightyellow: [255, 255, 224],
    lime: [0, 255, 0], limegreen: [50, 205, 50],
    linen: [250, 240, 230], magenta: [255, 0, 255],
    maroon: [128, 0, 0], mediumaquamarine: [102, 205, 170],
    mediumblue: [0, 0, 205], mediumorchid: [186, 85, 211],
    mediumpurple: [147, 112, 219], mediumseagreen: [60, 179, 113],
    mediumslateblue: [123, 104, 238], mediumspringgreen: [0, 250, 154],
    mediumturquoise: [72, 209, 204], mediumvioletred: [199, 21, 133],
    midnightblue: [25, 25, 112], mintcream: [245, 255, 250],
    mistyrose: [255, 228, 225], moccasin: [255, 228, 181],
    navajowhite: [255, 222, 173], navy: [0, 0, 128],
    oldlace: [253, 245, 230], olive: [128, 128, 0],
    olivedrab: [107, 142, 35], orange: [255, 165, 0],
    orangered: [255, 69, 0], orchid: [218, 112, 214],
    palegoldenrod: [238, 232, 170], palegreen: [152, 251, 152],
    paleturquoise: [175, 238, 238], palevioletred: [219, 112, 147],
    papayawhip: [255, 239, 213], peachpuff: [255, 218, 185],
    peru: [205, 133, 63], pink: [255, 192, 203],
    plum: [221, 160, 221], powderblue: [176, 224, 230],
    purple: [128, 0, 128], red: [255, 0, 0],
    rosybrown: [188, 143, 143], royalblue: [65, 105, 225],
    saddlebrown: [139, 69, 19], salmon: [250, 128, 114],
    sandybrown: [244, 164, 96], seagreen: [46, 139, 87],
    seashell: [255, 245, 238], sienna: [160, 82, 45],
    silver: [192, 192, 192], skyblue: [135, 206, 235],
    slateblue: [106, 90, 205], slategray: [112, 128, 144],
    snow: [255, 250, 250], springgreen: [0, 255, 127],
    steelblue: [70, 130, 180], tan: [210, 180, 140],
    teal: [0, 128, 128], thistle: [216, 191, 216],
    tomato: [255, 99, 71], turquoise: [64, 224, 208],
    violet: [238, 130, 238], wheat: [245, 222, 179],
    white: [255, 255, 255], whitesmoke: [245, 245, 245],
    yellow: [255, 255, 0], yellowgreen: [154, 205, 50],
  }

  @_color_list = []
  @_color_cache = {}

  # ### Static members

  # Helper static wrapper converting an array into an `ABM.Color`.
  #
  # It gains access to all the methods below. Ex:
  #
  #     array = [1, 2, 3]
  #     ABM.Array.from(array)
  #     randomNr = array.random()
  #
  @from: (array, arrayType = ABM.Array) ->
    arrayString = array.toString()

    if !@_color_cache[arrayString]
      array.__proto__ = ABM.Color.prototype ? ABM.Color.constructor.prototype
      @_color_cache[arrayString] = array
      @_color_list.push arrayString
      if @_color_list.length > 200
        delete @_color_cache[@_color_list.shift()]

    return @_color_cache[arrayString]

  # Helper static for getting the color from one of the 140 CSS
  # color names.
  #
  @fromName: (colorIn) ->
    colorIn = colorIn.toLowerCase().replace /(\s|-)/, ""

    # All colors are set as ABM.Color.red at the bottom of this file.
    return @[colorIn]

  # Helper static for getting the rgb array from a hex string.
  #
  # Acceptable input:
  #
  # #ff00ff
  # #ffa
  # ffa
  #
  @fromHex: (colorIn) ->
    colorIn = colorIn.toLowerCase()

    if /^#?([0-9]|[a-f])+$/.test colorIn
      if colorIn[0] == '#'
        colorIn = colorIn.subStr(1, 6)

      if colorIn.length is 3
        colorIn = colorIn[0] + colorIn[0] + colorIn[1] + colorIn[1] +
          colorIn[2] + colorIn[2]

      if colorIn.length is 6
        return @from [
          parseInt(colorIn.slice(0, 2), 16)
          parseInt(colorIn.slice(2, 4), 16)
          parseInt(colorIn.slice(4, 6), 16)
        ]

  # Return a random Color.
  #
  # Plain random if no arg.
  #
  # "gray", or type: "gray", for gray
  # "bright", or type: "bright", for a bright colormap
  # "map", or map: [the, colors], for a selection from a set
  # min: min r, g & b color
  # max: max r, g & b color
  #
  # Colormaps are incompatible with min & max.
  #
  @random: (options = {}) ->
    if u.isString(options)
      if options == "map"
        options = map: [0, 63, 127, 191, 255]
      else
        options = type: options

    if options.type == "bright"
      return @random map: [0, 127, 255]

    if options.map
      color = [u.array.sample(options.map), u.array.sample(options.map),
        u.array.sample(options.map)]
    else
      color = []

      if options.type == "gray"
        min = options.min || 64
        max = options.max || 192

        random = u.randomInt min, max

        for i in [0..2]
          color[i] = random
      else
        min = options.min || 0
        max = options.max || 256

        for i in [0..2]
          color[i] = u.randomInt min, max

    return new Color color

  # Constructs the ABM.Color object.
  #
  # WARNING: Needs constructor or subclassing Array won't work
  #
  # Accepts a name, hex string, or rgb array.
  #
  constructor: (colorIn) ->
    color = colorIn
    if !u.isArray color
      color = @constructor.fromName(colorIn) ||
        @constructor.fromHex(colorIn)
      if !u.isArray color
        u.error "unless you're using basic colors, specify an rgb array [nr, nr, nr]"

    return @constructor.from(color)

  # Return new color, c, by scaling each value of the rgb color max.
  #
  fraction: (fraction) ->
    color = []

    for value in @
      color.push u.clamp(Math.round(value * fraction), 0, 255)

    return new Color color

  # Returns a new color, lightened with float fraction of 0..255.
  #
  brighten: (fraction) ->
    color = []

    for value in @
      color.push u.clamp(Math.round(value + fraction * 255), 0, 255)

    return new Color color

  # Return HTML color as used by canvas element. Can include Alpha.
  #
  rgbString: ->
    if !@_rgbString?
      if @[3]? and @[3] > 1
        u.error "alpha > 1"
      if @[3]?
        @_rgbString = "rgba(#{@[0]},#{@[1]},#{@[2]},#{@[3]})"
      else
        @_rgbString = "rgb(#{@[0]},#{@[1]},#{@[2]})"

    return @_rgbString

  # Compare two colors. Alas, there is no array.Equal operator.
  #
  equals: (color2) ->
    @toString() is color2.toString()

for name, array of ABM.Color.COLORS
  ABM.Color[name] = ABM.Color.from(array)
