SECTION "BricksMain", ROM0

HandleAndDestroyBrickLeft::
    ld a, [hl]
    cp a, BRICK_LEFT
    jp nz, HandleAndDestroyBrickRight

    ld [hl], BLANK_TILE
    inc hl
    ld [hl], BLANK_TILE

    jp HandleAndDestroyBrickEnd

HandleAndDestroyBrickRight:
    cp a, BRICK_RIGHT
    jp nz, HandleAndDestroyBrickEnd

    ld [hl], BLANK_TILE
    dec hl
    ld [hl], BLANK_TILE
    
    jp HandleAndDestroyBrickEnd

HandleAndDestroyBrickEnd:
    ret

SECTION "BricksConstants", WRAM0

DEF BRICK_LEFT EQU $05
DEF BRICK_RIGHT EQU $06
DEF BLANK_TILE EQU $08
