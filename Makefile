.PHONY: all framework clean

all: framework

framework:
	cd Go/mihomo-bridge && $(MAKE) ios

framework-arm64:
	cd Go/mihomo-bridge && $(MAKE) ios-arm64

clean:
	cd Go/mihomo-bridge && $(MAKE) clean
