SECTION "PaddleMain", ROM0

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

