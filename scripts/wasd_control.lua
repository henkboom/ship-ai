function update()
  local dir = (game.keyboard.key_held(string.byte('A')) and 1 or 0) -
              (game.keyboard.key_held(string.byte('D')) and 1 or 0)
  self.ship.turn(dir)
  if game.keyboard.key_held(string.byte('W')) then
    self.ship.thrust()
  end
  if game.keyboard.key_held(string.byte(' ')) then
    self.ship.shoot()
  end
end
