//
//  ScoreBoxPlotPerGenreChart.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct GenreScoreBox: Identifiable {
    let id = UUID()
    let genre: String
    let min: Double
    let q1: Double
    let median: Double
    let q3: Double
    let max: Double
}

struct ScoreBoxPlotPerGenreChart: View {
    let games: [SteamGame]
    let selectedGenres: [String]

    private var boxData: [GenreScoreBox] {
        selectedGenres.compactMap { genre in
            let scores = games
                .filter { $0.mainGenre == genre }
                .map { $0.scoreColor }
                .sorted()

            guard scores.count > 2 else { return nil }

            func percentile(_ p: Double) -> Double {
                let idx = Int(Double(scores.count - 1) * p)
                return scores[idx]
            }

            return GenreScoreBox(
                genre: genre,
                min: scores.first ?? 0,
                q1: percentile(0.25),
                median: percentile(0.5),
                q3: percentile(0.75),
                max: scores.last ?? 0
            )
        }
    }

    var body: some View {
        Chart {
            ForEach(boxData) { box in
                GenreBoxPlotMarks(box: box)
            }
        }
        .chartXAxisLabel("Genre")
        .chartYAxisLabel("User Score (positive ratio / 100)")
        .padding()
    }
}

// MARK: - Chart Marks

private struct GenreBoxPlotMarks: ChartContent {
    let box: GenreScoreBox

    var body: some ChartContent {
        RectangleMark(
            x: .value("Genre", box.genre),
            yStart: .value("Q1", box.q1),
            yEnd: .value("Q3", box.q3)
        )
        .foregroundStyle(by: .value("Genre", box.genre))

        RuleMark(
            x: .value("Genre", box.genre),
            y: .value("Median", box.median),
            z: .value("Z", 0)
        )
        .foregroundStyle(.black)

        RuleMark(
            x: .value("Genre", box.genre),
            yStart: .value("Min", box.min),
            yEnd: .value("Q1", box.q1),
        )
        .foregroundStyle(.gray.opacity(0.6))

        RuleMark(
            x: .value("Genre", box.genre),
            yStart: .value("Q3", box.q3),
            yEnd: .value("Max", box.max),
        )
        .foregroundStyle(.gray.opacity(0.6))
    }
}
