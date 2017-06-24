# 4_digit_hex_display
A 4-digit hex display.

* Runs off 5V. Draws 30mA with all segments lit.
* Uses Vishay TDSR1060 7-segment displays (the dots are not used).
* Uses ATTINY84A as a 16x7 ROM (requires a programmer).
* See bin2hex.S for pinouts, instructions.
* Bill of materials:
  * 28x 0805 3.3k 1/8W SMD resistors
  * 4x 0805 100k 1/8W SMD resistors
  * 4x 0805 100n 16V or above SMD ceramic capacitors
  * 4x ATTINY84A-SSU (the 14-pin SOIC package)
  * 4x Vishay TDSR1060 7-segment displays
  * 2x 1x10 0.1" pitch pin headers (optional)
  
In the image, it looks like the off segments are slightly lit, but they are actually very very slightly illuminated from the other segments. That's just a camera effect. In actual viewing conditions, the effect is hardly visible. If you wanted to reduce the lumens as well as the current consumption, you might increase the 3.3k resistors.

![Image of device](4_digit_hex_display_img.jpg)
