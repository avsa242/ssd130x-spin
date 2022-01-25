{
    --------------------------------------------
    Filename: SSD1306-Demo.spin
    Description: Demo of the SSD1306 driver
    Author: Jesse Burt
    Copyright (c) 2022
    Started: Apr 26, 2018
    Updated: Jan 25, 2022
    See end of file for terms of use.
    --------------------------------------------
}
#define SSD130X_I2C
'#define SSD130X_SPI

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants:
    LED         = cfg#LED1
    SER_BAUD    = 115_200

#ifdef SSD130X_I2C
' I2C
    SCL_PIN     = 0
    SDA_PIN     = 1
    RES_PIN     = -1                            ' optional; -1 to disable
    ADDR_BIT    = 0
    I2C_HZ      = 400_000                       ' max: 400_000 (unenforced)
#elseifdef SSD130X_SPI
' SPI
    CS_PIN      = 2
    SCK_PIN     = 3
    SDIN_PIN    = 4
    DC_PIN      = 6
    RES_PIN     = 5                             ' optional; -1 to disable
#endif
    WIDTH       = 128
    HEIGHT      = 32
' --
    BPP         = disp#BYTESPERPX
    BYTESPERLN  = WIDTH * BPP
    BUFFSZ      = (WIDTH * HEIGHT) / 8
    XMAX        = WIDTH - 1
    YMAX        = HEIGHT - 1

OBJ

    cfg         : "core.con.boardcfg.flip"
    ser         : "com.serial.terminal.ansi"
    time        : "time"
    disp        : "display.oled.ssd1306.i2cspi"
    int         : "string.integer"
    fnt5x8      : "font.5x8"

VAR

    long _stack_timer[50]
    long _timer_set
    long _rndseed
    byte _framebuff[BUFFSZ]
    byte _timer_cog

PUB Main{} | time_ms

    setup{}
    disp.clear{}

    disp.mirrorh(TRUE)
    disp.mirrorv(TRUE)

    demo_greet{}
    time.sleep(5)
    disp.clear{}

    time_ms := 5_000

    ser.position(0, 3)

    demo_sinewave(time_ms)
    disp.clear{}

    demo_triwave(time_ms)
    disp.clear{}

    demo_memscroller(time_ms, $0000, $FFFF-BUFFSZ)
    disp.clear{}

    demo_bitmap(time_ms, @Beanie)
    disp.clear{}

    demo_box(time_ms)
    disp.clear{}

    demo_boxfilled(time_ms)
    disp.clear{}

    demo_linesweepx(time_ms)
    disp.clear{}

    demo_linesweepy(time_ms)
    disp.clear{}

    demo_line(time_ms)
    disp.clear{}

    demo_plot(time_ms)
    disp.clear{}

    demo_bouncingball(time_ms, 5)
    disp.clear{}

    demo_circle(time_ms)
    disp.clear{}

    demo_wander(time_ms)
    disp.clear{}

    demo_seqtext(time_ms)
    disp.clear{}

    demo_rndtext(time_ms)

    demo_contrast(2, 1)
    disp.clear{}

    stop{}
    repeat

PUB Demo_BouncingBall(testtime, radius) | iteration, bx, by, dx, dy
' Draws a simple ball bouncing off screen edges
' Pick a random screen location to start from, and a random direction
    bx := (rnd(XMAX) // (WIDTH - radius * 4)) + radius * 2
    by := (rnd(YMAX) // (HEIGHT - radius * 4)) + radius * 2
    dx := rnd(4) // 2 * 2 - 1
    dy := rnd(4) // 2 * 2 - 1

    ser.str(string("Demo_BouncingBall - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        bx += dx
        by += dy

        ' if any edge of the screen is reached, change direction
        if (by =< radius OR by => (YMAX-radius))
            dy *= -1                            ' top/bottom edges
        if (bx =< radius OR bx => (XMAX-radius))
            dx *= -1                            ' left/right edges

        disp.circle(bx, by, radius, disp#MAX_COLOR, false)
        disp.update{}
        iteration++
        disp.clear{}

    report(testtime, iteration)

PUB Demo_Bitmap(testtime, ptr_bitmap) | iteration
' Continuously redraws bitmap at address ptr_bitmap
    ser.str(string("Demo_Bitmap - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.bitmap(ptr_bitmap, 0, 0, XMAX, YMAX)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_Box(testtime) | iteration, c
' Draws random lines
    ser.str(string("Demo_Box - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.box(rnd(XMAX), rnd(YMAX), rnd(XMAX), rnd(YMAX), -1, FALSE)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_BoxFilled(testtime) | iteration, c
' Draws random lines
    ser.str(string("Demo_BoxFilled - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.box(rnd(XMAX), rnd(YMAX), rnd(XMAX), rnd(YMAX), -1, TRUE)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_Circle(testtime) | iteration, x, y, r
' Draws circles at random locations
    ser.str(string("Demo_Circle - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        x := rnd(XMAX)
        y := rnd(YMAX)
        r := rnd(YMAX/2)
        disp.circle(x, y, r, -1, false)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_Contrast(reps, delay_ms) | contrast_level
' Fades out and in display contrast
    ser.str(string("Demo_Contrast - N/A"))

    repeat reps
        repeat contrast_level from 255 to 1
            disp.contrast(contrast_level)
            time.msleep(delay_ms)
        repeat contrast_level from 0 to 254
            disp.contrast(contrast_level)
            time.msleep(delay_ms)

    ser.newline{}

PUB Demo_Greet{}
' Display the banner/greeting on the OLED
    disp.fgcolor(disp#MAX_COLOR)
    disp.bgcolor(0)
    disp.position(0, 0)
    disp.strln(string("SSD1306 on the"))
    disp.strln(string("Parallax"))
    disp.printf1(string("P8X32A @ %dMHz\n"), clkfreq/1_000_000)
    disp.printf2(string("%dx%d"), WIDTH, HEIGHT)
    disp.update{}

PUB Demo_Line(testtime) | iteration
' Draws random lines with color -1 (invert)
    ser.str(string("Demo_Line - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.line(rnd(XMAX), rnd(YMAX), rnd(XMAX), rnd(YMAX), -1)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_LineSweepX(testtime) | iteration, x
' Draws lines top left to lower-right, sweeping across the screen
    x := 0

    ser.str(string("Demo_LineSweepX - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        x++
        if x > XMAX
            x := 0
        disp.line(x, 0, XMAX-x, YMAX, -1)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_LineSweepY(testtime) | iteration, y
' Draws lines top left to lower-right, sweeping across the screen
    y := 0

    ser.str(string("Demo_LineSweepY - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        y++
        if y > YMAX
            y := 0
        disp.line(XMAX, y, 0, YMAX-y, -1)
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_MEMScroller(testtime, start_addr, end_addr) | iteration, ptr
' Dumps Propeller Hub RAM (and/or ROM) to the display buffer
    ptr := start_addr

    ser.str(string("Demo_MEMScroller - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.bitmap(ptr, 0, 0, XMAX, YMAX)      ' show 1 screenful of RAM
        ptr += BYTESPERLN                       ' advance memory pointer
        if ptr > end_addr                       ' wrap around if the end of
            ptr := start_addr                   '   Propeller RAM is reached
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_Plot(testtime) | iteration, x, y
' Draws random pixels to the screen, with random color
    ser.str(string("Demo_Plot - "))
    _timer_set := testtime
    iteration := 0

    if disp#MAX_COLOR > 1
        repeat while _timer_set
            disp.plot(rnd(XMAX), rnd(YMAX), rnd(disp#MAX_COLOR))
            disp.update{}
            iteration++
    else
        repeat while _timer_set
            disp.plot(rnd(XMAX), rnd(YMAX), -1)
            disp.update{}
            iteration++
    report(testtime, iteration)

PUB Demo_Sinewave(testtime) | iteration, x, y, modifier, offset, div
' Draws a sine wave the length of the screen, influenced by the system counter
    ser.str(string("Demo_Sinewave - "))

    case HEIGHT
        32:
            div := 4096
        64:
            div := 2048
        other:
            div := 2048

    offset := YMAX/2                            ' Offset for Y axis

    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        repeat x from 0 to XMAX
            modifier := (||(cnt) / 1_000_000)   ' system counter as modifier
            y := offset + sin(x * modifier) / div
            disp.plot(x, y, disp#MAX_COLOR)

        disp.update{}
        iteration++
        disp.clear{}

    report(testtime, iteration)

PUB Demo_SeqText(testtime) | iteration, ch
' Sequentially draws the whole font table to the screen, then random characters
    disp.fgcolor(disp#MAX_COLOR)
    disp.bgcolor(0)
    ch := $20
    disp.position(0, 0)

    ser.str(string("Demo_SeqText - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.char(ch)
        ch++
        if ch > $7F
            ch := $20
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_RndText(testtime) | iteration

    disp.fgcolor(disp#MAX_COLOR)
    disp.bgcolor(0)
    disp.position(0, 0)

    ser.str(string("Demo_RndText - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        disp.char(32 #> rnd(127))
        disp.update{}
        iteration++

    report(testtime, iteration)

PUB Demo_TriWave(testtime) | iteration, x, y, ydir
' Draws a simple triangular wave
    ydir := 1
    y := 0

    ser.str(string("Demo_TriWave - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        repeat x from 0 to XMAX
            if y == YMAX
                ydir := -1
            if y == 0
                ydir := 1
            y := y + ydir
            disp.plot(x, y, disp#MAX_COLOR)
        disp.update{}
        iteration++
        disp.clear{}

    report(testtime, iteration)

PUB Demo_Wander(testtime) | iteration, x, y, d
' Draws randomly wandering pixels
    _rndseed := cnt
    x := XMAX/2                                 ' start at screen center
    y := YMAX/2

    ser.str(string("Demo_Wander - "))
    _timer_set := testtime
    iteration := 0

    repeat while _timer_set
        case d := rnd(4)                        ' which way to move?
            1:                                  ' wander right
                x += 2
                if x > XMAX                     ' wrap around at the edge
                    x := 0
            2:                                  ' wander left
                x -= 2
                if x < 0
                    x := XMAX
            3:                                  ' wander down
                y += 2
                if y > YMAX
                    y := 0
            4:                                  ' wander up
                y -= 2
                if y < 0
                    y := YMAX
        disp.plot(x, y, -1)
        disp.update{}
        iteration++

    report(testtime, iteration)

PRI Sin(angle): sine
' Return the sine of angle
    sine := angle << 1 & $FFE
    if angle & $800
       sine := word[$F000 - sine]   ' Use sine table from ROM
    else
       sine := word[$E000 + sine]
    if angle & $1000
       -sine

PRI RND(maxval): r
' Return random number up to maxval
    return ||(? _rndseed) // maxval

PRI Report(testtime, iterations)

    ser.printf2(string("Total iterations: %d, iterations/sec: %d, ms/iteration: "),{
}   iterations, iterations / (testtime/1000))
    decimal((testtime * 1_000) / iterations, 1_000)
    ser.newline{}

PRI Decimal(scaled, divisor) | whole[4], part[4], places, tmp
' Display a fixed-point scaled up number in decimal-dot notation - scale it back down by divisor
'   e.g., Decimal (314159, 100000) would display 3.14159 on the termainl
'   scaled: Fixed-point scaled up number
'   divisor: Divide scaled-up number by this amount
    whole := scaled / divisor
    tmp := divisor
    places := 0

    repeat
        tmp /= 10
        places++
    until tmp == 1
    part := int.deczeroed(||(scaled // divisor), places)

    ser.dec(whole)
    ser.char(".")
    ser.str(part)

PRI cog_Timer{} | time_left

    repeat
        repeat until _timer_set
        time_left := _timer_set

        repeat
            time_left--
            time.msleep(1)
        while time_left > 0
        _timer_set := 0

PUB Setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))

#ifdef SSD130X_I2C
    if disp.startx(SCL_PIN, SDA_PIN, RES_PIN, I2C_HZ, ADDR_BIT, WIDTH, HEIGHT, @_framebuff)
        ser.strln(string("SSD1306 driver started (I2C)"))
#elseifdef SSD130X_SPI
    if disp.startx(CS_PIN, SCK_PIN, SDIN_PIN, DC_PIN, RES_PIN, WIDTH, HEIGHT, @_framebuff)
        ser.strln(string("SSD1306 driver started (SPI)"))
#endif
        disp.fontscale(1)
        disp.fontsize(6, 8)
        disp.fontaddress(fnt5x8.baseaddr{})
        disp.reset{}
        disp.preset_128x{}
    else
        ser.strln(string("SSD1306 driver failed to start - halting"))
        stop{}
        repeat
    _timer_cog := cognew(cog_timer{}, @_stack_timer)

PUB Stop{}

    disp.powered(FALSE)
    disp.stop{}
    cogstop(_timer_cog)
    ser.stop{}

#include "propeller-beanie-1bpp.spin"
'#include "propeller-beanie-16bpp.spin"

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
