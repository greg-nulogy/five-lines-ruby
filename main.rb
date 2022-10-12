require 'ruby2d'

TILE_SIZE = 30
FPS = 30
SLEEP = 1000 / FPS

TILE = {
  AIR: 0,
  FLUX: 1,
  UNBREAKABLE: 2,
  PLAYER: 3,
  STONE: 4, FALLING_STONE: 5,
  BOX: 6, FALLING_BOX: 7,
  KEY1: 8, LOCK1: 9,
  KEY2: 10, LOCK2: 11
}

INPUT = {
  UP: 0, DOWN: 1, LEFT: 2, RIGHT: 3
}

@playerx = 1
@playery = 1

@map = [
  [2, 2, 2, 2, 2, 2, 2, 2],
  [2, 3, 0, 1, 1, 2, 0, 2],
  [2, 4, 2, 6, 1, 2, 0, 2],
  [2, 8, 4, 1, 1, 2, 0, 2],
  [2, 4, 1, 1, 1, 9, 0, 2],
  [2, 2, 2, 2, 2, 2, 2, 2],
]

@inputs = []

def remove(tile)
  for y in 0...@map.length
    for x in 0...@map[y].length
      if @map[y][x] == tile
        @map[y][x] = TILE[:AIR]
      end
    end
  end
end

def moveToTile(newx, newy)
  @map[@playery][@playerx] = TILE[:AIR]
  @map[newy][newx] = TILE[:PLAYER]
  @playerx = newx
  @playery = newy
end

def moveHorizontal(dx)
  if (@map[@playery][@playerx + dx] == TILE[:FLUX] ||
    @map[@playery][@playerx + dx] == TILE[:AIR])
    moveToTile(@playerx + dx, @playery)
  elsif ((@map[@playery][@playerx + dx] == TILE[:STONE] ||
    @map[@playery][@playerx + dx] == TILE[:BOX]) &&
    @map[@playery][@playerx + dx + dx] == TILE[:AIR] &&
    @map[@playery + 1][@playerx + dx] != TILE[:AIR])
    @map[@playery][@playerx + dx + dx] = @map[@playery][@playerx + dx]
    moveToTile(@playerx + dx, @playery)
  elsif (@map[@playery][@playerx + dx] == TILE[:KEY1])
    remove(TILE[:LOCK1])
    moveToTile(@playerx + dx, @playery)
  elsif (@map[@playery][@playerx + dx] == TILE[:KEY2])
    remove(TILE[:LOCK2])
    moveToTile(@playerx + dx, @playery)
  end
end

def moveVertical(dy)
  if (@map[@playery + dy][@playerx] == TILE[:FLUX] ||
    @map[@playery + dy][@playerx] == TILE[:AIR])
    moveToTile(@playerx, @playery + dy)
  elsif @map[@playery + dy][@playerx] == TILE[:KEY1]
    remove(TILE[:LOCK1])
    moveToTile(@playerx, @playery + dy)
  elsif @map[@playery + dy][@playerx] == TILE[:KEY2]
    remove(TILE[:LOCK2])
    moveToTile(@playerx, @playery + dy)
  end
end

def update_game
  while @inputs.length > 0
    current = @inputs.pop
    if current == INPUT[:LEFT]
      moveHorizontal(-1)
    elsif current == INPUT[:RIGHT]
      moveHorizontal(1)
    elsif current == INPUT[:UP]
      moveVertical(-1)
    elsif current == INPUT[:DOWN]
      moveVertical(1)
    end
  end

  for y in (0...@map.length).to_a.reverse
    for x in 0...@map[y].length
      if ((@map[y][x] == TILE[:STONE] || @map[y][x] == TILE[:FALLING_STONE]) &&
        @map[y + 1][x] == TILE[:AIR])
        @map[y + 1][x] = TILE[:FALLING_STONE]
        @map[y][x] = TILE[:AIR]
      elsif ((@map[y][x] == TILE[:BOX] || @map[y][x] == TILE[:FALLING_BOX]) &&
        @map[y + 1][x] == TILE[:AIR])
        @map[y + 1][x] = TILE[:FALLING_BOX]
        @map[y][x] = TILE[:AIR]
      elsif @map[y][x] == TILE[:FALLING_STONE]
        @map[y][x] = TILE[:STONE]
      elsif @map[y][x] == TILE[:FALLING_BOX]
        @map[y][x] = TILE[:BOX]
      end
    end
  end
end

def draw
  canvas = @document.getElementById("GameCanvas")
  g = canvas.getContext("2d")

  g.clearRect(0, 0, canvas.width, canvas.height)

  # Draw map
  for y in 0...@map.length
    for x in 0...@map[y].length
      if @map[y][x] == TILE[:FLUX]
        g.fillStyle = "#ccffcc"
      elsif @map[y][x] == TILE[:UNBREAKABLE]
        g.fillStyle = "#999999"
      elsif @map[y][x] == TILE[:STONE] || @map[y][x] == TILE[:FALLING_STONE]
        g.fillStyle = "#0000cc"
      elsif @map[y][x] == TILE[:BOX] || @map[y][x] == TILE[:FALLING_BOX]
        g.fillStyle = "#8b4513"
      elsif @map[y][x] == TILE[:KEY1] || @map[y][x] == TILE[:LOCK1]
        g.fillStyle = "#ffcc00"
      elsif @map[y][x] == TILE[:KEY2] || @map[y][x] == TILE[:LOCK2]
        g.fillStyle = "#00ccff"
      end

      if @map[y][x] != TILE[:AIR] && @map[y][x] != TILE[:PLAYER]
        g.fillRect(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
      end
    end
  end

  # Draw player
  g.fillStyle = "#ff0000"
  g.fillRect(@playerx * TILE_SIZE, @playery * TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

def gameLoop
  update_game
  draw
end

# ruby2d call to run the gameLoop
update do
  gameLoop
end

LEFT_KEY = "left"
UP_KEY = "up"
RIGHT_KEY = "right"
DOWN_KEY = "down"

on :key_down do |e|
  if e.key == LEFT_KEY || e.key == "a"
    @inputs.push(INPUT[:LEFT])
  elsif e.key == UP_KEY || e.key == "w"
    @inputs.push(INPUT[:UP])
  elsif e.key == RIGHT_KEY || e.key == "d"
    @inputs.push(INPUT[:RIGHT])
  elsif e.key == DOWN_KEY || e.key == "s"
    @inputs.push(INPUT[:DOWN])
  elsif e.key == "escape"
    close
  end
end

# Hacks to make the ruby2d API look/act similar to the JS canvas/context/graphics API
class GraphicsObject
  attr_accessor :fillStyle

  def initialize
    @fillStyle = ""
  end

  def clearRect(x, y, width, height)
    Window.clear
    Rectangle.new(x: x, y: y, width: width, height: height, color: 'white')
  end

  def fillRect(x, y, width, height)
    Rectangle.new(x: x, y: y, width: width, height: height, color: @fillStyle)
  end

end

@document = Object.new

def @document.getElementById(id)
  canvas = Object.new

  def canvas.getContext(context)
    GraphicsObject.new
  end

  def canvas.width
    Window.width
  end

  def canvas.height
    Window.height
  end

  canvas
end

# ruby2d call to make it all work
show