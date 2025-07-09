//
//  TestPenguin3DChart2.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI
internal import Spatial

struct TestPenguin3DChart2: View {
    @State var pose: Chart3DPose = .init(
        azimuth: .degrees(20),
        inclination: .degrees(7)
    )

    var body: some View {
        let xLabel = "Flipper Length (mm)"
        let yLabel = "Weight (kg)"
        let zLabel = "Beak Length (mm)"

        Chart3D(penguins) { penguin in
            PointMark(
                x: .value("Flipper Length", penguin.flipperLength),
                y: .value("Weight", penguin.weight),
                z: .value("Beak Length", penguin.beakLength)
            )
            .foregroundStyle(by: .value("Species", penguin.species))
        }
        .chart3DPose($pose)
        .chartXAxisLabel(xLabel)
        .chartYAxisLabel(yLabel)
        .chartZAxisLabel(zLabel)
        .chartXScale(domain: 160...240, range: -0.5...0.5)
        .chartYScale(domain: 2...7, range: -0.5...0.5)
        .chartZScale(domain: 30...60, range: -0.5...0.5)
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
        .chartZAxis {
            AxisMarks(values: [30, 40, 50, 60]) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}
