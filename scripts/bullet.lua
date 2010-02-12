local v2 = require 'dokidoki.v2'

assert(velocity)

if v2.sqrmag(velocity) == 0 then
  self.dead = true
else
  self.transform.facing = v2.norm(velocity)
end

local function out_of_bounds()
  return self.transform.pos.x < game.constants.left or 
         self.transform.pos.x > game.constants.right or
         self.transform.pos.y < game.constants.bottom or 
         self.transform.pos.y > game.constants.top
end

function update()
  self.transform.pos = self.transform.pos + velocity
  if out_of_bounds() then
    self.dead = true
  end
end
