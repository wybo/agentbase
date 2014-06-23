t = require "./test.coffee"

ABM = t.ABM
u = ABM.util

describe "Patch", ->
  describe "neighbors", ->
    testMiddlePatch = (model) ->
      patch = model.patches.patch(10, 10)

      neighbors = patch.neighbors()

      expect(neighbors.length).toBe 8
      expect(neighbors[0].x).toBe 9
      expect(neighbors[0].y).toBe 9
      expect(neighbors[7].x).toBe 11
      expect(neighbors[7].y).toBe 11

      neighbors = patch.neighbors(1)

      expect(neighbors.length).toBe 8

      neighbors = patch.neighbors(2)

      expect(neighbors.length).toBe 24
      expect(neighbors[0].x).toBe 8
      expect(neighbors[0].y).toBe 8
      expect(neighbors[23].x).toBe 12
      expect(neighbors[23].y).toBe 12

      middlePatch = model.patches.patch(1, 1)

      neighbors = middlePatch.neighbors()

      expect(neighbors.length).toBe 8
      expect(neighbors[0].x).toBe 0
      expect(neighbors[0].y).toBe 0
      expect(neighbors[1].x).toBe 1
      expect(neighbors[1].y).toBe 0
      expect(neighbors[2].x).toBe 2
      expect(neighbors[2].y).toBe 0

    testMiddlePatchDiamond = (model) ->
      patch = model.patches.patch(10, 10)

      neighbors = patch.neighbors(diamond: 1)

      expect(neighbors.length).toBe 4
      expect(neighbors[0].x).toBe 10
      expect(neighbors[0].y).toBe 9
      expect(neighbors[3].x).toBe 10
      expect(neighbors[3].y).toBe 11

      neighbors = patch.neighbors(diamond: 4)

      expect(neighbors.length).toBe 40
      expect(neighbors[0].x).toBe 10
      expect(neighbors[0].y).toBe 6
      expect(neighbors[1].x).toBe 9
      expect(neighbors[1].y).toBe 7

      expect(neighbors[39].x).toBe 10
      expect(neighbors[39].y).toBe 14

      neighbors = patch.neighbors(diamond: 4)

      expect(neighbors.length).toBe 40

    it "returns the neighbors requested if the world is euclidian", ->
      model = t.setupModel()

      testMiddlePatch(model)

    it "returns the diamond neighbors if the world is euclidian", ->
      model = t.setupModel()

      testMiddlePatchDiamond(model)

      bottomRightPatch = model.patches.patch(17, 17)
      neighbors = bottomRightPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 80
      expect(neighbors[0].x).toBe 17
      expect(neighbors[0].y).toBe 10
      expect(neighbors[79].x).toBe 20
      expect(neighbors[79].y).toBe 20

      topLeftPatch = model.patches.patch(-18, -18)
      neighbors = topLeftPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 65
      expect(neighbors[0].x).toBe -20
      expect(neighbors[0].y).toBe -20
      expect(neighbors[1].x).toBe -19
      expect(neighbors[1].y).toBe -20
      expect(neighbors[64].x).toBe -18
      expect(neighbors[64].y).toBe -11

    it "returns the neighbors requested if the world is a torus", ->
      model = t.setupModel(torus: true)

      testMiddlePatch(model)

    it "returns the diamond neighbors if the world is a torus", ->
      model = t.setupModel(torus: true)

      testMiddlePatchDiamond(model)

      bottomRightPatch = model.patches.patch(17, 17)
      neighbors = bottomRightPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 112
      expect(neighbors[0].x).toBe 17
      expect(neighbors[0].y).toBe 10
      expect(neighbors[111].x).toBe 17
      expect(neighbors[111].y).toBe -17

      topLeftPatch = model.patches.patch(-18, -18)
      neighbors = topLeftPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 112
      expect(neighbors[0].x).toBe -18
      expect(neighbors[0].y).toBe 16
      expect(neighbors[1].x).toBe -19
      expect(neighbors[1].y).toBe 17
      expect(neighbors[54].x).toBe -20
      expect(neighbors[54].y).toBe -18

    it "caches correcly", ->
      model = t.setupModel()
      patch = model.patches.patch(10, 10)

      neighbors = patch.neighbors(range: 1, cache: false)
      expect(patch.neighborsCache).toEqual {}

      neighbors = patch.neighbors(range: 1)
      expect(patch.neighborsCache['{"range":1}'].length).toBe 8
