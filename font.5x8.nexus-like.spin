CON
'' Font definition:
    WIDTH       = 5	' Width
    HEIGHT      = 7	' and height, in pixels
    LASTCHAR    = 127	' ASCII code of last/highest char in the table

PUB Null
' This is not a top-level object

PUB baseaddr
' Return base address of font table
    return @table

'' * = Leave 0's here if you want visible space between one char and the next
''      when drawing
DAT'                     Upper
'                 *      |_ Left
    table   byte %00000000      '$00
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000'*

            byte %00000000      '$01
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$02
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$03
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$04
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$05
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$06
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$07
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$08
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$09
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$0A
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$0B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$0C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$0D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$0E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$0F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$10
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$11
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$12
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$13
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$14
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$15
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$16
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$17
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$18
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$19
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$1A
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$1B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$1C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$1D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$1E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$1F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$20
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$21
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$22
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$23
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$24
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$25
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$26
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$27
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$28
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$29
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$2A
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$2B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$2C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$2D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$2E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$2F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00110110      '$30
            byte %01000001
            byte %01000001
            byte %01000001
            byte %00110110
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$31
            byte %00000000
            byte %00000000
            byte %00000000
            byte %01110111
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00110000      '$32
            byte %01001001
            byte %01001001
            byte %01001001
            byte %00000110
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$33
            byte %01001001
            byte %01001001
            byte %01001001
            byte %00110110
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000111      '$34
            byte %00001000
            byte %00001000
            byte %00001000
            byte %01110111
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000110      '$35
            byte %01001001
            byte %01001001
            byte %01001001
            byte %00110000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00110110      '$36
            byte %01001001
            byte %01001001
            byte %01001001
            byte %00110000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$37
            byte %00000001
            byte %00000001
            byte %00000001
            byte %01110110
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00110110      '$38
            byte %01001001
            byte %01001001
            byte %01001001
            byte %00110110
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000110      '$39
            byte %00001001
            byte %00001001
            byte %00001001
            byte %01110110
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$3A
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$3B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$3C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$3D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$3E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$3F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$40
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$41
            byte %00001011
            byte %00001100
            byte %00001000
            byte %01110000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$42
            byte %01001001
            byte %01001110
            byte %00110000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00111000      '$43
            byte %01000100
            byte %01000010
            byte %01000001
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$44
            byte %01000010
            byte %01000100
            byte %00111000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01110000      '$45
            byte %01001000
            byte %01001100
            byte %01001010
            byte %01000001
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01110000      '$46
            byte %00001000
            byte %00001100
            byte %00001010
            byte %00000001
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00110000      '$47
            byte %01001000
            byte %01000100
            byte %01010010
            byte %01110001
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$48
            byte %00000100
            byte %00000100
            byte %01111111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01000001      '$49
            byte %01111111
            byte %01000001
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$4A
            byte %01000000
            byte %01000001
            byte %00100001
            byte %00011111
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$4B
            byte %00000100
            byte %00001010
            byte %01110001
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$4C
            byte %01000000
            byte %01000000
            byte %01000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$4D
            byte %00000110
            byte %00001110
            byte %01111111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$4E
            byte %00000010
            byte %00000100
            byte %01111111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00111110      '$4F
            byte %01000001
            byte %01000001
            byte %00111110
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$50
            byte %00001001
            byte %00001001
            byte %00000110
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00111110      '$51
            byte %01010001
            byte %01100001
            byte %01111110
            byte %10000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$52
            byte %00001001
            byte %00001001
            byte %01110110
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01000110      '$53
            byte %01001001
            byte %01010001
            byte %00100001
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000001      '$54
            byte %00000001
            byte %01111111
            byte %00000001
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00111111      '$55
            byte %01000000
            byte %01000000
            byte %00111111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$56
            byte %00100000
            byte %00010000
            byte %00001111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111111      '$57
            byte %00100000
            byte %00110000
            byte %01111111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01110111      '$58
            byte %00001000
            byte %00001000
            byte %01110111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000011      '$59
            byte %00000100
            byte %00001000
            byte %01111111
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %01111001      '$5A
            byte %01000101
            byte %01000011
            byte %01000001
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$5B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$5C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$5D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$5E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$5F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$60
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$61
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$62
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$63
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$64
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$65
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$66
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$67
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$68
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$69
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$6A
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$6B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$6C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$6D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$6E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$6F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$70
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$71
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$72
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$73
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$74
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$75
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$76
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$77
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$78
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$79
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$7A
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$7B
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$7C
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$7D
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$7E
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000

            byte %00000000      '$7F
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
            byte %00000000
