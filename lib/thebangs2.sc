// "the" bangs

Thebangs2  {
	classvar maxVoices = 32;

	var server;
	var group;

	// synth params
	var <>hz1;
	var <>hz2;
	var <>mod1;
	var <>mod2;
	var <>amp;
	var <>pan;
	var <>attack;
	var <>decay;
	var <>sustain;
	var <>release;

	// some bangs
	var bangs;
	// the bang - a method of Bangs, as a string
	var <thebang;
	// which bang - numerical index
	var <whichbang;

	var <voicer;

	*new { arg srv;
		^super.new.init(srv);
	}

	init {
		arg srv;
		server = srv;
		group = Group.new(server);

		// default parameter values
		hz1 = 330;
		hz2 = 10000;
		mod1 = 0.0;
		mod2 = 0.0;

		attack = 0.01;
		sustain = 0.5;
		decay = 0.1;
		release = 2;
		amp = 0.1;
		pan = 0.0;

		bangs = Bangs2.class.methods.collect({|m| m.name});
		bangs.do({|name| postln(name); });

		this.whichBang = 0;

		voicer = OneshotVoicer2.new(maxVoices);
	}

	//--- setters
	bang_{ arg name;
		postln("bang_("++name++")");
		thebang = name;
	}

	whichBang_ { arg i;
		postln("whichBang_("++i++")");
		whichbang = i;
		thebang = bangs[whichbang];
	}

	// bang!
	bang { arg hz;
		var fn;

		postln([hz1, mod1, hz2, mod2, amp, pan, attack, release]);
		// postln("bang!");
		/*
		postln([hz1, mod1, hz2, mod2, amp, pan, attack, release]);
		postln([server, group]);
		*/
		
		if (hz != nil, { hz1 = hz; });
		
		fn = {
			var syn;
			syn = {
				arg gate=1;
				var snd, perc, ender;

				// perc = EnvGen.ar(Env.perc(attack, release), doneAction:Done.freeSelf);
				ender = EnvGen.ar(
					Env.new(
						levels: [0,1,sustain,0],
						times: [attack,decay,release],
						releaseNode: 2
					),
					gate: gate,
					doneAction:Done.freeSelf
				);
				// ender = EnvGen.ar(Env.asr(0, 1, 0.01), gate:gate, doneAction:Done.freeSelf);				
				snd = Bangs2.perform(thebang, hz1, mod1, hz2, mod2, perc);

				Out.ar(0, Pan2.ar(snd * amp * ender, pan));
			}.play(group);
			syn
		};

		voicer.newVoice(fn);
	}

	
	stopNote { 
		voicer.stopCurrentVoice;
	}

	freeAllNotes {
		// do need this to keep the voicer in sync..
		voicer.stopAllVoices;
		// but it should ultimately do the same as this (more reliable):
		group.set(\gate, 0);
	}

}