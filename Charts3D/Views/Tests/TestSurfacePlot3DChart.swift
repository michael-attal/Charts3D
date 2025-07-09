//
//  TestSurfacePlot3DChart.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI

struct TestSurfacePlot3DChart: View {
    @State var pose: Chart3DPose = .default
    @State var display2DChart: Bool = false

    var body: some View {
        Chart3D {
            SurfacePlot(x: "X", y: "Y", z: "Z") { x, z in
                let h = hypot(x, z)
                return sin(h) / h
            }
            .foregroundStyle(.normalBased)
        }
        .chart3DPose($pose)
        .chartXScale(domain: -10...10, range: -0.5...0.5)
        .chartZScale(domain: -10...10, range: -0.5...0.5)
        .chartYScale(domain: -0.23...1, range: -0.5...0.5)
        .scaleEffect(0.8)
        #if os(visionOS)
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    VStack(spacing: 12) {
                        Button {
                            display2DChart.toggle()
                        } label: {
                            Text(display2DChart ? "Hide 2D Chart" : "Display 2D Chart")
                        }
                        .animation(.none, value: 0)
                        .fontWeight(.semibold)

                        // ToggleImmersiveSpaceButton()
                    }
                }
            }
        #endif
    }
}

#if os(visionOS)
    #Preview(windowStyle: .plain) {
        TestSurfacePlot3DChart()
            .environment(AppModel())
    }
#endif
