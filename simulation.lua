require 'dokidoki.module' [[ make ]]

local base = require 'dokidoki.base'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

local ai_loader = require 'ai_loader'
local blueprints = require 'blueprints'

function make()
  return game.make_game(
    {'update_setup', 'update', 'collision_registry', 'collision_check',
     'update_cleanup'},
    {'draw_setup', 'draw'},
    function (game)
      collectgarbage()
      math.randomseed(os.time())

      game.init_component('exit_handler')
      game.init_component('keyboard')
      game.init_component('opengl_2d')
      game.init_component('resources')
      game.init_component('constants')

      game.opengl_2d.width = game.constants.right
      game.opengl_2d.height = game.constants.top

      local ais = base.irandomize(ai_loader.load_all())
      for i, ai in ipairs(ais) do
        i = 0
        local pos = game.constants.center + 200*v2.unit(2*math.pi/#ais*i)
        game.actors.new(blueprints.ai_ship,
          {'transform', pos=pos, facing = v2.unit(2*math.pi/#ais*i+math.pi)},
          {'ai', ai=ai})
      end
      game.actors.new(blueprints.test_ship,
          {'transform', pos = v2(200, 100)})
      game.actors.new(blueprints.restart_handler)
    end)
end

return get_module_exports()
