MusicUtil = require "musicutil"

engine.name = 'Thebangs2'

currentEngine = "" -- global current engine

local SoundEngine = {
	adsr = {1,1,0.5,1},
	mods = {0,0},
	engine_name = "square",
	current_notes = {},
	index_start = 1
}

function SoundEngine:init(o)
	-- class init
	o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

	-- self.index_start = math.random(1,1000) -- random index in case overlapping sounds
    self:update()

    -- engine update
	engine.stealMode(0) -- set to static steal-mode 
	return o
end

function SoundEngine:set_engine(engine_name)
	if engine_name then 
		self.engine_name = engine_name 
	end
	if currentEngine ~= self.engine_name then 
		print("setting engine to "..self.engine_name)
		engine.algoName(self.engine_name)
		currentEngine = self.engine_name
	end
end

function SoundEngine:note_on(midinote)
	if self.current_notes[midinote] ~= nil then 
		do return end 
	end
	self.current_notes[midinote] = #self.current_notes+self.index_start -- new index
	self:set_engine()
	print("stealing note "..self.current_notes[midinote])
	engine.stealIndex(self.current_notes[midinote]) -- change to new index
	engine.hz1(MusicUtil.note_num_to_freq(midinote)) -- turn the note on
end

function SoundEngine:note_off(midinote)
	if self.current_notes[midinote] == nil then 
		do return end 
	end
	self:set_engine()
	engine.stealIndex(self.current_notes[midinote]) -- stealing current index removes note
	self.current_notes[midinote] = nil 
end

function SoundEngine:update()
	self:set_adsr()
	self:set_mods()
end

function SoundEngine:set_adsr(adsr) 
	if adsr then 
		self.adsr = adsr
	end
	engine.amp(1.0)
	engine.attack(self.adsr[1])
	engine.decay(self.adsr[2])
	engine.sustain(self.adsr[3])
	engine.release(self.adsr[4])
end

function SoundEngine:set_mods(mods)
	if mods then 
		self.mods = mods 
	end
	engine.mod1(self.mods[1])
	engine.mod1(self.mods[2])
end

return SoundEngine