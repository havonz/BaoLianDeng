import SwiftUI

struct TrafficView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @State private var uploadBytes: Int64 = 0
    @State private var downloadBytes: Int64 = 0
    @State private var timer: Timer?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label(formatBytes(uploadBytes), systemImage: "arrow.up.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.subheadline)
                Text("Upload")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Label(formatBytes(downloadBytes), systemImage: "arrow.down.circle.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
                Text("Download")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .onAppear { startPolling() }
        .onDisappear { stopPolling() }
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            fetchTraffic()
        }
    }

    private func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    private func fetchTraffic() {
        guard vpnManager.isConnected else {
            uploadBytes = 0
            downloadBytes = 0
            return
        }

        vpnManager.sendMessage(["action": "get_traffic"]) { data in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            DispatchQueue.main.async {
                uploadBytes = json["upload"] as? Int64 ?? 0
                downloadBytes = json["download"] as? Int64 ?? 0
            }
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}
