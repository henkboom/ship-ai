require 'dokidoki.module' [[ player, bullet ]]

local game = require 'dokidoki.game'

player = game.make_blueprint('player',
  {'transform'},
  {'sprite', resource = 'player_sprite'},
  {'ship'},
  {'wasd_control'},
  {'ai'})

bullet = game.make_blueprint('bullet',
  {'transform'},
  {'sprite', resource = 'bullet_sprite'},
  {'bullet'})

return get_module_exports()
