import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "network.badge.shield.half.filled")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        Text("BaoLianDeng")
                            .font(.title2.bold())
                        Text("Global Proxy powered by Mihomo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            }

            Section("Information") {
                InfoRow(title: "Version", value: Bundle.main.appVersion)
                InfoRow(title: "Build", value: Bundle.main.buildNumber)
                InfoRow(title: "Mihomo Core", value: "Loading...")
            }

            Section("Links") {
                Link(destination: URL(string: "https://github.com/madeye/BaoLianDeng")!) {
                    Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                Link(destination: URL(string: "https://wiki.metacubex.one")!) {
                    Label("Mihomo Documentation", systemImage: "book")
                }
            }

            Section("License") {
                Text("This app is open source and distributed under the GPL-3.0 license.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
    }
}

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
