//
//  TestPenguin2DChart2.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct TestPenguin2DChart2: View {
    var body: some View {
        Chart(penguins) { penguin in
            PointMark(
                x: .value("Beak Length", penguin.beakLength),
                y: .value("Flipper Length", penguin.flipperLength)
            )
            .foregroundStyle(by: .value("Species", penguin.species))
        }
        .chartXAxisLabel("Beak Length (mm)")
        .chartYAxisLabel("Flipper Length (mm)")
        .chartXScale(domain: 30...60)
        .chartYScale(domain: 160...240)
        .chartXAxis {
            AxisMarks(values: [30, 40, 50, 60]) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(values: [160, 180, 200, 220, 240]) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}
