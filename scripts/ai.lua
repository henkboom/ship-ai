assert(ai)

local response_handlers = {
  left = function ()
    self.ship.turn(1)
  end,
  right = function ()
    self.ship.turn(-1)
  end,
  thrust = function ()
    self.ship.thrust()
  end,
  shoot = function ()
    self.ship.shoot()
  end
}

function update()
  local handler = response_handlers[ai()]
  if handler then handler() end
end
