%.swf: %.as
	mxmlc $<

all: FlashCamera.swf

.PHONY: all
