import random

proc populate(cells: var seq[int]) =
  for i in 0..high(cells):
    cells[i] = rand(1)

proc seed*(grid: var seq[seq[int]]) =
  ## Sets time as seed and starts populating the grid with cells.
  randomize()
  for i in 0..high(grid):
    populate(grid[i])

proc activeNeighbours*(grid: seq[seq[int]], x: int, y: int): int =
  ## Counts the living neighbours of a cell.
  var active = 0
  for i in [x - 1, x, x + 1]:
    for j in [y - 1, y, y + 1]:
      if i == x and j == y:
        continue

      if (i >= 0 and i < grid[0].len) and (j >= 0 and j < grid.len):
        active += grid[j][i]
        
  return active

proc transition*(alive: bool, livingNeighbours: int): int =
  ## Returns a living or dying cell depending on the livingNeighbours count.
  if alive and (livingNeighbours < 2 or livingNeighbours > 3):
    return 0

  if alive and livingNeighbours in 2..3:
    return 1

  if not alive and livingNeighbours == 3:
    return 1
