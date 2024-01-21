//
//  View + Placeholder.swift
//  Wordy
//
//  Created by user on 21.01.2024.
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
            self
        }
    }
}
