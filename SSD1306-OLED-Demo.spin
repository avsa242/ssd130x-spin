{
    --------------------------------------------
    Filename:
    Author:
    Copyright (c) 20__
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

    SSD1306_SCL = 28
    SSD1306_SDA = 29
    SSD1306_HZ  = 1_000_000

    WIDTH       = oled#SSD1306_WIDTH
    HEIGHT      = oled#SSD1306_HEIGHT
    BUFFSZ      = oled#BUFFSZ
    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1

OBJ

    cfg   : "core.con.client.flip"
    ser   : "com.serial.terminal"
    time  : "time"
    oled  : "display.oled.128x32.i2c"
    debug : "debug"
    int   : "string.integer"

VAR

    byte _framebuff[BUFFSZ]
    byte _fps
    long _fmon_cog, _fmon_stack[50]
    long _rndSeed

    long bx, by, dx, dy

PUB Main | x, y

    _fps := 0
    Setup
    ClearFrameBuffer
'    FillScreen (1000, $FF_FF_FF_FF)
'    Wave (1000)
'    MEMScroller($0000, $2000)
'    DrawBitmap (1000)
'    LineSweep(3)
'    LineRND (1000)
'    PlotRND (1000)
'    BallDemo (1000)
    ExpandingCircle(5)
    ContrastDemo(2, 1)
    oled.DisplayOff
    halted

PUB BouncingBallDemo(frames) | radius

    radius := 5

    bx := (rnd(127) // (WIDTH - radius * 4)) + radius * 2   'Pick a random screen location to
    by := (rnd(31) // (HEIGHT - radius * 4)) + radius * 2   ' start from
    dx := rnd(4) // 2 * 2 - 1                               'Pick a random direction to
    dy := rnd(4) // 2 * 2 - 1                               ' start moving

    repeat frames
        bx += dx
        by += dy
        if (by =< radius OR by => HEIGHT - radius)  'If we reach the top or bottom of the screen,
            dy *= -1                                ' change direction
        if (bx =< radius OR bx => WIDTH - radius)   'Ditto with the left or right sides
            dx *= -1

        oled.DrawCircle (@_framebuff, bx, by, radius, 1)
        oled.writeBuffer (@_framebuff)
        _fps++
        ClearFrameBuffer

PUB ClearDisplayBuffer

    longfill(@_framebuff, $00, BUFFSZ/4)
    oled.writeBuffer (@_framebuff)

PUB ClearFrameBuffer

    longfill(@_framebuff, $00, BUFFSZ/4)

PUB DrawBitmap(reps)

    repeat reps
        bytemove(@_framebuff, @bitmap1, BUFFSZ)
        oled.WriteBuffer (@_framebuff)
        _fps++

PUB ExpandingCircle(reps) | i

    repeat reps
        repeat i from 1 to 31'31 to -31
            oled.DrawCircle (@_framebuff, WIDTH/4, HEIGHT/4, ||i, -1)
            oled.DrawCircle (@_framebuff, WIDTH/2, HEIGHT/2, ||i, -1)
            oled.writeBuffer (@_framebuff)
            _fps++
            ClearFrameBuffer

PUB ContrastDemo(reps, delay_ms) | contrast_level

    repeat reps
        repeat contrast_level from 255 to 1
            oled.SetContrast (contrast_level)
            time.MSleep (delay_ms)
        repeat contrast_level from 0 to 254
            oled.SetContrast (contrast_level)
            time.MSleep (delay_ms)

PUB FillScreen(reps, pattern)

    repeat reps
        longfill(@_framebuff, pattern, BUFFSZ/4)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB LineRND (reps) | x, y

    repeat reps
        oled.DrawLine (@_framebuff, rnd(127), rnd(31), rnd(127), rnd(31), -1)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB LineSweep (reps) | x, y

    repeat reps
        repeat x from 0 to 127 step 1
            oled.DrawLine (@_framebuff, x, 0, 127-x, 31, -1)
            oled.writeBuffer (@_framebuff)
            _fps++

        repeat y from 0 to 31 step 1
            oled.DrawLine (@_framebuff, 127, y, 0, 31-y, -1)
            oled.writeBuffer (@_framebuff)
            _fps++

PUB MEMScroller(start_addr, end_addr) | pos, st, en

    repeat pos from start_addr to end_addr
        bytemove(@_framebuff, pos, BUFFSZ)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB PlotRND (reps) | x, y

    repeat reps
        oled.DrawPixel (@_framebuff, rnd(127), rnd(31), -1)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB Wave(frames) | i, x, y, yf

    yf := 1
    repeat frames
        repeat x from 127 to 0
            y := y + yf
            if y > 127
                yf := -1
            if y < 0
                yf := 1
            oled.DrawPixel (@_framebuff, x, y, -1)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB halted

    ser.Str (string("Press a key to power off", ser#NL))
    ser.CharIn
    oled.DisplayOff
    oled.Stop
    cogstop(_fmon_cog)
    ser.Str (string("Halted", ser#NL))
    debug.LEDFast (27)

PUB WriteBuffTerm(ptr_buf) | i

    repeat i from 0 to BUFFSZ-1
        ser.Hex (byte[ptr_buf][i], 2)
        ser.Char (" ")
        if lookdown(i: 127, 255, 383, 511)
            ser.NewLine

PUB RND(upperlimit) | i       'Returns a random number between 0 and upperlimit

    i :=? _rndSeed
    i >>= 16
    i *= (upperlimit + 1)
    i >>= 16

    return i

PUB fmon

    ser.Position (0, 5)
    ser.Str (string("FPS: "))
    repeat
        time.Sleep (1)
        ser.Position (5, 5)
        ser.Str (int.DecZeroed (_fps, 3))
        _fps := 0

PUB Setup

    repeat until ser.Start (115_200)
    ser.Clear
    ser.Str (string("Serial terminal started", ser#NL))
    if oled.Startx (SSD1306_SCL, SSD1306_SDA, SSD1306_HZ)
        oled.Defaults
        ser.Str (string("SSD1306 object started", ser#NL))
    else
        ser.Str (string("SSD1306 object failed to start - halting"))
        oled.Stop
        time.MSleep (100)
        ser.Stop
        debug.LEDSlow (cfg#LED1)
    ser.Str (string("Ready", ser#NL))
    _fmon_cog := cognew(fmon, @_fmon_stack)  'Start framerate monitor in another cog/core

DAT

  bitmap1 byte  $F,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$F,{
}               $F,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}               $F,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}               $F,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,$F

  bitmap2 byte  $A,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$F,{
}               $A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}               $A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}               $A,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,$F

{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
