# ssd130x-spin
--------------

This is a P8X32A/Propeller 1, P2X8C4M64P/Propeller 2 driver object for the Solomon Systech SSD130x OLED display controller.

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* I2C connection at up to approx 400kHz (unenforced)
(NOTE: Datasheet specifies max I2C clock of 400kHz. May function at higher bus speeds. __YMMV!__)
* SPI connection at fixed 4MHz (P1), up to 10MHz (P2, unenforced)
(NOTE: Datasheet specifies max SPI clock of 10MHz. May function at higher bus speeds. __YMMV!__)
* Supports 128x32 and 128x64 displays
* Display mirroring (horizontal and vertical)
* Display visibility modes: normal, inverted, all pixels on
* Variable contrast
* Low-level display control: Logic voltages, oscillator frequency, addressing mode, row/column mapping
* Supports display modules with or without discrete RESET pin
* Integration with the generic bitmap graphics library
* Buffered display or direct-to-display drawing (*see 'Limitations' for direct-to-display*)
* Hardware-accelerated scrolling (horizontal L/R, combined vertical and horizontal L/R)


## Requirements

P1/SPIN1:
* spin-standard-library
* P1/SPIN1: 1 extra core/cog for the PASM I2C engine

_or_

* P1/SPIN1: 1 extra core/cog for the PASM SPI engine
* graphics.common.spinh (provided by spin-standard-library)

P2/SPIN2:
* p2-spin-standard-library
* graphics.common.spin2h (provided by p2-spin-standard-library)


## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.2.1)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.2.1)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.2.1)       | NuCode       | FTBFS                 |
| P2        | SPIN2    | FlexSpin (6.2.1)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Hardware Compatibility

* SSD1306 (tested)
* SSD1309 (tested)


## Limitations

* Doesn't support parallel interface-connected displays (currently unplanned)
* Unbuffered/Direct-draw operations are limited, due to the nature of serial 1bpp displays. Box(), Line(), Circle and Plot() aren't implemented.

