-- ynth

engine.name = 'Thebangs2'

graphics = include("lib/graphics") -- graphics library
utils = include("lib/utils")
soundengine = include("lib/soundengine")


state = {
	available_pages={"adsr","mod"},
	current_page=1,
	adsr={1,0.5,0.5,1},
	selected_adsr=0,
	update_ui=false,
}

function init()
	print("starting")
	refresher = metro.init()
	refresher.time = 0.1
	refresher.count=-1
	refresher.event = refresh
	refresher:start()
	state.update_ui=true
	state.synth = soundengine:init()
end

function refresh(c)
	if state.update_ui then
		redraw()
	end
end

function enc(k,d)
	if k==1 then 
		state.current_page = utils.sign_cycle(state.current_page,d,1,2)
	elseif state.available_pages[state.current_page]=="adsr" then
		if k==2 then 
			state.selected_adsr = utils.sign_cycle(state.selected_adsr,d,0,4)
		elseif k==3 and state.selected_adsr > 0 then 
			if state.selected_adsr == 2 then 
				state.adsr[state.selected_adsr] = util.clamp(state.adsr[state.selected_adsr] + d/100,0,1)
			elseif state.selected_adsr == 4 then 
				state.adsr[state.selected_adsr] = util.clamp(state.adsr[state.selected_adsr] - d/10,0,10)
			else
				state.adsr[state.selected_adsr] = util.clamp(state.adsr[state.selected_adsr] + d/10,0,10)
			end
			state.synth:set_adsr(state.adsr)
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
  local selected_adsr = state.selected_adsr
  if not state.available_pages[state.current_page]=="adsr" then 
  	selected_adsr = 0 
  end
  graphics:adsr(state.adsr,selected_adsr)
  graphics:rect(64, 33, 7, 33, state.available_pages[state.current_page]=="mod")
  graphics:text_rotate(70, 62, "MOD", -90, 0)
  graphics:text(74,48,"1: 1.0")
  graphics:text(74,58,"2: 1.0")
  graphics:teardown()
end

function rerun()
  norns.script.load(norns.state.script)
end