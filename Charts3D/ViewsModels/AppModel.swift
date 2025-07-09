//
//  AppModel.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    var games: [SteamGame] = []
    var stats: [GenreYearStat] = []
    var allGenres: [String] = []
    var allYears: [Int] = []

    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed

    let SteamCharts2DWindowID = "SteamCharts2DWindow"
    let SteamCharts3DWindowID = "SteamCharts3DWindow"

    static func loadDataset(filename: String, suffle: Bool = false, prefix: Int? = nil) -> [SteamGame] {
        guard let url = Bundle.main.url(forResource: "Dataset", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rawDataset = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            print("Warning: Failed to load or parse Dataset_Small.json")
            return []
        }

        var games: [SteamGame] = SteamChartsDataProcessor.parseGames(from: rawDataset)

        if suffle {
            games = games.shuffled()
        }

        if let prefix = prefix {
            games = Array(games.prefix(prefix))
        }

        return games
    }
}
