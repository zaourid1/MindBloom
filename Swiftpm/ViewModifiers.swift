//
//  ViewModfiers.swift
//  MindBloom
//
//  Created by Zineb Aourid on 2026-02-26.
//

import SwiftUI

extension View {
    func glassCard(cornerRadius: CGFloat = 22, shadowRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.white.opacity(0.72))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.65), lineWidth: 1))
                .shadow(color: .black.opacity(0.06), radius: shadowRadius, x: 0, y: 10)
        )
    }
}
