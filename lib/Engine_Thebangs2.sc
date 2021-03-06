// thin wrapper around `thebangs` for norns

Engine_Thebangs2 : CroneEngine {

	var thebangs;
	
	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		thebangs = Thebangs2.new(Crone.server);

		// TODO: should probably clamp incoming values.
		// or, at minimum, provide a lua layer which does so
		// (e.g. by defining parameters.)

		// setting the primary frequency also triggers a new self-freeing synth voice.
		// this is the defining behavior of a Bang.
		this.addCommand("hz1", "f", { arg msg;
			thebangs.hz1 = msg[1];
			thebangs.bang;
		});

		// add updaters to update live values
		this.addCommand("mod1","f", { arg msg;
			thebangs.mod1 = msg[1];
			// thebangs.voicer.updateMod1(msg[1]); // update current voices
			thebangs.doUpdateMod1;
		});
		
		// each of these commands simply calls a correspondingly-named setter,
		// with a single float argument
		["hz2", "mod2", "amp", "pan", "attack", "decay", "sustain", "release"].do({
			arg str;
			this.addCommand(str, "f", { arg msg;
				thebangs.perform((str++"_").asSymbol, msg[1]);
			});
		});
		
		
		// select the synthesis algorithm by name
		this.addCommand("algoName", "s", { arg msg;
			thebangs.bang = msg[1];
		});

		// select the synthesis algorithm by index
		this.addCommand("algoIndex", "i", { arg msg;
			thebangs.whichBang = msg[1]-1; // convert from 1-based
		});

		// select the voice-stealing mode
		// - 0: static; always steal the voice that is `stealIdx` from oldest
		// - 1: (default): oldest first
		// - 2: newest first
		// - 3: ignore new notes until a voice becomes free
		this.addCommand("stealMode", "i", { arg msg;
			thebangs.voicer.stealMode = msg[1];
		});

		// set the voice-stealing index to be used with stealMode=0
		this.addCommand("stealIndex", "i", { arg msg;
			thebangs.voicer.stealIdx = msg[1];
		});

		// stop all currently sustaining voices
		this.addCommand("stopAllVoices", "", { arg msg;
			thebangs.voicer.stopAllVoices;
		});

		// stop voice based on current stealIndex, to be used with stealMode=0
		this.addCommand("stopVoice", "", { arg msg;
			thebangs.voicer.stopVoice;
		});

		// set the max number of simultaneous voices
		this.addCommand("maxVoices", "i", { arg msg;
			thebangs.voicer.maxVoices = msg[1];
		});	

	}

	free {
		thebangs.stopNote;
		thebangs.freeAllNotes;
	}
}