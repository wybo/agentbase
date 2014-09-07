# An array, with some helper methods added in from ABM.util.array.
#
# It is a subclass of `Array` and is the base class for `ABM.Set`.
#
# Note: subclassing `Array` can be dangerous but thus far we've
# resolved all related problems. See Trevor Burnham's
# [comments](http://goo.gl/Lca8g)
#
# Shim for `Array.indexOf` if not implemented.
#
# Use [es5-shim](https://github.com/kriskowal/es5-shim) if additional
# shims are needed.
#
Array::indexOf or= (given) ->
  for object, i in @
    return i if object is given
  -1
  # TODO look into more.

# Keeps a copy of the original sort method for use within our
# redifinition.
#
Array::_sort = Array::sort

class ABM.Array extends Array
  # ### Static members
  
  # A static wrapper function converting an array into an `ABM.Array`.
  #
  # It gains access to all the methods below. Ex:
  #
  #   array = [1, 2, 3]
  #   ABM.Array.from(array)
  #   randomNr = array.random()
  #
  @from: (array, arrayType = ABM.Array) ->
    array.__proto__ = arrayType.prototype ? arrayType.constructor.prototype
    array
 
  # Constructs the ABM.Array.
  #
  # WARNING: Needs constructor or subclassing Array won't work
  #
  constructor: (options...) ->
    return @constructor.from(options)
 
# ### Extending

# All methods are added by this call.
#
ABM.util.array.extender.extendArray('ABM.Array')
