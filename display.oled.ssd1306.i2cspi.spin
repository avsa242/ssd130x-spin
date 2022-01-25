{
    --------------------------------------------
    Filename: display.oled.ssd1306.i2cspi.spin
    Description: Driver for Solomon Systech SSD1306 OLED displays
    Author: Jesse Burt
    Copyright (c) 2021
    Created: Apr 26, 2018
    Updated: Jan 25, 2022
    See end of file for terms of use.
    --------------------------------------------
}
#define 1BPP
#define MEMMV_NATIVE bytemove
#include "lib.gfx.bitmap.spin"

CON

    SLAVE_WR        = core#SLAVE_ADDR
    SLAVE_RD        = core#SLAVE_ADDR|1

    DEF_HZ          = 100_000
    MAX_COLOR       = 1
    BYTESPERPX      = 1

' States for D/C pin
    DATA            = 1
    CMD             = 0

' Display visibility modes
    NORMAL          = 0
    ALL_ON          = 1
    INVERTED        = 2

' Addressing modes
    HORIZ           = 0
    VERT            = 1
    PAGE            = 2

OBJ

    core: "core.con.ssd1306"
    time: "time"
#ifdef SSD130X_I2C
    i2c : "com.i2c"                             ' PASM I2C engine (~1MHz)
#elseifdef SSD130X_SPI
    spi : "com.spi.bitbang"                     ' PASM SPI engine (~4MHz)
#endif

VAR

    long _DC, _RES
    long _ptr_drawbuffer
    word _buff_sz
    word _bytesperln
    byte _disp_width, _disp_height, _disp_xmax, _disp_ymax
    byte _sa0

PUB Null{}
' This is not a top-level object

#ifdef SSD130X_I2C
PUB Startx(SCL_PIN, SDA_PIN, RES_PIN, I2C_HZ, ADDR_BIT, WIDTH, HEIGHT, ptr_dispbuff): status
' Start the driver with custom I/O settings
'   SCL_PIN: 0..31
'   SDA_PIN: 0..31
'   RES_PIN: 0..31 (optional; use -1 to disable)
'   I2C_HZ: max official is 400_000 (unenforced, YMMV!)
'   SLAVE_LSB: 0, 1
'   WIDTH: 96, 128
'   HEIGHT: 32, 64
    ' validate pins
    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if (status := i2c.init(SCL_PIN, SDA_PIN, I2C_HZ))
            time.usleep(core#TPOR)              ' wait for device startup
            _sa0 := ||(ADDR_BIT == 1) << 1      ' slave address bit option
            _RES := RES_PIN                     ' -1 to disable

            if i2c.present(SLAVE_WR | _sa0)     ' test device bus presence
                _disp_width := width
                _disp_height := height
                _disp_xmax := _disp_width-1
                _disp_ymax := _disp_height-1
                ' calc display memory usage from dimensions and 1bpp depth
                _buff_sz := (_disp_width * _disp_height) / 8
                _bytesperln := _disp_width * BYTESPERPX

                address(ptr_dispbuff)           ' set display buffer address
                return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE
#elseifdef SSD130X_SPI
PUB Startx(CS_PIN, SCK_PIN, SDIN_PIN, DC_PIN, RES_PIN, WIDTH, HEIGHT, ptr_dispbuff): status
' Start the driver with custom I/O settings
'   CS_PIN: 0..31
'   SCK_PIN: 0..31
'   SDIN_PIN: 0..31
'   DC_PIN: 0..31
'   RES_PIN: 0..31 (optional; use -1 to disable)
'   WIDTH: 96, 128
'   HEIGHT: 32, 64
    if lookdown(CS_PIN: 0..31) and lookdown(SCK_PIN: 0..31) and {
}   lookdown(SDIN_PIN: 0..31) and lookdown(DC_PIN: 0..31)
        if (status := spi.init(CS_PIN, SCK_PIN, SDIN_PIN, SDIN_PIN, core#SPI_MODE))
            time.usleep(core#TPOR)              ' wait for device startup
            _DC := DC_PIN
            _RES := RES_PIN                     ' -1 to disable

            outa[_DC] := 0
            dira[_DC] := 1
            _disp_width := WIDTH
            _disp_height := HEIGHT
            _disp_xmax := _disp_width-1
            _disp_ymax := _disp_height-1
            ' calc display memory usage from dimensions and 1bpp depth
            _buff_sz := (_disp_width * _disp_height) / 8
            _bytesperln := _disp_width * BYTESPERPX

            address(ptr_dispbuff)               ' set display buffer address
            return
    ' if this point is reached, something above failed
    ' Re-check I/O pin assignments, bus speed, connections, power
    ' Lastly - make sure you have at least one free core/cog
    return FALSE
#endif

PUB Stop{}

    powered(FALSE)
#ifdef SSD130X_I2C
    i2c.deinit{}
#elseifdef SSD130X_SPI
    spi.deinit{}
#endif

PUB Defaults{}
' Apply power-on-reset default settings
    powered(FALSE)
    displaylines(64)
    displaystartline(0)
    chgpumpvoltage(7_500)
    addrmode(PAGE)
    contrast(127)
    displayvisibility(NORMAL)
    displaybounds(0, 0, _disp_xmax, _disp_ymax)
    powered(TRUE)

PUB Preset_128x{}
' Preset: 128px wide, determine settings for height at runtime
    displaylines(_disp_height)
    displaystartline(0)
    chgpumpvoltage(7_500)
    addrmode(HORIZ)
    displayvisibility(NORMAL)
    case _disp_height
        32:
            compincfg(0, 0)
        64:
            compincfg(1, 0)
        other:
            compincfg(0, 0)
    powered(TRUE)

PUB Preset_128x32{}
' Preset: 128px wide, setup for 32px height
    displaylines(32)
    displaystartline(0)
    chgpumpvoltage(7_500)
    addrmode(HORIZ)
    displayvisibility(NORMAL)
    compincfg(0, 0)
    powered(TRUE)

PUB Preset_128x64{}
' Preset: 128px wide, setup for 64px height
    displaylines(64)
    displaystartline(0)
    chgpumpvoltage(7_500)
    addrmode(HORIZ)
    displayvisibility(NORMAL)
    compincfg(1, 0)
    powered(TRUE)

PUB Address(addr)
' Set framebuffer address
    case addr
        $0004..$7FFF-_buff_sz:
            _ptr_drawbuffer := addr
        other:
            return _ptr_drawbuffer

PUB AddrMode(mode)
' Set Memory Addressing Mode
'   Valid values:
'       0: Horizontal addressing mode
'       1: Vertical
'      *2: Page
'   Any other value is ignored
    case mode
        HORIZ, VERT, PAGE:
        other:
            return

    writereg(core#MEM_ADDRMODE, 1, mode)

PUB ChgPumpVoltage(v)
' Set charge pump regulator voltage, in millivolts
'   Valid values:
'       0 (off), 6_000, *7_500, 8_500, 9_000
'   Any other value is ignored
'   NOTE: This must be called before display power is enabled with Powered()
    case v
        0_000:
            v := core#CHGP_OFF
        6_000:
            v := core#CHGP_6000
        7_500:
            v := core#CHGP_7500
        8_500:
            v := core#CHGP_8500
        9_000:
            v := core#CHGP_9000
        other:
            return

    writereg(core#CHGPUMP, 1, v)

PUB Clear{}
' Clear the display buffer
    bytefill(_ptr_drawbuffer, _bgcolor, _buff_sz)

PUB ClockFreq(freq)
' Set display internal oscillator frequency, in kHz
'   Valid values: 333, 337, 342, 347, 352, 357, 362, 367, 372, 377, 382, 387,
'       392, 397, 402, 407
'   Any other value is ignored
'   NOTE: Range is interpolated, based solely on the range specified in the
'   datasheet, divided into 16 steps
    case freq
        core#FOSC_MIN..core#FOSC_MAX:
            freq := lookdownz(freq: 333, 337, 342, 347, 352, 357, 362, 367, {
}           372, 377, 382, 387, 392, 397, 402, 407) << core#OSCFREQ
        other:
            return

    writereg(core#SETOSCFREQ, 1, freq)

PUB COMLogicHighLevel(level)
' Set COMmon pins high logic level, relative to Vcc
'   Valid values:
'       0_65: 0.65 * Vcc
'      *0_77: 0.77 * Vcc
'       0_83: 0.83 * Vcc
'   Any other value sets the default value
    case level
        0_65:
            level := %000 << 4
        0_77:
            level := %010 << 4
        0_83:
            level := %011 << 4
        other:
            level := %010 << 4

    writereg(core#SETVCOMDESEL, 1, level)

PUB COMPinCfg(pin_config, remap) | config
' Set COM Pins Hardware Configuration and Left/Right Remap
'   Valid values:
'       pin_config: 0: Sequential                      1: Alternative (POR)
'       remap:      0: Disable Left/Right remap (POR)  1: Enable remap
'   Any other value sets the default value
    config := %0000_0010    ' XXX use named constant/clarify
    case pin_config
        0:
        other:
            config := config | (1 << 4)

    case remap
        1:
            config := config | (1 << 5)
        other:

    writereg(core#SETCOM_CFG, 1, config)

PUB Contrast(level)
' Set Contrast Level
'   Valid values: 0..255 (default: 127)
'   Any other value sets the default value
    case level
        0..255:
        other:
            level := 127

    writereg(core#CONTRAST, 1, level)

PUB DisplayBounds(sx, sy, ex, ey)
' Set displayable area
    ifnot lookup(sx: 0..127) or lookup(sy: 0..63) or lookup(ex: 0..127) {
}   or lookup(ey: 0..63)
        return

    sy >>= 3                                    ' convert y-coordinates to
    ey >>= 3                                    '   page numbers
    writereg(core#SET_COLADDR, 2, (ex << 8) | sx)
    writereg(core#SET_PAGEADDR, 2, (ey << 8) | sy)

PUB DisplayInverted(state) | tmp
' Invert display colors
    case ||(state)
        0:
            displayvisibility(NORMAL)
        1:
            displayvisibility(INVERTED)
        other:
            return

PUB DisplayLines(lines)
' Set total number of display lines
'   Valid values: 16..64
'   Typical values: 32, 64
'   Any other value is ignored
    case lines
        16..64:
            lines -= 1
        other:
            return

    writereg(core#SETMUXRATIO, 1, lines)

PUB DisplayOffset(offset)
' Set display offset/vertical shift
'   Valid values: 0..63 (default: 0)
'   Any other value sets the default value
    case offset
        0..63:
        other:
            offset := 0

    writereg(core#SETDISPOFFS, 1, offset)

PUB DisplayStartLine(start_line)
' Set Display Start Line
'   Valid values: 0..63 (default: 0)
'   Any other value sets the default value
    case start_line
        0..63:
        other:
            start_line := 0

    writereg(core#DISP_STLINE, 0, start_line)

PUB DisplayVisibility(mode)
' Set display visibility
    case mode
        NORMAL:
            writereg(core#RAMDISP_ON, 0, 0)
            writereg(core#DISP_NORM, 0, 0)
        ALL_ON:
            writereg(core#RAMDISP_ON, 0, 1)
        INVERTED:
            writereg(core#DISP_NORM, 0, 1)
        other:
            return

PUB MirrorH(state)
' Mirror display, horizontally
'   Valid values: TRUE (-1 or 1), *FALSE (0)
'   Any other value is ignored
'   NOTE: Takes effect only after next display update
    case ||(state)
        0, 1: state := ||(state)
        other:
            return

    writereg(core#SEG_MAP0, 0, state)

PUB MirrorV(state)
' Mirror display, vertically
'   Valid values: TRUE (-1 or 1), *FALSE (0)
'   Any other value is ignored
'   NOTE: Takes effect only after next display update
    case ||(state)
        0:
        1: state := 8
        other:
            return

    writereg(core#COMDIR_NORM, 0, state)

#ifdef GFX_DIRECT
PUB Plot(x, y, color)
' Plot pixel at (x, y) in color (direct to display)
#else
PUB Plot(x, y, color)
' Plot pixel at (x, y) in color (buffered)
    case color
        1:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] |= (|< (y&7))
        0:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] &= !(|< (y&7))
        -1:
            byte[_ptr_drawbuffer][x + (y>>3) * _disp_width] ^= (|< (y&7))
        OTHER:
            return
#endif

PUB Point(x, y): pix_clr
' Get color of pixel at x, y
    x := 0 #> x <# _disp_xmax
    y := 0 #> y <# _disp_ymax

    return (byte[_ptr_drawbuffer][(x + (y >> 3) * _disp_width)] & (1 << (y & 7)) <> 0) * -1

PUB Powered(state) | tmp
' Enable display power
    case ||(state)
        0, 1:
            state := ||(state) + core#DISP_OFF
        other:
            return
    writereg(state, 0, 0)

PUB PrechargePeriod(phs1_clks, phs2_clks)
' Set display refresh pre-charge period, in display clocks
'   Valid values: 1..15 (default: 2, 2)
'   Any other value sets the default value
    case phs1_clks
        1..15:
        other:
            phs1_clks := 2

    case phs2_clks
        1..15:
        other:
            phs2_clks := 2

    writereg(core#SETPRECHARGE, 1, (phs2_clks << 4) | phs1_clks)

PUB Reset{}
' Reset the display controller
    if lookdown(_RES: 0..31)
        outa[_RES] := 1
        dira[_RES] := 1
        time.usleep(3)
        outa[_RES] := 0
        time.usleep(3)
        outa[_RES] := 1

PUB Update{} | tmp
' Write display buffer to display
    displaybounds(0, 0, _disp_xmax, _disp_ymax)

#ifdef SSD130X_I2C
    i2c.start{}
    i2c.wr_byte(SLAVE_WR | _sa0)
    i2c.wr_byte(core#CTRLBYTE_DATA)
    i2c.wrblock_lsbf(_ptr_drawbuffer, _buff_sz)
    i2c.stop{}
#elseifdef SSD130X_SPI
    outa[_DC] := DATA
    spi.deselectafter(true)
    spi.wrblock_lsbf(_ptr_drawbuffer, _buff_sz)
#endif

PUB WriteBuffer(ptr_buff, buff_sz) | tmp
' Write alternate buffer to display
'   buff_sz: bytes to write
'   ptr_buff: address of buffer to write to display
    displaybounds(0, 0, _disp_xmax, _disp_ymax)

#ifdef SSD130X_I2C
    i2c.start{}
    i2c.wr_byte(SLAVE_WR | _sa0)
    i2c.wr_byte(core#CTRLBYTE_DATA)
    i2c.wrblock_lsbf(ptr_buff, buff_sz)
    i2c.stop{}
#elseifdef SSD130X_SPI
    outa[_DC] := DATA
    spi.deselectafter(true)
    spi.wrblock_lsbf(ptr_buff, buff_sz)
#endif

PRI memFill(xs, ys, val, count)
' Fill region of display buffer memory
'   xs, ys: Start of region
'   val: Color
'   count: Number of consecutive memory locations to write
    bytefill(_ptr_drawbuffer + (xs + (ys * _bytesperln)), val, count)

PRI writeReg(reg_nr, nr_bytes, val) | cmd_pkt[2], tmp, ackbit
' Write nr_bytes from val to device
#ifdef SSD130X_I2C
    cmd_pkt.byte[0] := SLAVE_WR | _sa0
    cmd_pkt.byte[1] := core#CTRLBYTE_CMD
    case nr_bytes
        0:
            cmd_pkt.byte[2] := reg_nr | val 'Simple command
            nr_bytes := 3
        1:
            cmd_pkt.byte[2] := reg_nr       'Command w/1-byte argument
            cmd_pkt.byte[3] := val
            nr_bytes := 4
        2:
            cmd_pkt.byte[2] := reg_nr       'Command w/2-byte argument
            cmd_pkt.byte[3] := val & $FF
            cmd_pkt.byte[4] := (val >> 8) & $FF
            nr_bytes := 5
        other:
            return

    i2c.start{}
    i2c.wrblock_lsbf(@cmd_pkt, nr_bytes)
    i2c.stop{}
#elseifdef SSD130X_SPI
    case nr_bytes
        0:
            cmd_pkt.byte[0] := reg_nr | val 'Simple command
            nr_bytes := 1
        1:
            cmd_pkt.byte[0] := reg_nr       'Command w/1-byte argument
            cmd_pkt.byte[1] := val
            nr_bytes := 2
        2:
            cmd_pkt.byte[0] := reg_nr       'Command w/2-byte argument
            cmd_pkt.byte[1] := val & $FF
            cmd_pkt.byte[2] := (val >> 8) & $FF
            nr_bytes := 3
        other:
            return

    outa[_DC] := CMD
    spi.deselectafter(true)
    spi.wrblock_lsbf(@cmd_pkt, nr_bytes)
#endif

DAT
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
