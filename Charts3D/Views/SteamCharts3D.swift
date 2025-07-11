//
//  SteamCharts3D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

// TODO: Replace category/tags id and month by first 3 characters and replace year id by full year

/// Supported platforms (Windows, Mac, Linux)
let allPlatforms: [String] = ["space", "windows", "space2", "mac", "space3", "linux", "space4"]

struct PlatformStats: Identifiable {
    var id: String { "\(platform)-\(year)-\(nbGames)" }
    var platform: String
    var year: Int
    var nbGames: Int
}

enum SurfaceMode: String, CaseIterable, Identifiable {
    case square = "Cubique"
    case wave = "Vague"
    case smoothWaves = "Vagues arrondies"

    var id: String { rawValue }
}

/// Types of 3D chart aggregation for analysis
enum Chart3DAggregation: String, CaseIterable, Identifiable {
    case platformYear = "Par plateforme/année"
    case countByGenreYear = "Sorties par genre/année"
    case avgScoreByGenreYear = "Score moyen genre/année"
    case avgPriceByGenreYear = "Prix moyen genre/année"

    var id: String { rawValue }
}

/// 3D chart of Steam games, multiple analysis modes (platform/genre/year/score/price)
struct SteamCharts3D: View {
    @Environment(AppModel.self) private var appModel

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    let games: [SteamGame]
    var allYears: [Int] = [] // Years present in the dataset, sorted
    var formattedYears: [Int] {
        var formattedYears = allYears
        if formattedYears.count > 0 {
            formattedYears.insert(formattedYears.first! - 1, at: 0)
            formattedYears.append(formattedYears.last! + 1)
        }
        return formattedYears
    }

    #if os(visionOS)
    @State private var pose: Chart3DPose = .init(
        azimuth: .degrees(-22.5),
        inclination: .degrees(0)
    )
    #endif
    #if !os(visionOS)
    @State private var pose: Chart3DPose = .default
    #endif

    @State private var display2DChart: Bool = false
    @State private var displayDot: Bool = false
    @State private var selectedYearIdx: Int = 0
    @State private var yearWindow: Int = 1
    @State private var showAll: Bool = true
    @State private var surfaceMode: SurfaceMode = .square
    @State private var aggregation: Chart3DAggregation = .platformYear

    private let monthLabels = ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sep", "Oct", "Nov", "Déc"]

    private var allGenres: [String] {
        var genres = Array(Set(games.flatMap { $0.genres })).sorted()
        genres.insert("empty_space_start", at: 0)
        genres.append("empty_space_end")
        return genres
    }

    // MARK: Data helpers (by aggregation mode)

    /// Returns the Y value for each aggregation mode
    private func yValue(x: Double, z: Double) -> Double {
        switch aggregation {
            case .platformYear:
                return yValuePlatformYear(x: x, z: z)
            case .countByGenreYear:
                return yValueCountByGenreYear(x: x, z: z)
            case .avgScoreByGenreYear:
                return yValueAvgScoreByGenreYear(x: x, z: z)
            case .avgPriceByGenreYear:
                return yValueAvgPriceByGenreYear(x: x, z: z)
        }
    }

    /// Classic: releases per platform and year (or month if zoom)
    private func yValuePlatformYear(x: Double, z: Double) -> Double {
        let platformIdx = Int(round(x))
        guard platformIdx >= 0, platformIdx < allPlatforms.count else { return .nan }
        if isZoomOnYear {
            let monthIdx = Int(round(z))
            guard monthIdx >= 1, monthIdx <= 12 else { return 0 }
            let selectedYear = allYears[safe: selectedYearIdx] ?? allYears.first ?? 0
            let platform = allPlatforms[platformIdx]
            return Double(games.filter {
                $0.releaseYear == selectedYear &&
                    $0.releaseMonth == monthIdx &&
                    $0.platforms.contains(platform)
            }.count)
        } else {
            let yearIdx = Int(round(z))
            guard yearIdx >= 0, yearIdx < formattedYears.count else { return .nan }
            let year = formattedYears[yearIdx]
            let platform = allPlatforms[platformIdx]
            return Double(games.filter {
                $0.releaseYear == year &&
                    $0.platforms.contains(platform)
            }.count)
        }
    }

    /// Releases by genre and year
    private func yValueCountByGenreYear(x: Double, z: Double) -> Double {
        let genreIdx = Int(round(x))
        guard genreIdx >= 0, genreIdx < allGenres.count else { return .nan }
        let yearIdx = Int(round(z))
        guard yearIdx >= 0, yearIdx < formattedYears.count else { return .nan }
        let year = formattedYears[yearIdx]
        let genre = allGenres[genreIdx]
        return Double(games.filter { $0.releaseYear == year && $0.genres.contains(genre) }.count)
    }

    /// Average score by genre/year
    private func yValueAvgScoreByGenreYear(x: Double, z: Double) -> Double {
        let genreIdx = Int(round(x))
        guard genreIdx >= 0, genreIdx < allGenres.count else { return .nan }
        let yearIdx = Int(round(z))
        guard yearIdx >= 0, yearIdx < formattedYears.count else { return .nan }
        let year = formattedYears[yearIdx]
        let genre = allGenres[genreIdx]
        let filtered = games.filter { $0.releaseYear == year && $0.genres.contains(genre) && $0.positiveRatioReview > 0 }
        guard !filtered.isEmpty else { return .nan }
        return filtered.map { Double($0.positiveRatioReview) }.reduce(0, +) / Double(filtered.count)
    }

    /// Average price (in USD) by genre/year
    private func yValueAvgPriceByGenreYear(x: Double, z: Double) -> Double {
        let genreIdx = Int(round(x))
        guard genreIdx >= 0, genreIdx < allGenres.count else { return .nan }
        let yearIdx = Int(round(z))
        guard yearIdx >= 0, yearIdx < formattedYears.count else { return .nan }
        let year = formattedYears[yearIdx]
        let genre = allGenres[genreIdx]
        let filtered = games.filter {
            $0.releaseYear == year &&
                $0.genres.contains(genre) &&
                $0.priceUSD != nil
        }
        guard !filtered.isEmpty else { return .nan }
        return filtered.map { $0.priceUSD! }.reduce(0, +) / Double(filtered.count)
    }

    /// For z axis range (years or months)
    private var zRange: ClosedRange<Double> {
        switch aggregation {
            case .platformYear:
                return isZoomOnYear ? 0...13 : 0...Double(max(formattedYears.count - 1, 1))
            default:
                return 0...Double(max(formattedYears.count - 1, 1))
        }
    }

    /// For x axis range (platforms or genres)
    private var xRange: ClosedRange<Double> {
        switch aggregation {
            case .platformYear:
                return 0...Double(allPlatforms.count - 1)
            default:
                return 0...Double(max(allGenres.count - 1, 1))
        }
    }

    /// Max Y value for current aggregation (for scale)
    private var yMax: Double {
        switch aggregation {
            case .platformYear:
                if isZoomOnYear {
                    let selectedYear = allYears[safe: selectedYearIdx] ?? allYears.first ?? 0
                    return Double(
                        allPlatforms.flatMap { platform in
                            (1...12).map { month in
                                games.filter { $0.releaseYear == selectedYear && $0.releaseMonth == month && $0.platforms.contains(platform) }.count
                            }
                        }.max() ?? 1
                    ) * 1.1
                } else {
                    return Double(
                        allPlatforms.flatMap { platform in
                            formattedYears.map { year in
                                games.filter { $0.releaseYear == year && $0.platforms.contains(platform) }.count
                            }
                        }.max() ?? 1
                    ) * 1.1
                }
            case .countByGenreYear:
                return Double(
                    allGenres.flatMap { genre in
                        formattedYears.map { year in
                            games.filter { $0.releaseYear == year && $0.genres.contains(genre) }.count
                        }
                    }.max() ?? 1
                ) * 1.1
            case .avgScoreByGenreYear:
                return 100 // Percentage (score)
            case .avgPriceByGenreYear:
                var maxAvg: Double = 0
                for genre in allGenres {
                    for year in formattedYears {
                        let filtered = games.filter { $0.releaseYear == year && $0.genres.contains(genre) && $0.priceUSD != nil }
                        guard !filtered.isEmpty else { continue }
                        let avg = filtered.map { $0.priceUSD! }.reduce(0, +) / Double(filtered.count)
                        if avg > maxAvg { maxAvg = avg }
                    }
                }
                return maxAvg * 1.1
        }
    }

    func getValueLabelX(from: AxisValue) -> String {
        if aggregation == .platformYear {
        } else if aggregation == .countByGenreYear {}

        return "Test"
    }

    /// Helper: are we in zoom on one year/month (only platformYear supports months)
    private var isZoomOnYear: Bool { aggregation == .platformYear && !showAll }

    func getPlatformStats() -> [PlatformStats] {
        var stats: [PlatformStats] = []

        for game in games {
            for platform in game.platforms {
                if let existantPlatform = stats.first(where: { $0.platform == platform }) {
                    if var existantYearID = stats.firstIndex(where: { $0.year == game.releaseYear && $0.platform == platform }) {
                        stats[existantYearID].nbGames += 1
                    } else {
                        stats.append(PlatformStats(platform: platform, year: game.releaseYear, nbGames: 1))
                    }
                } else {
                    stats.append(PlatformStats(platform: platform, year: game.releaseYear, nbGames: 1))
                }
            }
        }

        print(stats)
        return stats
    }

    var body: some View {
        VStack {
            #if !os(visionOS)
            analyseTypePicker
            surfaceModePicker
            toogleChart2DButton
            #endif

            Chart3D {
                if displayDot {
                    ForEach(getPlatformStats()) { stats in
                        if let yearIdx = formattedYears.firstIndex(of: stats.year),
                           let platformIdx = allPlatforms.firstIndex(of: stats.platform)
                        {
                            PointMark(
                                x: .value(xAxisLabel(), Double(platformIdx)),
                                y: .value(yAxisLabel(), stats.nbGames),
                                z: .value(zAxisLabel(), Double(yearIdx))
                            )
                        }
                    }
                }

                SurfacePlot(x: xAxisLabel(), y: yAxisLabel(), z: zAxisLabel()) { x, z in
                    let yVal: Double
                    switch surfaceMode {
                        case .square:
                            yVal = yValue(x: x, z: z)
                        case .wave:
                            // Only for platform/année: smoothing on x (genre or platform)
                            yVal = smoothingX(x: x, z: z, window: 0.45)
                        case .smoothWaves:
                            yVal = smoothingXZ(x: x, z: z, windowX: 0.7, windowZ: 1.0)
                    }
                    return yVal
                }
                .foregroundStyle(.heightBased(Gradient(colors: [.blue, .green, .yellow, .orange, .red])))
            }
            .chart3DPose($pose)
            .chartXAxisLabel(xAxisLabel())
            .chartYAxisLabel(yAxisLabel())
            .chartZAxisLabel(zAxisLabel())
            .chartXScale(domain: xRange, range: -0.5...0.5)
            .chartYScale(domain: 0...yMax, range: -0.5...0.5)
            .chartZScale(domain: zRange, range: -0.5...0.5)
            .chartXAxis {
                AxisMarks(values: .stride(by: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                    // AxisValueLabel( {
                    //     if let intValue = value.as(Int.self), intValue >= 0, intValue < allPlatforms.count {
                    //         Text("\(String((allPlatforms[intValue].capitalized).prefix(3)))")
                    //     }
                    // })
                }
            }
            .chartZAxis {
                // AxisMarks(values: .stride(by: allYears.count > 10 ? 2 : 1)) { value in
                AxisMarks(values: .stride(by: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                    // AxisValueLabel( {
                    //     if let intValue = value.as(Int.self), intValue >= 0, intValue < formattedYears.count {
                    //         Text("\(formattedYears[intValue])")
                    //     }
                    // })
                }
            }
            .overlay(
                axesLegendView(),
                alignment: .bottomTrailing
            )
            #if !os(visionOS)
            .overlay(
                zAxisLegendView(),
                alignment: .bottomLeading
            )
            #endif
            #if os(visionOS)
            .overlay(
                zAxisLegendView(),
                alignment: .topLeading
            )
            .padding(.bottom, 50)
            #endif
            #if !os(visionOS)
            // Controls
            if aggregation == .platformYear {
                zoomButton.padding(20)
            }
            #endif
        }
        #if os(visionOS)
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                zoomButton
                analyseTypePicker
                surfaceModePicker
                toogleChart2DButton
            }
        }
        #endif
    }

    var toogleChart2DButton: some View {
        Button {
            display2DChart.toggle()
            if display2DChart {
                openWindow(id: appModel.SteamCharts2DWindowID)
            } else {
                dismissWindow(id: appModel.SteamCharts2DWindowID)
            }
        } label: {
            Text(display2DChart ? "Cacher plus" : "Voir plus")
        }
    }

    var analyseTypePicker: some View {
        HStack {
            Picker("Type d'analyse", selection: $aggregation) {
                ForEach(
                    Chart3DAggregation.allCases.filter { agg in
                        agg == .platformYear || agg == .countByGenreYear
                    }
                ) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
        .padding(.horizontal, 8)
    }

    var surfaceModePicker: some View {
        HStack {
            Picker("Forme", selection: $surfaceMode) {
                ForEach(SurfaceMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    var zoomButton: some View {
        HStack(spacing: 20) {
            Button(showAll ? "Zoom sur une année" : "Afficher tout") {
                showAll.toggle()
            }
            if isZoomOnYear {
                VStack(spacing: 4) {
                    Text("Année : \(allYears[safe: selectedYearIdx] ?? allYears.first ?? 0)")
                    Slider(value: Binding(
                        get: { Double(selectedYearIdx) },
                        set: { selectedYearIdx = Int($0) }
                    ), in: 0...Double(max(allYears.count - 1, 0)), step: 1)
                }
            }
        }
    }

    // MARK: Smoothing functions

    /// Simple smoothing on X axis (platform or genre)
    private func smoothingX(x: Double, z: Double, window: Double) -> Double {
        let count = aggregation == .platformYear ? allPlatforms.count : allGenres.count
        var sum: Double = 0
        var weight: Double = 0
        for i in 0..<count {
            let d = abs(Double(i) - x)
            let w = exp(-pow(d, 2) / (2 * pow(window, 2)))
            let yVal = yValue(x: Double(i), z: z)
            guard !yVal.isNaN else { continue }
            sum += w * yVal
            weight += w
        }
        return weight > 0 ? sum / weight : 0
    }

    /// Smoothing on X and Z axes (platform/genre + année)
    private func smoothingXZ(x: Double, z: Double, windowX: Double, windowZ: Double) -> Double {
        let countX = aggregation == .platformYear ? allPlatforms.count : allGenres.count
        let countZ = formattedYears.count
        var sum: Double = 0
        var weight: Double = 0
        for i in 0..<countX {
            for j in 0..<countZ {
                let dx = Double(i) - x
                let dz = Double(j) - z
                let d = sqrt((dx * dx) / (windowX * windowX) + (dz * dz) / (windowZ * windowZ))
                let w = exp(-pow(d, 2) / 2)
                let yVal = yValue(x: Double(i), z: Double(j))
                guard !yVal.isNaN else { continue }
                sum += w * yVal
                weight += w
            }
        }
        return weight > 0 ? sum / weight : 0
    }

    // MARK: Labels & Legends

    private func xAxisLabel() -> String {
        switch aggregation {
            case .platformYear:
                return "Plateforme"
            case .countByGenreYear, .avgScoreByGenreYear, .avgPriceByGenreYear:
                return "Genre"
        }
    }

    private func yAxisLabel() -> String {
        switch aggregation {
            case .platformYear, .countByGenreYear:
                return "Nb jeux"
            case .avgScoreByGenreYear:
                return "Score"
            case .avgPriceByGenreYear:
                return "Prix"
        }
    }

    private func zAxisLabel() -> String {
        switch aggregation {
            case .platformYear:
                return isZoomOnYear ? "Mois" : "Année"
            default:
                return "Année"
        }
    }

    private func axesLegendView() -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack(spacing: 8) {
                Text("Axe X : \(aggregation == .platformYear ? "Plateforme" : "Genre")")
                #if !os(visionOS)
                    .font(.caption)
                #endif
                if aggregation == .platformYear {
                    Text("1=Windows, 3=Mac, 5=Linux")
                    #if !os(visionOS)
                        .font(.caption2)
                    #endif
                } else if aggregation == .countByGenreYear {
                    Text("Liste : \(Array(Set(games.flatMap { $0.genres })).sorted())   Total \(allGenres.count)")
                        .font(.caption2)
                }
            }
            HStack(spacing: 8) {
                Text("Axe Y : \(yAxisLabel()) (total \(games.count))")
                #if !os(visionOS)
                    .font(.caption)
                #endif
            }
            HStack(spacing: 8) {
                Text("Axe Z : \(zAxisLabel())")
                #if !os(visionOS)
                    .font(.caption)
                #endif
                if aggregation == .platformYear {
                    Text(isZoomOnYear ?
                        "1=Janvier … 12=Décembre"
                        : "\(allYears.first ?? 0) → \(allYears.last ?? 0) (total \(allYears.count))")
                    #if !os(visionOS)
                        .font(.caption2)
                    #endif
                } else {
                    Text("\(allYears.first ?? 0) → \(allYears.last ?? 0) (total \(allYears.count))")
                    #if !os(visionOS)
                        .font(.caption2)
                    #endif
                }
            }
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 3)
        .padding()
    }

    private func zAxisLegendView() -> some View {
        HStack(spacing: 6) {
            Text(zAxisLabel() + " :")
                .font(.caption)
            if aggregation == .platformYear && isZoomOnYear {
                ForEach(0..<12, id: \.self) { i in
                    Text(monthLabels[i])
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }
            } else {
                ForEach(allYears.indices, id: \.self) { i in
                    Text("\(allYears[i])")
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(8)
        .background(.thinMaterial, in: Capsule())
        .shadow(radius: 2)
        .padding([.leading, .bottom])
    }
}

// Safe array indexing
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#if os(visionOS)
#Preview(windowStyle: .plain) {
    let games: [SteamGame] = AppModel.loadDataset(filename: "Dataset", prefix: 50)
    let allYears = Array(Set(games.map(\.releaseYear))).sorted()
    SteamCharts3D(games: games, allYears: allYears)
        .environment(AppModel())
}
#endif
