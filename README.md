# Bad Apple!! in Sonic 1 (32X)
Exactly as described. Bad Apple overlayed on top of Sonic 1 via the 32X.

## Note
This makes use of the Sega/"Super Street Fighter 2" mapper. The only emulators that supports this configuration is PicoDrive are ares. The version of PicoDrive on RetroArch will run this. The version on BizHawk as of June 2022 will NOT. Running this on any other emulator with 32X support will either result in the ROM not loading or a REALLY LOUD sound while it loops on the first several seconds of the animation.

I would not be surprised if this doesn't work on hardware. It's untested and I'm a 32X noob, and also the 32X sucks. Pointers to issues found would be appreciated, though!

It uses the RLE mode and the trick to combine multiple frames into 1 and displaying an individual frame via palette cycling to compress the animation down in ROM usage. Audio is streamed via PWM on the slave SH-2. You can set the priority of each individual palette color, which is how I was able to get the black to overlay on top of Sonic 1, with the white (with the Genesis background color converted over to it) being rendered behind.
