// Copyright (c) 2026 Max Lv <max.c.lv@gmail.com>
//
// Licensed under the MIT License. See LICENSE file in the project root for details.

import SwiftUI

struct ConfigEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var configText: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                configHeader
                TextEditor(text: $configText)
                    .font(.system(.body, design: .monospaced))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .navigationTitle("Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveConfig() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Reset to Default") { resetConfig() }
                            .foregroundStyle(.red)
                        Spacer()
                        Button("Import from URL") { /* TODO: URL import */ }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
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
            dismiss()
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
