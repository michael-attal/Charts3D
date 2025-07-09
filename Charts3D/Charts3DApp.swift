//
//  Charts3DApp.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import SwiftUI

@main
struct Charts3DApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup(id: appModel.SteamCharts3DWindowID) {
            SteamCharts3D()
                .environment(appModel)
        }
        #if os(visionOS)
        .windowStyle(.plain)
        #endif

        WindowGroup(id: appModel.SteamCharts2DWindowID) {
            SteamCharts2D()
                .environment(appModel)
        }
        .defaultWindowPlacement { _, context in
            if let main = context.windows.first(where: { $0.id == appModel.SteamCharts3DWindowID }) {
                WindowPlacement(.trailing(main))
            } else {
                WindowPlacement()
            }
        }
        .windowResizability(.contentSize)

        #if os(visionOS)
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        #endif
    }
}
