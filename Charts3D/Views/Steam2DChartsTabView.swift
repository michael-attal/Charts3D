//
//  Steam2DChartsTabView.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import SwiftUI

struct Steam2DChartsTabView: View {
    let games: [SteamGame]
    let stats: [GenreYearStat]

    @State private var selectedGenres: [String] = []
    @State private var selectedChart: Int = 0
    @State private var recentPeriod: ClosedRange<Int>?

    var allGenres: [String] {
        Array(Set(games.map(\.mainGenre))).sorted()
    }

    var allYears: [Int] {
        Array(Set(games.map(\.releaseYear))).sorted()
    }

    var body: some View {
        VStack {
            Picker("Graphique", selection: $selectedChart) {
                Text("Sorties par année").tag(0)
                // Text("Évolution score/genre").tag(1)
                Text("Répartition des genres").tag(2)
                // Text("Boxplot score/genre").tag(3)
                Text("Free-to-play vs Payant").tag(4)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if selectedChart == 0 {
                ReleasesPerYearChart(games: games)
            } else if selectedChart == 1 {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(allGenres, id: \.self) { genre in
                                Button {
                                    if selectedGenres.contains(genre) {
                                        selectedGenres.removeAll { $0 == genre }
                                    } else {
                                        selectedGenres.append(genre)
                                    }
                                } label: {
                                    Text(genre)
                                        .padding(6)
                                        .background(selectedGenres.contains(genre) ? .blue : .gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 4)
                    AvgScorePerGenreOverTimeChart(
                        stats: stats,
                        selectedGenres: selectedGenres.isEmpty ? Array(allGenres.prefix(3)) : selectedGenres
                    )
                }
            } else if selectedChart == 2, var recentPeriod {
                VStack {
                    HStack {
                        Text("Période :")
                        Picker("Début", selection: Binding(get: { recentPeriod.lowerBound }, set: { recentPeriod = $0...recentPeriod.upperBound })) {
                            ForEach(allYears, id: \.self) { y in Text("\(y)").tag(y) }
                        }
                        Text("→")
                        Picker("Fin", selection: Binding(get: { recentPeriod.upperBound }, set: { recentPeriod = recentPeriod.lowerBound...$0 })) {
                            ForEach(allYears, id: \.self) { y in Text("\(y)").tag(y) }
                        }
                    }
                    .padding(.horizontal)
                    GenreDistributionChart(games: games, period: recentPeriod)
                }
            } else if selectedChart == 3 {
                ScoreBoxPlotPerGenreChart(games: games, selectedGenres: selectedGenres.isEmpty ? Array(allGenres.prefix(3)) : selectedGenres)
            } else if selectedChart == 4 {
                FreeVsPaidOverTimeChart(games: games)
            }
        }
        .onAppear {
            if recentPeriod == nil, let first = allYears.first, let last = allYears.last {
                recentPeriod = first...last
            }
        }
    }
}
