// Copyright (c) 2026 Max Lv <max.c.lv@gmail.com>
//
// Licensed under the MIT License. See LICENSE file in the project root for details.

import SwiftUI

struct ConfigEditorView: View {
    @State private var configText: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                configHeader
                TextEditor(text: $configText)
                    .font(.system(.caption, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .navigationTitle("Config")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveConfig() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Reset Default", role: .destructive) { resetConfig() }
                        Spacer()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if showSaved {
                    savedToast
                }
            }
            .onAppear { loadConfig() }
        }
    }

    private var configHeader: some View {
        HStack {
            Image(systemName: "doc.text")
            Text("config.yaml")
                .font(.caption)
            Spacer()
            Text("\(configText.count) chars")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    private var savedToast: some View {
        VStack {
            Spacer()
            Text("Saved")
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.thinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, 80)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func loadConfig() {
        if ConfigManager.shared.configExists() {
            do {
                configText = try ConfigManager.shared.loadConfig()
            } catch {
                configText = ConfigManager.shared.defaultConfig()
            }
        } else {
            configText = ConfigManager.shared.defaultConfig()
        }
    }

    private func saveConfig() {
        isSaving = true
        do {
            try ConfigManager.shared.saveConfig(configText)
            withAnimation { showSaved = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showSaved = false }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isSaving = false
    }

    private func resetConfig() {
        configText = ConfigManager.shared.defaultConfig()
    }
}

#Preview {
    ConfigEditorView()
}
