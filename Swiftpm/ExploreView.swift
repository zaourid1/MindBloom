//
//  ExploreView.swift
//  MindBloom
//
//  Created by Zineb Aourid on 2026-02-28.
//

import SwiftUI

// MARK: - ExploreView

struct ExploreView: View {

    @ObservedObject var store: BrainStore
    @State private var selectedConcept: MLConcept = .howitlearns
    @State private var hoveredLabel: ShapeLabel? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.mbBackgroundTop, Color.mbBackgroundBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            GrainOverlay().opacity(0.10).ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                header
                    .padding(.top, 14)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)

                conceptPicker
                    .padding(.horizontal, 18)
                    .padding(.bottom, 14)

                // Content swaps based on selected concept no scroll needed
                ZStack {
                    switch selectedConcept {
                    case .howitlearns: howItLearnsCard
                    case .yourdata:    yourDataCard
                    case .knn:         knnCard
                    }
                }
                .padding(.horizontal, 18)
                .animation(.spring(response: 0.4, dampingFraction: 0.82), value: selectedConcept)

                Spacer()
            }
        }
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("How does your brain work?")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("Peek inside the machine. No math required.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Concept Picker

    private var conceptPicker: some View {
        HStack(spacing: 8) {
            ForEach(MLConcept.allCases, id: \.self) { concept in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        selectedConcept = concept
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text(concept.icon)
                            .font(.system(size: 16))
                        Text(concept.title)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(selectedConcept == concept
                                  ? concept.color.opacity(0.18)
                                  : Color.white.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(selectedConcept == concept
                                            ? concept.color.opacity(0.45)
                                            : Color.white.opacity(0.5),
                                            lineWidth: 1.5)
                            )
                    )
                    .foregroundStyle(selectedConcept == concept ? concept.color : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Card 1: How It Learns

    private var howItLearnsCard: some View {
        VStack(spacing: 18) {

            // Analogy banner
            HStack(spacing: 14) {
                Text("🧒")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Think of it like a toddler")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text("A toddler learns what a \"dog\" looks like by seeing many dogs. Your brain does the same — but with shapes you draw.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.mbPrimary.opacity(0.07)))

            Divider().opacity(0.4)

            // 3-step visual flow
            HStack(spacing: 0) {
                LearningStep(emoji: "✏️", label: "You draw\nexamples", color: .mbPrimary)
                StepArrow()
                LearningStep(emoji: "📐", label: "Shape gets\nmeasured", color: .mbMint)
                StepArrow()
                LearningStep(emoji: "🧠", label: "Brain\nremembers", color: .mbCoral)
            }

            Divider().opacity(0.4)

            // Key insight
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.mbGlow)
                    .font(.system(size: 14))
                Text("The more examples you give, the more confident the brain becomes. It's not magic — it's just counting and comparing.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.mbGlow.opacity(0.08)))

            // Sample count progress
            VStack(spacing: 8) {
                HStack {
                    Text("Your training library")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                    Spacer()
                    Text("\(store.samples.count) drawings saved")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    ForEach(ShapeLabel.allCases, id: \.self) { label in
                        let count = store.samples.filter { $0.label == label }.count
                        ShapeCountBar(label: label, count: count, color: colorFor(label))
                    }
                }
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 24)
    }

    // MARK: - Card 2: Your Data

    private var yourDataCard: some View {
        VStack(spacing: 18) {

            HStack(spacing: 14) {
                Text("🗃️")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 4) {
                    Text("Every drawing becomes a number")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text("Computers can't \"see\" a circle. So we turn your drawing into a short list of numbers — like a fingerprint.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.mbMint.opacity(0.07)))

            Divider().opacity(0.4)

            // Feature explainer pills
            VStack(spacing: 8) {
                Text("What gets measured when you draw")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    FeaturePill(icon: "arrow.up.left.and.arrow.down.right", label: "How wide vs tall", color: .mbPrimary)
                    FeaturePill(icon: "scribble", label: "How curvy it is", color: .mbMint)
                    FeaturePill(icon: "move.3d", label: "How spread out", color: .mbCoral)
                    FeaturePill(icon: "point.topleft.down.curvedto.point.bottomright.up", label: "Corner sharpness", color: .mbGlow)
                }
            }

            Divider().opacity(0.4)

            // Mini scatter-plot (2 axes: aspect ratio vs curvature proxy)
            if store.samples.count >= 3 {
                VStack(spacing: 8) {
                    Text("Your drawings plotted (width vs height)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MiniScatterPlot(samples: store.samples)
                        .frame(height: 140)
                }
            } else {
                HStack(spacing: 10) {
                    Image(systemName: "chart.dots.scatter")
                        .foregroundStyle(Color.mbMint)
                    Text("Train at least 3 shapes to see your data plotted here.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .frame(height: 80)
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 24)
    }

    // MARK: - Card 3: k-NN Explained

    private var knnCard: some View {
        VStack(spacing: 18) {

            HStack(spacing: 14) {
                Text("👥")
                    .font(.system(size: 40))
                VStack(alignment: .leading, spacing: 4) {
                    Text("\"Ask your neighbours\"")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Text("When you draw something new, the brain asks: which saved drawings look most like this? The majority wins.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.mbCoral.opacity(0.07)))

            Divider().opacity(0.4)

            // Voting visual
            VStack(spacing: 10) {
                Text("How a prediction gets made")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                KNNVotingDiagram()
            }

            Divider().opacity(0.4)

            // Why it can be fooled
            VStack(alignment: .leading, spacing: 8) {
                Label("The catch", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mbCoral)

                Text("k-NN **always** gives an answer — even when the input is weird. It has no way to say \"I have no idea.\" This is why you can trick it with scribbles!")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    CatchTag(text: "More examples = better", color: .mbMint)
                    CatchTag(text: "Always picks something", color: .mbCoral)
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.mbCoral.opacity(0.06))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.mbCoral.opacity(0.18), lineWidth: 1)))
        }
        .padding(18)
        .glassCard(cornerRadius: 24)
    }

    // MARK: - Helpers

    private func colorFor(_ label: ShapeLabel) -> Color {
        switch label {
        case .circle:   return .mbPrimary
        case .triangle: return .mbMint
        case .star:     return .mbCoral
        }
    }
}

// MARK: - Supporting Types

enum MLConcept: CaseIterable {
    case howitlearns, yourdata, knn

    var title: String {
        switch self {
        case .howitlearns: return "Learning"
        case .yourdata:    return "Your Data"
        case .knn:         return "Predicting"
        }
    }
    var icon: String {
        switch self {
        case .howitlearns: return "🧒"
        case .yourdata:    return "🗃️"
        case .knn:         return "👥"
        }
    }
    var color: Color {
        switch self {
        case .howitlearns: return .mbPrimary
        case .yourdata:    return .mbMint
        case .knn:         return .mbCoral
        }
    }
}

// MARK: - Sub-views

struct LearningStep: View {
    let emoji: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 44, height: 44)
                Text(emoji).font(.system(size: 20))
            }
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StepArrow: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.secondary.opacity(0.5))
            .padding(.bottom, 18)
    }
}

struct ShapeCountBar: View {
    let label: ShapeLabel
    let count: Int
    let color: Color

    private var emoji: String {
        switch label {
        case .circle: return "⭕"
        case .triangle: return "🔺"
        case .star: return "⭐"
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(emoji).font(.system(size: 18))
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.10)).frame(height: 36)
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.65))
                    .frame(height: max(4, CGFloat(count) / CGFloat(max(1, count + 2)) * 36))
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: count)
            }
            .frame(maxWidth: .infinity)
            Text("\(count)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FeaturePill: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(color.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 1)))
    }
}

struct CatchTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.10))
                .overlay(Capsule().stroke(color.opacity(0.25), lineWidth: 1)))
    }
}

// MARK: - KNN Voting Diagram

struct KNNVotingDiagram: View {
    // Fixed demo data: 5 neighbours, 3 circles 1 triangle 1 circle = circle wins
    private let neighbours: [(emoji: String, label: String, color: Color, dist: String)] = [
        ("⭕", "Circle",   .mbPrimary, "d=0.12"),
        ("⭕", "Circle",   .mbPrimary, "d=0.18"),
        ("🔺", "Triangle", .mbMint,    "d=0.21"),
        ("⭕", "Circle",   .mbPrimary, "d=0.25"),
        ("⭐", "Star",     .mbCoral,   "d=0.31"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            // New drawing bubble
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(Color.mbGlow.opacity(0.15)).frame(width: 44, height: 44)
                    Text("❓").font(.system(size: 22))
                }
                Text("New\ndrawing")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary.opacity(0.4))
                .padding(.horizontal, 4)

            // Neighbours
            VStack(spacing: 5) {
                Text("5 closest matches")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                HStack(spacing: 5) {
                    ForEach(Array(neighbours.enumerated()), id: \.offset) { _, n in
                        VStack(spacing: 2) {
                            Text(n.emoji).font(.system(size: 16))
                            Text(n.dist)
                                .font(.system(size: 8, weight: .semibold, design: .rounded))
                                .foregroundStyle(n.color.opacity(0.7))
                        }
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(n.color.opacity(0.09))
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(n.color.opacity(0.22), lineWidth: 1)))
                    }
                }
            }

            // Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary.opacity(0.4))
                .padding(.horizontal, 4)

            // Vote result
            VStack(spacing: 4) {
                ZStack {
                    Circle().fill(Color.mbPrimary.opacity(0.15)).frame(width: 44, height: 44)
                    Text("⭕").font(.system(size: 22))
                }
                Text("Circle\nwins! 3-2")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mbPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.mbPrimary.opacity(0.04)))
    }
}

// MARK: - Mini Scatter Plot

struct MiniScatterPlot: View {
    let samples: [TrainingSample]

    private func colorFor(_ label: ShapeLabel) -> Color {
        switch label {
        case .circle:   return .mbPrimary
        case .triangle: return .mbMint
        case .star:     return .mbCoral
        }
    }

    private func emojiFor(_ label: ShapeLabel) -> String {
        switch label {
        case .circle:   return "⭕"
        case .triangle: return "🔺"
        case .star:     return "⭐"
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background grid
                RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.5))
                GridLines(width: geo.size.width, height: geo.size.height)

                // Axis labels
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("wider →")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.6))
                            .padding(6)
                    }
                }

                // Dots
                ForEach(Array(samples.enumerated()), id: \.offset) { i, sample in
                    let x = plotX(sample.features, in: geo.size.width)
                    let y = plotY(sample.features, in: geo.size.height)
                    Circle()
                        .fill(colorFor(sample.label))
                        .frame(width: 10, height: 10)
                        .shadow(color: colorFor(sample.label).opacity(0.35), radius: 4, x: 0, y: 2)
                        .position(x: x, y: y)
                }

                // Legend
                HStack(spacing: 8) {
                    ForEach(ShapeLabel.allCases, id: \.self) { label in
                        HStack(spacing: 4) {
                            Circle().fill(colorFor(label)).frame(width: 7, height: 7)
                            Text(label.rawValue.capitalized)
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.6), lineWidth: 1))
        }
    }

    private func plotX(_ features: [Double], in width: CGFloat) -> CGFloat {
        guard features.count > 0 else { return width / 2 }
        let v = min(max(features[0], 0), 3.0) / 3.0
        return CGFloat(v) * (width - 24) + 12
    }

    private func plotY(_ features: [Double], in height: CGFloat) -> CGFloat {
        guard features.count > 1 else { return height / 2 }
        let v = min(max(features[1], 0), 1.0)
        return (1.0 - CGFloat(v)) * (height - 24) + 12
    }
}

struct GridLines: View {
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Canvas { ctx, size in
            let color = Color.gray.opacity(0.12)
            for i in 1..<4 {
                let x = size.width / 4 * CGFloat(i)
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                ctx.stroke(path, with: .color(color), lineWidth: 1)
            }
            for i in 1..<4 {
                let y = size.height / 4 * CGFloat(i)
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(path, with: .color(color), lineWidth: 1)
            }
        }
    }
}
