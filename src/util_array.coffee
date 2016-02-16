# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

# Array utility functions. Are added to ABM.Array.
#
# TODO allow be used in user models through an ABM.noArray() function.
#
# @mixin # for codo doc generator
ABM.util.array =
  # The static `ABM.Array.from` as a method.  Used by methods creating
  # new arrays.
  #
  from: (array, arrayType) ->
    return ABM.Array.from array, arrayType

  # Return string representative of agentset.
  #
  toString: (array) ->
    return "[" + (object.toString() for object in array).join(", ") + "]"

  # Return an array of floating pt numbers as strings at given
  # precision; useful for printing.
  #
  toFixed: (array, precision = 2) ->
    newArray = []
    for number in array
      newArray.push number.toFixed precision

    return newArray

  # Does the array have any elements? Is the array empty?
  #
  any: (array) ->
    return not @empty(array)

  # Checks for emptyness.
  #
  empty: (array) ->
    return array.length is 0

  # Clears the array.
  #
  clear: (array) ->
    array.length = 0

    return array

  # Make a copy of the array. Needed when you don't want to modify the
  # given array with mutator methods like sort, splice or your own
  # functions. By giving begin/arguments, retrieve a subset of the
  # array. Works with TypedArrays too.
  #
  clone: (array, begin = null, end = null) ->
    if array.slice?
      method = "slice"
    else
      method = "subarray"

    if begin?
      return array[method] begin, end
    else
      return array[method] 0

  # Return first element of array.
  #
  first: (array) ->
    return array[0]

  # Return last element of array.
  #
  last: (array) ->
    if @empty array
      return undefined
    else
      return array[array.length - 1]

  # Return all elements of array that match condition.
  #
  select: (array, condition) ->
    newArray = new ABM.Array

    for object in array
      if condition(object)
        newArray.push object

    return newArray

  # Return all elements of array that don't match condition.
  #
  reject: (array, condition) ->
    newArray = new ABM.Array

    for object in array
      if !condition(object)
        newArray.push object

    return newArray

  # Return random element of array or number random elements of array.
  #
  # Note: Objects are presumed unique, and the same object will never
  # be included twice if more than one random object is requested.
  #
  # Note: clone, shuffle then first number has poor performance.
  #
  # Options:
  #   size: Size of the requested sample (defaults to one if null).
  #   condition: Function that elements should return true for
  #     elements.
  #
  sample: (array, options) ->
    if !options? or u.isNumber(options)
      options = {size: options}

    if @empty(array) and !options.size?
      return null

    options.size = Math.floor(options.size)

    if options.condition?
      return @sample(@select(array, options.condition), size: options.size)
    else if options.size
      options.uniqueArray ?= array.clone().uniq()
      if options.size > options.uniqueArray.length
        options.size = options.uniqueArray.length

      if options.size * 1.8 > options.uniqueArray.length
        # sampling way more than half, faster to sample those rejected
        rejects = @sample(array, u.merge(options, {size: options.uniqueArray.length - options.size}))
        return @shuffle(@removeItems(options.uniqueArray, rejects))
      else
        newArray = new ABM.Array
        object = true

        while newArray.length < options.size and object?
          # array, not unique to preserve odds
          object = array[u.randomInt array.length]
          if object and object not in newArray
            newArray.push object

        return newArray
    else
      return array[u.randomInt array.length]

  # True if object is in array.
  #
  contains: (array, object) ->
    return array.indexOf(object) >= 0

  # Remove an object from an array.
  #
  # Error if object not in array.
  #
  remove: (array, object) ->
    while true
      index = array.indexOf object
      break if index is -1
      array.splice index, 1

    return array

  # Remove elements in objects from an array. Binary search if f isnt
  # null. Error if an object not in array.
  #
  # TODO: Make part of remove above.
  #
  removeItems: (array, objects) ->
    for object in objects
      @remove array, object

    return array

  # Randomize the elements of this array.
  #
  shuffle: (array) ->
    array.sort -> 0.5 - Math.random()

    return array

  # Return object when call(object) min/max in array. Error if array empty.
  # If f is a string, return element with max value of that property.
  # If "valueToo" then return a 2-array of the element and the value;
  # used for cases where f is costly function.
  #
  #     array = [{x: 1, y: 2}, {x: 3, y: 4}]
  #     array.min()
  #     # returns {x: 1, y: 2} 5
  #
  #     [min, dist2] = array.min(((o) -> o.x * o.x + o.y * o.y), true)
  #     # returns {x: 3, y: 4}
  #
  min: (array, call = u.identityFunction, valueToo = false) ->
    u.error "min: empty array" if @empty array
    if u.isString call
      call = u.propertyFunction call
    minValue = Infinity
    minObject = null

    for object in array
      value = call(object)
      if value < minValue
        minValue = value
        minObject = object

    if valueToo
      return [minObject, minValue]
    else
      return minObject

  # See min.
  #
  max: (array, call = u.identityFunction, valueToo = false) ->
    u.error "max: empty array" if @empty array
    if u.isString call
      call = u.propertyFunction call
    maxValue = -Infinity
    maxObject = null

    for object in array
      value = call(object)
      if value > maxValue
        maxValue = value
        maxObject = object

    if valueToo
      return [maxObject, maxValue]
    else
      return maxObject

  # Sums up the contents of the array.
  #
  sum: (array, call = u.identityFunction) ->
    if u.isString call
      call = u.propertyFunction call

    value = 0
    for object in array
      value += call(object)

    return value

  # Calculates the average of the array.
  #
  average: (array, call = u.identityFunction) ->
    return @sum(array, call) / array.length

  # Returns the median for the array.
  #
  median: (array) ->
    if array.sort?
      array = @clone array
    else
      array = u.typedToJS array

    middle = (array.length - 1) / 2

    @sort array

    return (array[Math.floor(middle)] + array[Math.ceil(middle)]) / 2

  # Return histogram of o when f(o) is a numeric value in array.
  # Histogram interval is bin. Error if array empty. If call
  # is a string, return histogram of that property.
  #
  # In examples below, histogram returns [3, 1, 1, 0, 0, 1]
  #
  #     array = [1, 3, 4, 1, 1, 10]
  #     histogram = histogram array, 2, (i) -> i
  #
  #     hash = ({id:i} for i in array)
  #     histogram = histogram hash, 2, (o) -> o.id
  #     histogram = histogram hash, 2, "id"
  #
  histogram: (array, binSize = 1, call = u.identityFunction) ->
    if u.isString call
      call = u.propertyFunction call
    histogram = []

    for object in array
      integer = Math.floor call(object) / binSize
      histogram[integer] or= 0
      histogram[integer] += 1

    for value, integer in histogram when not value?
      histogram[integer] = 0

    return histogram

  # Mutator. Sort array of objects in place by the function f. If f
  # is string, f returns property of object.
  #
  # Returns array.
  #
  # Clone first if you want to preserve the original array.
  #
  #     array = [{i: 1}, {i: 5}, {i: -1}, {i: 2}, {i: 2}]
  #     sortBy array, "i"
  #     # array now is [{i: -1}, {i: 1}, {i: 2}, {i: 2}, {i:5}]
  #
  sort: (array, call = null) ->
    if u.isString call # use item[f] if f is string
      call = u.propertySortFunction call

    array._sort call

    return array

  # Mutator. Removes dups, by reference, in place from array. Note
  # "by reference" means literally same object, not copy. Returns
  # array. Clone first if you want to preserve the original array.
  #
  #     ids = ({id: i} for i in [0..10])
  #     array = (ids[i] for i in [1, 3, 4, 1, 1, 10])
  #     # array is [{id: 1}, {id: 3}, {id: 4}, {id: 1}, {id: 1}, {id: 10}]
  #
  #     arrayB = clone array
  #     sortBy arrayB, "id"
  #     # arrayB is [{id:1}, {id: 1}, {id: 1}, {id: 3}, {id: 4}, {id: 10}]
  #
  #     uniq arrayB
  #     # arrayB now is [{id:1}, {id: 3}, {id: 4}, {id: 10}]
  #
  uniq: (array) ->
    hash = {}

    i = 0
    while i < array.length
      if hash[array[i]] is true
        array.splice i, 1
        i -= 1
      else
        hash[array[i]] = true
      i += 1

    return array

  # Return a new array composed of the rows of a matrix.
  #
  #     array = [[1, 2, 3], [4, 5, 6]]
  #     array.flatten()
  #     # returns [1, 2, 3, 4, 5, 6]
  #
  flatten: (array) ->
    return array.reduce((arrayA, arrayB) ->
      if not u.isArray arrayA
        arrayA = new ABM.Array arrayA
      arrayA.concat arrayB)

  # Returns a new array that has addArray appended.
  #
  # Concat checks [[ClassName]], and this does not work for things
  # inheriting from Array.
  #
  concat: (array, addArray) ->
    newArray = array.clone()
    if u.isArray addArray
      for element in addArray
        newArray.push element
    else
      newArray.push addArray

    return newArray

  # Return an array with values in [low, high], defaults to [0, 1].
  # Note: to have a half-open interval, [low, high), try high = high - .00009
  #
  normalize: (array, low = 0, high = 1) ->
    min = @min array
    max = @max array
    scale = 1 / (max - min)
    newArray = []

    for number in array
      newArray.push u.linearInterpolate(low, high, scale * (number - min))

    return newArray

  normalizeInt: (array, low, high) ->
    return (Math.round i for i in @normalize array, low, high)

  # ### Property & debugging

  # Useful in console.
  # Also see [CoffeeConsole](http://goo.gl/1i7bd) Chrome extension.
  #
  # Similar to NetLogo ask & with operators.
  # Use:
  #
  #     array.with((object) -> object.x < 5)
  #       .ask((object) -> object.x = object.x + 1)
  #     myModel.agents.with((object) -> object.id < 100)
  #       .ask(object.color = u.color.red)
  #
  ask: (array, call) ->
    for object in array
      call(object)

    return array

  with: (array, functionString) ->
    if u.isString functionString
      eval("f=function(object){return " + functionString + ";}")

    return @from (object for object in array when functionString(object))

  # Property access, also useful for debugging.
  #
  # Return an array of a property of the BreedSet.
  #
  #     array.getProperty("x") # [1, 8, 6, 2, 2]
  #     array.getProperty("x") # [2, 8, 6, 3, 3]
  #
  getProperty: (array, property) ->
    newArray = new ABM.Array
    for object in array
      newArray.push object[property]

    return newArray

  # Set the property of the agents to a given value. If value is an
  # array, its values will be used, indexed by agentSet's index. This
  # is generally used via: getProperty, modify results, setProperty.
  #
  #     set.setProperty "x", 2
  #     # {id: 4, x: 2, y: 3}, {id: 5, x: 2, y: 1}
  #
  setProperty: (array, property, value) ->
    for object in array
      object[property] = value

    return array

  # Return an array without given object.
  #
  #     as = AS.clone().other(AS[0])
  #     as.getProperty "id" # [1, 2, 3, 4]
  #
  other: (array, given) ->
    newArray = new ABM.Array
    for object in array
      if object isnt given
        newArray.push object

    return newArray

# ### Extensions

# Extends ABM.Array and util

ABM.util.array.extender =
  methods: ->
    (key for key, value of ABM.util.array when typeof value is 'function')

  extendArray: (className) ->
    methods = @methods()
    for method in methods
      eval("""
        #{className}.prototype.#{method} = function() {
          var options, _ref, _ret;
          options = 1 <= arguments.length ? Array.prototype.slice.call(arguments, 0) : [];
          _ret = (_ref = u.array).#{method}.apply(_ref, [this].concat(Array.prototype.slice.call(options)));
          if (ABM.util.isArray(_ret)) {
            return this.constructor.from(_ret);
          } else {
            return _ret;
          }
        };""")

# Dummy class for codo doc generator.
#
# @include ABM.util.array
class ABM.Util.Array
