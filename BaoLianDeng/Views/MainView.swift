// Copyright (c) 2026 Max Lv <max.c.lv@gmail.com>
//
// Licensed under the MIT License. See LICENSE file in the project root for details.

import SwiftUI
import NetworkExtension

struct MainView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @State private var selectedMode: ProxyMode = .rule
    @State private var showConfig = false
    @State private var showLog = false

    var body: some View {
        NavigationStack {
            List {
                statusSection
                modeSection
                trafficSection
                settingsSection
            }
            .navigationTitle("BaoLianDeng")
            .sheet(isPresented: $showConfig) {
                ConfigEditorView()
            }
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(statusText)
                        .font(.headline)
                    Text(statusDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { vpnManager.toggle() }) {
                    Image(systemName: vpnManager.isConnected ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(statusColor)
                }
                .buttonStyle(.plain)
                .disabled(vpnManager.isProcessing)
            }
            .padding(.vertical, 8)

            if let error = vpnManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Proxy Status")
        }
    }

    // MARK: - Mode Section

    private var modeSection: some View {
        Section {
            Picker("Proxy Mode", selection: $selectedMode) {
                ForEach(ProxyMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedMode) { _, newMode in
                vpnManager.switchMode(newMode)
            }
        } header: {
            Text("Mode")
        } footer: {
            Text(modeDescription)
        }
    }

    // MARK: - Traffic Section

    private var trafficSection: some View {
        Section {
            TrafficView()
        } header: {
            Text("Traffic")
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        Section {
            Button("Edit Configuration") {
                showConfig = true
            }

            NavigationLink("Proxy Groups") {
                ProxyGroupView()
            }

            NavigationLink("About") {
                AboutView()
            }
        } header: {
            Text("Settings")
        }
    }

    // MARK: - Helpers

    private var statusText: String {
        switch vpnManager.status {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnecting: return "Disconnecting..."
        case .disconnected: return "Disconnected"
        case .reasserting: return "Reconnecting..."
        case .invalid: return "Not Configured"
        @unknown default: return "Unknown"
        }
    }

    private var statusDescription: String {
        switch vpnManager.status {
        case .connected: return "Global proxy is active"
        case .connecting: return "Starting Mihomo engine..."
        case .disconnected: return "Tap play to start"
        default: return ""
        }
    }

    private var statusColor: Color {
        switch vpnManager.status {
        case .connected: return .green
        case .connecting, .disconnecting: return .orange
        default: return .blue
        }
    }

    private var modeDescription: String {
        switch selectedMode {
        case .rule: return "Route traffic based on rules"
        case .global: return "Route all traffic through proxy"
        case .direct: return "All traffic goes direct"
        }
    }
}

#Preview {
    MainView()
        .environmentObject(VPNManager.shared)
}
