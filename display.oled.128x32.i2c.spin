{
    --------------------------------------------
    Filename: display.oled.128x32.i2c.spin
    Description: Driver for Solomon Systech SSD1306 I2C OLED display drivers
      Tested to 1.0MHz
    Author: Jesse Burt
    Copyright (c) 2018
    Created: Apr 26, 2018
    Updated: Oct 27, 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

    SLAVE_WR        = core#SLAVE_ADDR
    SLAVE_RD        = core#SLAVE_ADDR|1

    DEF_SCL         = 28
    DEF_SDA         = 29
    DEF_HZ          = 400_000

    SSD1306_WIDTH   = 128
    SSD1306_HEIGHT  = 32'64
    BUFFSZ          = ((SSD1306_WIDTH * SSD1306_HEIGHT)/8)

OBJ

    core    : "core.con.ssd1306"
    time    : "time"
    i2c     : "jm_i2c_fast_2018"
'    font    : "font.5x8.nexus-like.spin"
    font    : "font.5x8.thomaspsullivan.spin"

VAR

    long _draw_buffer

PUB Null
''This is not a top-level object

PUB Start: okay                                                 'Default to "standard" Propeller I2C pins and 400kHz

    okay := Startx (DEF_SCL, DEF_SDA, DEF_HZ)

PUB Startx(SCL_PIN, SDA_PIN, I2C_HZ): okay

    if lookdown(SCL_PIN: 0..31) and lookdown(SDA_PIN: 0..31)
        if I2C_HZ =< core#I2C_MAX_FREQ
            if okay := i2c.setupx (SCL_PIN, SDA_PIN, I2C_HZ)    'I2C Object Started?
                time.MSleep (20)
                if Ping                                         'Response from device?
                    return okay

    return FALSE                                                'If we got here, something went wrong

PUB Stop

    i2c.terminate

PUB Ping
'' "Pings" device and returns TRUE if present
    i2c.start
    result := i2c.write (SLAVE_WR)
    i2c.stop
    return (result == i2c#ACK)

PUB Defaults

    DisplayOff
    SetOSCFreq ($80)
    SetMuxRatio(SSD1306_HEIGHT-1)
    SetDisplayOffset(0)
    SetDisplayStartLine(0)
    EnableChargePumpReg(TRUE)
    SetAddrMode (0)
    MirrorH(FALSE)
    MirrorV(FALSE)
    SetCOMPinCfg(0, 0) ' 1, 0 - 64  0, 0 - 32
    SetContrast($7F)
    SetPrecharge (1, 15)
    SetVCOMHDeselectLevel ($40)
    EntireDisplayOn(FALSE)
    InvertDisplay(FALSE)
    StopScroll
    SetColumnStartEnd (0, SSD1306_WIDTH-1)'*
    SetPageStartEnd (0, 3)' 0, 7 - 64  0, 3 - 32
    DisplayOn

PUB DisplayOn
' $AF
    writeRegX(core#CMD_DISP_ON, 0, 0)

PUB DisplayOff
' $AE
    writeRegX(core#CMD_DISP_OFF, 0, 0)

PUB DrawCircle(buf_ptr, x0, y0, radius, color) | x, y, err, cdx, cdy

    x := radius - 1
    y := 0
    cdx := 1
    cdy := 1
    err := cdx - (radius << 1)

    repeat while (x => y)
        DrawPixel(buf_ptr, x0 + x, y0 + y, color)
        DrawPixel(buf_ptr, x0 + y, y0 + x, color)
        DrawPixel(buf_ptr, x0 - y, y0 + x, color)
        DrawPixel(buf_ptr, x0 - x, y0 + y, color)
        DrawPixel(buf_ptr, x0 - x, y0 - y, color)
        DrawPixel(buf_ptr, x0 - y, y0 - x, color)
        DrawPixel(buf_ptr, x0 + y, y0 - x, color)
        DrawPixel(buf_ptr, x0 + x, y0 - y, color)

        if (err =< 0)
            y++
            err += cdy
            cdy += 2

        if (err > 0)
            x--
            cdx += 2
            err += cdx - (radius << 1)

PUB DrawPixel (buf_ptr, x, y, c)

    if ((x < 0) or (x => SSD1306_WIDTH) or (y < 0) or (y => SSD1306_HEIGHT))
        return

    case c
        1:
            byte[buf_ptr][x + (y/8)*SSD1306_WIDTH] |= (1 << (y&7))
        0:
            byte[buf_ptr][x + (y/8)*SSD1306_WIDTH] &= (1 << (y&7))
        -1:
            byte[buf_ptr][x + (y/8)*SSD1306_WIDTH] ^= (1 << (y&7))
        OTHER:
            return

PUB DrawLine(buf_ptr, x1, y1, x2, y2, c) | sx, sy, ddx, ddy, err, e2

    ddx := ||(x2-x1)
    ddy := ||(y2-y1)
    err := ddx-ddy

    sx := -1
    if (x1 < x2)
        sx := 1

    sy := -1
    if (y1 < y2)
        sy := 1

    case c
        1:
            repeat until ((x1 == x2) AND (y1 == y2))
                byte[buf_ptr][x1 + (y1/8)*SSD1306_WIDTH] |= (1 << (y1&7))

                e2 := err << 1

                if e2 > -ddy
                    err := err - ddy
                    x1 := x1 + sx

                if e2 < ddx
                    err := err + ddx
                    y1 := y1 + sy

        0:
            repeat until ((x1 == x2) AND (y1 == y2))
                byte[buf_ptr][x1 + (y1/8)*SSD1306_WIDTH] &= (1 << (y1&7))

                e2 := err << 1

                if e2 > -ddy
                    err := err - ddy
                    x1 := x1 + sx

                if e2 < ddx
                    err := err + ddx
                    y1 := y1 + sy

        -1:
            repeat until ((x1 == x2) AND (y1 == y2))
                byte[buf_ptr][x1 + (y1/8)*SSD1306_WIDTH] ^= (1 << (y1&7))

                e2 := err << 1

                if e2 > -ddy
                    err := err - ddy
                    x1 := x1 + sx

                if e2 < ddx
                    err := err + ddx
                    y1 := y1 + sy

        OTHER:
            return

PUB Char (col, row, ch) | i
'' Write a character to the display @ row and column
    col &= $F
    row &= $3
    repeat i from 0 to 7
        byte[_draw_buffer][row << 7{* 128} + col << 3{* 8} + i] := byte[font.baseaddr + 8 * ch + i]

PUB EnableChargePumpReg(enabled)
'8D, 14

    case ||enabled
        0, 1: enabled := ||enabled
        OTHER:
            return
    writeRegX(core#CMD_CHARGEPUMP, 1, lookupz(enabled: $10, $14))

PUB EntireDisplayOn(enabled)
'' $A4
''  TRUE    - Turns on all pixels (doesn't affect GDDRAM contents)
''  FALSE   - Displays GDDRAM contents
    case ||enabled
        0, 1:
            enabled := ||enabled
        OTHER:
            return

    writeRegX(core#CMD_RAMDISP_ON, 0, enabled)

PUB InvertDisplay(enabled)
'A6 - norm, A6|1 - inverted
    case ||enabled
        0, 1:
            enabled := ||enabled
        OTHER:
            return

    writeRegX(core#CMD_DISP_NORM, 0, enabled)

PUB MirrorH(enabled)
' $A0-$A1 bit 0
' Set Segment Re-map: 0 or 127
' NOTE: Only affects subsequent data - no effect on data in GDDRAM
    case ||enabled
        0, 1: enabled := ||enabled
        OTHER:
            return

    writeRegX(core#CMD_SEG_MAP0, 0, enabled)

PUB MirrorV(enabled)
' $C0-$C8 bit 3
' Set COM Output Scan Direction: FALSE or 0: normal, TRUE or 1: remapped
' NOTE: Only affects subsequent data - no effect on data in GDDRAM
' POR: 0
    case ||enabled
        0:
        1: enabled := 8
        OTHER:
            return

    writeRegX(core#CMD_COMDIR_NORM, 0, enabled)

PUB SetAddrMode(mode)
' $20 bits 1..0 mask ****_**AA
' Set Memory Addressing Mode from 0 to 2
'   0: Horizontal addressing mode
'   1: Vertical
'   2: Page (POR)
    case mode
        0, 1:
        OTHER:
            return

    writeRegX(core#CMD_MEM_ADDRMODE, 1, mode)

PUB SetColumnStartEnd(column_start, column_end)
' $21 bits 6..0
    case column_start
        0..127:
        OTHER:
            column_start := 0

    case column_end
        0..127:
        OTHER:
            column_end := 127

    writeRegX(core#CMD_SET_COLADDR, 2, (column_end << 8) | column_start)

PUB SetDisplayOffset(offset)
' $D3 bits 5..0
' Set Display Offset/vertical shift from 0..63
' POR: 0
    case offset
        0..63:
        OTHER:
            offset := 0

    writeRegX(core#CMD_SETDISPOFFS, 1, offset)

PUB SetDisplayStartLine(start_line)'$40-$7F
' $40-$7F bits 5..0
' Set Display Start Line from 0..63
    case start_line
        0..63:
'            command1b($40 + start_line)
        OTHER:
'            command1b($00)
            return
    writeRegX($40, 0, start_line)

PUB SetDrawBuffer(address)

    _draw_buffer := address

PUB SetCOMPinCfg(pin_config, remap) | config
' $DA bits 5..4 mask 00AA_0010
' Set COM Pins Hardware Configuration and Left/Right Remap
'  pin_config: 0: Sequential                      1: Alternative (POR)
'       remap: 0: Disable Left/Right remap (POR)  1: Enable remap
' POR: $12
    config := %0000_0010
    case pin_config
        0:
        OTHER:
            config := config | (1 << 4)

    case remap
        1:
            config := config | (1 << 5)
        OTHER:

    writeRegX(core#CMD_SETCOM_CFG, 1, config)

PUB SetContrast(contrast_level)
' $81 bits 7..0
' Set Contrast Level 0..255 (POR = 127/$7F)
    case contrast_level
        0..255:
        OTHER:
            contrast_level := 127

    writeRegX(core#CMD_CONTRAST, 1, contrast_level)

PUB SetMuxRatio(mux_ratio)
'A8, 3F
' Valid values: 16..64
    case mux_ratio
        16..63:
        OTHER:
            return

    writeRegX(core#CMD_SETMUXRATIO, 1, mux_ratio-1)

PUB SetPageStartEnd(page_start, page_end)
' $22 bits 2..0
    case page_start
        0..7:{1..7}
        OTHER:
            page_start := 0

    case page_end
        0..7:{0..6}
        OTHER:
            page_end := 7

    writeRegX(core#CMD_SET_PAGEADDR, 2, (page_end << 8) | page_start)

PUB SetPrecharge(phase1_period, phase2_period)
' $D9 bits 7..0
' Set Pre-charge period: 1..15 DCLK, 0 is invalid
' POR: 2 (both)
    case phase1_period
        1..15:
        OTHER:
            phase1_period := 2

    case phase2_period
        1..15:
        OTHER:
            phase2_period := 2

    writeRegX(core#CMD_SETPRECHARGE, 1, (phase2_period << 4) | phase1_period)

PUB SetOSCFreq(freq)
'D5, 80 XXX NEEDS VALIDATION
    writeRegX(core#CMD_SETOSCFREQ, 1, freq)

PUB SetVCOMHDeselectLevel(level)
' $DB bits 6..4
' Set Vcomh deselect level 0.65, 0.77, 0.83 * Vcc
' POR: 0.77 * Vcc
    case level
        0.67:
            level := %000 << 4
        0.83:
            level := %011 << 4
        $40:
            level := %100 << 4
        OTHER:
            level := %010 << 4 '0.77 * Vcc

    writeRegX(core#CMD_SETVCOMDESEL, 1, level)

PUB StopScroll

    writeRegX(core#CMD_STOPSCROLL, 0, 0)

PUB writeBuffer

'  SetColumnStartEnd (0, SSD1306_WIDTH-1)
'  SetPageStartEnd (0, 3)

    i2c.start
    i2c.write (SLAVE_WR)
    i2c.write (core#CTRLBYTE_DATA)
    i2c.wr_block (_draw_buffer, BUFFSZ{512})
    i2c.stop

PUB writeAltBuffer(ptr_buf)

'  SetColumnStartEnd (0, SSD1306_WIDTH-1)
'  SetPageStartEnd (0, 3)

    i2c.start
    i2c.write (SLAVE_WR)
    i2c.write (core#CTRLBYTE_DATA)
    i2c.wr_block (ptr_buf, BUFFSZ{512})
    i2c.stop

PRI writeRegX(reg, nr_bytes, val) | cmd_packet[2]
' Write nr_bytes to register 'reg' stored in val
' If nr_bytes is
'   0, It's a command that has no arguments - write the command only
'   1, It's a command with a single byte argument - write the command, then the byte
'   2, It's a command with two arguments - write the command, then the two bytes (encoded as a word)
    cmd_packet.byte[0] := SLAVE_WR
    cmd_packet.byte[1] := core#CTRLBYTE_CMD
    case nr_bytes
        0:
            cmd_packet.byte[2] := reg | val 'Simple command
        1:
            cmd_packet.byte[2] := reg       'Command w/1-byte argument
            cmd_packet.byte[3] := val
        2:
            cmd_packet.byte[2] := reg       'Command w/2-byte argument
            cmd_packet.byte[3] := val & $FF
            cmd_packet.byte[4] := (val >> 8) & $FF
        OTHER:
            return

    i2c.start
    i2c.wr_block (@cmd_packet, 3 + nr_bytes)
    i2c.stop

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
