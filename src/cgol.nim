import conway
import math
import parseopt
import sequtils
import sdl2/sdl
import strutils

proc printHelp() =
  echo """Usage: cgol [options]
Simulation for Conway's Game of Life (cgol).
-w, --width=<width>
            Set the width of the window [default: 640]
-h, --height=<height>
            Set the height of the window [default: 480]
-s, --scale=<scale>
            Set the scale of the game [default: 4]
-f, --framerate=<fps>
            Set the framerate of the game [default: 20]

-h, --help  Display this help and exit"""
  quit 0

proc shutdown(window: Window) =
  sdl.destroyWindow(window)
  sdl.quit()
  quit 0 

if sdl.init(sdl.INIT_VIDEO) != 0:
  echo "Error initializing the video system: ", sdl.getError()
  quit 1

var
  width = 640
  height = 480
  scale = 4
  framerate = 20
  outline = false
 
var p = initOptParser()
while true:
  p.next()
  case p.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    if p.val == "":
      case p.key
      of "h", "help":
        printHelp()
      of "o", "outline":
        outline = true
    else:
      case p.key
      of "w", "width":
        width = p.val.string.parseInt
      of "h", "height":
        height = p.val.string.parseInt
      of "s", "scale":
        scale = p.val.string.parseInt.nextPowerOfTwo()
      of "f", "framerate":
        framerate = p.val.string.parseInt
  else:
    discard

let
  fps = (1000 div framerate).uint32
  scaledWidth = width div scale
  scaledHeight = height div scale

# Sequences are used for the grid because the openArray interface does not support nested structures.
# Therefore a 2d array cannot be passed to functions without knowing their dimensions.
var currentGrid = newSeqWith(scaledHeight, newSeq[int](scaledWidth))
seed(currentGrid)
# copy the grid over
var newGrid = currentGrid

let window = sdl.createWindow(
  "cgol",
  sdl.WINDOWPOS_UNDEFINED,
  sdl.WINDOWPOS_UNDEFINED,
  width,
  height,
  0
)

if isNil(window):
  echo "Error creating window: ", sdl.getError()
  quit 1

let renderer = sdl.createRenderer(window, -1, 0)
var done = false
var e: sdl.Event

while not done:
  while sdl.pollEvent(addr(e)) > 0:
    if e.kind == sdl.QUIT:
      done = true
    elif e.kind == sdl.KEYDOWN and e.key.keysym.sym == sdl.K_q:
      shutdown(window)

  discard renderer.setRenderDrawColor(0, 0, 0, 0)
  discard renderer.renderClear()

  for y in 0..<scaledHeight:
    for x in 0..<scaledWidth:
      var rect = sdl.Rect(x: x * scale, y: y * scale, w: scale, h: scale)
      if newGrid[y][x] == 1:
        discard renderer.setRenderDrawColor(255, 255, 255, 0)
        discard renderer.renderFillRect(addr(rect))

      if outline:
        discard renderer.setRenderDrawColor(30, 30, 30, 0)
        discard renderer.renderDrawRect(addr(rect))

  renderer.renderPresent()

  for y in 0..high(currentGrid):
    for x in 0..high(currentGrid[0]):
      let count = activeNeighbours(currentGrid, x, y)
      newGrid[y][x] = transition(bool(currentGrid[y][x]), count)

  currentGrid = newGrid
  sdl.delay(fps)

shutdown(window)
