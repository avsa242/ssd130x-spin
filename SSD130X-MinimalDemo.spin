{
    --------------------------------------------
    Filename: SSD130X-MinimalDemo.spin
    Description: Graphics demo using minimal code
    Author: Jesse Burt
    Copyright (c) 2024
    Started: May 28, 2022
    Updated: Jan 2, 2024
    See end of file for terms of use.
    --------------------------------------------
}
CON

    _clkmode    = xtal1 + pll16x
    _xinfreq    = 5_000_000


OBJ

    fnt:    "font.5x8"
    disp:   "display.oled.ssd130x" | WIDTH=128, HEIGHT=64, ...
                                    {I2C} SCL=28, SDA=29, I2C_ADDR=0, I2C_FREQ=400_000, ...
                                    {SPI} CS=0, SCK=1, MOSI=2, DC=3, RST=4


PUB main()

    { Uncomment one or both pairs of the below if applicable.
        The driver defaults to I2C, SSD1306 model if nothing is specified }
'#define SSD130X_SPI                             { SPI-connected displays }
'#pragma exportdef(SSD130X_SPI)

'#define SSD1309                                { SSD1309 models only }
'#pragma exportdef(SSD1309)

    disp.start()

    { configure the display with the minimum required setup:
        1. Use a common settings preset for 128x# displays
        2. Tell the driver where to find the font setup }
    disp.preset_128x()
    disp.set_font(fnt.ptr(), fnt.setup())
    disp.clear()

    { draw some text }
    disp.pos_xy(0, 0)
    disp.fgcolor(1)
    disp.strln(@"Testing 12345")
    disp.show()                                 ' send the buffer to the display
                                                ' (ignored if GFX_DIRECT is #defined)

    { draw one pixel at the center of the screen }
    {   disp.plot(x, y, color) }
    disp.plot(disp.CENTERX, disp.CENTERY, 1)
    disp.show()

    { draw a box at the screen edges }
    {   disp.box(x_start, y_start, x_end, y_end, color, filled) }
    disp.box(0, 0, disp.XMAX, disp.YMAX, 1, false)
    disp.show()

    repeat

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

