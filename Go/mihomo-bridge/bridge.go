// Package bridge provides a gomobile-compatible interface to the Mihomo proxy core.
// It exposes a minimal API for starting/stopping the proxy engine from iOS.
package bridge

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sync"

	"github.com/metacubex/mihomo/component/process"
	"github.com/metacubex/mihomo/config"
	"github.com/metacubex/mihomo/constant"
	"github.com/metacubex/mihomo/hub"
	"github.com/metacubex/mihomo/hub/executor"
	"github.com/metacubex/mihomo/log"
	"github.com/metacubex/mihomo/tunnel"
)

var (
	mu        sync.Mutex
	running   bool
	cancelCtx context.CancelFunc
)

// SetHomeDir sets the Mihomo home directory for config and data files.
func SetHomeDir(path string) {
	constant.SetHomeDir(path)
}

// SetConfig writes the proxy configuration YAML to the home directory.
func SetConfig(yamlContent string) error {
	homeDir := constant.Path.HomeDir()
	configPath := filepath.Join(homeDir, "config.yaml")
	return os.WriteFile(configPath, []byte(yamlContent), 0644)
}

// StartProxy starts the Mihomo proxy engine with the configuration in the home directory.
// It returns an error if the engine is already running or if configuration parsing fails.
func StartProxy() error {
	mu.Lock()
	defer mu.Unlock()

	if running {
		return fmt.Errorf("proxy is already running")
	}

	homeDir := constant.Path.HomeDir()
	configPath := filepath.Join(homeDir, "config.yaml")

	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("config.yaml not found in %s", homeDir)
	}

	// Disable process finding on iOS (not supported)
	process.EnableFindProcess = false

	// Parse configuration
	cfg, err := executor.Parse()
	if err != nil {
		return fmt.Errorf("failed to parse config: %w", err)
	}

	// Apply configuration and start the engine
	executor.ApplyConfig(cfg, true)

	running = true
	log.Infoln("Mihomo proxy engine started")
	return nil
}

// StartWithExternalController starts the proxy engine with the REST API enabled
// on the given address (e.g., "127.0.0.1:9090").
func StartWithExternalController(addr, secret string) error {
	mu.Lock()
	defer mu.Unlock()

	if running {
		return fmt.Errorf("proxy is already running")
	}

	homeDir := constant.Path.HomeDir()
	configPath := filepath.Join(homeDir, "config.yaml")

	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return fmt.Errorf("config.yaml not found in %s", homeDir)
	}

	process.EnableFindProcess = false

	cfg, err := executor.Parse()
	if err != nil {
		return fmt.Errorf("failed to parse config: %w", err)
	}

	// Override external controller settings
	cfg.General.ExternalController = addr
	cfg.General.Secret = secret

	executor.ApplyConfig(cfg, true)

	// Start the REST API
	go hub.Parse()

	running = true
	log.Infoln("Mihomo proxy engine started with external controller at %s", addr)
	return nil
}

// StopProxy stops the Mihomo proxy engine gracefully.
func StopProxy() {
	mu.Lock()
	defer mu.Unlock()

	if !running {
		return
	}

	// Close all tunnel connections
	tunnel.DefaultManager.ResetStatistic()

	if cancelCtx != nil {
		cancelCtx()
		cancelCtx = nil
	}

	running = false
	log.Infoln("Mihomo proxy engine stopped")
}

// IsRunning returns whether the proxy engine is currently active.
func IsRunning() bool {
	mu.Lock()
	defer mu.Unlock()
	return running
}

// SetTUNFileDescriptor sets the TUN device file descriptor provided by iOS NetworkExtension.
// This allows Mihomo to read/write packets from the VPN tunnel.
func SetTUNFileDescriptor(fd int32) error {
	if fd < 0 {
		return fmt.Errorf("invalid file descriptor: %d", fd)
	}
	os.Setenv("MIHOMO_TUN_FD", fmt.Sprintf("%d", fd))
	return nil
}

// UpdateLogLevel updates the logging level (debug, info, warning, error, silent).
func UpdateLogLevel(level string) {
	log.SetLevel(log.LogLevelMapping[level])
}

// ReadConfig reads the current configuration file and returns its contents.
func ReadConfig() (string, error) {
	homeDir := constant.Path.HomeDir()
	configPath := filepath.Join(homeDir, "config.yaml")
	data, err := os.ReadFile(configPath)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// ValidateConfig validates a YAML configuration string without applying it.
func ValidateConfig(yamlContent string) error {
	tmpDir, err := os.MkdirTemp("", "mihomo-validate")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tmpDir)

	tmpFile := filepath.Join(tmpDir, "config.yaml")
	if err := os.WriteFile(tmpFile, []byte(yamlContent), 0644); err != nil {
		return err
	}

	_, err = config.Parse([]byte(yamlContent))
	return err
}

// GetTrafficStats returns the current upload and download traffic in bytes.
func GetTrafficStats() (up, down int64) {
	snapshot := tunnel.DefaultManager.Snapshot()
	return snapshot.UploadTotal, snapshot.DownloadTotal
}

// Version returns the Mihomo core version.
func Version() string {
	return constant.Version
}
