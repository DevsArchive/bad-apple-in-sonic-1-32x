# Bad Apple!! in Sonic 1 (32X)
Exactly as described. Bad Apple overlayed on top of Sonic 1 via the 32X.

## Note
This makes use of the Sega/"Super Street Fighter 2" mapper, which is not supported by ANY emulator (the hardware manual does specify that it is usable with the 32X). I did test this with a version of Ares that I made had basic support for the mapper. I did submit a PR for preliminary support, so hopefully that'll go through.

I would not be surprised if this doesn't work on hardware. It's untested and I'm a noob. Pointers to issues found would be appreciated, though!

It uses the RLE mode and the trick to combine multiple frames into 1 and displaying an individual frame via palette cycling to compress the animation down in ROM usage. Audio is streamed via PWM on the slave SH-2. You can set the priority of each individual palette color, which is how I was able to get the black to overlay on top of Sonic 1, with the white being rendered behind.

## Links
[Video](https://youtu.be/4J3FDcb3Wbc)
[Download](https://drive.google.com/file/d/1c9DkUdI_PHRtLHCXXtAPmtNPZkNmgsC2/view?usp=sharing)
