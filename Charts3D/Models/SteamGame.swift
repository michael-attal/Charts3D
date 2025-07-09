//
//  SteamGame.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Foundation

struct SteamGame: Identifiable, Sendable {
    let id: Int
    let name: String
    let releaseYear: Int
    let releaseMonth: Int
    let genres: [String]
    let positiveRatioReview: Int
    let totalReviews: Int
    let mainGenre: String
    let scoreColor: Double // Normalized between 0 and 1
    let isFree: Bool?
    let priceUSD: Double?
    let platforms: [String]
}

// MARK: - Game Aggregated Stat by Year & Genre

struct GenreYearStat: Identifiable, Sendable {
    let id = UUID()
    let year: Int
    let genre: String
    let count: Int
    let avgScore: Double // Average review score for that genre/year
}
