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

