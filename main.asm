INCLUDE "hardware.inc"
INCLUDE "utils.asm"
INCLUDE "paddle.asm"
INCLUDE "ball.asm"
INCLUDE "bricks.asm"

SECTION "header", ROM0[$100]
  jp EntryPoint

  ds $150 - @, 0 ; Make room for header


EntryPoint:
  ; Do not turn off LCD outside of VBlank
WaitVBlank:
  ld a, [rLY]
  cp 144
  jp c, WaitVBlank

  ; Turn off LCD
  ld a, 0
  ld [rLCDC], a

  ; Copy tile data
  ld de, Tiles
  ld hl, $9000 ; Location of tiles in VRAM
  ld bc, TilesEnd - Tiles ; Length of Tiles
  call Memcpy

  ; Copy TileMap
  ld de, Tilemap
  ld hl, $9800
  ld bc, TilemapEnd - Tilemap
  call Memcpy

  ; Copy the paddle tile
  ld de, paddleImage
  ld hl, $8000
  ld bc, paddleImageEnd - paddleImage
  call Memcpy

  ld de, ballImage
  ld hl, $8010
  ld bc, ballImageEnd - ballImage
  call Memcpy

  ; Clear OAM (Object Attribute Memory)
  ld a, 0
  ld b, 160
  ld hl, _OAMRAM
  call ClearOam

  ld hl, _OAMRAM

  ; Initialize sprite objects
  call InitPaddle
  call InitBall

  ; Initializing Global Variables
  ld a, 0
  ld [wFrameCounter], a
  
  ; OBS: Every operation that involves copying and moving tiles or writting stuff to the OAM
  ; needs to be performed BEFORE TURNING THE LCD ON! Otherwise, changes will be ignored
  ; and glitches can happen

  ; Turn LCD on
  ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
  ld [rLCDC], a

  ; Initialize display registers during the first blank frame
  ld a, %11100100
  ld [rBGP], a
  ld a, %11100100
  ld [rOBP0], a

Main:
  ; Main loop/entrypoint. A.K.A. our "Main() function"
  ; Wait until it's *NOT* VBlank
  ld a, [rLY]
  cp 144
  jp nc, Main
WaitVBlank2:
  ld a, [rLY]
  cp 144
  jp c, WaitVBlank2
  call UpdateKeys

  ld a, [wFrameCounter]
  inc a
  ld [wFrameCounter], a
  cp a, 1 ; Run the following code every frame
  jp nz, Main

  ; Set the frame counter back to zero
  ld a, 0
  ld [wFrameCounter], a

  ; Move the ball
  call MoveBall

  ; Move the paddle
  call MovePaddle
  jp Main

Tiles:
    INCBIN "assets/Tilesets/Playfield.2bpp"
    ; Paste your logo here:
  INCLUDE "portrait.asm"
TilesEnd:

Tilemap: INCBIN "assets/Levels/Level_01.tilemap"
TilemapEnd:


SECTION "Counter", WRAM0
wFrameCounter: db

SECTION "Input Variables", WRAM0
wCurKeys: db
wNewKeys: db
