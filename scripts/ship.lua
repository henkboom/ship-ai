local v2 = require 'dokidoki.v2'
local blueprints = require 'blueprints'

local velocity = v2(0, 0)

local hp = 30

function damage()
  hp = hp - 1
  if hp == 0 then
    self.dead = true
  end
end

function update()
  self.transform.pos = self.transform.pos + velocity
  velocity = velocity * 0.98

  local x, y = v2.coords(self.transform.pos)
  local vx, vy = v2.coords(velocity)
  if x < game.constants.left then
    x = game.constants.left
    vx = math.max(0, vx)
  end
  if x > game.constants.right then
    x = game.constants.right
    vx = math.min(0, vx)
  end
  if y < game.constants.bottom then
    y = game.constants.bottom
    vy = math.max(0, vy)
  end
  if y > game.constants.top then
    y = game.constants.top
    vy = math.min(0, vy)
  end
  self.transform.pos = v2(x, y)
  velocity = v2(vx, vy)
end

function turn(dir)
  self.transform.facing =
    v2.norm(v2.rotate(self.transform.facing, dir * math.pi/64))
end

function thrust()
  velocity = velocity + self.transform.facing * 0.1
end

function shoot(angle)
  game.actors.new(blueprints.bullet,
    {'transform', pos = self.transform.pos},
    {'bullet', velocity = velocity + v2.unit(angle) * 12 + v2.random()/2,
               ship = self})
end
