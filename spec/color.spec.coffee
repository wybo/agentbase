# AgentBase is Free Software (GPL v3 & later), (c) 2014, Wybo Wiersma.

if typeof window == 'undefined'
  t = require "./shared.coffee"
  eval 'var ABM = t.ABM' # because CoffeeScript sets var to null

t = ABM.test
u = ABM.util

describe "Color", ->
  describe "from", ->
    it "returns the color with given array", ->
      color = ABM.Color.from [1, 2, 3]
      expect(color[0]).toEqual 1
      expect(color[1]).toEqual 2
      expect(color[2]).toEqual 3

  describe "fromName", ->
    it "returns the rgb", ->
      expect(ABM.Color.fromName "green")
        .toEqual new ABM.Color [0, 128, 0]

    it "returns the rgb even if with spaces", ->
      expect(ABM.Color.fromName "dark green")
        .toEqual new ABM.Color [0, 100, 0]

  describe "fromHex", ->
    it "returns the rgb", ->
      expect(ABM.Color.fromHex "00aa0f")
        .toEqual new ABM.Color [0, 170, 15]

    it "returns the rgb even if uppercase", ->
      expect(ABM.Color.fromHex "00AA0F")
        .toEqual new ABM.Color [0, 170, 15]

  describe "random", ->
    it "returns a random color", ->
      u.randomSeed(2)
      expect(ABM.Color.random())
        .toEqual new ABM.Color [249, 51, 249]

    it "returns a random gray", ->
      u.randomSeed(2)
      expect(ABM.Color.random("gray"))
        .toEqual new ABM.Color [188, 188, 188]

    it "returns a random gray with min and max", ->
      u.randomSeed(2)
      expect(ABM.Color.random(type: "gray", min: 100, max: 105))
        .toEqual new ABM.Color [104, 104, 104]

    it "returns a random bright", ->
      u.randomSeed(2)
      expect(ABM.Color.random(type: "bright"))
        .toEqual new ABM.Color [255, 0, 255]

  describe "constructor", ->
    it "returns the color", ->
      color = new ABM.Color [0, 128, 0]
      expect(color[0]).toEqual 0
      expect(color[1]).toEqual 128
      expect(color[2]).toEqual 0

    it "returns the color from string", ->
      color = new ABM.Color 'green'
      expect(color[0]).toEqual 0
      expect(color[1]).toEqual 128

  describe "fraction", ->
    it "reduces the color towards white with fraction", ->
      color = new ABM.Color [128, 0, 32]
      expect(color.fraction(0.5)).toEqual new ABM.Color [64, 0, 16]

  describe "brighten", ->
    it "brightens the color by fraction", ->
      color = new ABM.Color [0, 255, 128]
      expect(color.brighten(0.1)).toEqual new ABM.Color [26, 255, 154]

  describe "rgbString", ->
    it "returns the color as an rgb string", ->
      expect((new ABM.Color [0, 255, 128])
        .rgbString()).toEqual "rgb(0,255,128)"
      expect((new ABM.Color [11, 25, 12, 0.4])
        .rgbString()).toEqual "rgba(11,25,12,0.4)"

  describe "equals", ->
    it "returns true if the colors are equal", ->
      expect((new ABM.Color [0, 255, 128]).equals(new ABM.Color [0, 255, 128])).toBe true
      expect((new ABM.Color [0, 255, 128]).equals(new ABM.Color [1, 255, 128])).toBe false
