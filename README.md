### AgentScript

AgentBase is a minimalist Agent Based Modeling (ABM) platform that allows you to quickly build models that run directly in the browser. It follows [NetLogo](http://ccl.northwestern.edu/netlogo/)'s Agent Oriented Programming model and is entirely implemented in [CoffeeScript](http://coffeescript.org/). Tinker with models and share them on [agentbase.org](http://agentbase.org/) or drop by our [Google Group](https://groups.google.com/forum/?hl=en#!forum/agentbase) to get involved.

We think:
- ABM models should be easy to share and run directly from a webpage. No software to install.
- AgentBase is optimized for the rapid development of illustrative models: It values minimalism over complexity, readable and pretty code over cpu performance, and sensible defaults over configurability. It is [opinionated software](https://gettingreal.37signals.com/ch04_Make_Opinionated_Software.php).
- [NetLogo](http://ccl.northwestern.edu/netlogo/) (the most commonly used ABM toolset) is a great inspiration. However, we don't try to copy every bit of it. The web is not the desktop. Coffeescript is not Logo.
- AgentBase is well-tested through automated testing and thus a platform that you can trust. [See for yourself] TODO.

#### Documentation

Documentation is hosted on [GitHub](http://wybo.github.io/agentbase) and on [docs.agentbase.org](http://docs.agentbase.org/). It is generated from docco in the source code.

[**template.html**](http://docs.agentbase.org/template.html) is a trivial subclass of Model showing the basic structure how you build your own models. In addition, the models/ directory contains 10 simple models used in teaching NetLogo. You can [run the model here](models/template.html).

[**agents.coffee**](docs/agents.html) The Agentset subclass for class Agents and class Agent which it manages.

[**patches.coffee**](docs/patches.html) The Agentset subclass for class Patches and class Patch which it manages.

[**links.coffee**](docs/links.html) The Agentset subclass for class Links and class Link which it manages.

[**model.coffee**](docs/model.html) is the top level integration for all the agentsets and is subclassed by all user models.

[**util.coffee**](docs/util.html): is the base module for tools used by the rest of the project.

[**util_shapes.coffee**](docs/util_shapes.html): contains the default shapes and a few functions for getting named shapes and adding your own shapes.

[**util_array.coffee**](docs/util_array.html): contains array helpers. If you don't want them added to Array, you should set TODO in your model.

[**agentset.coffee**](docs/breedestset.html) AgentSet is the core Array subclass used by patches, agents, and links.

#### Sample Models

The models/ directory contains example models that you can use to get started with. They show what AgentBase can do. Some print to the console.log, so opening the developer's JavaScript console will show model information.

[**ants.html**](models/ants.html) A model of ant foraging behavior incorporating a nest location and food pheromone diffusion.

[**buttons.html**](models/buttons.html) Stuart Kauffman's example of randomly connecting pairs of buttons in a pile resulting in a tipping point.

[**diffusion.html**](models/diffusion.html) Agents randomly flying on a patch grid dropping a color which is diffused over the grid.

[**fire.html**](models/fire.html) A CA (cellular automata) based model of fire spreading and burn behavior.

[**flock.html**](models/flock.html) The classic "boids" model where agents each follow three simple rules resulting in realistic flocking. This example uses the as.dat.gui.js extra.

[**headlessflock.html**](models/headlessflock.html) The same classic "boids" model as above, only this time agents are rendered as DOM elements instead of being drawn to a canvas.

[**gridpath.html**](models/gridpath.html) One of Knuth's great puzzles on the probability of all Manhattan traversals diagonally traversing a grid.

[**linktravel.html**](models/linktravel.html) Agents traversing a graph of nodes and links.

[**nbody.html**](models/nbody.html) A simulation of the nonlinear gravitation of n bodies.

[**prefattach.html**](models/prefattach.html) An example of a dynamic graph where new links preferentially attach to the nodes that have the most links.  This results in a power-law distribution.

[**tspga.html**](models/tspga.html) A Traveling Sales Person solution via a Genetic Algorithm showing the rapid conversion of stochastic methods.

[**droplets.html**](models/droplets.html) A simple GIS model based on an ESRI asc elevation file where droplet agents seek low-elevation patches. This example uses the data.js extra.

[**tiledroplets.html**](models/tiledroplets.html) A model similar to the above droplets.html, but here the droplets move on top of a Leaflet map, and elevation data is loaded from a tileserver as the map is panned. This example uses the data.js, data.tile.js, and as.dat.gui.js extras.

[**life.html**](models/life.html) An implementation of [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) with a twist. This example demonstrates running multiple models on the same page.

#### Sample Models Format

Our example models use CoffeeScript directly within the browser via `text/coffeescript` [script tags](http://coffeescript.org/#scripts):

      <html>
        <head>
          <title>AgentScript Model</title>
          <script src="agentscript.js"></script>
          <script src="coffee-script.js"></script>
          <script type="text/coffeescript">
          class MyModel extends ABM.Model
                ...
          model = new MyModel {
            div: "layers",
            size: 6,
            minX: -40,
            maxX: 40,
            minY: -40,
            maxY: 40
          }
                ...
          </script>
        </head>
        <body>
          <div id="layers"></div>
        </body>
      </html>

You can see this by running a sample model, then using the browser's View Page Source.

Many of the models print to the "JavaScript console" while they run.

#### Building a Model

Class Model is an "abstract class" with three abscract methods:

    startup() Called from Model ctor for loading files needed by model.
    setup()   Called during startup and by Model.reset()
    step()    Called by animator to advance the model one step

CoffeeScript modelers simply subclass ABM.Model, supplying the three abstract methods.  All the sample models do this, including the docs/ template example.

JavaScript modelers can simply replace the empty ABM.Model abstract methods:

    myModel = function () {
      var u = ABM.util; // useful alias for utilities
      ABM.Model.prototype.startup = function () {...};
      ABM.Model.prototype.setup = function () {...};
      ABM.Model.prototype.step = function () {...};

      // Startup like CoffeeScript examples
      var model = new MyModel({
        div: "layers",
        size: 6,
        minX: -40,
        maxX: 40,
        minY: -40,
        maxY: 40
      })
      .debug() // Debug: Put Model vars in global name space
      .start();
    }

See [sketches/jsmodel.html](sketches/jsmodel.html) for a random walker in JavaScript.  We'll also have more of our models/ converted to JavaScript in the future.

#### Files

    Gulpfile.coffee     Gulp file for build, docs etc.
    LICENSE             GPLv3 License
    README.md           This file
    STYLEGUIDE.txt      Suggestions for coding-style 
    package.json        NPM Package file, see npm install below
    docs/               Docco documentation
    lib/                All .js/min.js files
    models/             Sample models
    src/                Component .coffee files for agentscript.coffee
    tools/              coffee-script.js and others

#### Build

Install the dev dependencies with

    npm install

and build with

    npm run all

Our tasks are all run via npm run <task>` and they are:

    watch         # Watch for source file updates, invoke build
    build         # compile and minify src/ and extras/ to lib/
    docs          # use docco on sources to create docs/
    all           # Compile coffee, minify js, create docs

Behind the scenes npm invokes [gulp](http://gulpjs.com/), whose tasks
are defined in Gulpfile.coffee. The command "npm run all" is equivalent
to "gulp all". The "npm run" commands are defined in package.json.

#### Contribute

If you would like to contribute, please make sure all the unit tests ("cake test") and sample models work as expected before you create a pull-request. If you add new functionality, add matching tests as well.

In addition, make sure the docco files display correctly. They can be built with `npm run docs`. Use your browser on docs/ to test. Note that all single line comments are converted into docs using Markdown. Be careful not to mistakenly add a "code" comment to the docs!

The typical workflow looks like:

* npm run watch - process files when they change.
* npm run all - compile & minify all code, create docs. Done before git add to insure everything is ready for git.
* npm run git-diff - diff all source and related files.  Good for creating complete commit comments. You may want to pipe this into your editor.
* npm run git-prep - in master, invokes "npm run all", git add ., git status.  Used prior to commiting, stages all files. Remember to git rm any files that are removed so that remote correctly sync'ed.
* npm run git-commit - in master, commit locally and push to github

#### License

Copyright (c) Wybo Wiersma, 2014, (http://agentbase.org). AgentBase
is licensed under the [GNU General Public License, version 
3](http://www.fsf.org/licensing/licenses/gpl-3.0.html). AgentBase 
was derived from and inspired by [AgentScript](http://agentscript.org)
by Owen Densmore, RedfishGroup LLC, 2012-13 (under the same license).

AgentBase is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program, see LICENSE within the distribution.
If not, see <http://www.gnu.org/licenses/>.
