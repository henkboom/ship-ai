require 'dokidoki.module'
[[ test_ship, ai_ship, bullet, scan, restart_handler ]]

local game = require 'dokidoki.game'

test_ship = game.make_blueprint('ship',
  {'transform'},
  {'sprite', resource = 'player_sprite'},
  {'ship'},
  {'wasd_control'})

ai_ship = game.make_blueprint('ship',
  {'transform'},
  {'sprite', resource = 'player_sprite'},
  {'ship'},
  {'ai'})

bullet = game.make_blueprint('bullet',
  {'transform'},
  {'sprite', resource = 'bullet_sprite'},
  {'bullet'})

scan = game.make_blueprint('scan',
  {'transform'},
  {'scan'})

restart_handler = game.make_blueprint('restart_handler',
  {'restart'})

return get_module_exports()
