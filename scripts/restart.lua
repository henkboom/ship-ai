local kernel = require 'dokidoki.kernel'
local simulation = require 'simulation'

local countdown = 120

function update()
  if #game.actors.get('ship') <= 1 then
    countdown = countdown - 1
    if countdown == 0 then
      kernel.switch_scene(simulation.make())
    end
  end
end
