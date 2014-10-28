### AgentBase

The AgentBase software library allows you to build Agent Based Models (ABMs) that run in the browser. It follows [NetLogo](http://ccl.northwestern.edu/netlogo/)'s Agent oriented Programming model and is entirely implemented in [CoffeeScript](http://coffeescript.org/). Tinker with models on [AgentBase.org](http://agentbase.org/) or drop by our [Google Group](https://groups.google.com/d/forum/agentbase) to get involved. Documentation [is here](http://doc.agentbase.org/).

AgentBase:

* Allows you to easily share and run ABM models, directly from a webpage. No software to install.
* Is optimized for the quick development of illustrative ABM models: It values minimalism over complexity, readable and pretty code over CPU performance, and sensible defaults over choice. It is [opinionated software](https://gettingreal.37signals.com/ch04_Make_Opinionated_Software.php).
* While [NetLogo](http://ccl.northwestern.edu/netlogo/) formed a great inspiration (the most commonly used ABM toolset), AgentBase does not try to copy it (unlike "AgentScript":http://agentscript.org/, from which the AgentBase library is derived). The web is not the desktop. Coffeescript is not Logo.
* AgentBase is well-tested through automated testing and thus a library that you can trust. [See for yourself](http://lib.agentbase.org/spec.html).

#### Sample models

Have a look at these example models.

[Template](http://agentbase.org/model.html?9d54597f7aafc995d227) shows the basic structure of a model and is a good place to get started when you want to try building your own. [Advanced Template](http://agentbase.org/model.html?95eddda521dfaf11c015) is more elaborate.

[Ants](http://agentbase.org/model.html?b24f11b263d0de2610f1) is a model of ant foraging behavior incorporating a nest location and food pheromone diffusion.

[Buttons](http://agentbase.org/model.html?f4c4388138450bdf9732) provides [Stuart Kauffman's example](http://www.msci.memphis.edu/~franklin/kauffman.html) of randomly connecting pairs of buttons in a pile resulting in a tipping point.

[Diffusion](http://agentbase.org/model.html?5a0c13a0e385074a060f) has randomly flying agents on a patch grid dropping a color which is diffused over the grid.

[Fire](http://agentbase.org/model.html?36f24ba1b335aea212eb) is a cellular automata model of fire spreading.

[Flock](http://agentbase.org/model.html?82ef4f46d2a05838dc5f) is the classic "boids" model where agents each follow three simple rules resulting in realistic flocking. This example uses the as.dat.gui.js extra.

[Grid Path](http://agentbase.org/model.html?aabffc060db58fb7032a) shows one of Knuth's great puzzles on the probability of all Manhattan traversals diagonally traversing a grid.

[Life](http://agentbase.org/model.html?d10d06e31f41874b982c) provides an implementation of [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) with a twist. This example demonstrates running multiple models on the same page.

[Link Travel](http://agentbase.org/model.html?96c36a9b3a1760f3c55f) has agents traversing a graph of nodes and links.

[N body](http://agentbase.org/model.html?78e4557ef610be9abf04) is a simulation of the nonlinear gravitation of n bodies.

[Preferential Attachment](http://agentbase.org/model.html?beba752ebfce2daaaa0e) models a dynamic graph where new links preferentially attach to the nodes that have the most links. This results in a power-law distribution.

[Traveling Salesman](http://agentbase.org/model.html?6f0e70c8dd0fabdf7621) demonstrates a [Traveling Sales Person](http://en.wikipedia.org/wiki/Travelling_salesman_problem) solution via a [Genetic Algorithm](http://en.wikipedia.org/wiki/Genetic_algorithm) showing the rapid conversion of stochastic methods.

#### The format of sample models

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

#### Building a model

Visit [agentbase.org](http://agentbase.org) and tinker with the [Template](http://agentbase.org/model.html?9d54597f7aafc995d227), the [Advanced Template](http://agentbase.org/model.html?95eddda521dfaf11c015) or any other example model to get started.

Class ABM.Model has three methods that it calls automatically for you:

    startup() Optional. Called only once, for pre-initializing the model.
    setup()   Called during startup and by Model.reset().
    step()    Called by the animator to advance the model one step.

To build a model from scratch, simply subclass ABM.Model to build a model, supplying the three methods. You can also edit models locally: [Download AgentBase](https://github.com/wybo/agentbase/zipball/master), [unzip it](http://en.wikipedia.org/wiki/Zip_(file_format)), then go to the models directory and edit the [template.html](http://lib.agentbase.org/models/template.html) model you find there.

We'd be grateful if you cite/link to AgentBase when you use it for a model or publication.

#### Development installation

If you want to tinker with AgentBase itself, instead of just building a model that uses it, you will need to do as follows (on Mac/Linux).

Git clone with

    git clone git@github.com:wybo/agentbase.git

    cd agentbase

install the development dependencies with

    npm install

and build with.

    npm run watch

Tasks are all run via npm run <task>` and they are:

    watch         # Watch for source file updates, invoke build
    build         # compile and minify src/ and extras/ to lib/
    doc           # use codo on sources to create docs/
    all           # Compile coffee, minify js, create docs

Behind the scenes npm invokes [gulp](http://gulpjs.com/), whose tasks are defined in Gulpfile.coffee. The command "npm run all" is equivalent to "gulp all". All "npm run" commands are defined in package.json.

#### Contribute

If you would like to contribute, please make sure all the unit tests ("cake test") and sample models work as expected before you create a pull-request. If you add new functionality, add matching tests as well.

In addition, make sure the docs build correctly. They can be built with `npm run codo`. Use your browser on doc/ to test.

Finally, be sure to follow the [STYLEGUIDE.txt](http://lib.agentbase.org/STYLEGUIDE.txt) for code you'd like to see included.

The typical workflow looks like:

Process files when they change

    npm run watch

compile & minify all code, create docs. Done before git add to insure everything is ready for git.

    npm run all

and commit locally.

    git commit -a

See [github](https://guides.github.com/activities/contributing-to-open-source/) for more information on forking and pull-requests.

#### Files

    Gulpfile.coffee     Gulp file for build, docs etc.
    LICENSE             GPLv3 License
    README.md           This file
    STYLEGUIDE.txt      Suggestions for coding-style 
    package.json        NPM Package file, see npm install below
    doc/                Documentation
    lib/                All .js/min.js files
    models/             Sample models
    src/                Component .coffee files for agentscript.coffee
    tools/              coffee-script.js and others

Inside src/ the most important files are:

[Agent.coffee](http://doc.agentbase.org/class/ABM/Agent.html) contains the agents that populate your model.

[Agents.coffee](http://doc.agentbase.org/class/ABM/Agents.html) is the set of @agents you see called in models.

[Patches.coffee](http://doc.agentbase.org/class/ABM/Patches.html) provides the set of @patches that each model has.

[Model.coffee](http://doc.agentbase.org/class/ABM/Model.html) holds the basis for your model. It is subclassed by all models.

[Util.coffee](http://doc.agentbase.org/mixin/ABM/util.html) is the base module for tools.

[Util_array.coffee](http://doc.agentbase.org/mixin/ABM/util.array.html) contains helpers that are included in ABM.Array. You will be using these.

Full documentation can be found on [doc.agentbase.org](http://doc.agentbase.org/).

#### License

AgentBase Copyright (c) Wybo Wiersma, 2014. The AgentBase library
is Free Software, licensed under the [GNU General Public License, version
3](http://www.fsf.org/licensing/licenses/gpl-3.0.html) or any later
version. AgentBase was derived from [AgentScript](http://agentscript.org)
by Owen Densmore and RedfishGroup LLC, 2012-13 (under the same license).

AgentBase is Free Software: you can redistribute it and/or modify
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
