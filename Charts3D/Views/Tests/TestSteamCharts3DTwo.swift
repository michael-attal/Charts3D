//
//  TestSteamCharts3DTwo.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct TestSteamCharts3DTwo: View {
    let stats: [GenreYearStat]
    let allGenres: [String]

    @State var pose: Chart3DPose = .default
    @State var display2DChart: Bool = false

    var allYears: [Int] {
        Array(Set(stats.map(\.year))).sorted()
    }

    var body: some View {
        let yearGenreDict: [Int: [String: GenreYearStat]] = {
            var dict: [Int: [String: GenreYearStat]] = [:]
            for stat in stats {
                dict[stat.year, default: [:]][stat.genre] = stat
            }
            return dict
        }()

        let minYear = allYears.first ?? 0
        let maxYear = allYears.last ?? 1

        Chart3D {
            SurfacePlot(x: "Year", y: "Games", z: "Genre") { x, z in
                let year = Int(round(x))
                let genreIdx = Int(round(z))
                guard
                    allYears.contains(year),
                    genreIdx >= 0, genreIdx < allGenres.count
                else {
                    return .nan
                }
                let genre = allGenres[genreIdx]
                let count = yearGenreDict[year]?[genre]?.count ?? 0
                return Double(count)
            }
            .foregroundStyle(.normalBased)
        }
        .chart3DPose($pose)
        .chartXAxisLabel("Release Year")
        .chartYAxisLabel("Games Released")
        .chartZAxisLabel("Genre")
        .chartXScale(domain: Double(minYear)...Double(maxYear), range: -0.5...0.5)
        .chartYScale(domain: 0...(Double(stats.map(\.count).max() ?? 1) * 1.1), range: -0.23...1)
        .chartZScale(domain: 0...Double(allGenres.count - 1), range: -0.5...0.5)
        .overlay(
            axesLegendView(allYears: allYears, allGenres: allGenres, yMax: stats.map(\.count).max() ?? 1),
            alignment: .bottomTrailing
        )
        #if os(visionOS)
        .scaleEffect(0.85)
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack(spacing: 12) {
                    Button {
                        display2DChart.toggle()
                    } label: {
                        Text(display2DChart ? "Hide 2D Chart" : "Display 2D Chart")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)
                }
            }
        }
        #endif
    }

    private func axesLegendView(allYears: [Int], allGenres: [String], yMax: Int) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.blue)
                Text("X : Release Year").font(.caption)
                Text("Ex: \(allYears.first ?? 0)").font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.green)
                Text("Y : Games Released").font(.caption)
                Text("Ex: 0 → \(yMax)").font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.purple)
                Text("Z : Genre").font(.caption)
            }
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(allGenres.indices, id: \.self) { i in
                    HStack(spacing: 4) {
                        Text("\(i):").font(.caption2)
                        Text(allGenres[i]).font(.caption2)
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 3)
        .padding()
    }
}

#if os(visionOS)
#Preview(windowStyle: .plain) {
    let games = AppModel.loadDataset(filename: "Dataset", prefix: 50)
    let stats = SteamChartsDataProcessor.aggregateByYearAndGenre(games: games)
    let allGenres = SteamChartsDataProcessor.allGenres(from: stats)
    TestSteamCharts3DTwo(stats: stats, allGenres: allGenres)
        .environment(AppModel())
}
#endif
