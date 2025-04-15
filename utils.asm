SECTION "memoryUtils", ROM0

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
