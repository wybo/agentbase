### AgentBase

AgentBase is a minimalist Agent Based Modeling (ABM) platform that allows you to quickly build models that run directly in the browser. It follows [NetLogo](http://ccl.northwestern.edu/netlogo/)'s Agent riented Programming model and is entirely implemented in [CoffeeScript](http://coffeescript.org/). Tinker with models and share them on [agentbase.org](http://agentbase.org/) or drop by our [Google Group](https://groups.google.com/forum/?hl=en#!forum/agentbase) to get involved. Documentation [is here](http://doc.agentbase.org/).

We think:
- ABM models should be easy to share and run directly from a webpage. No software to install.
- AgentBase is optimized for the quick development of illustrative ABM models: It values minimalism over complexity, readable and pretty code over cpu performance, and sensible defaults over choice. It is [opinionated software](https://gettingreal.37signals.com/ch04_Make_Opinionated_Software.php).
- [NetLogo](http://ccl.northwestern.edu/netlogo/) (the most commonly used ABM toolset) is a great inspiration. However, we don't try to copy every bit of it. Minimalistic is fine. The web is not the desktop. Coffeescript is not Logo.
- AgentBase is well-tested through automated testing and thus a platform that you can trust. [See for yourself](http://lib.agentbase.org/spec.html).

#### Sample models

The models/ directory contains example models that show what AgentBase can do.

[template.html](http://lib.agentbase.org/models/template.html) shows the basic structure of a model and (if you look at the source) is a good place to get started when you are building your own. [advanced_template.html](http://lib.agentbase.org/models/advanced_template.html) is more elaborate.

[ants.html](http://lib.agentbase.org/models/ants.html) A model of ant foraging behavior incorporating a nest location and food pheromone diffusion.

[buttons.html](http://lib.agentbase.org/models/buttons.html) Stuart Kauffman's example of randomly connecting pairs of buttons in a pile resulting in a tipping point.

[diffusion.html](http://lib.agentbase.org/models/diffusion.html) Agents randomly flying on a patch grid dropping a color which is diffused over the grid.

[fire.html](http://lib.agentbase.org/models/fire.html) A cellular automata model of fire spreading and burn behavior.

[flock.html](http://lib.agentbase.org/models/flock.html) The classic "boids" model where agents each follow three simple rules resulting in realistic flocking. This example uses the as.dat.gui.js extra.

[grid\_path.html](http://lib.agentbase.org/models/grid_path.html) One of Knuth's great puzzles on the probability of all Manhattan traversals diagonally traversing a grid.

[life.html](http://lib.agentbase.org/models/life.html) An implementation of [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) with a twist. This example demonstrates running multiple models on the same page.

[link\_travel.html](http://lib.agentbase.org/models/link_travel.html) Agents traversing a graph of nodes and links.

[n\_body.html](http://lib.agentbase.org/models/n_body.html) A simulation of the nonlinear gravitation of n bodies.

[preferential\_attachment.html](http://lib.agentbase.org/models/preferential_attachment.html) An example of a dynamic graph where new links preferentially attach to the nodes that have the most links.  This results in a power-law distribution.

[traveling\_salesman.html](http://lib.agentbase.org/models/traveling_salesman.html) A Traveling Sales Person solution via a Genetic Algorithm showing the rapid conversion of stochastic methods.

#### Building a model

Class ABM.Model is an "abstract class" with three abscract methods:

  startup() Called from Model constructor for loading files needed by the model.
  setup()   Called during startup and by Model.reset().
  step()    Called by the animator to advance the model one step.

Simply subclass ABM.Model to build a model, supplying the three abstract methods.

See the source of [template.html](http://lib.agentbase.org/models/template.html) and [advanced_template.html](http://lib.agentbase.org/models/advanced_template.html) to get started.

#### Development installation

After git cloning with

    git clone git@github.com:wybo/agentbase.git

    cd agentbase

Install the development dependencies with

    npm install

and build with

    npm run watch

Our tasks are all run via npm run <task>` and they are:

    watch         # Watch for source file updates, invoke build
    build         # compile and minify src/ and extras/ to lib/
    doc           # use codo on sources to create docs/
    all           # Compile coffee, minify js, create docs

Behind the scenes npm invokes [gulp](http://gulpjs.com/), whose tasks
are defined in Gulpfile.coffee. The command "npm run all" is equivalent
to "gulp all". All "npm run" commands are defined in package.json.

#### Contribute

If you would like to contribute, please make sure all the unit tests ("cake test") and sample models work as expected before you create a pull-request. If you add new functionality, add matching tests as well.

In addition, make sure the docs build correctly. They can be built with `npm run codo`. Use your browser on doc/ to test.

Finally, be sure to follow the [STYLEGUIDE.txt](http://lib.agentbase.org/STYLEGUIDE.txt) for code you'd like to see included.

The typical workflow looks like:

* npm run watch - process files when they change.
* npm run all - compile & minify all code, create docs. Done before git add to insure everything is ready for git.
* git commit -a - in master, to commit locally

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

[agent.coffee](http://doc.agentbase.org/class/ABM/Agent.html) The agents that populate your model.

[agents.coffee](http://doc.agentbase.org/class/ABM/Agents.html) The set of @agents you see called in models.

[patches.coffee](http://doc.agentbase.org/class/ABM/Patches.html) The set of @patches that each model has.

[model.coffee](http://doc.agentbase.org/class/ABM/Model.html) holds the basis for your model. It is subclassed by all models.

[util.coffee](http://doc.agentbase.org/mixin/ABM/util.html) is the base module for tools.

[util_array.coffee](http://doc.agentbase.org/mixin/ABM/util.array.html) contains helpers that are included in Array.

Full documentation can be found on [doc.agentbase.org](http://doc.agentbase.org/).

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
