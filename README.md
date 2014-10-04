### AgentBase

AgentBase is a minimalistic Agent Based Modeling (ABM) software library that allows you to build models that run directly in the browser. It follows [NetLogo](http://ccl.northwestern.edu/netlogo/)'s Agent oriented Programming model and is entirely implemented in [CoffeeScript](http://coffeescript.org/). Tinker with models on [AgentBase.org](http://agentbase.org/) or drop by our [Google Group](https://groups.google.com/d/forum/agentbase) to get involved. Documentation [is here](http://doc.agentbase.org/).

AgentBase:

* Allows you to easily share and run ABM models, directly from a webpage. No software to install.
* Is optimized for the quick development of illustrative ABM models: It values minimalism over complexity, readable and pretty code over cpu performance, and sensible defaults over choice. It is [opinionated software](https://gettingreal.37signals.com/ch04_Make_Opinionated_Software.php).
* While [NetLogo](http://ccl.northwestern.edu/netlogo/) is a great inspiration for us (the most commonly used ABM toolset), we don't try to copy every bit of it. Minimalistic is fine. The web is not the desktop. Coffeescript is not Logo.
* AgentBase is well-tested through automated testing and thus a library that you can trust. [See for yourself](http://lib.agentbase.org/spec.html).

#### Sample models

Have a look at these example models.

[Template.html](http://lib.agentbase.org/models/template.html) shows the basic structure of a model and ([if you look at the source](http://agentbase.org/models/template.coffee)) is a good place to get started when you are building your own. [advanced_template.html](http://lib.agentbase.org/models/advanced_template.html) is more elaborate.

[Ants.html](http://lib.agentbase.org/models/ants.html) is a model of ant foraging behavior incorporating a nest location and food pheromone diffusion.

[Buttons.html](http://lib.agentbase.org/models/buttons.html) provides Stuart Kauffman's example of randomly connecting pairs of buttons in a pile resulting in a tipping point.

[Diffusion.html](http://lib.agentbase.org/models/diffusion.html) has randomly flying on a patch grid dropping a color which is diffused over the grid.

[Fire.html](http://lib.agentbase.org/models/fire.html) is a cellular automata model of fire spreading.

[Flock.html](http://lib.agentbase.org/models/flock.html) is the classic "boids" model where agents each follow three simple rules resulting in realistic flocking. This example uses the as.dat.gui.js extra.

[Grid\_path.html](http://lib.agentbase.org/models/grid_path.html) shows one of Knuth's great puzzles on the probability of all Manhattan traversals diagonally traversing a grid.

[Life.html](http://lib.agentbase.org/models/life.html) provides an implementation of [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) with a twist. This example demonstrates running multiple models on the same page.

[Link\_travel.html](http://lib.agentbase.org/models/link_travel.html) has agents traversing a graph of nodes and links.

[N\_body.html](http://lib.agentbase.org/models/n_body.html) is a simulation of the nonlinear gravitation of n bodies.

[Preferential\_attachment.html](http://lib.agentbase.org/models/preferential_attachment.html) is a dynamic graph where new links preferentially attach to the nodes that have the most links.  This results in a power-law distribution.

[Traveling\_salesman.html](http://lib.agentbase.org/models/traveling_salesman.html) demonstrates a Traveling Sales Person solution via a Genetic Algorithm showing the rapid conversion of stochastic methods.

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

[Download AgentBase](https://github.com/wybo/agentbase/zipball/master), [unzip it](http://en.wikipedia.org/wiki/Zip_(file_format)), then go to the models directory and edit [template.html](http://lib.agentbase.org/models/template.html), [advanced_template.html](http://lib.agentbase.org/models/advanced_template.html) or any other example model to get started. Open it locally in your browser and reload to see changes take effect.

Class ABM.Model has three methods that it calls automatically for you:

    startup() Optional. Called only once, for pre-initializing the model.
    setup()   Called during startup and by Model.reset().
    step()    Called by the animator to advance the model one step.

Simply subclass ABM.Model to build a model, supplying the three methods.

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

[Util_array.coffee](http://doc.agentbase.org/mixin/ABM/util.array.html) contains helpers that are included in Array.

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
