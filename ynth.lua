-- ynth

engine.name = 'Thebangs2'

graphics = include("lib/graphics") -- graphics library
utils = include("lib/utils")
soundengine = include("lib/soundengine")


state = {
	available_pages={"adsr","mods"},
	current_page=2,
	adsr={1,0.5,0.5,1},
	adsr_selected=0,
	mods={0,0},
	mods_selected=1,
	update_ui=false,
	update_adsr=false,
	update_mods=false,
}

function init()
	print("starting")

	-- refresh screen 
	refresher = metro.init()
	refresher.time = 0.1
	refresher.count=-1
	refresher.event = refresh
	refresher:start()

	-- midi events 
	midi_signal_in=midi.connect()
	midi_signal_in.event=on_midi_event
  
	state.update_ui=true
	state.synth = soundengine:init()
end

function on_midi_event(data)
  msg=midi.to_msg(data)
  if msg.type=='note_on' then
		state.synth:note_on(msg.note)
  elseif msg.type=='note_off' then
		state.synth:note_off(msg.note)
  end
end

function refresh(c)
	if state.update_ui then
		redraw()
	end
	if state.update_adsr then 
		state.update_adsr=false
		state.synth:set_adsr(state.adsr)
	end
	if state.update_mods then 
		state.update_mods=false 
		state.synth:set_mods(state.mods)
	end
end

function enc(k,d)
	if k==1 then 
		state.current_page = utils.sign_cycle(state.current_page,d,1,2)
	elseif state.available_pages[state.current_page]=="adsr" then
		if k==2 then 
			state.adsr_selected = utils.sign_cycle(state.adsr_selected,d,0,4)
		elseif k==3 and state.adsr_selected > 0 then 
			if state.adsr_selected == 2 then 
				state.adsr[state.adsr_selected] = util.clamp(state.adsr[state.adsr_selected] + d/100,0,1)
			elseif state.adsr_selected == 4 then 
				state.adsr[state.adsr_selected] = util.clamp(state.adsr[state.adsr_selected] - d/10,0,10)
			else
				state.adsr[state.adsr_selected] = util.clamp(state.adsr[state.adsr_selected] + d/10,0,10)
			end
			state.update_adsr=true
		end
	elseif state.available_pages[state.current_page]=="mods" then
		if k==2 then 
			state.mods_selected = utils.sign_cycle(state.mods_selected,d,0,2)
			print(state.mods_selected)
		elseif k==3 and state.mods_selected > 0 then 
			state.mods[state.mods_selected] = util.clamp(state.mods[state.mods_selected] + d/100,0,1)
			state.update_mods=true
		end
	end
	state.update_ui=true
end

function key(k,z)
	note = 60
	if k==3 then 
		note = 54
	end
	if z ==1 then 
		state.synth:note_on(note)
	else
		state.synth:note_off(note)
	end		
end


function redraw()
  if state.update_ui == false then 
  	do return end
  end
  state.update_ui=false
  graphics:setup()
  graphics:rect(1, 33, 7, 33, state.available_pages[state.current_page]=="adsr")
  graphics:text_rotate(7, 62, "ADSR", -90, 0)
  local adsr_selected = state.adsr_selected
  if not state.available_pages[state.current_page]=="adsr" then 
  	adsr_selected = 0 
  end
  graphics:adsr(state.adsr,adsr_selected)
  graphics:rect(64, 33, 7, 33, state.available_pages[state.current_page]=="mods")
  graphics:text_rotate(70, 62, "MOD", -90, 0)
  local mods_selected = state.mods_selected
  if not state.available_pages[state.current_page]=="mods" then 
  	mods_selected = 0 
  end
  graphics:text(74,48,"1: "..state.mods[1],mods_selected == 0 or mods_selected == 1)
  graphics:text(74,58,"2: "..state.mods[2],mods_selected == 0 or mods_selected == 2)
  graphics:teardown()
end

function rerun()
  norns.script.load(norns.state.script)
end