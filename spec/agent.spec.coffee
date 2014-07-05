t = require "./test.coffee"

ABM = t.ABM
u = ABM.util

describe "Agent", ->
  describe "toString", ->
    it "gives the string representation of an agent", ->
      model = t.setupModel()
      agent = model.agents[0]
      agent.heading = 2.25
      # TODO make from string
      agent.color = u.colorFromString("red")

      expect(agent.toString()).toEqual(
        "{id: 0, position: {x: -20.00, y: -20.00}, c: 255,0,0, h: 2.25}")

  describe "moveTo", ->
    it "moves to the given location", ->
      model = t.setupModel()
      agent = model.agents[0]

      agent.moveTo x: 17, y: 15
      patch = model.patches.patch x: 17, y: 15

      expect(agent.position).toEqual x: 17, y: 15
      expect(agent.patch).toBe patch
      expect(patch.agents[0]).toBe agent

      agent.moveTo x: 11, y: 12
      patch = model.patches.patch x: 11, y: 12

      expect(agent.position).toEqual x: 11, y: 12
      expect(patch.agents[0]).toBe agent

  describe "moveOff", ->
    it "moves the agent off the grid", ->
      model = t.setupModel()
      agent = model.agents[0]

      agent.moveOff()

      expect(agent.patch).toBe null
      expect(agent.position).toBe null

  describe "forward", ->
    it "moves the agent forward", ->
      model = t.setupModel()
      agents = model.agents

      agents[0].face(agents[1].position)
      agents[0].forward(Math.sqrt(2))

      expect(agents[0].position.x).toBeCloseTo agents[1].position.x
      expect(agents[0].position.y).toBeCloseTo agents[1].position.y
      expect(agents[0].patch).toBe agents[1].patch

  describe "rotate", ->
    it "rotates the agent", ->
      model = t.setupModel()
      agent = model.agents[0]

      agent.heading = old_heading = 1.5
      angle = 2.1
      agent.rotate(angle)

      expect(agent.heading).toBeCloseTo old_heading + angle

  describe "face", ->
    it "makes the agent face the given point", ->
      model = t.setupModel()
      agent = model.agents[0]

      agent.face(x: 0, y: 0)

      expect(agent.heading).toBeCloseTo u.degreesToRadians(45)

  describe "neighbors", ->
    it "returns the neighbors in euclidian space", ->
      agents = t.setupModel().agents

      neighbors = agents[20].neighbors(3)

      expect(neighbors.length).toBe 6

      neighbors = agents[40].neighbors(2)

      expect(neighbors.length).toBe 2

    it "returns no neighbors if there are none", ->
      agent = t.setupModel().agents[20]
      agent.moveTo x: -10, y: 10

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

      agents[0].moveTo x: 0, y: 3
      agents[1].moveTo x: 0, y: -3

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 6

      agents[20].moveTo x: 0, y: 0.1

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 5

      agents[3].moveTo x: 0, y: 3.1

      neighbors = agents[20].neighbors(radius: 3)
      expect(neighbors.length).toBe 6

    it "returns the cone neighbors", ->
      agents = t.setupModel().agents

      agents[20].heading = 0

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(180), radius: 3)
      expect(neighbors.length).toBe 2

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(360), radius: 3)
      expect(neighbors.length).toBe 4

      agents[0].moveTo x: 0, y: 2

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(180), radius: 3)
      expect(neighbors.length).toBe 3

      neighbors = agents[20].neighbors(cone: u.degreesToRadians(90), radius: 3)
      expect(neighbors.length).toBe 2
