//
//  SteamChartsDataProcessor.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Foundation

enum SteamChartsDataProcessor {
    static func parseGames(from rawDataset: [[String: Any]]) -> [SteamGame] {
        var games: [SteamGame] = []

        for game in rawDataset {
            guard
                let id = game["id"] as? Int,
                let name = game["name"] as? String,
                let genres = game["genres"] as? [String],
                let releaseDateStr = game["releaseDate"] as? String,
                let positiveRatio = game["positiveRatioReview"] as? Int,
                let posRev = game["positiveReview"] as? Int,
                let negRev = game["negativeReview"] as? Int,
                let platforms = game["supportedPlatforms"] as? [String]

            else { continue }

            let totalReviews = posRev + negRev

            // Extract year (ex: "Dec 17, 2020" -> 2020) and month
            let (year, month): (Int, Int) = {
                let comps = releaseDateStr.split(separator: ",")
                let yearStr = comps.last?.trimmingCharacters(in: .whitespaces)
                let monthDayStr = comps.first?.trimmingCharacters(in: .whitespaces) ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd"
                let monthNum: Int
                if let md = dateFormatter.date(from: String(monthDayStr)) {
                    monthNum = Calendar.current.component(.month, from: md)
                } else {
                    monthNum = 1 // fallback
                }
                let y = yearStr.flatMap { Int($0) } ?? 0
                return (y, monthNum)
            }()

            let mainGenre = genres.first ?? "Unknown"

            // Normalize the score (for color, between 0 and 1)
            let score = Double(positiveRatio) / 100.0

            let isFree = game["isFree"] as? Bool

            // Parse priceUSD from priceOverview
            let priceUSD: Double? = {
                if let price = game["priceOverview"] as? [String: Any],
                   let finalPriceInCents = price["finalPriceInCents"] as? Int,
                   let currency = price["currency"] as? String, currency == "USD"
                {
                    return Double(finalPriceInCents) / 100.0
                } else {
                    return nil
                }
            }()

            games.append(SteamGame(
                id: id,
                name: name,
                releaseYear: year,
                releaseMonth: month,
                genres: genres,
                positiveRatioReview: positiveRatio,
                totalReviews: totalReviews,
                mainGenre: mainGenre,
                scoreColor: score,
                isFree: isFree,
                priceUSD: priceUSD,
                platforms: platforms,
            ))
        }

        return games
    }

    /// Aggregate by (year, genre): how many releases + average score
    static func aggregateByYearAndGenre(games: [SteamGame]) -> [GenreYearStat] {
        var dict: [String: [SteamGame]] = [:]
        for game in games {
            let key = "\(game.releaseYear)-\(game.mainGenre)"
            dict[key, default: []].append(game)
        }
        return dict.compactMap { key, games in
            guard let first = games.first else { return nil }
            let comps = key.split(separator: "-")
            guard comps.count == 2, let year = Int(comps[0]) else { return nil }
            let genre = String(comps[1])
            let avgScore = games.map(\.scoreColor).reduce(0, +) / Double(games.count)
            return GenreYearStat(
                year: year,
                genre: genre,
                count: games.count,
                avgScore: avgScore
            )
        }
    }

    /// All unique genres
    static func allGenres(from stats: [GenreYearStat]) -> [String] {
        Array(Set(stats.map(\.genre))).sorted()
    }

    /// Map genre to Z index
    static func genreToZIndex(_ genre: String, genres: [String]) -> Double {
        Double(genres.firstIndex(of: genre) ?? 0)
    }

    static func yearGenreMatrix(stats: [GenreYearStat], genres: [String]) -> [Int: [String: GenreYearStat]] {
        var dict: [Int: [String: GenreYearStat]] = [:]
        for stat in stats {
            dict[stat.year, default: [:]][stat.genre] = stat
        }
        return dict
    }

    static func scoreFor(year: Int, genreIdx: Int, allYears: [Int], allGenres: [String], yearGenreDict: [Int: [String: GenreYearStat]]) -> Double? {
        guard year >= 0, year < allYears.count, genreIdx >= 0, genreIdx < allGenres.count else { return nil }
        let yearVal = allYears[year]
        let genre = allGenres[genreIdx]
        return yearGenreDict[yearVal]?[genre]?.avgScore
    }
}
