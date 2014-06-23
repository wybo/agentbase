t = require "./test.coffee"

ABM = t.ABM
u = ABM.util

describe "Agent", ->
  describe "neighbors", ->
    it "returns the neighbors in euclidian space", ->
      agents = t.setupModel().agents

      neighbors = agents[20].neighbors(3)

      expect(neighbors.length).toBe 6

      neighbors = agents[40].neighbors(2)

      expect(neighbors.length).toBe 2

    it "returns no neighbors if there are none", ->
      agent = t.setupModel().agents[20]
      agent.setXY -10, 10

      neighbors = agent.neighbors()

      expect(neighbors.length).toBe 0

    it "returns the diamond neighbors", ->
      agents = t.setupModel().agents

      neighbors = agents[20].neighbors(diamond: 2)
      expect(neighbors.length).toBe 2

      neighbors = agents[20].neighbors(diamond: 3)
      expect(neighbors.length).toBe 2

      #    2       3
      #
      #            #
      #    #      ###
      #   X##    #X###
      #  ##O##  ###O###
      #   ##X    ###X#
      #    #      ###
      #            #

      neighbors = agents[20].neighbors(diamond: 4)
      expect(neighbors.length).toBe 4

    it "returns the neighbors requested if the world is a torus", ->
      agents = t.setupModel(torus: true).agents

      neighbors = agents[40].neighbors(2)
      expect(neighbors.length).toBe 4

      expect(neighbors[0]).toBe agents[38]
      expect(neighbors[1]).toBe agents[39]
      expect(neighbors[2]).toBe agents[0]
      expect(neighbors[3]).toBe agents[1]

    it "returns the diamond neighbors if the world is a torus", ->
      model = t.setupModel(torus: true)

      agents = t.setupModel(torus: true).agents

      neighbors = agents[40].neighbors(diamond: 3)
      expect(neighbors.length).toBe 2

      expect(neighbors[0]).toBe agents[39]
      expect(neighbors[1]).toBe agents[0]

    it "returns the radius neighbors", ->
      agents = t.setupModel().agents

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 4

      agents[0].setXY 0, 3
      agents[1].setXY 0, -3

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 6

      agents[20].setXY 0, 0.1

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 5

      agents[3].setXY 0, 3.1

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 6

    it "returns the cone neighbors", ->
      agents = t.setupModel().agents

      agents[20].heading = 0

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(180), radius: 3)
      expect(neighbors.length).toBe 2

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(360), radius: 3)
      expect(neighbors.length).toBe 4

      agents[0].setXY 0, 2

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(180), radius: 3)
      expect(neighbors.length).toBe 3

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(90), radius: 3)
      expect(neighbors.length).toBe 2
