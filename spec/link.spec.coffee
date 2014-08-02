t = require "./test.coffee"

ABM = t.ABM
u = ABM.util

class LinkModel extends t.Model
  setup: ->
    super

    for [i, j] in [[1, 2], [2, 3], [2, 4], [5, 11]]
      @links.create(@agents[i], @agents[j])

describe "Link", ->
  describe "die", ->
    it "removes the link", ->
      model = t.setupModel(model: LinkModel)
      link = model.links[0]
      from = link.from
      to = link.to

      link.die()

      #expect(link).toEqual(null)
      expect(from.links.length).toEqual(0)
      expect(to.links.length).toEqual(2)

  describe "bothEnds", ->
    it "returns both ends", ->
      model = t.setupModel(model: LinkModel)
      link = model.links[0]

      both = link.bothEnds()

      expect(both.length).toEqual 2
      expect(both[0].id).toBe(link.from.id)
      expect(both[1].id).toBe(link.to.id)

  describe "length", ->
    it "returns the length between both ends", ->
      model = t.setupModel(model: LinkModel)
      link = model.links[0]

      expect(link.length()).toBeCloseTo 1.41

      long = model.links[3]

      expect(long.length()).toBeCloseTo 8.49

  describe "otherEnd", ->
    it "returns the other end", ->
      model = t.setupModel(model: LinkModel)
      link = model.links[1]

      expect(link.otherEnd(link.from)).toBe link.to
      expect(link.otherEnd(link.to)).toBe link.from
