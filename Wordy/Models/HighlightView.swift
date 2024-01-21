//
//  HighlightView.swift
//  Wordy
//
//  Created by user on 20.01.2024.
//

import SwiftUI

struct HighlightView: Identifiable, Equatable {
    var id: UUID = .init()
    
    var anchor: Anchor<CGRect>
    var text: String
    var cornerRadius: CGFloat?
    var style: RoundedCornerStyle = .continuous
    var scale: CGFloat = 1
    var direction: PopupDirection = .top
}
