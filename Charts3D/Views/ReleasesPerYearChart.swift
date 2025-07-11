//
//  ReleasesPerYearChart.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct ReleasesPerYearChart: View {
    let games: [SteamGame]

    var yearCounts: [(year: Int, count: Int)] {
        let grouped = Dictionary(grouping: games, by: { $0.releaseYear })
        return grouped.map { (year: $0.key, count: $0.value.count) }
            .sorted(by: { $0.year < $1.year })
    }

    var body: some View {
        let minYear = yearCounts.map(\.year).min()!
        let maxYear = yearCounts.map(\.year).max()!

        Chart(yearCounts, id: \.year) { item in
            BarMark(
                x: .value("Year", item.year),
                y: .value("Releases", item.count)
            )
            .annotation(position: .top) {
                if item.count > 0 {
                    Text("\(item.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartXAxisLabel("Année de sortie")
        .chartYAxisLabel("Nombre de jeux sortis")
        .chartXScale(domain: minYear ... maxYear)
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .padding()
    }
}
