if typeof window == 'undefined'
  t = require "./shared.coffee"
  eval 'var ABM = t.ABM' # because CoffeeScript sets var to null

t = ABM.test
u = ABM.util

describe "Patch", ->
  describe "toString", ->
    it "returns the patch as a string", ->
      model = t.setupModel()
      patch = model.patches.patch x: -20, y: 20
      
      expect(patch.toString())
        .toBe '{id: 0 position: {x: -20, y: 20}, c: 0, 0, 0}'

  describe "empty", ->
    it "returns true if the patch is empty", ->
      model = t.setupModel()
      patch = model.patches.patch x: -20, y: 20
      agent = model.agents[0]

      agent.moveTo x: -20, y: 20
      expect(patch.empty()).toBe false

      agent.moveTo x: -19, y: 20
      expect(patch.empty()).toBe true

  describe "isOnEdge", ->
    it "returns true if the patch is on the edge", ->
      model = t.setupModel()
      patch = model.patches.patch x: -20, y: 20
      
      expect(patch.isOnEdge()).toBe true

      patch2 = model.patches.patch x: -10, y: 20

      expect(patch2.isOnEdge()).toBe true

      patch3 = model.patches.patch x: -10, y: 11

      expect(patch3.isOnEdge()).toBe false

  describe "sprout", ->
    it "gets the patch", ->
      model = t.setupModel()
      patch = model.patches.patch x: -20, y: 20

      agent_count = model.agents.length
      @adder = new ABM.Array

      test = (object) => # keep context
        @adder.push object.id

      patch.sprout(2, model.agents, test)

      expect(model.agents.length).toBe agent_count + 2
      expect(@adder.length).toBe 2
      expect(@adder.last()).toBe model.agents.last().id

  describe "distance", ->
    it "returns distance to the point", ->
      model = t.setupModel()
      patch = model.patches.patch x: 1, y: 1

      expect(patch.distance({x: 3, y: 1})).toBe 2

  describe "neighbors", ->
    testMiddlePatch = (model) ->
      patch = model.patches.patch(x: 10, y: 10)

      neighbors = patch.neighbors()

      expect(neighbors.length).toBe 8
      expect(neighbors[0].position).toEqual x: 9, y: 9
      expect(neighbors[7].position).toEqual x: 11, y: 11

      neighbors = patch.neighbors(1)

      expect(neighbors.length).toBe 8

      neighbors = patch.neighbors(2)

      expect(neighbors.length).toBe 24
      expect(neighbors[0].position).toEqual x: 8, y: 8
      expect(neighbors[23].position).toEqual x: 12, y: 12

      middlePatch = model.patches.patch(x: 1, y: 1)

      neighbors = middlePatch.neighbors()

      expect(neighbors.length).toBe 8
      expect(neighbors[0].position).toEqual x: 0, y: 0
      expect(neighbors[1].position).toEqual x: 1, y: 0
      expect(neighbors[2].position).toEqual x: 2, y: 0

    testMiddlePatchDiamond = (model) ->
      patch = model.patches.patch(x: 10, y: 10)

      neighbors = patch.neighbors(diamond: 1)

      expect(neighbors.length).toBe 4
      expect(neighbors[0].position).toEqual x: 10, y: 9
      expect(neighbors[3].position).toEqual x: 10, y: 11

      neighbors = patch.neighbors(diamond: 4)

      expect(neighbors.length).toBe 40
      expect(neighbors[0].position).toEqual x: 10, y: 6
      expect(neighbors[1].position).toEqual x: 9, y: 7
      expect(neighbors[39].position).toEqual x: 10, y: 14

      neighbors = patch.neighbors(diamond: 4)

      expect(neighbors.length).toBe 40

    it "returns the neighbors requested if the world is euclidian", ->
      model = t.setupModel()

      testMiddlePatch(model)

    it "returns the diamond neighbors if the world is euclidian", ->
      model = t.setupModel()

      testMiddlePatchDiamond(model)

      bottomRightPatch = model.patches.patch(x: 17, y: 17)
      neighbors = bottomRightPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 80
      expect(neighbors[0].position).toEqual x: 17, y: 10
      expect(neighbors[79].position).toEqual x: 20, y: 20

      topLeftPatch = model.patches.patch(x: -18, y: -18)
      neighbors = topLeftPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 65
      expect(neighbors[0].position).toEqual x: -20, y: -20
      expect(neighbors[1].position).toEqual x: -19, y: -20
      expect(neighbors[64].position).toEqual x: -18, y: -11

    it "returns the neighbors requested if the world is a torus", ->
      model = t.setupModel(torus: true)

      testMiddlePatch(model)

    it "returns the diamond neighbors if the world is a torus", ->
      model = t.setupModel(torus: true)

      testMiddlePatchDiamond(model)

      bottomRightPatch = model.patches.patch(x: 17, y: 17)
      neighbors = bottomRightPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 112
      expect(neighbors[0].position).toEqual x: 17, y: 10
      expect(neighbors[111].position).toEqual x: 17, y: -17

      topLeftPatch = model.patches.patch(x: -18, y: -18)
      neighbors = topLeftPatch.neighbors(diamond: 7)

      expect(neighbors.length).toBe 112
      expect(neighbors[0].position).toEqual x: -18, y: 16
      expect(neighbors[1].position).toEqual x: -19, y: 17
      expect(neighbors[54].position).toEqual x: -20, y: -18

    it "caches correcly", ->
      model = t.setupModel()
      patch = model.patches.patch(x: 10, y: 10)

      neighbors = patch.neighbors(range: 1, cache: false)
      expect(patch.neighborsCache).toEqual {}

      neighbors = patch.neighbors(range: 1)
      expect(patch.neighborsCache['{"range":1}'].length).toBe 8
