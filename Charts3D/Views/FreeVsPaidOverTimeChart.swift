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

    struct YearTypeValue: Identifiable {
        let year: Int
        let type: String
        let value: Int
        var id: String { "\(year)-\(type)" }
    }

    var points: [YearTypeValue] {
        let grouped = Dictionary(grouping: games, by: { $0.releaseYear })
        let years = grouped.keys.sorted()
        var all: [YearTypeValue] = []
        for year in years {
            let free = grouped[year]?.filter { $0.isFree ?? false }.count ?? 0
            let paid = grouped[year]?.filter { !($0.isFree ?? false) }.count ?? 0
            all.append(.init(year: year, type: "Free-to-Play", value: free))
            all.append(.init(year: year, type: "Payant", value: paid))
        }
        return all
    }

    var body: some View {
        let minYear = points.map(\.year).min()!
        let maxYear = points.map(\.year).max()!

        Chart(points) { point in
            LineMark(
                x: .value("Year", point.year),
                y: .value("Count", point.value),
                series: .value("Type", point.type)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(by: .value("Type", point.type))
        }
        .chartXAxisLabel("Année de sortie")
        .chartYAxisLabel("Nombre de jeux")
        .chartXScale(domain: minYear ... maxYear)
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .padding()
        // .overlay(alignment: .bottomTrailing) {
        //     HStack(spacing: 12) {
        //         LegendItem(color: .green, text: "Free-to-Play")
        //         LegendItem(color: .blue, text: "Payant")
        //     }
        //     .padding(10)
        //     .background(.ultraThinMaterial)
        //     .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        //     .shadow(radius: 6)
        //     .padding(16)
        // }
    }
}

// Custom legend item view
struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}
