code = require "../var/agentscript.coffee"

ABM = code.ABM
u = ABM.util

describe "Util", ->
  describe "error", ->
    it "throws an error", ->
      expect(u.error, "Something").toThrow()

  describe "isArray", ->
    it "detects arrays as arrays", ->
      arrays = [
        []
        ABM.Agents.asSet []
        [1,2,3]
        ["some", 4]
      ]

      for array in arrays
        expect(u.isArray(array)).toBe true

    it "excluded non-arrays", ->
      objects = [
        1
        {a: 2}
        -> 1
      ]

      for object in objects
        expect(u.isArray(object)).toBe false

  describe "isFunction", ->
    it "detects functions", ->
      expect(u.isFunction(=> 1 + 1)).toBe true

    it "rejects non-functions", ->
      expect(u.isFunction(1 + 1)).toBe false

  describe "isString", ->
    it "detects strings", ->
      expect(u.isString("Big dog " + 2)).toBe true

    it "rejects non-strings", ->
      expect(u.isString(-> 3)).toBe false

  describe "isNumber", ->
    it "detects numbers", ->
      expect(u.isNumber(2)).toBe true

    it "rejects non-numbers", ->
      expect(u.isString(-> 3)).toBe false

  describe "randomSeed", ->
    it "replaces random", ->
      u.randomSeed(2)
      expect(Math.random()).toBeCloseTo 0.97
      expect(Math.random()).toBeCloseTo 0.20
      u.randomSeed(3)
      expect(Math.random()).toBeCloseTo 0.20

  describe "randomInt", ->
    it "returns a random int", ->
      u.randomSeed(2)
      for outcome in [1, 0, 1]
        expect(u.randomInt()).toEqual outcome

    it "returns a random int with max value", ->
      u.randomSeed(2)
      expect(u.randomInt(10)).toEqual 9

    it "returns a random int between values", ->
      expect(u.randomInt(15, 30)).toEqual 18

  describe "randomFloat", ->
    it "returns a random float", ->
      u.randomSeed(2)
      for outcome in [0.97, 0.20, 0.98]
        expect(u.randomFloat()).toBeCloseTo outcome

  describe "randomNormal", ->
    it "returns numbers out of a normal distribution", ->
      u.randomSeed(2)
      for outcome in [20.87, 3.09, 32.15, 13.15, 36.01, -9.53]
        expect(u.randomNormal(0, 25)).toBeCloseTo outcome

  describe "randomCentered", ->
    it "returns numbers centered ahead in rads", ->
      u.randomSeed(2)
      for outcome in [0.95, -0.60]
        expect(u.randomCentered(2)).toBeCloseTo outcome

  describe "onceEvery", ->
    it "returns true once every number", ->
      u.randomSeed(2)
      for outcome in [true, false]
        expect(u.onceEvery(2)).toBe outcome

  describe "log10", ->
    it "returns log base 10", ->
      expect(u.log10(30)).toBeCloseTo 1.48

  describe "log2", ->
    it "returns log base 2", ->
      expect(u.log2(8)).toEqual 3

  describe "logN", ->
    it "returns log base X", ->
      expect(u.logN(256, 4)).toEqual 4

  describe "mod", ->
    it "returns the correct modulo", ->
      expect(u.mod(-5, 4)).toEqual 3

  describe "wrap", ->
    it "returns number wrapped between min and max", ->
      expect(u.wrap(7, 10, 20)).toEqual 17

  describe "clamp", ->
    it "returns number clamped between min and max", ->
      expect(u.clamp(7, 10, 20)).toEqual 10
      expect(u.clamp(13, 10, 20)).toEqual 13

  describe "sign", ->
    it "returns the sign of the number", ->
      expect(u.sign(-30)).toEqual -1

  describe "aToFixed", ->
    it "returns the array rounded, as strings", ->
      expect(u.aToFixed([1.334, 5.445, 11.666], 1))
        .toEqual ["1.3", "5.4", "11.7"]

  describe "colorFromString", ->
    it "returns the color as an array", ->
      expect(u.colorFromString("green")).toEqual [0, 128, 0]

    it "throws an error if not supported", ->
      expect(u.colorFromString, "ultrasonicviolet").toThrow()

  describe "brightenColor", ->
    it "brightens the color by fraction", ->
      expect(u.brightenColor([0, 255, 128], 0.1)).toEqual [26, 255, 154]

  describe "colorString", ->
    it "returns the color as a string", ->
      expect(u.colorString([0, 255, 128])).toEqual "rgb(0,255,128)"
      expect(u.colorString([11, 25, 12, 0.4])).toEqual "rgba(11,25,12,0.4)"

  describe "colorsEqual", ->
    it "returns true if the colors are equal", ->
      expect(u.colorsEqual([0, 255, 128], [0, 255, 128])).toBe true
      expect(u.colorsEqual([0, 255, 128], [1, 255, 128])).toBe false

  describe "isLittleEndian", ->
    it "returns true on littleEndian systems", ->
      expect(u.isLittleEndian()).toBe true

  describe "degreesToRadians", ->
    it "returns the radians", ->
      expect(u.degreesToRadians(90)).toBeCloseTo 1.57

  describe "radiansToDegrees", ->
    it "returns the degrees", ->
      expect(u.radiansToDegrees(1)).toBeCloseTo 57.30

  describe "substractRadians", ->
    it "returns the angle, between PI and minus PI", ->
      expect(u.substractRadians(1, 8)).toBeCloseTo -0.72

  describe "ownKeys", ->
    it "returns the attributes", ->
      object = new Object # an object
      object.bull = "pen"
      object.fly = -> 1 + 1
      expect(u.ownKeys(object)).toEqual ["bull", "fly"]

  describe "ownVariableKeys", ->
    it "returns the attributes that are not functions", ->
      object = new Object # an object
      object.bull = "pen"
      object.fly = -> 1 + 1
      expect(u.ownVariableKeys(object)).toEqual ["bull"]

  describe "ownValues", ->
    it "returns the values", ->
      object = new Object # an object
      object.bull = "pen"
      object.fly = -> 1 + 1
      expect(u.ownValues(object)).toEqual ["pen", object.fly]

  describe "any", ->
    it "returns false if empty", ->
      expect(u.any([])).toBe false

  describe "empty", ->
    it "returns true if empty", ->
      expect(u.empty([])).toBe true
      expect(u.empty([1,2])).toBe false

  describe "clone", ->
    it "returns a copy of the array", ->
      array = [1,2,3]
      array2 = u.clone(array)
      expect(array).toEqual array2
      array2[1] = 7
      expect(array).not.toEqual array2

  describe "last", ->
    it "returns the last element", ->
      expect(u.last([1,2,3])).toEqual 3

  describe "sample", ->
    it "returns one object if no number given", ->
      u.randomSeed(2)
      number = u.sample([1, 2, 3, 4])
      expect(number).toEqual 4
  
    it "returns the number object if number given", ->
      u.randomSeed(2)
      array = u.sample([1, 2, 3, 4], 2)
      expect(array).toEqual [4, 1]

    it "returns sample for which true if condition given", ->
      u.randomSeed(10)
      number = u.sample([1, 2, 3, 4, 5, 6], (number) -> number % 2 is 0)
      expect(number).toEqual 2

    it "returns sample for which true if condition and number is given", ->
      u.randomSeed(2)
      array = u.sample([1, 2, 3, 4, 5, 6], 2, (number) -> number % 2 is 0)
      expect(array).toEqual [6, 2]

  describe "contains", ->
    it "returns true if it contains the element", ->
      expect(u.contains([1, 2, 3], 2)).toBe true
      expect(u.contains([1, 2, 3], 5)).toBe false

  describe "remove", ->
    it "removes the item", ->
      expect(u.remove([1, 2, 3], 2)).toEqual [1, 3]
      expect(u.remove, [1, 2, 3], 5).toThrow()

  describe "removeItems", ->
    it "removes the items", ->
      expect(u.removeItems([1, 2, 3, 4, 5], [2, 4])).toEqual [1, 3, 5]

  describe "shuffle", ->
    it "shuffles the array", ->
      u.randomSeed(2)
      expect(u.shuffle([1, 2, 3])).toEqual [1, 3, 2]

  describe "min", ->
    it "returns the smallest element", ->
      expect(u.min([7, 3, 2, 3])).toEqual 2

  describe "max", ->
    it "returns the biggest element", ->
      expect(u.max([7, 3, 2, 3])).toEqual 7

  describe "sum", ->
    it "returns the sum", ->
      expect(u.sum([7, 3, 2, 3])).toEqual 15

  describe "average", ->
    it "returns the average", ->
      expect(u.average([7, 3, 2, 3])).toEqual 3.75

  describe "median", ->
    it "returns the median", ->
      expect(u.median([7, 3, 2])).toEqual 3
      expect(u.median([7, 3, 2, 4])).toEqual 3.5

  describe "histogram", ->
    it "returns the histogram", ->
      expect(u.histogram([0, 2, 6, 8, 2], 3)).toEqual [3, 0, 2]

  describe "sort", ->
    it "sorts the array", ->
      array = [2.4, 8, 2]
      u.sort(array, (objectA, objectB) ->
        Math.floor(objectA) > Math.floor(objectB))
      expect(array).toEqual [2.4, 2, 8]

  describe "uniq", ->
    it "returns the array with only unique items", ->
      array = [0, 2, 0, 8, 2]
      u.uniq(array) # changes array in place
      expect(array).toEqual [0, 2, 8]

  describe "flatten", ->
    it "flattens the matrix to an array", ->
      expect(u.flatten([[7], [3, 2], [3]])).toEqual [7, 3, 2, 3]

  describe "normalize", ->
    it "returns the array normalized", ->
      expect(u.normalize([4, 9, 7], 5, 10)).toEqual [5, 10, 8]

  describe "linearInterpolate", ->
    it "returns a linear interpolation", ->
      expect(u.linearInterpolate(1, 5, 0.5)).toEqual 3

  describe "typedToJS", ->
    it "returns a JS array", ->
      array = Uint8Array([1,2])
      array = u.typedToJS(array)
      expect(array.sort?).toBe true

  describe "radiansToward", ->
    it "returns the radians toward the second point", ->
      expect(u.radiansToward({x: 1, y: 1}, {x: 3, y: 3})).toBeCloseTo 0.79

  describe "inCone", ->
    it "returns true if in cone", ->
      expect(u.inCone(3, 6, 3, {x: 1, y: 1}, {x: 2, y: 2})).toBe true
      expect(u.inCone(3, 3, 1, {x: 1, y: 1}, {x: 2, y: 2})).toBe false

  describe "distance", ->
    it "returns distance between the points", ->
      expect(u.distance({x: 1, y: 1}, {x: 4, y: 9})).toBeCloseTo 8.54

  describe "distance", ->
    it "returns distance between the points", ->
      expect(u.distance({x: 1, y: 1}, {x: 4, y: 9})).toBeCloseTo 8.54

  describe "torusDistance", ->
    it "returns distance between the closest points on the torus", ->
      expect(u.torusDistance({x: 1, y: 1}, {x: 4, y: 9}, 20, 20)).toBeCloseTo 8.54
      expect(u.torusDistance({x: 1, y: 1}, {x: 4, y: 9}, 10, 10)).toBeCloseTo 3.61

  describe "torus4Points", ->
    it "returns the 4 reflected points", ->
      expect(u.torus4Points({x: 1, y: 1}, {x: 4, y: 9}, 10, 10))
        .toEqual [{x: 4, y: 9}, {x: -6, y: 9}, {x: 4, y: -1}, {x: -6, y: -1}]

  describe "closestTorusPoint", ->
    it "returns the closest of the 4 reflected points", ->
      expect(u.closestTorusPoint({x: 1, y: 1}, {x: 4, y: 9}, 10, 10)).toEqual {x: 4, y: -1}

  describe "torusRadiansToward", ->
    it "returns the radians toward the second point on a torus", ->
      expect(u.torusRadiansToward({x: 1, y: 1}, {x: 3, y: 3}, 10, 10)).toBeCloseTo 0.79
      expect(u.torusRadiansToward({x: 1, y: 1}, {x: 3, y: 3}, 3, 3)).toBeCloseTo -2.36

  describe "inTorusCone", ->
    it "returns true if in cone", ->
      expect(u.inTorusCone(3, 6, 3, {x: 1, y: 1}, {x: 2, y: 2}, 10, 10)).toBe true
      expect(u.inTorusCone(3, 3, 3, {x: 1, y: 1}, {x: 2, y: 2}, 10, 10)).toBe false
      expect(u.inTorusCone(3, 3, 3, {x: 1, y: 1}, {x: 2, y: 2}, 3, 3)).toBe true

  describe "importImage", ->
    it "returns an image object", ->
      global.Image = class
      source = "http://www.duck.com/wing.jpg"
      call = (object) -> object * 23
      image = u.importImage(source, call)
      expect(image.src).toEqual source
      expect(image.isDone).toBe false
      expect(image.onload.toString()).toContain("isDone")

  describe "xhrLoadFile", ->
    it "returns an image object", ->
      global.XMLHttpRequest = class
        open: (a, b) ->
        send: ->
      source = "http://www.duck.com/quack.yml"
      type = "unicorns"
      call = (object) -> object * 23
      request = u.xhrLoadFile(source, null, type, call)
      expect(request.responseType).toEqual type
      expect(request.isDone).toBe false
      expect(request.onload.toString()).toContain("isDone")

  describe "filesLoaded", ->
    it "returns true if all files were loaded", ->
      global.Image = class
      u.fileIndex = {}
      source = "http://www.duck.com/beek.jpg"
      expect(u.filesLoaded()).toBe true
      image = u.importImage(source)
      expect(u.filesLoaded()).toBe false
      u.fileIndex[source].isDone = true
      expect(u.filesLoaded()).toBe true

