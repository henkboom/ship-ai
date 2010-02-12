local v2 = require 'dokidoki.v2'
local blueprints = require 'blueprints'

local velocity = v2(0, 0)

function update()
  self.transform.pos = self.transform.pos + velocity
  velocity = velocity * 0.98
end

function turn(dir)
  self.transform.facing =
    v2.norm(v2.rotate(self.transform.facing, dir * math.pi/64))
end

function thrust()
  velocity = velocity + self.transform.facing * 0.1
end

function shoot()
  game.actors.new(blueprints.bullet,
    {'transform', pos = self.transform.pos},
    {'bullet', velocity = velocity + self.transform.facing * 16})
end
