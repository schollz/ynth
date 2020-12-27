-- graphics library abstracting all screen functions
-- from https://github.com/northern-information/song

local graphics = {}

function graphics.init()
  screen.aa(0)
  screen.font_face(0)
  screen.font_size(8)
end

function graphics:setup()
  screen.clear()
end

function graphics:teardown()
  screen.update()
  screen.ping()
end

function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, highlight)
  if highlight then 
    screen.level(15)
  else
    screen.level(1)
  end
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, highlight)
  if highlight then 
    screen.level(15)
  else
    screen.level(1)
  end
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_right(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_right(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end

function graphics:text_rotate(x, y, s, d, l)
  screen.level(l or 15)
  screen.text_rotate(x, y, s, d)
end

function graphics:text_center_rotate(x, y, s, d, l)
  screen.level(l or 15)
  screen.text_center_rotate(x, y, s, d)
end

function graphics:curve_in_box(bbox,highlight,x1, y1, x2, y2, x3, y3)
  -- x,y should be between 0 and 1
  x1 = math.floor(util.linlin(0,1,bbox[1],bbox[2],x1))
  x2 = math.floor(util.linlin(0,1,bbox[1],bbox[2],x2))
  y1 = math.floor(util.linlin(0,1,bbox[3],bbox[4],1-y1))
  y2 = math.floor(util.linlin(0,1,bbox[3],bbox[4],1-y2))
  if x3 ~= nil then
    x3 = math.floor(util.linlin(0,1,bbox[1],bbox[2],x3))
    y3 = math.floor(util.linlin(0,1,bbox[3],bbox[4],1-y3))
  end
  if highlight then 
    screen.level(15)
    screen.line_width(2)
  else
    screen.level(1)
    screen.line_width(1)
  end
  screen.move(x1,y1)
  screen.curve(x1, y1, x2, y2, x3, y3)
  screen:stroke ()
end

function graphics:adsr(adsr,h)
  local a = adsr[1]
  local d = adsr[2]
  local s = adsr[3]
  local r = adsr[4]
  s = util.clamp(s,0,1)
  local total_time = a + d + r 
  local s_width = 0.2
  local a_width = a / total_time - s_width/3
  local d_width = d / total_time - s_width/3
  local r_width = r / total_time - s_width/3
  local pos = {0,0}
  local bbox = {11,60,32,64}
  graphics:curve_in_box(bbox,h==1 or h==0,0,0,0,0.75,a_width,1)
  pos[1] = pos[1] + a_width
  pos[2] = 1
  graphics:curve_in_box(bbox,h==2 or h==0,pos[1],pos[2],pos[1],1.25*s,pos[1]+d_width,s)
  pos[1] = pos[1] + d_width
  pos[2] = s 
  graphics:curve_in_box(bbox,h==3 or h==0,pos[1],pos[2],pos[1]+s_width,pos[2],pos[1]+s_width,pos[2])
  pos[1] = pos[1]+s_width
  graphics:curve_in_box(bbox,h==4 or h==0,pos[1],pos[2],pos[1],0.125,1,0)
end


return graphics