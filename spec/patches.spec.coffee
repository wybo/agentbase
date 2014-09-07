if typeof window == 'undefined'
  t = require "./shared.coffee"
  eval 'var ABM = t.ABM' # because CoffeeScript sets var to null

t = ABM.test
u = ABM.util

describe "Patches", ->
  describe "patchIndex", ->
    it "returns the index for the patch", ->
      model = t.setupModel()
      index = model.patches.patchIndex x: 0, y: 0

      expect(index).toBe 840

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
      model = t.setupModel(torus: true)

      coordinate = model.patches.coordinate x: 50, y: 25
      expect(coordinate).toEqual x: 9, y: -16

  # TODO finish
