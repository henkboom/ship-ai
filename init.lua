require 'dokidoki.module' [[]]

local kernel = require 'dokidoki.kernel'
local simulation = require 'simulation'

kernel.set_video_mode(600, 600)
kernel.start_main_loop(simulation.make())
