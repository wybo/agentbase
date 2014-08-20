t = require "./test.coffee"

ABM = t.ABM
u = ABM.util

describe "Set", ->
  describe "from", ->
    # TODO make new class so it is clear
    it "Turns the array into an ABM.Set", ->
      set = ABM.Set.from [1, 2]

      expect(set.length).toBe 2
      expect(typeof set.setDefault).toBe 'function'

  describe "setDefault", ->
    it "Sets the default", ->
      model = t.setupModel()

      model.agents.setDefault('size', 17)
 
      expect(ABM.Agent::size).toBe 17
