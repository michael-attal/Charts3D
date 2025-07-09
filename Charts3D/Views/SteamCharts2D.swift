//
//  SteamCharts2D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct SteamCharts2D: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Steam2DChartsTabView(games: appModel.games, stats: appModel.stats).padding(50)
    }
}
