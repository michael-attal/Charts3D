//
//  BackupOldT4SteamCharts3D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct BackupOldT4SteamCharts3D: View {
    let games: [SteamGame]
    let allGenres: [String]
    let allYears: [Int]

    @State private var pose: Chart3DPose = .default

    private func countFor(genre: String, year: Int) -> Int {
        games.filter { $0.mainGenre == genre && $0.releaseYear == year }.count
    }

    var body: some View {
        let minYear = allYears.first ?? 2000
        let maxYear = allYears.last ?? 2025

        Chart3D {
            SurfacePlot(x: "Genre", y: "Releases", z: "Year") { x, z in
                let genreIdx = Int(round(x))
                let year = Int(round(z))
                guard genreIdx >= 0, genreIdx < allGenres.count, allYears.contains(year) else {
                    return .nan
                }
                let genre = allGenres[genreIdx]
                return Double(countFor(genre: genre, year: year))
            }
            .foregroundStyle(.heightBased(Gradient(colors: [.red, .yellow, .green])))
        }
        .chart3DPose($pose)
        .chartXAxisLabel("Genre (X)")
        .chartYAxisLabel("Number of Releases (Y)")
        .chartZAxisLabel("Year (Z)")
        .chartXScale(domain: 0...Double(allGenres.count - 1), range: -0.5...0.5)
        .chartYScale(
            domain: 0...(Double(games.map { countFor(genre: $0.mainGenre, year: $0.releaseYear) }.max() ?? 1) * 1.1),
            range: -0.23...1
        )
        .chartZScale(domain: Double(minYear)...Double(maxYear), range: -0.5...0.5)
        .overlay(
            axesLegendView(allYears: allYears, allGenres: allGenres),
            alignment: .bottomTrailing
        )
        #if os(visionOS)
        .scaleEffect(0.85)
        #endif
    }

    private func axesLegendView(allYears: [Int], allGenres: [String]) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.blue)
                Text("X: Genre").font(.caption)
                Text("Ex: 0 = \(allGenres.first ?? "")").font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.green)
                Text("Y: Releases").font(.caption)
                Text("Games released for this genre").font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.purple)
                Text("Z: Year").font(.caption)
                Text("Ex: \(allYears.first ?? 0) → \(allYears.last ?? 0)").font(.caption2).foregroundStyle(.secondary)
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
    let allGenres = Array(Set(games.map(\.mainGenre))).sorted()
    let allYears = Array(Set(games.map(\.releaseYear))).sorted()
    BackupOldT4SteamCharts3D(games: games, allGenres: allGenres, allYears: allYears)
        .environment(AppModel())
}
#endif
