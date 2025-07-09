//
//  TestContentView.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct TestContentView: View {
    @State var display2DChart: Bool = false

    var body: some View {
        #if !os(visionOS)
        RealityView { t in
        } update: { t in
        } placeholder: {}
        #endif

        #if os(visionOS)
        RealityView { content in
            let attachment = ViewAttachmentComponent(
                rootView: TestSurfacePlot3DChart()
            )
            let test = Entity(components: attachment)

            content.add(test)

        } placeholder: {
            ProgressView()
        }
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
#Preview(windowStyle: .volumetric) {
    TestContentView()
        .environment(AppModel())
}
#endif
