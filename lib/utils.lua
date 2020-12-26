-- utils library abstracting all screen functions
-- from https://github.com/northern-information/song

local utils = {}


function utils.sign_cycle(value,d,min,max)
	if d > 0 then 
		value = value + 1 
	elseif d < 0 then 
		value = value - 1
	end
	if value > max then 
		value = min
	elseif value < min then 
		value = max
	end
	return value
end


function utils.sign(x)
  if x==nil then 
  	return 0 
  elseif x>0 then
    return 1
  elseif x<0 then
    return-1
  else
    return 0
  end
end

function utils.cycle(value, min, max)
    local y = value
    local d = max - min + 1
    while y > max do
      y = y - d
    end
    while value < min do
      y = y + d
    end
    return y
end


return utils
