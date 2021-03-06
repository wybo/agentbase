(function() {
  var AgentsCreateModel, LinksCreateModel, Model, code, isHeadless, t, u,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  if (typeof window === 'undefined') {
    code = require("../lib/agentbase.coffee");
    eval('var ABM = this.ABM = code.ABM');
    isHeadless = true;
  }

  u = ABM.util;

  ABM.test = {};

  ABM.test.Model = Model = (function(superClass) {
    extend(Model, superClass);

    function Model() {
      return Model.__super__.constructor.apply(this, arguments);
    }

    Model.prototype.setup = function() {
      this.preSetup();
      this.setupBreeds();
      this.setupPatches();
      this.setupAgents();
      this.setupCitizens();
      return this.setupLinks();
    };

    Model.prototype.preSetup = function() {};

    Model.prototype.setupBreeds = function() {
      return this.agentBreeds(["citizens"]);
    };

    Model.prototype.setupPatches = function() {
      return this.patches.create();
    };

    Model.prototype.setupAgents = function() {
      var agent, i, k, len, max, ref, results;
      i = this.world.min.x;
      max = this.world.max.x - this.world.min.x + 1;
      ref = this.agents.create(max);
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        agent = ref[k];
        agent.moveTo({
          x: i,
          y: i
        });
        results.push(i += 1);
      }
      return results;
    };

    Model.prototype.setupCitizens = function() {
      var citizen, i, j, k, len, ref, results;
      if (this.world.max.x > 15) {
        i = 10;
        j = 10;
        ref = this.citizens.create(10);
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          citizen = ref[k];
          citizen.moveTo({
            x: i,
            y: j
          });
          i += 1;
          if (i > 14) {
            i = 10;
            results.push(j += 1);
          } else {
            results.push(void 0);
          }
        }
        return results;
      }
    };

    Model.prototype.setupLinks = function() {
      var i, j, k, len, ref, ref1, results;
      if (this.world.max.x > 15) {
        ref = [[0, 1], [2, 1], [1, 2], [1, 3], [4, 10]];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          ref1 = ref[k], i = ref1[0], j = ref1[1];
          results.push(this.links.create(this.agents[i], this.agents[j]));
        }
        return results;
      }
    };

    return Model;

  })(ABM.Model);

  ABM.test.setupModel = function(options) {
    var model;
    if (options == null) {
      options = {};
    }
    if (options.model == null) {
      options.model = Model;
    }
    if (options.patchSize == null) {
      options.patchSize = 20;
    }
    if (options.mapSize == null) {
      options.mapSize = 41;
    }
    if (options.isTorus == null) {
      options.isTorus = false;
    }
    if (options.isHeadless == null) {
      options.isHeadless = isHeadless;
    }
    model = new options.model({
      patchSize: options.patchSize,
      mapSize: options.mapSize,
      isTorus: options.isTorus,
      hasNeighbors: true,
      isHeadless: options.isHeadless
    });
    return model;
  };

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Agent", function() {
    describe("toString", function() {
      return it("gives the string representation of an agent", function() {
        var agent, model;
        model = t.setupModel();
        agent = model.agents[0];
        agent.heading = 2.25;
        agent.color = u.color.red;
        return expect(agent.toString()).toEqual("{id: 0, position: {x: -20.00, y: -20.00}, c: [255, 0, 0], h: 2.25/129}");
      });
    });
    describe("moveTo", function() {
      it("moves to the given location", function() {
        var agent, model, oldPatch, oldPatchAgents, patch;
        model = t.setupModel();
        agent = model.agents[0];
        oldPatch = agent.patch;
        oldPatchAgents = oldPatch.agents.length;
        agent.moveTo({
          x: 17,
          y: 15
        });
        patch = model.patches.patch({
          x: 17,
          y: 15
        });
        expect(agent.position).toEqual({
          x: 17,
          y: 15
        });
        expect(agent.patch).toBe(patch);
        expect(patch.agents[0]).toBe(agent);
        expect(oldPatch.agents.length).toBe(oldPatchAgents - 1);
        agent.moveTo({
          x: 11,
          y: 12
        });
        patch = model.patches.patch({
          x: 11,
          y: 12
        });
        expect(agent.position).toEqual({
          x: 11,
          y: 12
        });
        expect(patch.agents[0]).toBe(agent);
        oldPatch = patch;
        agent.moveTo({
          x: 8.5,
          y: 7.4
        });
        patch = model.patches.patch({
          x: 9,
          y: 7
        });
        expect(oldPatch.agents).toEqual(new ABM.Array);
        expect(agent.position).toEqual({
          x: 8.5,
          y: 7.4
        });
        return expect(patch.agents[0]).toBe(agent);
      });
      return it("does not duplicate in agents if it moves twice", function() {
        var agent, model, patch, position;
        model = t.setupModel();
        agent = model.agents[0];
        position = {
          x: 17,
          y: 15
        };
        agent.moveTo(position);
        agent.moveTo(position);
        patch = model.patches.patch(position);
        return expect(patch.agents.length).toEqual(1);
      });
    });
    describe("moveOff", function() {
      return it("moves the agent off the grid", function() {
        var agent, model;
        model = t.setupModel();
        agent = model.agents[0];
        agent.moveOff();
        expect(agent.patch).toBe(null);
        return expect(agent.position).toBe(null);
      });
    });
    describe("forward", function() {
      return it("moves the agent forward", function() {
        var agents, model;
        model = t.setupModel();
        agents = model.agents;
        agents[0].face(agents[1].position);
        agents[0].forward(Math.sqrt(2));
        expect(agents[0].position.x).toBeCloseTo(agents[1].position.x);
        expect(agents[0].position.y).toBeCloseTo(agents[1].position.y);
        return expect(agents[0].patch).toBe(agents[1].patch);
      });
    });
    describe("rotate", function() {
      return it("rotates the agent", function() {
        var agent, angle, model, old_heading;
        model = t.setupModel();
        agent = model.agents[0];
        agent.heading = old_heading = 1.5;
        angle = 2.1;
        agent.rotate(angle);
        return expect(agent.heading).toBeCloseTo(old_heading + angle);
      });
    });
    describe("face", function() {
      return it("makes the agent face the given point", function() {
        var agent, model;
        model = t.setupModel();
        agent = model.agents[0];
        agent.face({
          x: 0,
          y: 0
        });
        return expect(agent.heading).toBeCloseTo(u.degreesToRadians(45));
      });
    });
    describe("distance", function() {
      it("returns the distance to the given point", function() {
        var agents, model;
        model = t.setupModel();
        agents = model.agents;
        return expect(agents[0].distance(agents[1].position)).toBeCloseTo(Math.sqrt(2));
      });
      return it("returns the max dimension distance to the given point", function() {
        var agents, model;
        model = t.setupModel();
        agents = model.agents;
        return expect(agents[0].distance({
          x: 29,
          y: 15
        }, {
          dimension: true
        })).toBe(49);
      });
    });
    describe("neighbors", function() {
      it("returns the neighbors in euclidian space", function() {
        var agents, neighbors;
        agents = t.setupModel().agents;
        neighbors = agents[20].neighbors(3);
        expect(neighbors.length).toBe(6);
        neighbors = agents[40].neighbors(2);
        return expect(neighbors.length).toBe(2);
      });
      it("returns no neighbors if there are none", function() {
        var agent, neighbors;
        agent = t.setupModel().agents[20];
        agent.moveTo({
          x: -10,
          y: 10
        });
        neighbors = agent.neighbors();
        return expect(neighbors.length).toBe(0);
      });
      it("returns the diamond neighbors", function() {
        var agents, neighbors;
        agents = t.setupModel().agents;
        neighbors = agents[20].neighbors({
          diamond: 2
        });
        expect(neighbors.length).toBe(2);
        neighbors = agents[20].neighbors({
          diamond: 3
        });
        expect(neighbors.length).toBe(2);
        neighbors = agents[20].neighbors({
          diamond: 4
        });
        return expect(neighbors.length).toBe(4);
      });
      it("returns the neighbors requested if the world is a torus", function() {
        var agents, neighbors;
        agents = t.setupModel({
          isTorus: true
        }).agents;
        neighbors = agents[40].neighbors(2);
        expect(neighbors.length).toBe(4);
        expect(neighbors[0]).toBe(agents[38]);
        expect(neighbors[1]).toBe(agents[39]);
        expect(neighbors[2]).toBe(agents[0]);
        return expect(neighbors[3]).toBe(agents[1]);
      });
      it("returns the diamond neighbors if the world is a torus", function() {
        var agents, model, neighbors;
        model = t.setupModel({
          isTorus: true
        });
        agents = model.agents;
        neighbors = agents[40].neighbors({
          diamond: 3
        });
        expect(neighbors.length).toBe(2);
        expect(neighbors[0]).toBe(agents[39]);
        return expect(neighbors[1]).toBe(agents[0]);
      });
      it("returns the radius neighbors", function() {
        var agents, neighbors;
        agents = t.setupModel().agents;
        neighbors = agents[20].neighbors({
          radius: 3
        });
        expect(neighbors.length).toBe(4);
        agents[0].moveTo({
          x: 0,
          y: 3
        });
        agents[1].moveTo({
          x: 0,
          y: -3
        });
        neighbors = agents[20].neighbors({
          radius: 3
        });
        expect(neighbors.length).toBe(6);
        agents[20].moveTo({
          x: 0,
          y: 0.1
        });
        neighbors = agents[20].neighbors({
          radius: 3
        });
        expect(neighbors.length).toBe(5);
        agents[3].moveTo({
          x: 0,
          y: 3.1
        });
        neighbors = agents[20].neighbors({
          radius: 3
        });
        return expect(neighbors.length).toBe(6);
      });
      return it("returns the cone neighbors", function() {
        var agents, neighbors;
        agents = t.setupModel().agents;
        agents[20].heading = 0;
        neighbors = agents[20].neighbors({
          cone: u.degreesToRadians(180),
          radius: 3
        });
        expect(neighbors.length).toBe(2);
        neighbors = agents[20].neighbors({
          cone: u.degreesToRadians(360),
          radius: 3
        });
        expect(neighbors.length).toBe(4);
        agents[0].moveTo({
          x: 0,
          y: 2
        });
        neighbors = agents[20].neighbors({
          cone: u.degreesToRadians(180),
          radius: 3
        });
        expect(neighbors.length).toBe(3);
        neighbors = agents[20].neighbors({
          cone: u.degreesToRadians(90),
          radius: 3
        });
        return expect(neighbors.length).toBe(2);
      });
    });
    describe("die", function() {
      return it("dies, is removed from patch and breed list", function() {
        var agent, id, model, patch;
        model = t.setupModel();
        agent = model.agents[0];
        id = agent.id;
        patch = agent.patch;
        agent.die();
        expect(patch.agents.length).toBe(0);
        return expect(model.agents[0].id).not.toBe(id);
      });
    });
    describe("hatch", function() {
      return it("creates num new agents at this location", function() {
        var agent, agents, model;
        model = t.setupModel();
        agent = model.agents[0];
        agent.custo = 1337;
        agent.hatch(2);
        agents = agent.patch.agents;
        expect(agents.length).toBe(3);
        expect(agents[1].custom).toBe(agent.custom);
        return expect(agents[2].custom).toBe(agent.custom);
      });
    });
    describe("otherEnd", function() {
      return it("returns the other end of a link", function() {
        var agents, model;
        model = t.setupModel();
        agents = model.agents;
        model.links.create(agents[0], agents[1]);
        return expect(agents[0].otherEnd(model.links[0])).toBe(agents[1]);
      });
    });
    describe("outLinks", function() {
      return it("returns the outgoing links", function() {
        var agents, links, model;
        model = t.setupModel();
        agents = model.agents;
        links = agents[1].outLinks();
        expect(links.length).toBe(2);
        expect(links[0]).toBe(model.links[2]);
        return expect(links[1]).toBe(model.links[3]);
      });
    });
    describe("inLinks", function() {
      return it("returns the incoming links", function() {
        var agents, links, model;
        model = t.setupModel();
        agents = model.agents;
        links = agents[1].inLinks();
        expect(links.length).toBe(2);
        expect(links[0]).toBe(model.links[0]);
        return expect(links[1]).toBe(model.links[1]);
      });
    });
    describe("linkNeighbors", function() {
      return it("returns all agents linked with", function() {
        var agents, linkedAgents, model;
        model = t.setupModel();
        agents = model.agents;
        linkedAgents = agents[1].linkNeighbors();
        expect(linkedAgents.length).toBe(3);
        expect(linkedAgents[0]).toBe(agents[0]);
        expect(linkedAgents[1]).toBe(agents[2]);
        return expect(linkedAgents[2]).toBe(agents[3]);
      });
    });
    describe("inLinkNeighbors", function() {
      return it("returns all agents that link to this one", function() {
        var agents, linkedAgents, model;
        model = t.setupModel();
        agents = model.agents;
        linkedAgents = agents[1].inLinkNeighbors();
        expect(linkedAgents.length).toBe(2);
        expect(linkedAgents[0]).toBe(agents[0]);
        return expect(linkedAgents[1]).toBe(agents[2]);
      });
    });
    return describe("outLinkNeighbors", function() {
      return it("returns all agents that link to this one", function() {
        var agents, linkedAgents, model;
        model = t.setupModel();
        agents = model.agents;
        linkedAgents = agents[1].outLinkNeighbors();
        expect(linkedAgents.length).toBe(2);
        expect(linkedAgents[0]).toBe(agents[2]);
        return expect(linkedAgents[1]).toBe(agents[3]);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  AgentsCreateModel = (function(superClass) {
    extend(AgentsCreateModel, superClass);

    function AgentsCreateModel() {
      return AgentsCreateModel.__super__.constructor.apply(this, arguments);
    }

    AgentsCreateModel.prototype.setup = function() {
      this.setupPatches();
      this.counter = 0;
      return this.agents.create(2, (function(_this) {
        return function(agent) {
          return _this.counter += 1;
        };
      })(this));
    };

    return AgentsCreateModel;

  })(t.Model);

  describe("Agents", function() {
    describe("in", function() {
      it("returns all instances of the default breed", function() {
        var inBreed, model;
        model = t.setupModel();
        inBreed = model.agents["in"](model.agents);
        expect(inBreed.length).toBe(model.agents.length - model.citizens.length);
        return expect(inBreed.first).toBe(model.agents.first);
      });
      return it("returns all instances of the given breed", function() {
        var citizens, model, noAgents, onlyCitizens;
        model = t.setupModel();
        noAgents = model.agents["in"](model.citizens);
        expect(noAgents.length).toBe(0);
        citizens = model.citizens["in"](model.citizens);
        expect(citizens.length).toBe(model.citizens.length);
        expect(citizens.first).toBe(model.citizens.first);
        onlyCitizens = model.citizens["in"](model.agents);
        return expect(onlyCitizens.length).toBe(model.citizens.length);
      });
    });
    describe("create", function() {
      it("creates the agents", function() {
        var model;
        model = t.setupModel({
          model: AgentsCreateModel
        });
        return expect(model.counter).toBe(model.agents.length);
      });
      return it("creates the agents for breeds", function() {
        var model;
        model = t.setupModel();
        expect(model.agents.length).toBe(51);
        expect(model.citizens.length).toBe(10);
        return expect(model.citizens.last().breed).toBe(model.citizens);
      });
    });
    describe("clear", function() {
      return it("clears agents", function() {
        var model;
        model = t.setupModel();
        model.citizens.clear();
        expect(model.citizens.length).toBe(0);
        return expect(model.agents.length).not.toBe(0);
      });
    });
    describe("neighboring", function() {
      return it("returns agents of same breed that are neighbors", function() {
        var model, neighbors;
        model = t.setupModel();
        neighbors = model.citizens.neighboring(model.citizens[2], 1);
        expect(neighbors.length).toBe(5);
        neighbors = model.citizens.neighboring(model.citizens[0], 8);
        return expect(neighbors.length).toBe(9);
      });
    });
    return describe("formCircle", function() {
      return it("positions the agents in a circle", function() {
        var model;
        model = t.setupModel();
        model.agents.formCircle(10);
        expect(model.agents[0].position.x).toBeCloseTo(0);
        expect(model.agents[0].position.y).toBeCloseTo(10);
        expect(model.agents[10].position.x).toBeCloseTo(9.43);
        expect(model.agents[10].position.y).toBeCloseTo(3.32);
        expect(model.agents[41].position.x).toBeCloseTo(-9.43);
        return expect(model.agents[41].position.y).toBeCloseTo(3.32);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Array", function() {
    describe("from", function() {
      it("turns array into an ABM.Array", function() {
        var array;
        array = ABM.Array.from([3, 2, 1]);
        expect(array.length).toBe(3);
        expect(typeof array.histogram).toBe('function');
        expect(array.constructor.name).toBe('Array');
        return expect(array).toEqual(new ABM.Array(3, 2, 1));
      });
      return it("also works on an ABM.Array", function() {
        var array, first;
        first = ABM.Array.from([3, 2, 1]);
        array = ABM.Array.from(first);
        expect(array.length).toBe(3);
        expect(typeof array.histogram).toBe('function');
        expect(array.constructor.name).toBe('Array');
        return expect(array).toEqual(new ABM.Array(3, 2, 1));
      });
    });
    describe("constructor", function() {
      it("Creates the array", function() {
        var array;
        array = new ABM.Array(1, 2, 3);
        expect(array.length).toBe(3);
        expect(array.constructor.name).toBe('Array');
        array = new ABM.Array([1, 4]);
        return expect(array.length).toBe(1);
      });
      return it("Creates empty arrays correctly", function() {
        var array;
        array = new ABM.Array;
        expect(array.length).toBe(0);
        expect(array.constructor.name).toBe('Array');
        array.push(2);
        expect(array.length).toBe(1);
        expect(array.constructor.name).toBe('Array');
        return expect(array).toEqual(new ABM.Array(2));
      });
    });
    describe("toString", function() {
      return it("returns the array as strings", function() {
        return expect(new ABM.Array(1.334, 5.445, 11.666).toString()).toEqual("[1.334, 5.445, 11.666]");
      });
    });
    describe("toFixed", function() {
      return it("returns the array rounded, as strings", function() {
        return expect(new ABM.Array(1.334, 5.445, 11.666).toFixed(1)).toEqual(new ABM.Array("1.3", "5.4", "11.7"));
      });
    });
    describe("any", function() {
      return it("returns false if empty", function() {
        return expect(new ABM.Array().any()).toBe(false);
      });
    });
    describe("empty", function() {
      return it("returns true if empty", function() {
        expect(new ABM.Array().empty()).toBe(true);
        return expect(new ABM.Array(1, 2).empty()).toBe(false);
      });
    });
    describe("clone", function() {
      return it("returns a copy of the array", function() {
        var array, array2;
        array = new ABM.Array(1, 2, 3);
        array2 = array.clone();
        expect(array).toEqual(ABM.Array.from(array2));
        array2[1] = 7;
        return expect(array[1]).not.toEqual(array2[1]);
      });
    });
    describe("first", function() {
      return it("returns the first element", function() {
        return expect(new ABM.Array(1, 2, 3).first()).toEqual(1);
      });
    });
    describe("last", function() {
      return it("returns the last element", function() {
        return expect(new ABM.Array(1, 2, 3).last()).toEqual(3);
      });
    });
    describe("select", function() {
      return it("returns if a condition is given", function() {
        var array;
        array = new ABM.Array(1, 2, 3, 4, 5, 6).select(function(number) {
          return number % 2 === 0;
        });
        return expect(array).toEqual(new ABM.Array(2, 4, 6));
      });
    });
    describe("sample", function() {
      it("returns null if nothing to match", function() {
        var number;
        number = new ABM.Array().sample();
        return expect(number).toEqual(null);
      });
      it("returns one object if no number given", function() {
        var number;
        u.randomSeed(2);
        number = new ABM.Array(1, 2, 3, 4).sample();
        return expect(number).toEqual(4);
      });
      it("returns the number of objects if number given", function() {
        var array;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 3, 4).sample(2);
        return expect(array).toEqual(new ABM.Array(4, 1));
      });
      it("returns an empty array if nothing to match and a number is given", function() {
        var number;
        number = new ABM.Array().sample(1);
        return expect(number).toEqual(new ABM.Array);
      });
      it("returns sample for which true if condition given", function() {
        var number;
        u.randomSeed(10);
        number = new ABM.Array(1, 2, 3, 4, 5, 6).sample({
          condition: function(number) {
            return number % 2 === 0;
          }
        });
        return expect(number).toEqual(6);
      });
      it("returns sample for which true if condition and size is given", function() {
        var array;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 3, 4, 5, 6).sample({
          size: 2,
          condition: function(number) {
            return number % 2 === 0;
          }
        });
        return expect(array).toEqual(new ABM.Array(4, 2));
      });
      it("returns an empty array if size is 0", function() {
        var array;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 3, 4, 5, 6).sample({
          size: 0
        });
        return expect(array).toEqual(new ABM.Array);
      });
      it("returns an empty array if none are found and size is set", function() {
        var array;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 3, 4, 5, 6).sample({
          size: 3,
          condition: function(number) {
            return number > 10;
          }
        });
        return expect(array).toEqual(new ABM.Array);
      });
      it("returns a sample without duplicates", function() {
        var array;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 2, 3, 4, 5, 6, 6, 5).sample({
          size: 5,
          condition: function(number) {
            return number > 1;
          }
        });
        return expect(array).toEqual(new ABM.Array(2, 4, 3, 5, 6));
      });
      return it("returns a sample even if there are too few elements", function() {
        var array;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 2, 3, 4, 5, 6, 6, 5).sample({
          size: 10,
          condition: function(number) {
            return number > 1;
          }
        });
        return expect(array).toEqual(new ABM.Array(2, 4, 3, 5, 6));
      });
    });
    describe("contains", function() {
      return it("returns true if it contains the element", function() {
        expect(new ABM.Array(1, 2, 3).contains(2)).toBe(true);
        return expect(new ABM.Array(1, 2, 3).contains(5)).toBe(false);
      });
    });
    describe("remove", function() {
      return it("removes the items", function() {
        var array;
        array = new ABM.Array(1, 'z', 7, 7);
        array.remove(7);
        expect(array).toEqual(new ABM.Array(1, 'z'));
        return expect(new ABM.Array(1, 2, 3, 4, 5).remove([2, 4])).toEqual(new ABM.Array(1, 3, 5));
      });
    });
    describe("removeItem", function() {
      return it("removes the item", function() {
        return expect(new ABM.Array(1, 2, 3).removeItem(2)).toEqual(new ABM.Array(1, 3));
      });
    });
    describe("shuffle", function() {
      it("shuffles the array", function() {
        u.randomSeed(2);
        return expect(new ABM.Array(1, 2, 3).shuffle()).toEqual(new ABM.Array(1, 3, 2));
      });
      return it("after shuffle, returns the same array", function() {
        var array, shuffled;
        u.randomSeed(2);
        array = new ABM.Array(1, 2, 3);
        array.booble = true;
        shuffled = array.shuffle();
        return expect(shuffled.booble).toEqual(true);
      });
    });
    describe("min", function() {
      return it("returns the smallest element", function() {
        return expect(new ABM.Array(7, 3, 2, 3).min()).toEqual(2);
      });
    });
    describe("max", function() {
      return it("returns the biggest element", function() {
        return expect(new ABM.Array(7, 3, 2, 3).max()).toEqual(7);
      });
    });
    describe("sum", function() {
      return it("returns the sum", function() {
        return expect(new ABM.Array(7, 3, 2, 3).sum()).toEqual(15);
      });
    });
    describe("average", function() {
      return it("returns the average", function() {
        return expect(new ABM.Array(7, 3, 2, 3).average()).toEqual(3.75);
      });
    });
    describe("median", function() {
      return it("returns the median", function() {
        expect(new ABM.Array(7, 3, 2).median()).toEqual(3);
        return expect(new ABM.Array(7, 3, 2, 4).median()).toEqual(3.5);
      });
    });
    describe("histogram", function() {
      return it("returns the histogram", function() {
        return expect(new ABM.Array(0, 2, 6, 8, 2).histogram(3)).toEqual(new ABM.Array(3, 0, 2));
      });
    });
    describe("sort", function() {
      it("sorts the array", function() {
        var array;
        array = new ABM.Array(2.4, 8, 2);
        array.sort();
        return expect(array).toEqual(new ABM.Array(2, 2.4, 8));
      });
      it("sorts the array with function", function() {
        var array;
        array = new ABM.Array(2.4, 8, 2);
        array.sort(function(objectA, objectB) {
          return Math.floor(objectA) > Math.floor(objectB);
        });
        return expect(array).toEqual(new ABM.Array(2.4, 2, 8));
      });
      return it("sorts an array of hashes", function() {
        var array;
        array = new ABM.Array({
          some: 2.4
        }, {
          some: 8
        }, {
          some: 2
        });
        array.sort("some");
        return expect(array).toEqual(new ABM.Array({
          some: 2
        }, {
          some: 2.4
        }, {
          some: 8
        }));
      });
    });
    describe("uniq", function() {
      return it("returns the array with only unique items", function() {
        var array;
        array = new ABM.Array(0, 2, 1, 0, 8, 2, 1, 1);
        array.uniq();
        return expect(array).toEqual(new ABM.Array(0, 2, 1, 8));
      });
    });
    describe("flatten", function() {
      return it("flattens the matrix to an array", function() {
        expect(new ABM.Array([7], [3, 2], [3]).flatten()).toEqual(new ABM.Array(7, 3, 2, 3));
        return expect(new ABM.Array([3, 2], [5, 7, 9], [3, 66]).flatten()).toEqual(new ABM.Array(3, 2, 5, 7, 9, 3, 66));
      });
    });
    describe("normalize", function() {
      return it("returns the array normalized", function() {
        return expect(new ABM.Array(4, 9, 7).normalize(5, 10)).toEqual(new ABM.Array(5, 10, 8));
      });
    });
    describe("ask", function() {
      return it("runs the function against the array", function() {
        var array;
        array = new ABM.Array({}, {}, {});
        array.ask(function(object) {
          return object.x = 3;
        });
        return expect(array[2].x).toEqual(3);
      });
    });
    describe("with", function() {
      return it("runs the array for which it evaluates to true", function() {
        var array, even, even2, variable;
        array = new ABM.Array(4, 9, 10, 7);
        even = array["with"](function(object) {
          return object % 2 === 0;
        });
        expect(even).toEqual(new ABM.Array(4, 10));
        variable = 3;
        even2 = array["with"](function(object) {
          return object % variable === 0;
        });
        return expect(even2).toEqual(new ABM.Array(9));
      });
    });
    describe("getProperty", function() {
      return it("returns the values for property", function() {
        return expect(new ABM.Array({
          x: 6
        }, {
          y: 77
        }, {
          x: 11
        }).getProperty('x')).toEqual(new ABM.Array(6, void 0, 11));
      });
    });
    describe("setProperty", function() {
      return it("returns the values for property", function() {
        return expect(new ABM.Array({}, {}, {}).setProperty('y', 22)).toEqual(new ABM.Array({
          y: 22
        }, {
          y: 22
        }, {
          y: 22
        }));
      });
    });
    return describe("other", function() {
      return it("returns the array without the given item", function() {
        return expect(new ABM.Array(4, 9, 7).other(9)).toEqual(new ABM.Array(4, 7));
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Set", function() {
    describe("constructor", function() {
      it("Creates the set", function() {
        var set;
        set = new ABM.BreedSet(ABM.Agent, "agents");
        expect(set.length).toBe(0);
        expect(set.name).toBe("agents");
        expect(set.agentClass).toBe(ABM.Agent);
        expect(set.mainSet).toBe(void 0);
        expect(set.breeds).toEqual([]);
        return expect(set.ID).toBe(0);
      });
      return it("Creates a subset", function() {
        var model, set;
        model = t.setupModel();
        set = new ABM.BreedSet(model.Agent, "ducks", model.Agent.prototype.breed);
        expect(set.length).toBe(0);
        expect(set.mainSet.name).toBe("agents");
        expect(set.mainSet.length).toEqual(model.agents.length);
        expect(set.breeds).toBe(void 0);
        expect(set.ID).toBe(void 0);
        expect(model.agents.breeds.length).toBe(1);
        return expect(model.agents.breeds[0].name).toBe("citizens");
      });
    });
    describe("push", function() {
      it("Adds to main set", function() {
        var model, nr, object;
        model = t.setupModel();
        nr = model.agents.ID;
        object = {};
        model.agents.push(object);
        expect(object.id).toBe(nr);
        expect(model.agents.last()).toBe(object);
        return expect(model.citizens.last()).not.toBe(object);
      });
      return it("Adds to sub- (& main) set", function() {
        var model, nr, object;
        model = t.setupModel();
        nr = model.agents.ID;
        object = {};
        model.citizens.push(object);
        expect(object.id).toBe(nr);
        expect(model.citizens.last()).toBe(object);
        return expect(model.agents.last()).toBe(object);
      });
    });
    describe("remove", function() {
      return it("Removes from both sets", function() {
        var agent, model;
        model = t.setupModel();
        agent = model.citizens.first();
        model.citizens.remove(agent);
        expect(model.agents.contains(agent)).not.toBe(true);
        return expect(model.citizens.contains(agent)).not.toBe(true);
      });
    });
    describe("pop", function() {
      return it("Removes last object", function() {
        var agent, model, returned;
        model = t.setupModel();
        agent = model.agents.last();
        returned = model.citizens.pop();
        expect(returned).toBe(agent);
        return expect(model.agents.contains(agent)).not.toBe(true);
      });
    });
    return describe("reBreed", function() {
      return it("Sets the breed", function() {
        var agent, agentsOldId, citizen, citizensOldId, model;
        model = t.setupModel();
        agent = model.agents.first();
        citizen = model.citizens.first();
        agentsOldId = agent.id;
        citizensOldId = citizen.id;
        model.citizens.reBreed(agent);
        expect(agent.breed.name).toBe("citizens");
        expect(agent.id).toBe(agentsOldId);
        model.agents.reBreed(citizen);
        expect(citizen.breed.name).toBe("agents");
        return expect(citizen.id).toBe(citizensOldId);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Color", function() {
    describe("from", function() {
      return it("returns the color with given array", function() {
        var color;
        color = ABM.Color.from([1, 2, 3]);
        expect(color[0]).toEqual(1);
        expect(color[1]).toEqual(2);
        return expect(color[2]).toEqual(3);
      });
    });
    describe("fromName", function() {
      it("returns the rgb", function() {
        return expect(ABM.Color.fromName("green")).toEqual(new ABM.Color([0, 128, 0]));
      });
      return it("returns the rgb even if with spaces", function() {
        return expect(ABM.Color.fromName("dark green")).toEqual(new ABM.Color([0, 100, 0]));
      });
    });
    describe("fromHex", function() {
      it("returns the rgb", function() {
        return expect(ABM.Color.fromHex("00aa0f")).toEqual(new ABM.Color([0, 170, 15]));
      });
      return it("returns the rgb even if uppercase", function() {
        return expect(ABM.Color.fromHex("00AA0F")).toEqual(new ABM.Color([0, 170, 15]));
      });
    });
    describe("random", function() {
      it("returns a random color", function() {
        u.randomSeed(2);
        return expect(ABM.Color.random()).toEqual(new ABM.Color([249, 51, 249]));
      });
      it("returns a random gray", function() {
        u.randomSeed(2);
        return expect(ABM.Color.random("gray")).toEqual(new ABM.Color([188, 188, 188]));
      });
      it("returns a random gray with min and max", function() {
        u.randomSeed(2);
        return expect(ABM.Color.random({
          type: "gray",
          min: 100,
          max: 105
        })).toEqual(new ABM.Color([104, 104, 104]));
      });
      return it("returns a random bright", function() {
        u.randomSeed(2);
        return expect(ABM.Color.random({
          type: "bright"
        })).toEqual(new ABM.Color([255, 0, 255]));
      });
    });
    describe("constructor", function() {
      it("returns the color", function() {
        var color;
        color = new ABM.Color([0, 128, 0]);
        expect(color[0]).toEqual(0);
        expect(color[1]).toEqual(128);
        return expect(color[2]).toEqual(0);
      });
      return it("returns the color from string", function() {
        var color;
        color = new ABM.Color('green');
        expect(color[0]).toEqual(0);
        return expect(color[1]).toEqual(128);
      });
    });
    describe("fraction", function() {
      return it("reduces the color towards white with fraction", function() {
        var color;
        color = new ABM.Color([128, 0, 32]);
        return expect(color.fraction(0.5)).toEqual(new ABM.Color([64, 0, 16]));
      });
    });
    describe("brighten", function() {
      return it("brightens the color by fraction", function() {
        var color;
        color = new ABM.Color([0, 255, 128]);
        return expect(color.brighten(0.1)).toEqual(new ABM.Color([26, 255, 154]));
      });
    });
    describe("rgbString", function() {
      return it("returns the color as an rgb string", function() {
        expect((new ABM.Color([0, 255, 128])).rgbString()).toEqual("rgb(0,255,128)");
        return expect((new ABM.Color([11, 25, 12, 0.4])).rgbString()).toEqual("rgba(11,25,12,0.4)");
      });
    });
    return describe("equals", function() {
      return it("returns true if the colors are equal", function() {
        expect((new ABM.Color([0, 255, 128])).equals(new ABM.Color([0, 255, 128]))).toBe(true);
        return expect((new ABM.Color([0, 255, 128])).equals(new ABM.Color([1, 255, 128]))).toBe(false);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Link", function() {
    describe("die", function() {
      return it("removes the link", function() {
        var from, length, link, model, to;
        model = t.setupModel();
        length = model.links.length;
        link = model.links[0];
        from = link.from;
        to = link.to;
        link.die();
        expect(model.links.length).toEqual(length - 1);
        expect(from.links.length).toEqual(0);
        return expect(to.links.length).toEqual(3);
      });
    });
    describe("bothEnds", function() {
      return it("returns both ends", function() {
        var both, link, model;
        model = t.setupModel();
        link = model.links[0];
        both = link.bothEnds();
        expect(both.length).toEqual(2);
        expect(both[0].id).toBe(link.from.id);
        return expect(both[1].id).toBe(link.to.id);
      });
    });
    describe("length", function() {
      return it("returns the length between both ends", function() {
        var link, long, model;
        model = t.setupModel();
        link = model.links[0];
        expect(link.length()).toBeCloseTo(1.41);
        long = model.links[4];
        return expect(long.length()).toBeCloseTo(8.49);
      });
    });
    return describe("otherEnd", function() {
      return it("returns the other end", function() {
        var link, model;
        model = t.setupModel();
        link = model.links[1];
        expect(link.otherEnd(link.from)).toBe(link.to);
        return expect(link.otherEnd(link.to)).toBe(link.from);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  LinksCreateModel = (function(superClass) {
    extend(LinksCreateModel, superClass);

    function LinksCreateModel() {
      return LinksCreateModel.__super__.constructor.apply(this, arguments);
    }

    LinksCreateModel.prototype.setup = function() {
      var i, j, k, len, ref, ref1, results;
      this.setupPatches();
      this.setupAgents();
      this.counter = 0;
      ref = [[0, 1], [1, 2]];
      results = [];
      for (k = 0, len = ref.length; k < len; k++) {
        ref1 = ref[k], i = ref1[0], j = ref1[1];
        results.push(this.links.create(this.agents[i], this.agents[j], (function(_this) {
          return function(link) {
            return _this.counter += 1;
          };
        })(this)));
      }
      return results;
    };

    return LinksCreateModel;

  })(t.Model);

  describe("Links", function() {
    describe("create", function() {
      return it("creates the link", function() {
        var link, model;
        model = t.setupModel({
          model: LinksCreateModel
        });
        link = model.links[0];
        expect(link.from).toBe(model.agents[0]);
        expect(link.to).toBe(model.agents[1]);
        return expect(model.counter).toBe(2);
      });
    });
    describe("clear", function() {
      return it("clears the list", function() {
        var link, model, to;
        model = t.setupModel();
        link = model.links[2];
        to = link.to;
        model.links.clear();
        expect(model.links.length).toBe(0);
        return expect(to.links.length).toBe(0);
      });
    });
    describe("nodesWithDups", function() {
      return it("all nodes, including duplicates", function() {
        var agents, model, nodes;
        model = t.setupModel();
        agents = model.agents;
        nodes = model.links.nodesWithDups();
        expect(nodes.length).toBe(10);
        return expect(nodes[5]).toBe(agents[2]);
      });
    });
    return describe("nodes", function() {
      return it("all nodes, without duplicates", function() {
        var agents, model, nodes;
        model = t.setupModel();
        agents = model.agents;
        nodes = model.links.nodes();
        expect(nodes.length).toBe(6);
        return expect(nodes[5]).toBe(agents[10]);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Model", function() {
    return describe("asSomet", function() {
      return it("Turns the array into a set", function() {
        return expect(2).toBe(2);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Patch", function() {
    describe("toString", function() {
      return it("returns the patch as a string", function() {
        var model, patch;
        model = t.setupModel();
        patch = model.patches.patch({
          x: -20,
          y: 20
        });
        return expect(patch.toString()).toBe('{id: 0 position: {x: -20, y: 20}, c: 0, 0, 0}');
      });
    });
    describe("empty", function() {
      return it("returns true if the patch is empty", function() {
        var agent, model, patch;
        model = t.setupModel();
        patch = model.patches.patch({
          x: -20,
          y: 20
        });
        agent = model.agents[0];
        agent.moveTo({
          x: -20,
          y: 20
        });
        expect(patch.empty()).toBe(false);
        agent.moveTo({
          x: -19,
          y: 20
        });
        return expect(patch.empty()).toBe(true);
      });
    });
    describe("isOnEdge", function() {
      return it("returns true if the patch is on the edge", function() {
        var model, patch, patch2, patch3;
        model = t.setupModel();
        patch = model.patches.patch({
          x: -20,
          y: 20
        });
        expect(patch.isOnEdge()).toBe(true);
        patch2 = model.patches.patch({
          x: -10,
          y: 20
        });
        expect(patch2.isOnEdge()).toBe(true);
        patch3 = model.patches.patch({
          x: -10,
          y: 11
        });
        return expect(patch3.isOnEdge()).toBe(false);
      });
    });
    describe("sprout", function() {
      return it("gets the patch", function() {
        var agent_count, model, patch, test;
        model = t.setupModel();
        patch = model.patches.patch({
          x: -20,
          y: 20
        });
        agent_count = model.agents.length;
        this.adder = new ABM.Array;
        test = (function(_this) {
          return function(object) {
            return _this.adder.push(object.id);
          };
        })(this);
        patch.sprout(2, model.agents, test);
        expect(model.agents.length).toBe(agent_count + 2);
        expect(this.adder.length).toBe(2);
        return expect(this.adder.last()).toBe(model.agents.last().id);
      });
    });
    describe("distance", function() {
      it("returns distance to the point", function() {
        var model, patch;
        model = t.setupModel();
        patch = model.patches.patch({
          x: 1,
          y: 1
        });
        return expect(patch.distance({
          x: 3,
          y: 1
        })).toBe(2);
      });
      it("returns torus distance to the point", function() {
        var model, patch;
        model = t.setupModel({
          isTorus: true
        });
        patch = model.patches.patch({
          x: 1,
          y: 1
        });
        return expect(patch.distance({
          x: 29,
          y: 1
        })).toBe(13);
      });
      it("returns euclidian distance to the point", function() {
        var model, patch;
        model = t.setupModel({
          isTorus: true
        });
        patch = model.patches.patch({
          x: 1,
          y: 1
        });
        return expect(patch.distance({
          x: 29,
          y: 1
        }, {
          euclidian: true
        })).toBe(28);
      });
      it("returns max dimension distance to the point", function() {
        var model, patch;
        model = t.setupModel({
          isTorus: true
        });
        patch = model.patches.patch({
          x: 1,
          y: 1
        });
        return expect(patch.distance({
          x: 29,
          y: 15
        }, {
          dimension: true
        })).toBe(14);
      });
      return it("returns euclidian max dimension distance to the point", function() {
        var model, patch;
        model = t.setupModel({
          isTorus: true
        });
        patch = model.patches.patch({
          x: 1,
          y: 1
        });
        return expect(patch.distance({
          x: 29,
          y: 15
        }, {
          euclidian: true,
          dimension: true
        })).toBe(28);
      });
    });
    return describe("neighbors", function() {
      var testMiddlePatch, testMiddlePatchDiamond;
      testMiddlePatch = function(model) {
        var middlePatch, neighbors, patch;
        patch = model.patches.patch({
          x: 10,
          y: 10
        });
        neighbors = patch.neighbors();
        expect(neighbors.length).toBe(8);
        expect(neighbors[0].position).toEqual({
          x: 9,
          y: 9
        });
        expect(neighbors[7].position).toEqual({
          x: 11,
          y: 11
        });
        neighbors = patch.neighbors(1);
        expect(neighbors.length).toBe(8);
        neighbors = patch.neighbors(2);
        expect(neighbors.length).toBe(24);
        expect(neighbors[0].position).toEqual({
          x: 8,
          y: 8
        });
        expect(neighbors[23].position).toEqual({
          x: 12,
          y: 12
        });
        middlePatch = model.patches.patch({
          x: 1,
          y: 1
        });
        neighbors = middlePatch.neighbors();
        expect(neighbors.length).toBe(8);
        expect(neighbors[0].position).toEqual({
          x: 0,
          y: 0
        });
        expect(neighbors[1].position).toEqual({
          x: 1,
          y: 0
        });
        return expect(neighbors[2].position).toEqual({
          x: 2,
          y: 0
        });
      };
      testMiddlePatchDiamond = function(model) {
        var neighbors, patch;
        patch = model.patches.patch({
          x: 10,
          y: 10
        });
        neighbors = patch.neighbors({
          diamond: 1
        });
        expect(neighbors.length).toBe(4);
        expect(neighbors[0].position).toEqual({
          x: 10,
          y: 9
        });
        expect(neighbors[3].position).toEqual({
          x: 10,
          y: 11
        });
        neighbors = patch.neighbors({
          diamond: 4
        });
        expect(neighbors.length).toBe(40);
        expect(neighbors[0].position).toEqual({
          x: 10,
          y: 6
        });
        expect(neighbors[1].position).toEqual({
          x: 9,
          y: 7
        });
        expect(neighbors[39].position).toEqual({
          x: 10,
          y: 14
        });
        neighbors = patch.neighbors({
          diamond: 4
        });
        return expect(neighbors.length).toBe(40);
      };
      it("returns the neighbors requested if the world is euclidian", function() {
        var model;
        model = t.setupModel();
        return testMiddlePatch(model);
      });
      it("returns the diamond neighbors if the world is euclidian", function() {
        var bottomRightPatch, model, neighbors, topLeftPatch;
        model = t.setupModel();
        testMiddlePatchDiamond(model);
        bottomRightPatch = model.patches.patch({
          x: 17,
          y: 17
        });
        neighbors = bottomRightPatch.neighbors({
          diamond: 7
        });
        expect(neighbors.length).toBe(80);
        expect(neighbors[0].position).toEqual({
          x: 17,
          y: 10
        });
        expect(neighbors[79].position).toEqual({
          x: 20,
          y: 20
        });
        topLeftPatch = model.patches.patch({
          x: -18,
          y: -18
        });
        neighbors = topLeftPatch.neighbors({
          diamond: 7
        });
        expect(neighbors.length).toBe(65);
        expect(neighbors[0].position).toEqual({
          x: -20,
          y: -20
        });
        expect(neighbors[1].position).toEqual({
          x: -19,
          y: -20
        });
        return expect(neighbors[64].position).toEqual({
          x: -18,
          y: -11
        });
      });
      it("returns the neighbors requested if the world is a torus", function() {
        var model;
        model = t.setupModel({
          isTorus: true
        });
        return testMiddlePatch(model);
      });
      it("returns the diamond neighbors if the world is a torus", function() {
        var bottomRightPatch, model, neighbors, topLeftPatch;
        model = t.setupModel({
          isTorus: true
        });
        testMiddlePatchDiamond(model);
        bottomRightPatch = model.patches.patch({
          x: 17,
          y: 17
        });
        neighbors = bottomRightPatch.neighbors({
          diamond: 7
        });
        expect(neighbors.length).toBe(112);
        expect(neighbors[0].position).toEqual({
          x: 17,
          y: 10
        });
        expect(neighbors[111].position).toEqual({
          x: 17,
          y: -17
        });
        topLeftPatch = model.patches.patch({
          x: -18,
          y: -18
        });
        neighbors = topLeftPatch.neighbors({
          diamond: 7
        });
        expect(neighbors.length).toBe(112);
        expect(neighbors[0].position).toEqual({
          x: -18,
          y: 16
        });
        expect(neighbors[1].position).toEqual({
          x: -19,
          y: 17
        });
        return expect(neighbors[54].position).toEqual({
          x: -20,
          y: -18
        });
      });
      return it("caches correcly", function() {
        var model, neighbors, patch;
        model = t.setupModel();
        patch = model.patches.patch({
          x: 10,
          y: 10
        });
        neighbors = patch.neighbors({
          range: 1,
          cache: false
        });
        expect(patch.neighborsCache).toEqual({});
        neighbors = patch.neighbors({
          range: 1
        });
        return expect(patch.neighborsCache['{"range":1}'].length).toBe(8);
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Patches", function() {
    describe("patch", function() {
      it("gets the patch", function() {
        var model, patch;
        model = t.setupModel();
        patch = model.patches.patch({
          x: -20,
          y: 20
        });
        return expect(patch).toBe(model.patches[0]);
      });
      return it("returns the patch even if the coordinate is a float", function() {
        var model, patch;
        model = t.setupModel();
        patch = model.patches.patch({
          x: 0,
          y: 0.2
        });
        return expect(patch.position).toEqual({
          x: 0,
          y: 0
        });
      });
    });
    describe("coordinate", function() {
      it("returns the position as a coordinate", function() {
        var coordinate, model;
        model = t.setupModel();
        coordinate = model.patches.coordinate({
          x: 17,
          y: 15
        });
        expect(coordinate).toEqual({
          x: 17,
          y: 15
        });
        coordinate = model.patches.coordinate({
          x: 37,
          y: 15
        });
        return expect(coordinate).toEqual({
          x: 20.5,
          y: 15
        });
      });
      return it("returns the position as a coordinate also for torus", function() {
        var coordinate, model;
        model = t.setupModel({
          isTorus: true
        });
        coordinate = model.patches.coordinate({
          x: 50,
          y: 25
        });
        return expect(coordinate).toEqual({
          x: 9,
          y: -16
        });
      });
    });
    describe("patchIndex", function() {
      return it("returns the index for the patch", function() {
        var index, model;
        model = t.setupModel();
        index = model.patches.patchIndex({
          x: 0,
          y: 0
        });
        return expect(index).toBe(840);
      });
    });
    return describe("patchRectangle", function() {
      it("returns the rectangle", function() {
        var model, patch, rectangle;
        model = t.setupModel();
        patch = model.patches.patch({
          x: 5,
          y: 10
        });
        rectangle = model.patches.patchRectangle(patch, 2, 2);
        expect(rectangle.length).toEqual(24);
        expect(rectangle[0].position).toEqual({
          x: 3,
          y: 8
        });
        return expect(rectangle[23].position).toEqual({
          x: 7,
          y: 12
        });
      });
      it("returns the rectangle with meToo", function() {
        var model, patch, rectangle;
        model = t.setupModel();
        patch = model.patches.patch({
          x: 5,
          y: 10
        });
        rectangle = model.patches.patchRectangle(patch, 2, 2, true);
        expect(rectangle.length).toEqual(25);
        return expect(rectangle[24].position).toEqual({
          x: 7,
          y: 12
        });
      });
      it("returns the rectangle if it goes over the edge when it isn't a torus", function() {
        var model, patch, rectangle;
        model = t.setupModel({
          mapSize: 5
        });
        patch = model.patches.patch({
          x: 2,
          y: 2
        });
        rectangle = model.patches.patchRectangle(patch, 2, 2);
        expect(rectangle.length).toEqual(8);
        return expect(rectangle[7].position).toEqual({
          x: 1,
          y: 2
        });
      });
      it("returns the rectangle if it goes over the edge when it is a torus", function() {
        var model, patch, rectangle;
        model = t.setupModel({
          mapSize: 5,
          isTorus: true
        });
        patch = model.patches.patch({
          x: 2,
          y: 2
        });
        rectangle = model.patches.patchRectangle(patch, 2, 2);
        expect(rectangle.length).toEqual(24);
        expect(rectangle[17].position).toEqual({
          x: -2,
          y: -2
        });
        return expect(rectangle[23].position).toEqual({
          x: -1,
          y: -1
        });
      });
      return it("returns the rectangle if it goes over the edge when it is a torus", function() {
        var model, patch, rectangle;
        model = t.setupModel({
          mapSize: 4,
          isTorus: true
        });
        patch = model.patches.patch({
          x: 2,
          y: 2
        });
        rectangle = model.patches.patchRectangle(patch, 2, 2);
        expect(rectangle.length).toEqual(15);
        return expect(rectangle[14].position).toEqual({
          x: -1,
          y: -1
        });
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Set", function() {
    describe("constructor", function() {
      return it("Creates a new ABM.Set", function() {
        var set;
        set = new ABM.Set(1, 2);
        expect(set.length).toBe(2);
        expect(typeof set.setDefault).toBe('function');
        return expect(set.constructor.name).toBe('Set');
      });
    });
    describe("from", function() {
      return it("Turns the array into an ABM.Set", function() {
        var set;
        set = ABM.Set.from([1, 2]);
        expect(set.length).toBe(2);
        expect(typeof set.setDefault).toBe('function');
        return expect(set.constructor.name).toBe('Set');
      });
    });
    describe("setDefault", function() {
      it("Sets the default", function() {
        var model;
        model = t.setupModel();
        model.agents.setDefault('size', 17);
        return expect(model.Agent.prototype.size).toBe(17);
      });
      return it("The default gets propagated", function() {
        var model;
        t.Model.prototype.preSetup = function() {
          return this.agents.setDefault("shape", "square");
        };
        model = t.setupModel();
        expect(model.Agent.prototype.shape).toBe("square");
        expect(model.agents[0].shape).toBe("square");
        return expect(model.citizens[0].shape).toBe("square");
      });
    });
    return describe("flatten", function() {
      it("Flattens the set, also with subsets", function() {
        var set, set2;
        set = new ABM.Set(1, 3, 9);
        set2 = set.flatten();
        expect(set2.constructor.name).toBe('Set');
        expect(set2).toEqual(new ABM.Set(1, 3, 9));
        set = new ABM.Set(1, [3, 5, 7], 9);
        expect(set.flatten()).toEqual(new ABM.Set(1, 3, 5, 7, 9));
        set = new ABM.Set([1, 2, 13], [3, 5, 7], [9, 10, 11]);
        expect(set.flatten()).toEqual(new ABM.Set(1, 2, 13, 3, 5, 7, 9, 10, 11));
        set = new ABM.Set(new ABM.Set(1, 2, 13), new ABM.Set(3, 5, 7));
        return expect(set.flatten()).toEqual(new ABM.Set(1, 2, 13, 3, 5, 7));
      });
      return it("Also works with agents/patches in the set", function() {
        var model, patches, set;
        model = t.setupModel();
        patches = model.patches;
        set = new ABM.Set(new ABM.Set(patches[3], patches[1], patches[4]), new ABM.Set(patches[2], patches[8], patches[9]));
        return expect(set.flatten()).toEqual(new ABM.Set(patches[3], patches[1], patches[4], patches[2], patches[8], patches[9]));
      });
    });
  });

  if (typeof window === 'undefined') {
    t = require("./shared.coffee");
    eval('var ABM = t.ABM');
  }

  t = ABM.test;

  u = ABM.util;

  describe("Util", function() {
    if (typeof window !== 'undefined') {
      eval('global = window');
    }
    describe("error", function() {
      return it("throws an error", function() {
        return expect(u.error, "Something").toThrow();
      });
    });
    describe("isArray", function() {
      it("detects arrays, and subclasses of array as arrays", function() {
        var array, arrays, k, len, results;
        arrays = [[], ABM.Agents.from([]), [1, 2, 3], ["some", 4], new ABM.Array(1, 2), new ABM.Set(5, 2, 99), new ABM.Set(), ABM.Set.from([5, 2, 99]), new ABM.BreedSet(ABM.Agent, "agents")];
        results = [];
        for (k = 0, len = arrays.length; k < len; k++) {
          array = arrays[k];
          results.push(expect(u.isArray(array)).toBe(true));
        }
        return results;
      });
      return it("excluded non-arrays", function() {
        var k, len, object, objects, results;
        objects = [
          1, {
            a: 2
          }, function() {
            return 1;
          }
        ];
        results = [];
        for (k = 0, len = objects.length; k < len; k++) {
          object = objects[k];
          results.push(expect(u.isArray(object)).toBe(false));
        }
        return results;
      });
    });
    describe("isFunction", function() {
      it("detects functions", function() {
        return expect(u.isFunction((function(_this) {
          return function() {
            return 1 + 1;
          };
        })(this))).toBe(true);
      });
      return it("rejects non-functions", function() {
        return expect(u.isFunction(1 + 1)).toBe(false);
      });
    });
    describe("isString", function() {
      it("detects strings", function() {
        return expect(u.isString("Big dog " + 2)).toBe(true);
      });
      return it("rejects non-strings", function() {
        return expect(u.isString(function() {
          return 3;
        })).toBe(false);
      });
    });
    describe("isNumber", function() {
      it("detects numbers", function() {
        return expect(u.isNumber(2)).toBe(true);
      });
      return it("rejects non-numbers", function() {
        return expect(u.isNumber(function() {
          return 3;
        })).toBe(false);
      });
    });
    describe("isInteger", function() {
      it("detects integers", function() {
        return expect(u.isInteger(2)).toBe(true);
      });
      it("rejects non-integers", function() {
        return expect(u.isInteger(2.1231)).toBe(false);
      });
      return it("rejects non-numbers too", function() {
        return expect(u.isInteger("Someshit")).toBe(false);
      });
    });
    describe("randomSeed", function() {
      return it("replaces random", function() {
        u.randomSeed(2);
        expect(Math.random()).toBeCloseTo(0.97);
        expect(Math.random()).toBeCloseTo(0.20);
        u.randomSeed(3);
        return expect(Math.random()).toBeCloseTo(0.20);
      });
    });
    describe("randomInt", function() {
      it("returns a random int", function() {
        var k, len, outcome, ref, results;
        u.randomSeed(2);
        ref = [1, 0, 1];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          outcome = ref[k];
          results.push(expect(u.randomInt()).toEqual(outcome));
        }
        return results;
      });
      it("returns a random int with max value", function() {
        u.randomSeed(2);
        return expect(u.randomInt(10)).toEqual(9);
      });
      return it("returns a random int between values", function() {
        return expect(u.randomInt(15, 30)).toEqual(18);
      });
    });
    describe("randomFloat", function() {
      return it("returns a random float", function() {
        var k, len, outcome, ref, results;
        u.randomSeed(2);
        ref = [0.97, 0.20, 0.98];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          outcome = ref[k];
          results.push(expect(u.randomFloat()).toBeCloseTo(outcome));
        }
        return results;
      });
    });
    describe("randomNormal", function() {
      return it("returns numbers out of a normal distribution", function() {
        var k, len, outcome, ref, results;
        u.randomSeed(2);
        ref = [20.87, 3.09, 32.15, 13.15, 36.01, -9.53];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          outcome = ref[k];
          results.push(expect(u.randomNormal(0, 25)).toBeCloseTo(outcome));
        }
        return results;
      });
    });
    describe("randomCentered", function() {
      return it("returns numbers centered ahead in rads", function() {
        var k, len, outcome, ref, results;
        u.randomSeed(2);
        ref = [0.95, -0.60];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          outcome = ref[k];
          results.push(expect(u.randomCentered(2)).toBeCloseTo(outcome));
        }
        return results;
      });
    });
    describe("onceEvery", function() {
      return it("returns true once every number", function() {
        var k, len, outcome, ref, results;
        u.randomSeed(2);
        ref = [true, false];
        results = [];
        for (k = 0, len = ref.length; k < len; k++) {
          outcome = ref[k];
          results.push(expect(u.onceEvery(2)).toBe(outcome));
        }
        return results;
      });
    });
    describe("log10", function() {
      return it("returns log base 10", function() {
        return expect(u.log10(30)).toBeCloseTo(1.48);
      });
    });
    describe("log2", function() {
      return it("returns log base 2", function() {
        return expect(u.log2(8)).toEqual(3);
      });
    });
    describe("logN", function() {
      return it("returns log base X", function() {
        return expect(u.logN(256, 4)).toEqual(4);
      });
    });
    describe("mod", function() {
      return it("returns the correct modulo", function() {
        return expect(u.mod(-5, 4)).toEqual(3);
      });
    });
    describe("wrap", function() {
      return it("returns number wrapped between min and max", function() {
        return expect(u.wrap(7, 10, 20)).toEqual(17);
      });
    });
    describe("clamp", function() {
      return it("returns number clamped between min and max", function() {
        expect(u.clamp(7, 10, 20)).toEqual(10);
        return expect(u.clamp(13, 10, 20)).toEqual(13);
      });
    });
    describe("sign", function() {
      return it("returns the sign of the number", function() {
        return expect(u.sign(-30)).toEqual(-1);
      });
    });
    describe("isLittleEndian", function() {
      return it("returns true on littleEndian systems", function() {
        return expect(u.isLittleEndian()).toBe(true);
      });
    });
    describe("degreesToRadians", function() {
      return it("returns the radians", function() {
        return expect(u.degreesToRadians(90)).toBeCloseTo(1.57);
      });
    });
    describe("radiansToDegrees", function() {
      return it("returns the degrees", function() {
        return expect(u.radiansToDegrees(1)).toBeCloseTo(57.30);
      });
    });
    describe("substractRadians", function() {
      return it("returns the angle, between PI and minus PI", function() {
        return expect(u.substractRadians(1, 8)).toBeCloseTo(-0.72);
      });
    });
    describe("ownKeys", function() {
      return it("returns the attributes", function() {
        var object;
        object = new Object;
        object.bull = "pen";
        object.fly = function() {
          return 1 + 1;
        };
        return expect(u.ownKeys(object)).toEqual(new ABM.Array("bull", "fly"));
      });
    });
    describe("ownVariableKeys", function() {
      return it("returns the attributes that are not functions", function() {
        var object;
        object = new Object;
        object.bull = "pen";
        object.fly = function() {
          return 1 + 1;
        };
        return expect(u.ownVariableKeys(object)).toEqual(new ABM.Array("bull"));
      });
    });
    describe("ownValues", function() {
      return it("returns the values", function() {
        var object;
        object = new Object;
        object.bull = "pen";
        object.fly = function() {
          return 1 + 1;
        };
        return expect(u.ownValues(object)).toEqual(new ABM.Array("pen", object.fly));
      });
    });
    describe("merge", function() {
      return it("returns the merged hashes", function() {
        expect(u.merge({
          a: 1
        }, {
          b: 7
        })).toEqual({
          a: 1,
          b: 7
        });
        expect(u.merge({
          a: 1,
          b: 4
        }, {
          b: 7
        })).toEqual({
          a: 1,
          b: 7
        });
        return expect(u.merge({
          a: 1,
          b: 4
        }, {
          b: 7,
          d: 11
        })).toEqual({
          a: 1,
          b: 7,
          d: 11
        });
      });
    });
    describe("addUp", function() {
      return it("returns the added up hashes", function() {
        expect(u.addUp({
          a: 1
        }, {
          b: 7
        })).toEqual({
          a: 1,
          b: 7
        });
        return expect(u.addUp({
          a: 1,
          b: 4
        }, {
          b: 7,
          c: -5
        })).toEqual({
          a: 1,
          b: 11,
          c: -5
        });
      });
    });
    describe("indexHash", function() {
      return it("returns the hash", function() {
        return expect(u.indexHash(["a", "b"])).toEqual({
          a: 0,
          b: 1
        });
      });
    });
    describe("deIndexHash", function() {
      return it("returns the array", function() {
        expect(u.deIndexHash({
          a: 0,
          b: 1
        })).toEqual(new ABM.Array("a", "b"));
        return expect(u.deIndexHash({
          b: 1,
          a: 0
        })).toEqual(new ABM.Array("a", "b"));
      });
    });
    describe("angle", function() {
      it("returns the radians toward the second point", function() {
        return expect(u.angle({
          x: 1,
          y: 1
        }, {
          x: 3,
          y: 3
        }, {
          isTorus: false
        })).toBeCloseTo(0.79);
      });
      return it("returns the radians toward the second point on a torus", function() {
        expect(u.angle({
          x: 1,
          y: 1
        }, {
          x: 3,
          y: 3
        }, {
          isTorus: true,
          width: 10,
          height: 10
        })).toBeCloseTo(0.79);
        return expect(u.angle({
          x: 1,
          y: 1
        }, {
          x: 3,
          y: 3
        }, {
          isTorus: true,
          width: 3,
          height: 3
        })).toBeCloseTo(-2.36);
      });
    });
    describe("inCone", function() {
      it("returns true if in cone", function() {
        expect(u.inCone(3, 6, 3, {
          x: 1,
          y: 1
        }, {
          x: 2,
          y: 2
        }, {
          isTorus: false
        })).toBe(true);
        return expect(u.inCone(3, 3, 1, {
          x: 1,
          y: 1
        }, {
          x: 2,
          y: 2
        }, {
          isTorus: false
        })).toBe(false);
      });
      return it("returns true if in cone for toruses too", function() {
        expect(u.inCone(3, 6, 3, {
          x: 1,
          y: 1
        }, {
          x: 2,
          y: 2
        }, {
          isTorus: true,
          width: 10,
          height: 10
        })).toBe(true);
        expect(u.inCone(3, 3, 3, {
          x: 1,
          y: 1
        }, {
          x: 2,
          y: 2
        }, {
          isTorus: true,
          width: 10,
          height: 10
        })).toBe(false);
        return expect(u.inCone(3, 3, 3, {
          x: 1,
          y: 1
        }, {
          x: 2,
          y: 2
        }, {
          isTorus: true,
          width: 3,
          height: 3
        })).toBe(true);
      });
    });
    describe("distance", function() {
      it("returns distance between the points", function() {
        expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 3,
          y: 1
        }, {
          isTorus: false
        })).toBe(2);
        return expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, {
          isTorus: false
        })).toBeCloseTo(8.54);
      });
      it("returns max dimension distance between the points", function() {
        expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 3,
          y: 1
        }, {
          isTorus: false
        }, {
          dimension: true
        })).toBe(2);
        return expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, {
          isTorus: false
        }, {
          dimension: true
        })).toBeCloseTo(8);
      });
      it("returns distance between the closest points on the torus", function() {
        expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, {
          isTorus: true,
          width: 20,
          height: 20
        })).toBeCloseTo(8.54);
        return expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, {
          isTorus: true,
          width: 10,
          height: 10
        })).toBeCloseTo(3.61);
      });
      return it("returns max dimension distance between the closest points on the torus", function() {
        expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, {
          isTorus: true,
          width: 20,
          height: 20
        }, {
          dimension: true
        })).toBeCloseTo(8);
        return expect(u.distance({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, {
          isTorus: true,
          width: 10,
          height: 10
        }, {
          dimension: true
        })).toBeCloseTo(3);
      });
    });
    describe("torus4Points", function() {
      return it("returns the 4 reflected points", function() {
        return expect(u.torus4Points({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, 10, 10)).toEqual([
          {
            x: 4,
            y: 9
          }, {
            x: -6,
            y: 9
          }, {
            x: 4,
            y: -1
          }, {
            x: -6,
            y: -1
          }
        ]);
      });
    });
    describe("closestTorusPoint", function() {
      return it("returns the closest of the 4 reflected points", function() {
        return expect(u.closestTorusPoint({
          x: 1,
          y: 1
        }, {
          x: 4,
          y: 9
        }, 10, 10)).toEqual({
          x: 4,
          y: -1
        });
      });
    });
    describe("importImage", function() {
      return it("returns an image object", function() {
        var call, image, source;
        global.Image = (function() {
          function _Class() {}

          return _Class;

        })();
        source = "http://www.duck.com/wing.jpg";
        call = function(object) {
          return object * 23;
        };
        image = u.importImage(source, call);
        expect(image.src).toEqual(source);
        expect(image.isDone).toBe(false);
        return expect(image.onload.toString()).toContain("isDone");
      });
    });
    describe("xhrLoadFile", function() {
      return it("returns an image object", function() {
        var call, request, source, type;
        global.XMLHttpRequest = (function() {
          function _Class() {}

          _Class.prototype.open = function(a, b) {};

          _Class.prototype.send = function() {};

          return _Class;

        })();
        source = "http://www.duck.com/quack.yml";
        type = "unicorns";
        call = function(object) {
          return object * 23;
        };
        request = u.xhrLoadFile(source, null, type, call);
        expect(request.responseType).toEqual(type);
        expect(request.isDone).toBe(false);
        return expect(request.onload.toString()).toContain("isDone");
      });
    });
    describe("filesLoaded", function() {
      return it("returns true if all files were loaded", function() {
        var image, source;
        global.Image = (function() {
          function _Class() {}

          return _Class;

        })();
        u.fileIndex = {};
        source = "http://www.duck.com/beek.jpg";
        expect(u.filesLoaded()).toBe(true);
        image = u.importImage(source);
        expect(u.filesLoaded()).toBe(false);
        u.fileIndex[source].isDone = true;
        return expect(u.filesLoaded()).toBe(true);
      });
    });
    describe("waitOnFiles", function() {
      return it("waits on files that weren't loaded yet", function() {
        var call, image;
        global.Image = (function() {
          function _Class() {}

          return _Class;

        })();
        global.setTimeout = function(call, timeout) {
          u.fileIndex["tail.jpg"].isDone = true;
          return call();
        };
        u.fileIndex = {};
        call = function() {
          return 1 + 1;
        };
        call = jasmine.createSpy();
        image = u.importImage("tail.jpg");
        expect(u.filesLoaded()).toBe(false);
        u.waitOnFiles(call);
        expect(u.filesLoaded()).toBe(true);
        return expect(call).toHaveBeenCalled();
      });
    });
    describe("cloneImage", function() {
      return it("creates a new image object with the same source", function() {
        var clone, image, source;
        global.Image = (function() {
          function _Class() {}

          return _Class;

        })();
        source = "pond.jpg";
        image = new Image;
        image.src = source;
        clone = u.cloneImage(image);
        expect(clone).not.toBe(image);
        return expect(clone.src).toEqual(source);
      });
    });
    describe("imageToData", function() {
      return it("creates a new image object with the same source", function() {
        var data, image, source;
        global.Image = (function() {
          function _Class() {}

          return _Class;

        })();
        source = "pond.jpg";
        image = new Image;
        image.src = source;
        data = u.imageToData(image);
        return expect(data.length).toEqual(0);
      });
    });
    describe("pixelByte", function() {
      return it("returns a pixel byte function", function() {
        return expect(u.pixelByte(1)([1, 2, 3], 1)).toEqual(3);
      });
    });
    describe("linearInterpolate", function() {
      return it("returns a linear interpolation", function() {
        return expect(u.linearInterpolate(1, 5, 0.5)).toEqual(3);
      });
    });
    return describe("typedToJS", function() {
      return it("returns a JS array", function() {
        var array;
        array = new Uint8Array([1, 2]);
        array = u.typedToJS(array);
        return expect(array.sort != null).toBe(true);
      });
    });
  });

}).call(this);
