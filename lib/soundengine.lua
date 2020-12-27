MusicUtil = require "musicutil"

engine.name = 'Thebangs2'

currentEngine = "" -- global current engine

local SoundEngine = {}
SoundEngine.__index = SoundEngine

function SoundEngine.init(o)
	-- class init
	o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self

    -- object init
    if o.adsr == nil then 
	    o.adsr = {1,1,0.5,1}
	end
	if o.mods == nil then 
	    o.mods = {0,0}
	end
	if o.engine == nil then 
		o.engine = "sinfmlp"
	end
	o.index_start = math.random(1,1000) -- random index in case overlapping sounds
    o:update()

    -- engine update
	engine.stealMode(0) -- set to static steal-mode 
	return o
end

function SoundEngine:set_engine(engine)
	if engine then 
		self.engine = engine 
	end
	if currentEngine ~= self.engine then 
		engine.algoName(self.engine)
		currentEngine = self.engine
	end
end

function SoundEngine:note_on(midinote)
	if self.current_notes[midinote] ~= nil then 
		do return end 
	end
	self.current_notes[midinote] = #self.current_notes+self.index_start -- new index
	self:set_engine()
	engine.stealIndex(self.current_notes[midinote]) -- change to new index
	engine.hz1(MusicUtil.note_num_to_freq(noteNumber)) -- turn the note on
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