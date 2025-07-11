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

    init() {
        // appModel.games = AppModel.loadDataset(filename: "Dataset")
        // TODO: Create prefix input in UI
        appModel.games = AppModel.loadDataset(filename: "Dataset", prefix: 100)
        // appModel.stats = SteamChartsDataProcessor.aggregateByYearAndGenre(games: appModel.games)
        appModel.allGenres = SteamChartsDataProcessor.allGenres(from: appModel.stats)
        appModel.allYears = Array(Set(appModel.games.map(\.releaseYear))).sorted()
    }

    var body: some Scene {
        WindowGroup(id: appModel.SteamCharts3DWindowID) {
            SteamCharts3D(games: appModel.games, allYears: appModel.allYears)
                .environment(appModel)
        }
        .windowResizability(.contentSize)
        #if os(visionOS)
            .windowStyle(.plain)
        #endif

        WindowGroup(id: appModel.SteamCharts2DWindowID) {
            SteamCharts2D()
                .environment(appModel)
        }
        .windowResizability(.contentSize)
        #if os(visionOS)
            .defaultWindowPlacement { _, context in
                if let main = context.windows.first(where: { $0.id == appModel.SteamCharts3DWindowID }) {
                    WindowPlacement(.trailing(main))
                } else {
                    WindowPlacement()
                }
            }
        #endif

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
