# ssd1306-spin
---

This is a P8X32A/Propeller driver object for Solomon System's SSD1306 line of OLED display controllers.

## Salient Features

* I2C connection (tested up to 1MHz)
* GDDRAM (Display RAM) writes are buffered
* Horizontal and Vertical mirroring
* Basic graphics primitives (pixel, line, circle (_circle_, not ellipse))
* Supports 128x32 displays
* Supports display modules without discrete RESET pin

## TODO

* Implement text rendering
* Handle other display sizes
* Implement scrolling
* Handle modules with RESET pin
