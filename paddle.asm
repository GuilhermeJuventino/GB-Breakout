SECTION "PaddleMain", ROM0

InitPaddle::
    ; Write paddle's object properties to OAM
    ld a, 128 + 16 ; Object's Y coordinate
    ld [hli], a
    ld a, 16 + 46 ; Object's X Coordinate
    ld [hli], a
    ld a, 0 ; Ojbect's Tile ID and attributes
    ld [hli], a
    ld [hli], a

    ret

MovePaddle::
  ; Move the paddle
checkLeft:
  ld a, [wCurKeys]
  and a, PADF_LEFT
  jp z, checkRight
moveLeft:
  ld a, [_OAMRAM + 1]
  sub a, 1
  ; Check if paddle has collided with the left wall
  ; and prevent it from moving further if so
  cp a, 15
  jp z, return

  ld [_OAMRAM + 1], a
  jp return
checkRight:
  ld a, [wCurKeys]
  and a, PADF_RIGHT
  jp z, return
moveRight:
  ld a, [_OAMRAM + 1]
  add a, 1

  ; Check if paddle has collided with the right wall
  ; and prevent it from moving further if so
  cp a, 105
  jp z, return

  ld [_OAMRAM + 1], a
  jp return
return:
  ret


SECTION "PaddleGraphics", ROM0

paddleImage:: INCBIN "assets/Paddle.2bpp"
paddleImageEnd::

