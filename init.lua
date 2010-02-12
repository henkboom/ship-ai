require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local game = require 'dokidoki.game'
local v2 = require 'dokidoki.v2'

local blueprints = require 'blueprints'
local java_ai = require 'java_ai'

kernel.set_video_mode(640, 480)
kernel.start_main_loop(game.make_game(
  {'update_setup', 'update', 'collision_registry', 'collision_check',
   'update_cleanup'},
  {'draw_setup', 'draw'},
  function (game)
    math.randomseed(os.time())

    game.init_component('exit_handler')
    game.init_component('keyboard')
    game.init_component('opengl_2d')
    game.init_component('resources')
    game.opengl_2d.width = 640
    game.opengl_2d.height = 480
    game.init_component('constants')

    game.actors.new(blueprints.player,
      {'transform', pos = v2(100, 100)},
      {'ai', ai=java_ai.make("Test")})
  end))
