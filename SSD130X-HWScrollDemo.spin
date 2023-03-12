{
    --------------------------------------------
    Filename: SSD130X-HWScrollDemo.spin
    Description: SSD130X Hardware-accelerated scrolling demo
    Author: Jesse Burt
    Copyright (c) 2023
    Started: Mar 12, 2023
    Updated: Mar 12, 2023
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    SER_BAUD    = 115_200

    WIDTH       = 128
    HEIGHT      = 32

{ I2C configuration }
    SCL_PIN     = 28
    SDA_PIN     = 29
    ADDR_BITS   = 0
    SCL_FREQ    = 1_000_000

{ SPI configuration }
    CS_PIN      = 4
    SCK_PIN     = 0
    MOSI_PIN    = 1
    DC_PIN      = 3

    RES_PIN     = 2                             ' optional; -1 to disable
' --

    BYTESPERLN  = WIDTH * disp#BYTESPERPX
    BUFFSZ      = ((WIDTH * HEIGHT) * disp.BYTESPERPX) / 8

OBJ

    cfg:    "boardcfg.flip"
    disp:   "display.oled.ssd130x"
    ser:    "com.serial.terminal.ansi"
    time:   "time"
    fnt:    "font.5x8"

VAR

    byte _framebuff[BUFFSZ]                     ' display buffer

PUB main{} | y

    setup{}

    disp.strln(@"SSD130x on the")
    disp.strln(@"Parallax P8X32A")
    disp.strln(@"HW-accelerated")
    disp.str(@"scrolling demo")
    disp.show{}

    time.msleep(2_000)

    { NOTE: the actual granularity of y coordinates is 8 pixels - they will be rounded
        to the nearest multiple of 8 by the driver (hardware limitation) }

    { horizontal scrolling }
    disp.scroll_left_cont(0, 0, 127, 63, 2)     ' sx, sy, ex, ey, inter-scroll step delay (frames)
    time.msleep(2_000)

    disp.scroll_right_cont(0, 0, 127, 63, 2)
    time.msleep(2_000)

    { vertical/horizontal scrolling }
    { NOTE: vertical scroll by itself isn't possible in hardware - there are two modes that
        combine vertical with horizontal scrolling }
    disp.scroll_right_up_cont(0, 63, 1, 2)      ' sy, ey, vertical scroll step (pixels), delay
    time.msleep(2_000)

    disp.scroll_left_up_cont(0, 63, 1, 2)
    time.msleep(2_000)

    { scroll invidual horizontal pages (groups of 8 rows) }
    repeat y from 0 to 24 step 8
        disp.scroll_left_cont(0, y, 127, y+7, 2)
        time.msleep(2_000)
        disp.scroll_right_cont(0, y, 127, y+7, 2)
        time.msleep(2_000)

    disp.scroll_stop{}
    repeat

PUB setup{}

    ser.start(SER_BAUD)
    time.msleep(30)
    ser.clear{}
    ser.strln(string("Serial terminal started"))

#ifdef SSD130X_SPI
    if disp.startx(CS_PIN, SCK_PIN, MOSI_PIN, DC_PIN, RES_PIN, WIDTH, HEIGHT, @_framebuff)
#else
#define SSD130X_I2C
    if disp.startx(SCL_PIN, SDA_PIN, RES_PIN, SCL_FREQ, ADDR_BITS, WIDTH, HEIGHT, @_framebuff)
#endif
        ser.strln(string("SSD130X driver started"))
        disp.font_spacing(1, 0)
        disp.font_scl(1)
        disp.font_sz(fnt#WIDTH, fnt#HEIGHT)
        disp.font_addr(fnt.ptr{})
        disp.preset_128x{}
    else
        ser.strln(string("SSD130X driver failed to start - halting"))
        repeat

    disp.mirror_h(FALSE)
    disp.mirror_v(FALSE)
    disp.clear{}
    disp.fgcolor(1)

{
Copyright 2023 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

