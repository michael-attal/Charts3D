//
//  BackupOld2SteamCharts3D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct BackupOld2SteamCharts3D: View {
    let games: [SteamGame]
    let allGenres: [String]
    let allYears: [Int]

    @State var pose: Chart3DPose = .default
    @State var display2DChart: Bool = false

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

    var body: some View {
        let minYear = allYears.first ?? 0
        let maxYear = allYears.last ?? 1

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
        .chartXScale(domain: 0...Double(allGenres.count - 1), range: -0.5...0.5)
        .chartYScale(
            domain: 0...(Double(games.map { recentCount(genre: $0.mainGenre, year: $0.releaseYear) }.max() ?? 1) * 1.1),
            range: -0.23...1
        )
        .chartZScale(domain: Double(minYear)...Double(maxYear), range: -0.5...0.5)
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

extension Color {
    static func lerp(from: Color, to: Color, fraction: Double) -> Color {
        let f = max(0, min(1, fraction))
        let fromRGBA = from.components()
        let toRGBA = to.components()
        return Color(
            red: fromRGBA.r + (toRGBA.r - fromRGBA.r) * f,
            green: fromRGBA.g + (toRGBA.g - fromRGBA.g) * f,
            blue: fromRGBA.b + (toRGBA.b - fromRGBA.b) * f,
            opacity: fromRGBA.a + (toRGBA.a - fromRGBA.a) * f
        )
    }

    func components() -> (r: Double, g: Double, b: Double, a: Double) {
        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #else
        typealias NativeColor = NSColor
        #endif
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        let native = NativeColor(self)
        native.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }
}

#if os(visionOS)
#Preview(windowStyle: .plain) {
    let games = AppModel.loadDataset(filename: "Dataset", prefix: 50)
    let allGenres = Array(Set(games.map(\.mainGenre))).sorted()
    let allYears = Array(Set(games.map(\.releaseYear))).sorted()
    BackupOld2SteamCharts3D(games: games, allGenres: allGenres, allYears: allYears)
        .environment(AppModel())
}
#endif
