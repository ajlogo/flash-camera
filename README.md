flash-camera
============
### A lightweight Javascript Flash Camera component

This is a very lightweight (under 2KB) SWF webcam component that can be used as a fallback where WebRTC is not available.

The component is entirely Javascript-driven, and is in fact a thin wrapper around the flash Camera component. It supports webcam stream publishing through both RTMP and RTMFP (p2p, as in WebRTC).

Usage
-----

`example.html` should get you started. The example uses RTMFP so you will need a Stratus key which can easily be obtained here [http://labs.adobe.com/technologies/cirrus/](http://labs.adobe.com/technologies/cirrus/). When the page is loaded open your browser console to get a peek at the internals. Once your webcam is published you will find a peerID in the console that can be used in the flash-stream component.

The API being very close to the original Flash API, when in doubt look as the Actionscript source and refer to the corresponding documentation.

Builing
-------

You can rebuild a modified `FlashCamera.as` with the included Makefile. You will need to have the Flex SDK installed and `mxmlc` in your PATH. Then simply run

```bash
$ make
```
