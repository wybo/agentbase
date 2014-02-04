(function() {
  ABM.DatGUI = (function() {

  	/*
  		ABM.DatGUI() accepts either:
		an ABM.FirebaseUI or
		an ABM.Model and a ui object
  	*/

    function DatGUI(fbuiOrModel, uiObject) {
    	var self = this;
		this.gui = new dat.GUI();
		this.datGuiModel = {};

		var model, ui, fbui;
		if (arguments.length == 2) {
			model = this.model = fbuiOrModel;
			ui = this.ui = uiObject;
		}
		else {
			fbui = this.fbui = fbuiOrModel;
			ui = this.ui = fbui.ui;
		}

		for (var name in ui) {
			if (ui.hasOwnProperty(name)) {
				var uiEl = ui[name];
				if (uiEl.type != 'button') {
					// init ui model
					this.datGuiModel[name] = uiEl.val;

					// init fb listeners
					fbui && fbui.refs[name].child('val').on('value', function(valSnap) {
						self.datGuiModel[this.name] = valSnap.val();
						self.updateGui();
					}.bind({ name: name }));
				}

				// init ui ctrl
				var ctrl = null;
				switch(uiEl.type) {
					case 'button':
						this.datGuiModel[name] = self.fbui ?
							function() { self.fbui.setUIValue(name, true); } :
							function() { self.setModelValue(name); };
						this.gui.add(this.datGuiModel, name);
					break;
					case 'choice':
						ctrl = this.gui.add(this.datGuiModel, name, uiEl.vals);
					break;
					case 'switch':
						ctrl = this.gui.add(this.datGuiModel, name);
					break;
					case 'slider':
						ctrl = this.gui.add(this.datGuiModel, name, uiEl.min, uiEl.max).step(uiEl.step);
					break;
				}
				if (ctrl) {
					if (self.fbui) {
						ctrl.onChange(function(value) {
							self.fbui.setUIValue(this.name, value);
						}.bind({ name: name }));
					}
					else {
						ctrl.onChange(function(value) {
							self.setModelValue(this.name, value);
						}.bind({ name: name }));	
					}
				}
			}
		}
	}

	DatGUI.prototype.setModelValue = function(name, value) {
		var setter = this.ui[name].setter;
		if (setter) {
			this.model[setter](value);
		}
		else {
			this.model[name] = value;
		}
	}

	DatGUI.prototype.updateGui = function() {
		for (var i in this.gui.__controllers) {
			this.gui.__controllers[i].updateDisplay();
		}
	}
      
	return DatGUI;

  })();

}).call(this);