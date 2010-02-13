local v2 = require 'dokidoki.v2'
local blueprints = require 'blueprints'

assert(ai)

local ai_cooldown = 0

local state = nil
local shoot_angle = nil

local function split(str)
  local fields = {}
  for f in str:gmatch('([^%s]+)') do
    table.insert(fields, f)
  end
  return fields
end

local command_handlers = {
  left    = function () state = "left" end,
  right   = function () state = "right" end,
  thrust  = function () state = "thrust" end,

  shoot   = function (angle)
    state = "shoot"
    shoot_angle = angle
  end,

  get_pos = function ()
    ai:send_response(self.transform.pos.x .. ' ' .. self.transform.pos.y)
  end,

  get_angle = function ()
    ai:send_response(math.atan2(
      self.transform.facing.y,
      self.transform.facing.x))
  end,

  scan = function (angle, span)
    angle = tonumber(angle)
    span = tonumber(span)
    if angle and span then
      local closest_dist_sqr
      for _, s in ipairs(game.actors.get('ship')) do
        if s ~= self then
          local disp = s.transform.pos - self.transform.pos
          local s_angle = math.atan2(disp.y, disp.x)
          local delta_angle = (angle - s_angle) % (math.pi * 2)
          if delta_angle > math.pi then
            delta_angle = 2 * math.pi - delta_angle
          end
          if delta_angle < span/2 then
            if not closest_dist_sqr or v2.sqrmag(disp) < closest_dist_sqr then
              closest_dist_sqr = v2.sqrmag(disp)
            end
          end
        end
      end

      if closest_dist_sqr then
        ai:send_response(math.sqrt(closest_dist_sqr))
      else
        ai:send_response(-1)
      end

      game.actors.new(blueprints.scan,
        {'transform', pos=self.transform.pos, facing=v2.unit(angle)},
        {'scan', span=span})
    end
  end
}

local state_handlers = {
  left   = function () self.ship.turn(1) end,
  right  = function () self.ship.turn(-1) end,
  thrust = function () self.ship.thrust() end,
  shoot  = function () self.ship.shoot(shoot_angle) end
}


function update()
  -- run ai if it's time
  ai_cooldown = math.max(ai_cooldown - 1, 0)
  if ai_cooldown == 0 then
    state = nil

    local command_line = ai:get_command()

    if command_line then
      ai_cooldown = 6

      local fields = split(command_line)

      if command_handlers[fields[1]] then
        command_handlers[fields[1]](select(2, unpack(fields)))
      end
    end
  end

  -- handle state
  if state_handlers[state] then
    state_handlers[state]()
  end
end
