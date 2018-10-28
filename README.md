# ssd1306-spin
--------------

This is a P8X32A/Propeller driver object for Solomon System's SSD1306 line of OLED display controllers.

## Salient Features

* I2C connection (tested up to 1MHz)
* GDDRAM (Display RAM) writes are buffered
* Horizontal and Vertical mirroring
* Basic graphics primitives (pixel, line, circle (_not_ ellipse)
* Supports 128x32 displays
* Supports display modules without discrete RESET pin

## TODO

* Implement text rendering (WIP)
* Handle other display sizes (WIP)
* Implement scrolling
* Handle modules with RESET pin
