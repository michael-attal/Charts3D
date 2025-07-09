//
//  TestPenguinModel.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Foundation

// MARK: - Penguin Data Model

struct Penguin: Identifiable {
    let id = UUID()
    let species: String
    let beakLength: Double // mm
    let flipperLength: Double // mm
    let weight: Double // kg
}

// MARK: - Fake Penguins Data

let penguins: [Penguin] = [
    Penguin(species: "Adelie", beakLength: 37.8, flipperLength: 181, weight: 3.9),
    Penguin(species: "Adelie", beakLength: 40.1, flipperLength: 190, weight: 4.2),
    Penguin(species: "Adelie", beakLength: 36.5, flipperLength: 180, weight: 3.7),

    Penguin(species: "Chinstrap", beakLength: 48.7, flipperLength: 195, weight: 5.1),
    Penguin(species: "Chinstrap", beakLength: 46.2, flipperLength: 192, weight: 4.8),
    Penguin(species: "Chinstrap", beakLength: 50.1, flipperLength: 198, weight: 5.3),

    Penguin(species: "Gentoo", beakLength: 53.9, flipperLength: 225, weight: 6.0),
    Penguin(species: "Gentoo", beakLength: 55.3, flipperLength: 230, weight: 6.2),
    Penguin(species: "Gentoo", beakLength: 52.6, flipperLength: 228, weight: 5.9),

    Penguin(species: "Adelie", beakLength: 39.0, flipperLength: 186, weight: 4.1),
    Penguin(species: "Chinstrap", beakLength: 49.3, flipperLength: 196, weight: 5.2),
    Penguin(species: "Gentoo", beakLength: 50.0, flipperLength: 220, weight: 5.7)
]
