//
//  TestPenguin3DChartSurfacePlot.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts

// import CreateML
import SwiftUI
import TabularData

import CoreML

struct PenguinWeightPredictor {
    private let model: PenguinWeightRegressor

    init() {
        model = try! PenguinWeightRegressor(configuration: MLModelConfiguration())
    }

    func predictWeight(flipperLength: Double, beakLength: Double) -> Double {
        return 1.0
        
        let input = PenguinWeightRegressorInput(
            beakLength: beakLength,
            flipperLength: Int64(flipperLength),
        )
        guard let prediction = try? model.prediction(input: input) else {
            return .nan
        }
        return prediction.weight
    }
}

// final class LinearRegression: Sendable {
//     let regressor: MLLinearRegressor
//
//     init<Data: RandomAccessCollection>(
//         _ data: Data,
//         x xPath: KeyPath<Data.Element, Double>,
//         y yPath: KeyPath<Data.Element, Double>,
//         z zPath: KeyPath<Data.Element, Double>
//     ) {
//         let x = Column(name: "X", contents: data.map { $0[keyPath: xPath] })
//         let y = Column(name: "Y", contents: data.map { $0[keyPath: yPath] })
//         let z = Column(name: "Z", contents: data.map { $0[keyPath: zPath] })
//         let data = DataFrame(columns: [x, y, z].map { $0.eraseToAnyColumn() })
//         regressor = try! MLLinearRegressor(trainingData: data, targetColumn: "Y")
//     }
//
//     func callAsFunction(_ x: Double, _ z: Double) -> Double {
//         let x = Column(name: "X", contents: [x])
//         let z = Column(name: "Z", contents: [z])
//         let data = DataFrame(columns: [x, z].map { $0.eraseToAnyColumn() })
//         return (try? regressor.predictions(from: data))?.first as? Double ?? .nan
//     }
// }

// let linearRegression = LinearRegression(
//     penguins,
//     x: \.flipperLength,
//     y: \.weight,
//     z: \.beakLength
// )

struct TestPenguin3DChartSurfacePlot: View {
    let weightPredictor = PenguinWeightPredictor()
    @State var pose: Chart3DPose = .default

    var body: some View {
        let xLabel = "Flipper Length (mm)"
        let yLabel = "Weight (kg)"
        let zLabel = "Beak Length (mm)"

        Chart3D {
            ForEach(penguins) { penguin in
                PointMark(
                    x: .value("Flipper Length", penguin.flipperLength),
                    y: .value("Weight", penguin.weight),
                    z: .value("Beak Length", penguin.beakLength),
                )
                .foregroundStyle(by: .value("Species", penguin.species))
            }

            SurfacePlot(x: "Flipper Length", y: "Weight", z: "Beak Length") { flipperLength, beakLength in
                // linearRegression(flipperLength, beakLength)
                weightPredictor.predictWeight(flipperLength: flipperLength, beakLength: beakLength)
            }
            .foregroundStyle(.gray)
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
