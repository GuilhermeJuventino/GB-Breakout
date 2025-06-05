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

    ; The ball starts moving up-left or up-right randomly
    ld d, -1
    ld e, 1
    call RandRange
    ld [wBallMomentumX], a
    ld a, -1
    ld [wBallMomentumY], a

    ret

BallReset::
    ld a, 16 + 16
    ld [_OAMRAM + 5], a
    ld a, 100 + 16
    ld [_OAMRAM + 4], a

    ld d, -1
    ld e, 1
    call RandRange
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

    call BounceOnTop
    call BounceOnPaddle
    call CheckBallFellOff

    ld a, 1
    cp a, b
    call z, BallReset

    ret

BounceOnTop:
    ; Remember to offset by OAM Position.
    ; (8, 16) = (0, 0) in OAM.
    ld a, [_OAMRAM + 4]
    sub a, 16 + 1
    ld c, a
    ld a, [_OAMRAM + 5]
    sub a, 8
    ld b, a
    
    call GetTileByPixel
    
    ld a, [hl]

    call IsWallTile

    jp nz, BounceOnRight
    call HandleAndDestroyBrickLeft

    ld a, 1
    ld [wBallMomentumY], a

BounceOnRight:
    ld a, [_OAMRAM + 4]
    sub a, 16
    ld c, a
    ld a, [_OAMRAM + 5]
    sub a, 8 - 1
    ld b, a

    call GetTileByPixel

    ld a, [hl]

    call IsWallTile

    jp nz, BounceOnLeft
    call HandleAndDestroyBrickLeft

    ld a, -1
    ld [wBallMomentumX], a

BounceOnLeft:
    ld a, [_OAMRAM + 4]
    sub a, 16
    ld c, a
    ld a, [_OAMRAM + 5]
    sub a, 8 + 1
    ld b, a

    call GetTileByPixel

    ld a, [hl]

    call IsWallTile

    jp nz, BounceOnBottom
    call HandleAndDestroyBrickLeft

    ld a, 1
    ld [wBallMomentumX], a

BounceOnBottom:
    ld a, [_OAMRAM + 4]
    sub a, 16 - 1
    ld c, a
    ld a, [_OAMRAM + 5]
    sub a, 8
    ld b, a

    call GetTileByPixel

    ld a, [hl]

    call IsWallTile

    jp nz, BounceDone
    call HandleAndDestroyBrickLeft

    ld a, -1
    ld [wBallMomentumY], a

BounceDone:
    ret

BounceOnPaddle:
    ; Check Y coordinates
    ld a, [_OAMRAM]
    ld b, a
    ld a, [_OAMRAM + 4]
    add a, 7
    cp a, b
    jp nz, BounceOnPaddleDone ; If the ball is not at the same Y position as the paddle, it won't bounce.
    ; Now we must compare the X coordinates to see if they match.
    ld a, [_OAMRAM + 5] ; Ball's X position.
    ld b, a
    ld a, [_OAMRAM + 1] ; Paddle's X Position.
    sub a, 8
    cp a, b
    jp nc, BounceOnPaddleDone
    add a, 8 + 16 ; 8 to Undo, 16 as the Paddle's width
    cp a, b
    jp c, BounceOnPaddleDone

    ld a, -1
    ld [wBallMomentumY], a

BounceOnPaddleDone:
    ret

CheckBallFellOff:
    ld a, [_OAMRAM + 4] ; ball's Y coordinate
    
    ; Check if ball has fallen off-screen
    cp a, 160
    jp nz, BallNotFellOff
    jp z, BallFellOff

BallFellOff:
    ld b, 1

    jp CheckBallFellOffEnd

BallNotFellOff:
    ld b, 0

    jp CheckBallFellOffEnd

CheckBallFellOffEnd:
    ret

SECTION "BallGraphics", ROM0

ballImage:: INCBIN "assets/Ball.2bpp"
ballImageEnd::


SECTION "Ball Variables", WRAM0

wBallMomentumX: db
wBallMomentumY: db
