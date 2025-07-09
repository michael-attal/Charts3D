//
//  SteamCharts2D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

// TODO: Display list of games of the years and their popularity
struct SteamCharts2D: View {
    var body: some View {
        Chart(penguins) { penguin in
            PointMark(
                x: .value("Flipper Length", penguin.flipperLength),
                y: .value("Weight", penguin.weight)
            )
            .foregroundStyle(by: .value("Species", penguin.species))
        }
        .chartXAxisLabel("Flipper Length (mm)")
        .chartYAxisLabel("Weight (kg)")
        .chartXScale(domain: 160...240)
        .chartYScale(domain: 2...7)
        .chartXAxis {
            AxisMarks(values: [160, 180, 200, 220, 240]) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(values: [2, 3, 4, 5, 6, 7]) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .padding(50)
    }
}
