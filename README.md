### AgentScript

AgentScript is a minimalist Agent Based Modeling (ABM) framework based on [NetLogo](http://ccl.northwestern.edu/netlogo/) (NL) agent semantics.  Its goal is to promote the Agent Oriented Programming model in a highly deployable [CoffeeScript](http://coffeescript.org/)/JavaScript (CS/JS) implementation.

#### Build

Currently we use a very simple build process using the coffeescript -wj
command which "joins" the individual coffeescript files, compiling
them on change, creating agentscript.js.

    files="\
      util.coffee \
      shapes.coffee \
      agentset.coffee \
      agentsets.coffee \
      model.coffee \
    "
    coffee -wj agentscript.js -c $files &

See the template.html and models/*.html files for example models.  The individual
.coffee files are documented via Jeremy Ashkenas's
[docco](http://jashkenas.github.com/docco/) in the docs/ dir.

#### Files

    LICENSE             GPLv3 License
    README.md           This file
    agentscript.coffee  Join of core .coffee files
    agentscript.js      Coffeescript generated files
    agentscript.min.js  Uglified agentscript.js
    agentscript.sh      Script for uglify etc
    agentset.coffee     Base agentset implementation
    agentsets.coffee    Subclasses of agentset for Agents, Patches, Links
    coffee-script.js    Coffeescript.org browser compiler
    doc.sh              Script to generate docco documentation
    docs                Dir for docco documentation
    model.coffee        Base model class
    models              Dir for example models
    nlmodels            Dir for example NL models
    nlwebgl             Dir for webgl diffusion experiment
    shapes.coffee       Core shapes module
    template.html       Sample model
    testmodels          Tests of CS/NL semantics
    util.coffee         Base utility model
    watch.sh            Coffeescript "watch" script

#### License

Copyright 2012-2013, Owen Densmore, RedFish LLC http://agentscript.org/<br>
AgentScript may be freely distributed under the GPLv3 license:

AgentScript is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program, see LICENSE within the distribution.
If not, see <http://www.gnu.org/licenses/>.
