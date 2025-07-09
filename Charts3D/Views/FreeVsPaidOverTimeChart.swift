//
//  FreeVsPaidOverTimeChart.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct FreeVsPaidOverTimeChart: View {
    let games: [SteamGame]

    struct YearCount: Identifiable {
        let year: Int
        let free: Int
        let paid: Int
        var id: Int { year }
    }

    var yearCounts: [YearCount] {
        let grouped = Dictionary(grouping: games, by: { $0.releaseYear })
        return grouped.map { year, gamesInYear in
            let free = gamesInYear.filter { $0.isFree ?? false }.count
            let paid = gamesInYear.filter { !($0.isFree ?? false) }.count
            return YearCount(year: year, free: free, paid: paid)
        }
        .sorted(by: { $0.year < $1.year })
    }

    var body: some View {
        let minYear = max(1980, yearCounts.map(\.year).min() ?? 1980)
        let maxYear = yearCounts.map(\.year).max() ?? 2025

        Chart {
            ForEach(yearCounts) { yc in
                LineMark(
                    x: .value("Année", yc.year),
                    y: .value("Free-to-Play", yc.free),
                    series: .value("Type", "Free-to-Play")
                )
                .foregroundStyle(.green)
                .interpolationMethod(.catmullRom)
                LineMark(
                    x: .value("Année", yc.year),
                    y: .value("Payant", yc.paid),
                    series: .value("Type", "Payant")
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxisLabel("Année de sortie")
        .chartYAxisLabel("Nombre de jeux")
        .chartXScale(domain: minYear ... maxYear)
        .padding()
        .chartLegend(position: .bottom)
    }
}
