//
//  TrainView.swift
//  MindBloom
//
//  Created by Zineb Aourid on 2026-02-19.
//

import SwiftUI

// MARK: - TrainView

struct TrainView: View {

    @ObservedObject var store: BrainStore

    @State private var currentStroke: [CGPoint] = []
    @State private var selectedLabel: ShapeLabel = .circle
    @State private var pulseTrain = false
    @State private var lastTrainMessage = "Draw a shape, pick its label, then feed the brain."

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.mbBackgroundTop, Color.mbBackgroundBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            GrainOverlay().opacity(0.10).ignoresSafeArea().allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    trainingCard
                    drawingCard
                    Spacer().frame(height: 18)
                }
                .padding(.top, 14)
            }
        }
        .navigationTitle("Train")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Train your model")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("Examples become patterns. Patterns become predictions.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }

    private var trainingCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Chamber")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(store.level.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(store.xp) XP")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mbPrimary)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(Capsule().fill(Color.mbPrimary.opacity(0.14)))
            }

            ZStack {
                NeuronNetworkView(seed: 42, connectionStrength: store.neuronStrength)
                    .frame(height: 160)

                BrainMascotView(level: store.level)
                    .frame(width: 150, height: 150)
                    .scaleEffect(pulseTrain ? 1.03 : 1.0)
                    .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 10)
            }
            .padding(.top, 4)

            ProgressView(value: store.progress)
                .tint(Color.mbPrimary)
                .scaleEffect(x: 1, y: 1.35, anchor: .center)

            Text(lastTrainMessage)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .padding(16)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 18)
    }

    private var drawingCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Draw (single stroke)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Button { currentStroke = [] } label: {
                    Text("Clear")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Capsule().fill(.white.opacity(0.75)))
                        .overlay(Capsule().stroke(.white.opacity(0.55), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            DoodlePad(stroke: $currentStroke)
                .frame(height: 260)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.82))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(.white.opacity(0.70), lineWidth: 1)))
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)

            ShapeLabelPicker(selected: $selectedLabel)

            Button { feedBrain() } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles").font(.system(size: 16, weight: .bold))
                    Text("Feed Brain").font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity).frame(height: 54)
                .background(LinearGradient(colors: [Color.mbPrimary, Color.mbPrimary2],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 12)
            }
            .buttonStyle(.plain)
            .disabled(currentStroke.count < 12)
            .opacity(currentStroke.count < 12 ? 0.55 : 1.0)

            datasetRow
        }
        .padding(.horizontal, 18)
    }

    private var datasetRow: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Your Dataset")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Spacer()
                Text("\(store.samples.count) samples")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                DatasetPill(label: "Circle",   count: store.count(.circle),   color: Color.mbPrimary)
                DatasetPill(label: "Triangle", count: store.count(.triangle), color: Color.mbMint)
                DatasetPill(label: "Star",     count: store.count(.star),     color: Color.mbCoral)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 18, shadowRadius: 14)
        .padding(.top, 6)
    }

    // MARK: Actions

    private func feedBrain() {
        guard currentStroke.count >= 12 else {
            lastTrainMessage = "Make the stroke longer so your AI has something to learn."
            return
        }
        store.addSample(label: selectedLabel, features: FeatureExtractor.features(from: currentStroke))
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { pulseTrain = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) { pulseTrain = false }
        }
        lastTrainMessage = "Learned a \(selectedLabel.rawValue) example. Try adding variety!"
        currentStroke = []
    }
}

// MARK: - BrainStore

final class BrainStore: ObservableObject {
    @Published var xp: Int
    @Published var samples: [TrainingSample]

    init(xp: Int = 0, samples: [TrainingSample] = []) {
        self.xp = xp
        self.samples = samples
    }

    var progress: Double       { min(1.0, Double(xp) / 800.0) }
    var level: GrowthLevel     { GrowthLevel.forProgress(progress) }
    var neuronStrength: Double { min(1.0, Double(xp) / 700.0) }

    func addSample(label: ShapeLabel, features: [Double]) {
        samples.append(TrainingSample(label: label, features: features))
        xp += 25
    }

    func count(_ label: ShapeLabel) -> Int {
        samples.filter { $0.label == label }.count
    }
}

// MARK: - Models

struct TrainingSample: Codable, Identifiable {
    let id: UUID
    let label: ShapeLabel
    let features: [Double]
    init(id: UUID = UUID(), label: ShapeLabel, features: [Double]) {
        self.id = id; self.label = label; self.features = features
    }
}

enum ShapeLabel: String, Codable, CaseIterable {
    case circle = "Circle", triangle = "Triangle", star = "Star"
}

// MARK: - Feature Extraction

enum FeatureExtractor {

    static func features(from points: [CGPoint]) -> [Double] {
        let norm = normalize(resample(points, to: 64))
        var vec = norm.flatMap { [Double($0.x), Double($0.y)] }
        vec.append(contentsOf: globalStats(norm))
        return vec
    }

    private static func resample(_ pts: [CGPoint], to n: Int) -> [CGPoint] {
        guard pts.count > 1 else { return pts }
        let total = pathLength(pts)
        guard total > 0 else { return Array(repeating: pts[0], count: n) }

        let step = total / CGFloat(n - 1)
        var out = [pts[0]]
        var distAccum: CGFloat = 0
        var prev = pts[0], i = 1

        while i < pts.count {
            let cur = pts[i]
            let d = dist(prev, cur)
            if distAccum + d >= step {
                let t = (step - distAccum) / d
                let np = CGPoint(x: prev.x + t*(cur.x - prev.x), y: prev.y + t*(cur.y - prev.y))
                out.append(np)
                prev = np; distAccum = 0
            } else {
                distAccum += d; prev = cur; i += 1
            }
        }
        while out.count < n { out.append(out.last ?? pts.last!) }
        return out
    }

    private static func normalize(_ pts: [CGPoint]) -> [CGPoint] {
        guard !pts.isEmpty else { return [] }
        let cx = pts.map(\.x).reduce(0, +) / CGFloat(pts.count)
        let cy = pts.map(\.y).reduce(0, +) / CGFloat(pts.count)
        let centered = pts.map { CGPoint(x: $0.x - cx, y: $0.y - cy) }
        let scale = max(
            centered.map(\.x).map(abs).max() ?? 0,
            centered.map(\.y).map(abs).max() ?? 0
        )
        guard scale > 0 else { return centered }
        return centered.map { CGPoint(x: $0.x/scale, y: $0.y/scale) }
    }

    private static func globalStats(_ pts: [CGPoint]) -> [Double] {
        guard pts.count > 2 else { return [0,0,0,0,0,0] }
        let radii = pts.map { sqrt($0.x*$0.x + $0.y*$0.y) }
        let mean = radii.reduce(0, +) / CGFloat(radii.count)
        let varR = radii.map { ($0 - mean)*($0 - mean) }.reduce(0, +) / CGFloat(radii.count)
        let xs = pts.map(\.x), ys = pts.map(\.y)
        let w = (xs.max() ?? 0) - (xs.min() ?? 0)
        let h = (ys.max() ?? 0) - (ys.min() ?? 0)
        return [
            Double(varR),
            h == 0 ? 0 : Double(w/h),
            Double(totalTurningAngle(pts)),
            Double(dist(pts.first!, pts.last!)),
            Double(pathLength(pts)),
            Double(mean)
        ]
    }

    private static func totalTurningAngle(_ pts: [CGPoint]) -> CGFloat {
        guard pts.count > 2 else { return 0 }
        return (1..<pts.count-1).reduce(0) { sum, i in
            let ab = CGVector(dx: pts[i].x-pts[i-1].x, dy: pts[i].y-pts[i-1].y)
            let bc = CGVector(dx: pts[i+1].x-pts[i].x, dy: pts[i+1].y-pts[i].y)
            let mag = sqrt((ab.dx*ab.dx+ab.dy*ab.dy)*(bc.dx*bc.dx+bc.dy*bc.dy))
            guard mag > 0 else { return sum }
            return sum + acos(min(1, max(-1, (ab.dx*bc.dx+ab.dy*bc.dy)/mag)))
        }
    }

    private static func pathLength(_ pts: [CGPoint]) -> CGFloat {
        zip(pts, pts.dropFirst()).reduce(0) { $0 + dist($1.0, $1.1) }
    }

    private static func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x-b.x, dy = a.y-b.y
        return sqrt(dx*dx+dy*dy)
    }
}

// MARK: - DoodlePad

struct DoodlePad: View {
    @Binding var stroke: [CGPoint]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.opacity(0.001)

                Path { p in
                    guard let first = stroke.first else { return }
                    p.move(to: first)
                    stroke.dropFirst().forEach { p.addLine(to: $0) }
                }
                .stroke(Color.black.opacity(0.75),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)

                if stroke.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text("Draw here")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.75))
                        Text("One stroke only (don't lift your finger).")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.65))
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { stroke.append($0.location.clamped(to: geo.size)) })
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

// MARK: - ShapeLabelPicker

struct ShapeLabelPicker: View {
    @Binding var selected: ShapeLabel

    private func color(for label: ShapeLabel) -> Color {
        switch label {
        case .circle: return .mbPrimary
        case .triangle: return .mbMint
        case .star: return .mbCoral
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ShapeLabel.allCases, id: \.self) { label in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { selected = label }
                } label: {
                    Text(label.rawValue)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(selected == label ? .white : .primary)
                        .padding(.horizontal, 14).frame(height: 40)
                        .background(Capsule().fill(selected == label ? color(for: label) : .white.opacity(0.70)))
                        .overlay(Capsule().stroke(.white.opacity(0.65), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - DatasetPill

struct DatasetPill: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(color.opacity(0.9)).frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
            Spacer(minLength: 0)
            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12).frame(height: 38)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.white.opacity(0.65))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.6), lineWidth: 1)))
    }
}

// MARK: - NeuronNetworkView

struct NeuronNetworkView: View {
    let seed: Int
    let connectionStrength: Double

    var body: some View {
        GeometryReader { geo in
            let nodes = NeuronLayout.nodes(seed: seed, count: 18, in: geo.size)
            let edges  = NeuronLayout.connections(nodes: nodes, strength: connectionStrength)
            Canvas { ctx, _ in
                let lineAlpha = 0.08 + 0.22 * connectionStrength
                for e in edges {
                    var p = Path(); p.move(to: e.a); p.addLine(to: e.b)
                    ctx.stroke(p, with: .color(Color.mbGlow.opacity(lineAlpha)), lineWidth: 2)
                }
                let r = 5.0 + 2.0 * connectionStrength
                for pt in nodes {
                    let rect = CGRect(x: pt.x-r/2, y: pt.y-r/2, width: r, height: r)
                    ctx.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.85)))
                    ctx.stroke(Path(ellipseIn: rect), with: .color(Color.mbGlow.opacity(0.35)), lineWidth: 1)
                }
            }
        }
    }
}

enum NeuronLayout {
    static func nodes(seed: Int, count: Int, in size: CGSize) -> [CGPoint] {
        var rng = SeededRNG(seed: seed)
        let pad: CGFloat = 18
        return (0..<count).map { _ in
            CGPoint(x: CGFloat(rng.nextDouble())*(size.width-2*pad)+pad,
                    y: CGFloat(rng.nextDouble())*(size.height-2*pad)+pad)
        }
    }

    static func connections(nodes: [CGPoint], strength: Double) -> [(a: CGPoint, b: CGPoint)] {
        let maxEdges = Int(Double(nodes.count * 3) * strength) + 4
        var edges: [(CGPoint, CGPoint)] = nodes.enumerated().flatMap { i, p in
            nodes.enumerated()
                .filter { $0.offset != i }
                .map { (offset: $0.offset, pt: $0.element, d: dist(p, $0.element)) }
                .sorted { $0.d < $1.d }
                .prefix(3)
                .map { (p, $0.pt) }
        }
        if edges.count > maxEdges { edges = Array(edges.prefix(maxEdges)) }
        return edges
    }

    private static func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x-b.x, dy = a.y-b.y; return sqrt(dx*dx+dy*dy)
    }
}

// MARK: - Helpers

extension CGPoint {
    func clamped(to size: CGSize) -> CGPoint {
        CGPoint(x: min(max(0, x), size.width), y: min(max(0, y), size.height))
    }
}

struct SeededRNG {
    private var state: UInt64
    init(seed: Int) { self.state = UInt64(seed) &+ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    mutating func nextDouble() -> Double { Double(next() >> 11) / Double(1 << 53) }
}

