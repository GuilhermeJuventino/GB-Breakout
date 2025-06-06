SECTION "Utils", ROM0

; memcpy(de source, hl destination, bc length)
; Copy data from specified address to target destination
Memcpy::
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, Memcpy
  ret

; ClearOam(a, b, hl)
; Clears OAM (object Attribute Memory)
ClearOam::
  ld [hli], a
  dec b
  jp nz, ClearOam

  ret

UpdateKeys::
  ; Poll half of the controller
  ld a, P1F_GET_BTN
  call .oneNibble
  ld b, a ; B7-4 = 1; B3-0 = Unpressed buttons

  ; Poll the other half of the controller
  ld a, P1F_GET_DPAD
  call .oneNibble
  swap a ; A7 - 4 = Unpressed directions; A3-0 = 1
  xor a, b ; A = Pressed buttons + directions
  ld b, a ; B = Pressed buttons + directions

  ; And release the controller
  ld a, P1F_GET_NONE
  ldh [rP1], a

  ; Combine previous wCurKeys to make wNewKeys
  ld a, [wCurKeys]
  xor a, b ; Keys that changed state
  and a, b ; Keys that changed to Pressed
  ld [wNewKeys], a
  ld a, b
  ld [wCurKeys], a
  ret

.oneNibble
  ldh [rP1], a ; Switch key matrix
  call .knownRet ; Burn 10 cycles calling a known ret
  ldh a, [rP1] ; Ignore value while waiting for the key matrix to settle
  ldh a, [rP1]
  ldh a, [rP1] ; This final reading is the one that counts
  or a, $F0 ; A7-4 = 1; A3-0 = Unpressed keys
.knownRet
  ret


; Convert a pixel position to a tile address
; hl = $9800 + X + Y  * 32
; param b: X
; param c: Y
; return hl: tile address
GetTileByPixel::
    ; First we must divide by 8 to convert a pixel to tile position.
    ; After that, we must multiply the Y coordinate by 32.
    ; Those operations cancel out, therefore, we only need to mask the Y value.
    ld a, c
    and a, %11111000
    ld l, a
    ld h, 0
    ; We now have the position * 8 in hl.
    add hl, hl ; hl * 16
    add hl, hl ; hl * 32
    ; Convert X position to an offset.
    ld a, b
    srl a ; a / 2
    srl a ; a / 4
    srl a ; a / 8
    ; Adding the two offsets together.
    add a, l
    ld l, a
    adc a, h
    sub a, l
    ld h, a
    ; Add the offset to the tilemap's base address, and then we're done.
    ld bc, $9800
    add hl, bc

    ret

; param a: Tile ID
; return z: set if it's a wall tile
IsWallTile::
    cp a, $00
    ret z
    cp a, $01
    ret z
    cp a, $02
    ret z
    cp a, $04
    ret z
    cp a, $05
    ret z
    cp a, $06
    ret z
    cp a, $07

    ret

;; From: https://github.com/pinobatch/libbet/blob/master/src/rand.z80#L34-L54
; Generates a pseudorandom 16-bit integer in BC
; using the LCG formula from cc65 rand():
; x[i + 1] = x[i] * 0x01010101 + 0xB3B3B3B3
; @return A=B=state bits 31-24 (which have the best entropy),
; C=state bits 23-16, HL trashed
Random::
  ; Add 0xB3 then multiply by 0x01010101
  ld hl, randData+0
  ld a, [hl]
  add a, $B3
  ld [hl+], a
  adc a, [hl]
  ld [hl+], a
  adc a, [hl]
  ld [hl+], a
  ld c, a
  adc a, [hl]
  ld [hl], a
  ld b, a
  ret


; RandRange(MinValue d, MaxValue, e)
; Return: value from specified range in a
RandRange::
    .randLoop
        call Random

        cp a, d
        jp z, EndRange
        
        cp a, e
        jp z, EndRange

        jp .randLoop
EndRange:
    ret

SECTION "MathVariables", WRAM0
randData:: ds 4
