# AgentBase is Free Software (GPL v3 & later), (c) 2014, Wybo Wiersma.

if typeof window == 'undefined'
  t = require "./shared.coffee"
  eval 'var ABM = t.ABM' # because CoffeeScript sets var to null

t = ABM.test
u = ABM.util

describe "Patches", ->
  describe "patch", ->
    it "gets the patch", ->
      model = t.setupModel()
      patch = model.patches.patch x: -20, y: 20

      expect(patch).toBe model.patches[0]

    it "returns the patch even if the coordinate is a float", ->
      model = t.setupModel()
      patch = model.patches.patch x: 0, y: 0.2

      expect(patch.position).toEqual x: 0, y: 0

  describe "coordinate", ->
    it "returns the position as a coordinate", ->
      model = t.setupModel()

      coordinate = model.patches.coordinate x: 17, y: 15
      expect(coordinate).toEqual x: 17, y: 15

      coordinate = model.patches.coordinate x: 37, y: 15
      expect(coordinate).toEqual x: 20.5, y: 15

    it "returns the position as a coordinate also for torus", ->
      model = t.setupModel(isTorus: true)

      coordinate = model.patches.coordinate x: 50, y: 25
      expect(coordinate).toEqual x: 9, y: -16

  describe "patchIndex", ->
    it "returns the index for the patch", ->
      model = t.setupModel()
      index = model.patches.patchIndex x: 0, y: 0

      expect(index).toBe 840


  describe "patchRectangle", ->
    it "returns the rectangle", ->
      model = t.setupModel()

      patch = model.patches.patch x: 5, y: 10
      rectangle = model.patches.patchRectangle patch, 2, 2
      expect(rectangle.length).toEqual 24
      expect(rectangle[0].position).toEqual x: 3, y: 8
      expect(rectangle[23].position).toEqual x: 7, y: 12

    it "returns the rectangle with meToo", ->
      model = t.setupModel()

      patch = model.patches.patch x: 5, y: 10
      rectangle = model.patches.patchRectangle patch, 2, 2, true
      expect(rectangle.length).toEqual 25
      expect(rectangle[24].position).toEqual x: 7, y: 12

    it "returns the rectangle if it goes over the edge when it isn't a torus", ->
      model = t.setupModel(mapSize: 5)

      patch = model.patches.patch x: 2, y: 2
      rectangle = model.patches.patchRectangle patch, 2, 2
      expect(rectangle.length).toEqual 8
      expect(rectangle[7].position).toEqual x: 1, y: 2

    it "returns the rectangle if it goes over the edge when it is a torus", ->
      model = t.setupModel(mapSize: 5, isTorus: true)

      patch = model.patches.patch x: 2, y: 2
      rectangle = model.patches.patchRectangle patch, 2, 2

      expect(rectangle.length).toEqual 24
      expect(rectangle[17].position).toEqual x: -2, y: -2
      expect(rectangle[23].position).toEqual x: -1, y: -1

    it "returns the rectangle if it goes over the edge when it is a torus", ->
      model = t.setupModel(mapSize: 4, isTorus: true)

      patch = model.patches.patch x: 2, y: 2
      rectangle = model.patches.patchRectangle patch, 2, 2

      expect(rectangle.length).toEqual 15
      expect(rectangle[14].position).toEqual x: -1, y: -1

  # TODO finish
