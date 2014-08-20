#t = require "../src/array.coffee"
#ABM = t.ABM
t = require "./test.coffee"

ABM = t.ABM
u = ABM.util

describe "Array", ->
  describe "from", ->
    it "Turns array into an ABM.Array", ->
      array = ABM.Array.from [3, 2, 1]

      expect(array.length).toBe 3
      expect(typeof array.histogram).toBe 'function'

  describe "constructor", ->
    it "Creates the array", ->
      array = new ABM.Array

      expect(array.length).toBe 0

      array = new ABM.Array 1, 2, 3

      expect(array.length).toBe 3

      array = new ABM.Array [1, 4]

      expect(array.length).toBe 1
