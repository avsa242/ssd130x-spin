{
---------------------------------------------------------------------------------------------------
    Filename:       SSD130X-HWScrollDemo.spin
    Description:    SSD130X Hardware-accelerated scrolling demo
    Author:         Jesse Burt
    Started:        Mar 12, 2023
    Updated:        Jan 22, 2024
    Copyright (c) 2024 - See end of file for terms of use.
---------------------------------------------------------------------------------------------------
}

{ uncomment these if your display is an SSD1309 }
'#define SSD1309
'#pragma exportdef(SSD1309)

{ uncomment these if your display is connected using SPI (SSD1306 or SSD1309) }
'#define SSD130X_SPI
'#pragma exportdef(SSD130X_SPI)

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq


OBJ

    cfg:    "boardcfg.flip"
    disp:   "display.oled.ssd130x" | WIDTH=128, HEIGHT=64, ...
                                    {I2C} SCL=28, SDA=29, I2C_ADDR=0, I2C_FREQ=1_000_000, ...
                                    {SPI} CS=0, SCK=1, MOSI=2, DC=3, RST=4
                                    ' (set RST=-1 to disable (reccommend tying to propeller RESET)
    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    time:   "time"
    fnt:    "font.5x8"


PUB main() | y

    setup()

    disp.char_attrs(disp.TERMINAL)              ' terminal mode: interpret control characters
    disp.strln(@"SSD130x on the")
    disp.strln(@"Parallax P8X32A")
    disp.strln(@"HW-accelerated")
    disp.str(@"scrolling demo")
    disp.show()

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

    disp.scroll_stop()
    repeat

PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(string("Serial terminal started"))

    if ( disp.start() )
        ser.strln(string("SSD130X driver started"))
        disp.set_font(fnt.ptr(), fnt.setup())
        disp.preset_128x()
    else
        ser.strln(string("SSD130X driver failed to start - halting"))
        repeat

    disp.mirror_h(FALSE)
    disp.mirror_v(FALSE)
    disp.clear()
    disp.fgcolor(1)

DAT
{
Copyright 2024 Jesse Burt

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

