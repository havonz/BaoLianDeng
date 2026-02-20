// Copyright (c) 2026 Max Lv <max.c.lv@gmail.com>
//
// Licensed under the MIT License. See LICENSE file in the project root for details.

import SwiftUI

@main
struct BaoLianDengApp: App {
    @StateObject private var vpnManager = VPNManager.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(vpnManager)
        }
    }
}
