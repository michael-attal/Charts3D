//
//  AppModel.swift
//  Charts3D
//
//  Created by Michaël ATTAL on 09/07/2025.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState = ImmersiveSpaceState.closed

    let SteamCharts2DWindowID = "SteamCharts2DWindow"
    let SteamCharts3DWindowID = "SteamCharts3DWindow"
}
