{
    --------------------------------------------
    Filename: display.oled.128x32.i2c.spin
    Author: Jesse Burt
    Copyright (c) 2018
    See end of file for terms of use.
    --------------------------------------------
}

CON

  SSD1306_SLAVE   = $3C << 1
  W               = %0
  R               = %1
  ACK             = i2c#ACK

VAR

  long _ackbit

OBJ

  ssd1306 : "core.con.ssd1306"
  time    : "time"
  i2c     : "jm_i2c_fast"

PUB null
''This is not a top-level object

PUB Start(scl, sda, hz): okay

  okay := i2c.setupx (scl, sda, hz)
  
  time.MSleep (20) 'Datasheet p.27, step 2-3

PUB Setup

  SetMuxRatio($3F)
  SetDisplayOffset($00)
  SetDisplayStartLine($40)
  SetSegmentRemap(%0)
  SetCOMDirection($00)
  SetCOMPinCfg($02)
  SetContrast($7F)
  EntireDisplayOn($00)
  SetNormalDisplay($00)
  SetOSCFreq($80)
  EnableChargePumpReg($14)
  DisplayOn

PUB dtest: check | i

  i2c.start
  check := 2|i2c.write (SSD1306_SLAVE)
  repeat i from 0 to 127
    check := 4|i2c.write (ssd1306#CTRLBYTE_DATA)
    check := 8|i2c.write (i)
  i2c.stop

PUB OnePix(addr)

  data_one(addr)
  i2c.stop

PUB DisplayOn

  command(ssd1306#SSD1306_CMD_DISP_ON)
  i2c.stop

PUB DisplayOff

  command(ssd1306#SSD1306_CMD_DISP_OFF)
  i2c.stop

PUB EnableChargePumpReg(bool__enabled)
'8D, 14
  command( ssd1306#SSD1306_CMD_CHARGEPUMP)
  writeval(bool__enabled)
  i2c.stop

PUB SetDisplayOffset(offset)
'D3, 00
  command(ssd1306#SSD1306_CMD_SETDISPOFFS)
  writeval(offset)
  i2c.stop

PUB SetDisplayStartLine(start_line)'$40-$7F
'40
  command(start_line)
  i2c.stop

PUB SetMuxRatio(ratio)
'A8, 3F
  command(ssd1306#SSD1306_CMD_SETMUXRATIO)
  writeval(ratio)
  i2c.stop

PUB SetSegmentRemap(column_addr)
'A0/A1
  command( ssd1306#SSD1306_CMD_SEG_MAP0|column_addr)
  i2c.stop

PUB SetCOMDirection(direction)
'C0/C8
  command (ssd1306#SSD1306_CMD_COMDIR_NORM|direction)
  i2c.stop

PUB SetCOMPinCfg(config)
'DA, 02
  command(ssd1306#SSD1306_CMD_SETCOM_CFG)
  writeval(config)
  i2c.stop

PUB SetContrast(contrast_level)
'81, 7F
  command(ssd1306#SSD1306_CMD_CONTRAST)
  writeval(contrast_level)
  i2c.stop

PUB EntireDisplayOn(bool__enabled)
'A4
  command(ssd1306#SSD1306_CMD_RAMDISP_ON|bool__enabled)
  i2c.stop

PUB SetNormalDisplay(norm_invert)
'A6
  command(ssd1306#SSD1306_CMD_DISP_NORM|norm_invert)
  i2c.stop

PUB SetOSCFreq(freq)
'D5, 80
  command(ssd1306#SSD1306_CMD_SETOSCFREQ)
  writeval(freq)
  i2c.stop

PUB Stop

  i2c.terminate

PRI command(byte__cmd)

  setupWrite
  if _ackbit == ACK
    _ackbit := i2c.write (ssd1306#CTRLBYTE_CMD)
  else
    i2c.stop
    return FALSE
  if _ackbit == ACK
    _ackbit := i2c.write (byte__cmd)
  else
    i2c.stop
    return FALSE

PRI writeval(val)

  _ackbit := i2c.write (val)

PRI data_one(byte__data)

  setupWrite
  if _ackbit == ACK
    _ackbit := i2c.write (ssd1306#CTRLBYTE_DATA)
  else
    i2c.stop
    return FALSE
  if _ackbit == ACK
    _ackbit := i2c.write (byte__data)
  else
    i2c.stop
    return FALSE
  i2c.stop

PRI setupWrite

  i2c.start
  _ackbit := i2c.write (SSD1306_SLAVE|W)

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
