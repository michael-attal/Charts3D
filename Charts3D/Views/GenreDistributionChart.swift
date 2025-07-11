//
//  GenreDistributionChart.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct GenreDistributionChart: View {
    let games: [SteamGame]
    let period: ClosedRange<Int>

    var body: some View {
        let filtered = games.filter { period.contains($0.releaseYear) }
        let counts = Dictionary(grouping: filtered, by: { $0.mainGenre })
            .map { (genre: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
        Chart(counts, id: \.genre) { item in
            BarMark(
                x: .value("Nombre de jeux", item.count),
                y: .value("Genre", item.genre)
            )
        }
        .chartXAxisLabel("Nombre de jeux sortis")
        .chartYAxisLabel("Genre principal")
        // .chartXAxis {
        //     AxisMarks(values: .stride(by: 5)) { value in
        //         AxisGridLine()
        //         AxisTick()
        //         AxisValueLabel()
        //     }
        // }
        .padding()
    }
}
