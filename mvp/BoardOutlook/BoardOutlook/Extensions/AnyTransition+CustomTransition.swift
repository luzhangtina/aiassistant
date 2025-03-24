//
//  AnyTransition+MoveUpAndFade.swift
//  BoardOutlook
//
//  Created by lu on 24/3/2025.
//
import SwiftUI

extension AnyTransition {
    static var moveUpAndFade: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .bottom)),
            removal: .opacity.combined(with: .move(edge: .top))
        )
    }
}
