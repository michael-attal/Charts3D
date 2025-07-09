//
//  AvgScorePerGenreOverTimeChart.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct AvgScorePerGenreOverTimeChart: View {
    let stats: [GenreYearStat]
    let selectedGenres: [String]

    var body: some View {
        let filtered = stats.filter { selectedGenres.contains($0.genre) }
        let minYear = max(1980, filtered.map(\.year).min() ?? 1980)
        let maxYear = filtered.map(\.year).max() ?? 2025

        Chart(filtered) { stat in
            LineMark(
                x: .value("Année", stat.year),
                y: .value("Score moyen", stat.avgScore),
                series: .value("Genre", stat.genre)
            )

            .interpolationMethod(.catmullRom)
            .symbol(by: .value("Genre", stat.genre))
            .foregroundStyle(by: .value("Genre", stat.genre))
        }
        .chartXAxisLabel("Année")
        .chartYAxisLabel("Score moyen (ratio positif/100)")
        .chartXScale(domain: minYear ... maxYear)
        .padding()
    }
}
