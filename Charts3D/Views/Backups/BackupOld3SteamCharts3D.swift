//
//  BackupOld3SteamCharts3D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct BackupOld3SteamCharts3D: View {
    let games: [SteamGame]
    let allGenres: [String]
    let allYears: [Int]

    @State var pose: Chart3DPose = .default
    @State var display2DChart: Bool = false

    @State private var selectedYearIndex: Int = 0
    @State private var selectedGenreIndex: Int = 0
    @State private var yearWindow: Int = 1
    @State private var showAll: Bool = true

    private func recentCount(genre: String, year: Int, window: Int = 1) -> Int {
        let minYear = year - window
        let maxYear = year + window
        return games.filter { $0.mainGenre == genre && $0.releaseYear >= minYear && $0.releaseYear <= maxYear }.count
    }

    private func smoothedRecentCount(x: Double, z: Double, window: Double = 1.0) -> Double {
        var sum: Double = 0
        var weight: Double = 0
        for i in 0 ..< allGenres.count {
            for year in allYears {
                let d = hypot(Double(i) - x, Double(year) - z)
                let w = exp(-pow(d, 2) / (2 * pow(window, 2)))
                sum += w * Double(recentCount(genre: allGenres[i], year: year))
                weight += w
            }
        }
        return weight > 0 ? sum / weight : 0
    }

    private var minYear: Int { allYears.first ?? 0 }
    private var maxYear: Int { allYears.last ?? 1 }
    private var yearRange: ClosedRange<Double> {
        if showAll {
            return Double(minYear)...Double(maxYear)
        } else {
            let year = allYears[safe: selectedYearIndex] ?? minYear
            return Double(year - yearWindow)...Double(year + yearWindow)
        }
    }

    private var genreRange: ClosedRange<Double> {
        if showAll {
            return 0...Double(allGenres.count - 1)
        } else {
            let genreIdx = selectedGenreIndex
            return Double(genreIdx - 1)...Double(genreIdx + 1)
        }
    }

    private var yMax: Double {
        Double(games.map { recentCount(genre: $0.mainGenre, year: $0.releaseYear) }.max() ?? 1) * 1.1
    }

    var body: some View {
        VStack {
            Chart3D {
                SurfacePlot(x: "Catégorie", y: "Sorties", z: "Année") { x, z in
                    smoothedRecentCount(x: x, z: z, window: 1.0)
                }
                .foregroundStyle(.heightBased(Gradient(colors: [.red, .yellow, .green])))
            }
            .chart3DPose($pose)
            .chartXAxisLabel("Catégorie/Tag (X)")
            .chartYAxisLabel("Sorties récentes (Y)")
            .chartZAxisLabel("Temps / Année (Z)")
            .chartXScale(domain: genreRange, range: -0.5...0.5)
            .chartYScale(domain: 0...yMax, range: -0.23...1)
            .chartZScale(domain: yearRange, range: -0.5...0.5)
            .overlay(
                axesLegendView(allYears: allYears, allGenres: allGenres),
                alignment: .bottomTrailing
            )
            .overlay(
                yearsLegendView(allYears: allYears),
                alignment: .bottomLeading
            )
            #if os(visionOS)
            .scaleEffect(0.85)
            #endif

            HStack(spacing: 20) {
                Button(showAll ? "Zoom sur sélection" : "Afficher tout") {
                    showAll.toggle()
                }
                if !showAll {
                    Picker("Catégorie", selection: $selectedGenreIndex) {
                        ForEach(allGenres.indices, id: \.self) { i in
                            Text(allGenres[i]).tag(i)
                        }
                    }
                    .frame(width: 180)
                    .pickerStyle(MenuPickerStyle())

                    VStack(spacing: 4) {
                        Text("Année : \(allYears[safe: selectedYearIndex] ?? minYear)")
                        Slider(value: Binding(
                            get: { Double(selectedYearIndex) },
                            set: { selectedYearIndex = Int($0) }
                        ), in: 0...Double(allYears.count - 1), step: 1)
                            .frame(width: 150)
                    }
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 4)
            .padding(.bottom, 12)
        }
    }

    private func axesLegendView(allYears: [Int], allGenres: [String]) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.blue)
                Text("X : Catégorie/Tag").font(.caption)
                Text("Ex: 0=\(allGenres.first ?? "")").font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.green)
                Text("Y : Sorties récentes").font(.caption)
                Text("Nb de jeux du même genre sortis sur 1 an").font(.caption2).foregroundStyle(.secondary)
            }
            HStack(spacing: 8) {
                Capsule().frame(width: 16, height: 4).foregroundStyle(.purple)
                Text("Z : Année").font(.caption)
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

    private func yearsLegendView(allYears: [Int]) -> some View {
        HStack(spacing: 6) {
            Text("Années :")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(allYears.indices, id: \.self) { i in
                let year = allYears[i]
                Text(i == 0 || i == allYears.count - 1 || allYears.count <= 5 || i % 2 == 0
                    ? "\(year)" : "")
                    .font(.caption2)
                    .foregroundStyle(i == 0 || i == allYears.count - 1 ? .primary : .secondary)
            }
        }
        .padding(8)
        .background(.thinMaterial, in: Capsule())
        .shadow(radius: 2)
        .padding([.leading, .bottom])
    }
}

// Helper safe subscript to avoid crash
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
