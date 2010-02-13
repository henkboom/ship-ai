local gl = require 'gl'
local v2 = require 'dokidoki.v2'

assert(span)

local life = 18

function update()
  life = life - 1
  if life == 0 then
    self.dead = true
  end
end

function draw()
  local pos = self.transform.pos
  local facing = self.transform.facing

  gl.glPushMatrix();
  gl.glTranslated(pos.x, pos.y, 0)
  gl.glRotated(180/math.pi * math.atan2(facing.y, facing.x), 0, 0, 1)

  local v = 1000 * v2.unit(span/2)
  gl.glColor4d(1, 1, 1, 0.25 * life/18)
  gl.glBegin(gl.GL_LINE_STRIP)
  gl.glVertex2d(v.x, v.y)
  gl.glVertex2d(0, 0)
  gl.glVertex2d(v.x, -v.y)
  gl.glEnd()
  gl.glColor4d(1, 1, 1, 0.05 * life/18)
  gl.glBegin(gl.GL_TRIANGLES)
  gl.glVertex2d(v.x, v.y)
  gl.glVertex2d(0, 0)
  gl.glVertex2d(v.x, -v.y)
  gl.glEnd()
  gl.glColor3d(1, 1, 1)

  gl.glPopMatrix()
end
