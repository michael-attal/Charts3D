//
//  TestSteamCharts3D.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import Charts
import SwiftUI
internal import Spatial

struct TestSteamCharts3D: View {
    @Environment(AppModel.self) private var appModel

    #if os(visionOS)
        @Environment(\.openWindow) private var openWindow
        @Environment(\.dismissWindow) private var dismissWindow
    #endif

    // @State var pose: Chart3DPose = .default
    @State var pose: Chart3DPose = .init(
        azimuth: .degrees(-22.5),
        inclination: .degrees(0)
    )

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
        #if os(visionOS)
            // .offset(z: -300)
            .scaleEffect(0.8)
            // .rotation3DLayout(Angle(degrees: 5), axis: (x: 1, y: 0, z: 0))
            .toolbar {
                ToolbarItemGroup(placement: .bottomOrnament) {
                    VStack(spacing: 12) {
                        Button {
                            display2DChart.toggle()
                            if display2DChart {
                                openWindow(id: appModel.SteamCharts2DWindowID)
                            } else {
                                dismissWindow(id: appModel.SteamCharts2DWindowID)
                            }
                        } label: {
                            Text(display2DChart ? "Hide 2D Games of Years Chart" : "Display 2D Games of Years Chart")
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
        TestSteamCharts3D()
            .environment(AppModel())
    }
#endif
