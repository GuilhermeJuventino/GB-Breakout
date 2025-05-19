SECTION "BallMain", ROM0

InitBall::
    ; Write ball's object properties to OAM
    ld a, 100 + 16 ; Object's Y coordinate
    ld [hli], a
    ld a, 16 + 46 ; Object's X Coordinate
    ld [hli], a
    ld a, 1 ; Object's Tile Id and attributes
    ld [hli], a
    ld [hli], a

    ; The ball starts moving up and to the right
    ld a, 1
    ld [wBallMomentumX], a
    ld a, -1
    ld [wBallMomentumY], a

    ret

MoveBall::
    ; Update ball's X position
    ld a, [wBallMomentumX]
    ld b, a
    ld a, [_OAMRAM + 5]
    add a, b
    ld [_OAMRAM + 5], a

    ; Update ball's Y position
    ld a, [wBallMomentumY]
    ld b, a
    ld a, [_OAMRAM + 4]
    add a, b
    ld [_OAMRAM + 4], a

    ret


SECTION "BallGraphics", ROM0

ballImage:: INCBIN "assets/Ball.2bpp"
ballImageEnd::


SECTION "Ball Variables", WRAM0

wBallMomentumX: db
wBallMomentumY: db
