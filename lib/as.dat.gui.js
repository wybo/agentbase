(function() {
  ABM.DatGUI = (function() {

    function DatGUI(fbui) {
    	var self = this;
		this.gui = new dat.GUI();
		this.model = {};
		this.fbui = fbui;
		fbui.fb.on('child_added', function(uiSnap) {
			var uiEl = uiSnap.val(),
				name = uiSnap.name();

			if (uiEl.type != 'button') {
				// init ui model
				this.model[name] = uiEl.val;

				// init fb listeners
				uiSnap.child('val').ref().on('value', function(valSnap) {
					this.model[name] = valSnap.val();
					this.updateGui();
				}, this);
			}

			// init ui ctrl
			var ctrl = null;
			switch(uiEl.type) {
				case 'button':
					this.model[name] = function() {
						self.fbui.setUIValue(name, true);
					};
					this.gui.add(this.model, name);
				break;
				case 'choice':
					ctrl = this.gui.add(this.model, name, uiEl.vals);
				break;
				case 'switch':
					ctrl = this.gui.add(this.model, name);
				break;
				case 'slider':
					ctrl = this.gui.add(this.model, name, uiEl.min, uiEl.max).step(uiEl.step);
				break;
			}
			if (ctrl) {
				ctrl.onChange(function(value) {
					console.log(self);
					self.fbui.setUIValue(name, value);
				});
			}
		}, this);
	}

	DatGUI.prototype.updateGui = function() {
		for (var i in this.gui.__controllers) {
			this.gui.__controllers[i].updateDisplay();
		}
	}
      
	return DatGUI;

  })();

}).call(this);