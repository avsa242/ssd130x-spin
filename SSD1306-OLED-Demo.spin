{
    --------------------------------------------
    Filename: SSD1306-OLED-Demo.spin
    Description: Demo of the ssd1306 i2c driver
    Author: Jesse Burt
    Copyright (c) 2018
    Created: Apr 26, 2018
    Updated: Oct 24, 2018
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
    int   : "string.integer"

VAR

    byte _framebuff[BUFFSZ]
    byte _fps, _fps_mon_cog
    long _fps_mon_stack[50]
    long _rndSeed

    long bx, by, dx, dy

PUB Main | x, y

    _fps := 0
    Setup
    ClearFrameBuffer

    Demo_Sine1 (500)
    ClearFrameBuffer

    Demo_Wave (500)
    ClearFrameBuffer

    Demo_FillScreen (500, $FF_FF_FF_FF)
    ClearFrameBuffer

    Demo_MEMScroller($1000, $2000)
    ClearFrameBuffer

    Demo_DrawBitmap (@bitmap1, 500)
    ClearFrameBuffer

    Demo_LineSweep(2)
    ClearFrameBuffer

    Demo_LineRND (500)
    ClearFrameBuffer

    Demo_PlotRND (500)
    ClearFrameBuffer

    Demo_BouncingBall (500, 5)
    ClearFrameBuffer

    Demo_ExpandingCircle(5)
    ClearFrameBuffer

    Demo_Wander (2000)

    Demo_Contrast(2, 1)
    ClearDisplayBuffer

    Stop

PUB Demo_BouncingBall(frames, radius)
'' Draws a simple ball bouncing off screen edges
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

PUB Demo_DrawBitmap(addr_bitmap, reps)
'' Continuously redraws bitmap at address 'addr_bitmap' (e.g., Demo_DrawBitmap(@bitmap1, 500)
'' Visually unexciting - just for demonstrating the max blit speed
    repeat reps
        bytemove(@_framebuff, addr_bitmap, BUFFSZ)
        oled.WriteBuffer (@_framebuff)
        _fps++

PUB Demo_ExpandingCircle(reps) | i
'' Draws two offset circles, expanding in radius
    repeat reps
        repeat i from 1 to 31
            oled.DrawCircle (@_framebuff, WIDTH/4, HEIGHT/4, ||i, -1)
            oled.DrawCircle (@_framebuff, WIDTH/2, HEIGHT/2, ||i, -1)
            oled.writeBuffer (@_framebuff)
            _fps++
            ClearFrameBuffer

PUB Demo_Contrast(reps, delay_ms) | contrast_level
'' Fades out and in display contrast
    repeat reps
        repeat contrast_level from 255 to 1
            oled.SetContrast (contrast_level)
            time.MSleep (delay_ms)
        repeat contrast_level from 0 to 254
            oled.SetContrast (contrast_level)
            time.MSleep (delay_ms)

PUB Demo_FillScreen(reps, pattern)
'' Fills framebuffer with 'pattern'
'' As visually unexciting as Demo_FillScreen - similar purpose
    repeat reps
        longfill(@_framebuff, pattern, BUFFSZ/4)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB Demo_LineRND (reps) | x, y
'' Draws random lines with color -1 (invert)
    repeat reps
        oled.DrawLine (@_framebuff, rnd(127), rnd(31), rnd(127), rnd(31), -1)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB Demo_LineSweep (reps) | x, y
'' Draws lines top left to lower-right, sweeping across the screen, then
''  from the top-down
    repeat reps
        repeat x from 0 to 127 step 1
            oled.DrawLine (@_framebuff, x, 0, 127-x, 31, -1)
            oled.writeBuffer (@_framebuff)
            _fps++

        repeat y from 0 to 31 step 1
            oled.DrawLine (@_framebuff, 127, y, 0, 31-y, -1)
            oled.writeBuffer (@_framebuff)
            _fps++

PUB Demo_MEMScroller(start_addr, end_addr) | pos, st, en
'' Dumps Propeller Hub RAM (or ROM) to the framebuffer
'' Very meta/introspective/magic mirror-looking if dumping covers the area of RAM
''  occupied by this program's variables!
    repeat pos from start_addr to end_addr
        bytemove(@_framebuff, pos, BUFFSZ)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB Demo_PlotRND (reps) | x, y
'' Draws random pixels to the screen, with color -1 (invert)
    repeat reps
        oled.DrawPixel (@_framebuff, rnd(127), rnd(31), -1)
        oled.writeBuffer (@_framebuff)
        _fps++

PUB Demo_Sine1(reps) | x, y, modifier, offset, div
'' Draws a sine wave the length of the screen, influenced by
''  the system counter
    div := 4096
    offset := 15                                    ' Offset for Y axis

    repeat reps
        repeat x from 0 to 127
            modifier := (cnt / 1_000_000)           ' Use system counter as modifier
            y := offset + sin(x * modifier) / div
            oled.DrawPixel(@_framebuff, x, y, 1)
        oled.writeBuffer (@_framebuff)
        _fps++
        ClearFrameBuffer

PUB Demo_Wave(frames) | i, x, y, yf
'' Draws a simple triangular wave
    yf := 1
    repeat frames
        repeat x from 0 to XMAX
            if y == YMAX
                yf := -1
            if y == 0
                yf := 1
            y := y + yf
            oled.DrawPixel (@_framebuff, x, y, 1)
        oled.writeBuffer (@_framebuff)
        ClearFrameBuffer
        _fps++

PUB Demo_Wander(reps) | x, y, d
'' Draws randomly wandering pixels
    _rndSeed := cnt
    x := XMAX/2
    y := YMAX/2
    repeat reps
        case d := rnd(4)
            1:
                x += 1
                if x > XMAX
                    x := 0
            2:
                x -= 1
                if x < 0
                    x := XMAX
            3:
                y += 1
                if y > YMAX
                    y := 0
            4:
                y -= 1
                if y < 0
                    y := YMAX
        oled.DrawPixel (@_framebuff, x, y, -1)
        oled.writeBuffer (@_framebuff)

PUB ClearDisplayBuffer
'' Clear the framebuffer and commit it to the display
    longfill(@_framebuff, $00, BUFFSZ/4)
    oled.writeBuffer (@_framebuff)

PUB ClearFrameBuffer
'' Clear the framebuffer only
    longfill(@_framebuff, $00, BUFFSZ/4)

PUB Cos(angle)                  'Cos angle is 13-bit ; Returns a 16-bit signed value
'' Return Cosine of angle
    result := sin(angle + $800)

PUB Sin(angle)                  'Sin angle is 13-bit ; Returns a 16-bit signed value

    result := angle << 1 & $FFE
    if angle & $800
       result := word[$F000 - result]
    else
       result := word[$E000 + result]
    if angle & $1000
       -result

PUB RND(upperlimit) | i       'Returns a random number between 0 and upperlimit

    i :=? _rndSeed
    i >>= 16
    i *= (upperlimit + 1)
    i >>= 16

    return i

PUB fps_mon
'' Sit in another cog and tell us (more or less) how many frames per second we're rendering
    ser.Position (0, 4)
    ser.Str (string("FPS: "))
    repeat
        time.MSleep (1000)
        ser.Position (5, 4)
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
    ser.Str (string("Ready", ser#NL))
    _fps_mon_cog := cognew(fps_mon, @_fps_mon_stack)  'Start framerate monitor in another cog/core

PUB Stop

    ser.Position (0, 6)
    ser.Str (string("Press a key to power off", ser#NL))
    ser.CharIn

    oled.DisplayOff
    oled.Stop

    cogstop(_fps_mon_cog)

    ser.Position (0, 7)
    ser.Str (string("Halted", ser#NL))
    time.MSleep (1)
    ser.Stop

DAT


    bitmap1 byte    $F,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$F,{
}                   $F,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}                   $F,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}                   $F,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,$F

    bitmap2 byte    $A,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,$F,{
}                   $A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}                   $A,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$F,{
}                   $A,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,$F

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
