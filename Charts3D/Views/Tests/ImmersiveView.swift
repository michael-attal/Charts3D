//
//  ImmersiveView.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            #if os(visionOS)
            let attachment = ViewAttachmentComponent(
                rootView: TestSurfacePlot3DChart()
            )
            let testSurfacePlotChart = Entity(components: attachment)
            testSurfacePlotChart.position.z = -1
            content.add(testSurfacePlotChart)
            #endif
        }
    }
}

#if os(visionOS)
#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
#endif
