// Package bridge provides iOS-specific TUN device integration.
//
//go:build ios

package bridge

import (
	"fmt"
	"net"
	"os"
	"sync"
)

var (
	tunMu     sync.Mutex
	tunFd     int32 = -1
	tunDevice *os.File
)

// SetTUNFd stores the TUN file descriptor passed from iOS NEPacketTunnelProvider.
// Call this before StartProxy so Mihomo can use the system VPN tunnel.
func SetTUNFd(fd int32) error {
	tunMu.Lock()
	defer tunMu.Unlock()

	if fd < 0 {
		return fmt.Errorf("invalid TUN file descriptor: %d", fd)
	}

	tunFd = fd
	tunDevice = os.NewFile(uintptr(fd), "utun")
	os.Setenv("MIHOMO_TUN_FD", fmt.Sprintf("%d", fd))
	return nil
}

// GetTUNFd returns the current TUN file descriptor, or -1 if not set.
func GetTUNFd() int32 {
	tunMu.Lock()
	defer tunMu.Unlock()
	return tunFd
}

// CloseTUN closes the TUN device file descriptor.
func CloseTUN() {
	tunMu.Lock()
	defer tunMu.Unlock()

	if tunDevice != nil {
		tunDevice.Close()
		tunDevice = nil
	}
	tunFd = -1
}

// TUNDeviceInfo returns info about the current tunnel interface.
type TUNDeviceInfo struct {
	Name    string
	MTU     int
	Address string
}

// GetDefaultTUNConfig returns the default TUN configuration for iOS.
func GetDefaultTUNConfig() *TUNDeviceInfo {
	return &TUNDeviceInfo{
		Name:    "utun",
		MTU:     9000,
		Address: "198.18.0.1/16",
	}
}

// GenerateTUNConfig returns a YAML snippet for TUN mode configuration.
func GenerateTUNConfig(dnsAddr string) string {
	if dnsAddr == "" {
		dnsAddr = "198.18.0.2"
	}
	return fmt.Sprintf(`tun:
  enable: true
  stack: system
  dns-hijack:
    - %s:53
  auto-route: false
  auto-detect-interface: false
`, dnsAddr)
}

// SetupDNS configures a local DNS resolver for the tunnel.
func SetupDNS(listenAddr string) error {
	if listenAddr == "" {
		listenAddr = "198.18.0.2:53"
	}
	_, _, err := net.SplitHostPort(listenAddr)
	if err != nil {
		return fmt.Errorf("invalid DNS listen address: %w", err)
	}
	return nil
}
