//
//  TestView.swift
//  MindBloom
//
//  Created by Zineb Aourid on 2026-02-25.
//
import SwiftUI

// MARK: - TestView

struct TestView: View {

    @ObservedObject var store: BrainStore

    @State private var stroke: [CGPoint] = []
    @State private var prediction: KNNShapeModel.Prediction? = nil
    @State private var phase: TestPhase = .idle
    @State private var feedbackGiven: FeedbackResult? = nil
    @State private var pulseResult = false
    @State private var correctStreak = 0
    @State private var totalTested = 0
    @State private var isAnalyzing = false
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var trickMode = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.mbBackgroundTop, Color.mbBackgroundBottom],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            GrainOverlay().opacity(0.10).ignoresSafeArea().allowsHitTesting(false)

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header
                        statsBar

                        // Guard: not enough samples
                        if store.samples.count < 3 {
                            notEnoughSamplesCard
                        } else {
                            brainCard
                            mlExplainerCard
                            drawingCard

                            if phase == .result, let pred = prediction {
                                resultCard(pred)
                                    .id("result")
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }

                        Spacer().frame(height: 24)
                    }
                    .padding(.top, 14)
                    .animation(.spring(response: 0.45, dampingFraction: 0.78), value: phase)
                }
                .onAppear { scrollProxy = proxy }
            }
        }
        .navigationTitle("Test")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Test your model")
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text("Draw a shape and see if your brain can recognize it.")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }

    // MARK: - Stats Bar

    private var statsBar: some View {
        HStack(spacing: 10) {
            StatPill(label: "Tests", value: "\(totalTested)", color: .mbPrimary)
            StatPill(label: "Streak", value: "\(correctStreak)🔥", color: .mbMint)
            StatPill(label: "Accuracy", value: accuracyText, color: .mbCoral)
            StatPill(label: "Samples", value: "\(store.samples.count)", color: .mbGlow)
        }
        .padding(.horizontal, 18)
    }

    private var accuracyText: String {
        guard totalTested > 0 else { return "–" }
        let pct = Int(store.testAccuracy * 100)
        return "\(pct)%"
    }

    // MARK: - Not Enough Samples Card

    private var notEnoughSamplesCard: some View {
        VStack(spacing: 16) {
            Text("🧠")
                .font(.system(size: 48))

            VStack(spacing: 6) {
                Text("Your brain needs more data!")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Text("Go to **Train** and draw at least 3 examples of each shape before testing. The more examples you give, the smarter it gets.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                Image(systemName: "circle")
                    .foregroundStyle(Color.mbPrimary)
                Image(systemName: "triangle")
                    .foregroundStyle(Color.mbMint)
                Image(systemName: "star")
                    .foregroundStyle(Color.mbCoral)
            }
            .font(.system(size: 22, weight: .bold))

            Text("\(store.samples.count) / 3 minimum samples collected")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.mbPrimary.opacity(0.10)))
        }
        .padding(24)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 18)
    }

    // MARK: - Brain Card

    private var brainCard: some View {
        HStack(spacing: 16) {
            BrainMascotView(level: store.level)
                .frame(width: 80, height: 80)
                .scaleEffect(pulseResult ? 1.10 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pulseResult)
                .shadow(color: Color.mbGlow.opacity(0.18), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(store.level.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))

                ProgressView(value: store.progress)
                    .tint(Color.mbPrimary)
                    .scaleEffect(x: 1, y: 1.3, anchor: .center)

                Text(phaseHint)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .glassCard(cornerRadius: 22)
        .padding(.horizontal, 18)
    }

    private var phaseHint: String {
        switch phase {
        case .idle:   return "Draw any shape below, then tap \"Ask the Brain\"."
        case .result: return "Was the prediction right? Your feedback helps it learn!"
        }
    }

    // MARK: - ML Explainer Card

    private var mlExplainerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How does this work?")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            VStack(spacing: 10) {
                MLStep(
                    number: "1",
                    icon: "hand.draw",
                    color: .mbPrimary,
                    title: "You draw",
                    detail: "Your finger traces a path of (x, y) points on screen.",
                    active: phase == .idle
                )
                MLStep(
                    number: "2",
                    icon: "function",
                    color: .mbMint,
                    title: "Features are extracted",
                    detail: "Raw points → compact numbers: aspect ratio, curvature, point spread, etc. This is called a feature vector.",
                    active: isAnalyzing
                )
                MLStep(
                    number: "3",
                    icon: "point.3.connected.trianglepath.dotted",
                    color: .mbCoral,
                    title: "k-NN finds nearest neighbours",
                    detail: "The model measures the distance between your vector and every training example. The closest \(store.samples.count < 5 ? store.samples.count : 5) \"neighbours\" vote on what shape it is.",
                    active: isAnalyzing
                )
                MLStep(
                    number: "4",
                    icon: "brain.head.profile",
                    color: .mbGlow,
                    title: "Prediction + confidence",
                    detail: "The majority vote wins. Confidence = what fraction of neighbours agreed.",
                    active: phase == .result
                )
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 22)
        .padding(.horizontal, 18)
    }

    // MARK: - Drawing Card

    private var drawingCard: some View {
        VStack(spacing: 14) {

            // Title row
            HStack {
                Text(phase == .idle ? "Draw a shape" : "Your drawing")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()

                // Trick mode toggle (only visible before prediction)
                if phase == .idle {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            trickMode.toggle()
                            stroke = []
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(trickMode ? "🎲" : "🎲")
                            Text(trickMode ? "Trick mode ON" : "Trick it")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(trickMode ? Color.mbCoral : .secondary)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Capsule().fill(trickMode ? Color.mbCoral.opacity(0.12) : Color.white.opacity(0.6)))
                        .overlay(Capsule().stroke(trickMode ? Color.mbCoral.opacity(0.35) : Color.white.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    stroke = []
                    if phase == .result { resetRound() }
                } label: {
                    Text(phase == .result ? "Try again" : "Clear")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(phase == .result ? Color.mbPrimary : .primary)
                        .padding(.horizontal, 10).padding(.vertical, 7)
                        .background(Capsule().fill(
                            phase == .result ? Color.mbPrimary.opacity(0.12) : Color.white.opacity(0.75)
                        ))
                        .overlay(Capsule().stroke(
                            phase == .result ? Color.mbPrimary.opacity(0.25) : Color.white.opacity(0.55),
                            lineWidth: 1
                        ))
                }
                .buttonStyle(.plain)
            }

            // Trick mode explainer banner
            if trickMode && phase == .idle {
                HStack(spacing: 10) {
                    Text("🎲")
                        .font(.system(size: 18))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Trick mode — draw anything weird!")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.mbCoral)
                        Text("Scribble, zigzag, write your name — see what the model guesses. ML models always predict *something*, even when the input makes no sense.")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.mbCoral.opacity(0.07))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.mbCoral.opacity(0.20), lineWidth: 1)))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Hint text
            if phase == .idle {
                if stroke.isEmpty {
                    Label("Draw a circle, triangle, or star", systemImage: "pencil.tip")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Label("\(stroke.count) points captured", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(stroke.count >= 12 ? Color.mbMint : .secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Canvas
            DoodlePad(stroke: $stroke)
                .frame(height: 240)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.white.opacity(0.82))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(borderColor, lineWidth: phase == .result ? 2.5 : 1)
                        )
                )
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
                .allowsHitTesting(phase == .idle)

            // Action button
            if phase == .idle {
                Button { runPrediction() } label: {
                    HStack(spacing: 10) {
                        if isAnalyzing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.85)
                        } else {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 16, weight: .bold))
                        }
                        Text(isAnalyzing ? "Thinking…" : "Ask the Brain")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: stroke.count >= 12
                                ? [Color.mbMint, Color.mbMint2]
                                : [Color.gray.opacity(0.4), Color.gray.opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: stroke.count >= 12 ? Color.mbMint.opacity(0.30) : .clear,
                            radius: 16, x: 0, y: 12)
                }
                .buttonStyle(.plain)
                .disabled(stroke.count < 12 || isAnalyzing)

                if stroke.count < 12 && !stroke.isEmpty {
                    Text("Keep drawing — need at least 12 points")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 22)
        .padding(.horizontal, 18)
    }

    private var borderColor: Color {
        guard phase == .result, let fb = feedbackGiven else {
            return stroke.count >= 12 ? Color.mbMint.opacity(0.35) : Color.white.opacity(0.70)
        }
        switch fb {
        case .correct:   return Color.mbMint.opacity(0.6)
        case .wrong:     return Color.mbCoral.opacity(0.6)
        case .corrected: return Color.mbPrimary.opacity(0.6)
        case .tricked:   return Color.mbCoral.opacity(0.4)
        }
    }

    // MARK: - Result Card

    private func resultCard(_ pred: KNNShapeModel.Prediction) -> some View {
        VStack(spacing: 16) {

            // ── Prediction headline ──
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(predictionColor(pred.label).opacity(0.14))
                        .frame(width: 58, height: 58)
                    Text(shapeEmoji(pred.label))
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("I think it's a…")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(pred.label?.rawValue.capitalized ?? "Unknown")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(predictionColor(pred.label))
                }

                Spacer()

                ConfidenceRing(confidence: pred.confidence, color: predictionColor(pred.label))
                    .frame(width: 52, height: 52)
            }

            // ── What confidence means ──
            confidenceExplainer(pred.confidence)

            // ── Neighbour evidence ──
            if !pred.neighborLabels.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Nearest neighbours")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("(lower distance = more similar)")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }

                    HStack(spacing: 8) {
                        ForEach(Array(zip(pred.neighborLabels, pred.neighborDistances).enumerated()), id: \.offset) { _, pair in
                            NeighborChip(label: pair.0, distance: pair.1)
                        }
                        Spacer()
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.mbPrimary.opacity(0.05)))
            }

            Divider().opacity(0.4)

            // ── Feedback section ──
            if feedbackGiven == nil {
                VStack(spacing: 10) {
                    Text(trickMode ? "What did the brain guess?" : "Did I get it right?")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text(trickMode
                         ? "You tried to fool it — ML models can't say \"I don't know\". They always pick the closest training example, even for nonsense input."
                         : "Your answer is fed back into the model as new training data.")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if trickMode {
                        // Trick mode: just one "Yep, I tricked it!" button
                        Button {
                            withAnimation { feedbackGiven = .tricked }
                            correctStreak = 0
                        } label: {
                            HStack(spacing: 8) {
                                Text("🎲")
                                Text("Yep, I drew something random!")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(Color.mbCoral)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.mbCoral.opacity(0.10))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.mbCoral.opacity(0.30), lineWidth: 1.5)))
                        }
                        .buttonStyle(.plain)
                    } else {
                        HStack(spacing: 12) {
                            FeedbackButton(title: "✓  Yes!", subtitle: "Add as correct example", isCorrect: true) {
                                submitFeedback(.correct, pred: pred, actualLabel: pred.label)
                            }
                            FeedbackButton(title: "✗  Nope", subtitle: "Tell me the right shape", isCorrect: false) {
                                submitFeedback(.wrong, pred: pred, actualLabel: nil)
                            }
                        }

                        // "Other" option for edge cases
                        Button {
                            withAnimation { feedbackGiven = .tricked }
                            correctStreak = 0
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "questionmark.circle")
                                    .font(.system(size: 12, weight: .bold))
                                Text("I drew something random / other")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity).frame(height: 38)
                            .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.5))
                                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else if feedbackGiven == .wrong {
                correctMePicker(pred)
            } else if feedbackGiven == .tricked {
                trickedBanner(pred)
            } else {
                feedbackBanner
            }
        }
        .padding(18)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 18)
    }

    // ── Confidence explainer ──
    private func confidenceExplainer(_ confidence: Double) -> some View {
        let (icon, message, color): (String, String, Color) = {
            switch confidence {
            case 0.85...: return ("checkmark.seal.fill",  "Very confident — most neighbours agreed.", .mbMint)
            case 0.60...: return ("questionmark.circle",  "Somewhat confident — a few neighbours disagreed.", .mbCoral)
            default:      return ("exclamationmark.triangle", "Low confidence — the neighbours were split. Try drawing more clearly, or add more training samples.", .mbCoral)
            }
        }()

        return HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(color)
            Text(message)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(color.opacity(0.07)))
    }

    private func correctMePicker(_ pred: KNNShapeModel.Prediction) -> some View {
        VStack(spacing: 10) {
            Text("What was it actually?")
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Text("This stroke will be saved as a training example with the correct label — improving future predictions.")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                ForEach(ShapeLabel.allCases, id: \.self) { label in
                    Button {
                        let features = FeatureExtractor.features(from: stroke)
                        store.addCorrectedSample(label: label, features: features)
                        withAnimation { feedbackGiven = .corrected }
                    } label: {
                        VStack(spacing: 4) {
                            Text(shapeEmoji(label)).font(.system(size: 22))
                            Text(label.rawValue.capitalized)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity).frame(height: 64)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(predictionColor(label).opacity(0.12))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(predictionColor(label).opacity(0.30), lineWidth: 1.5)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func trickedBanner(_ pred: KNNShapeModel.Prediction) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text("🎲")
                    .font(.system(size: 22))
                VStack(alignment: .leading, spacing: 2) {
                    Text("You fooled it… kind of!")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                    Text("The model still guessed \"\(pred.label?.rawValue.capitalized ?? "Unknown")\" with \(Int(pred.confidence * 100))% confidence.")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text("This reveals a key weakness of ML: models can't say \"I don't know.\" A k-NN classifier always finds the nearest neighbour — even if your input is total nonsense. In the real world, this is called an **out-of-distribution** problem, and it's why ML systems need careful validation before deployment.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.mbCoral.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.mbCoral.opacity(0.20), lineWidth: 1)))
    }

    private var feedbackBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: feedbackGiven == .correct ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(feedbackGiven == .correct ? Color.mbMint : Color.mbPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(feedbackGiven == .correct ? "Awesome! Streak +1" : "Feedback recorded!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text(feedbackGiven == .correct
                     ? "That stroke was saved — the brain remembers it next time."
                     : "Corrected stroke added to training data. The brain just got smarter.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill((feedbackGiven == .correct ? Color.mbMint : Color.mbPrimary).opacity(0.10)))
    }

    // MARK: - Actions

    private func runPrediction() {
        guard stroke.count >= 12, store.samples.count >= 3 else { return }

        withAnimation { isAnalyzing = true }

        // Small artificial delay so the "Thinking…" state is visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            let features = FeatureExtractor.features(from: stroke)
            let result = KNNShapeModel.predict(x: features, samples: store.samples)

            withAnimation(.spring(response: 0.45, dampingFraction: 0.78)) {
                isAnalyzing = false
                prediction = result
                phase = .result
                totalTested += 1
            }

            // Pulse the brain mascot
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) { pulseResult = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { pulseResult = false }
            }

            // Scroll to result card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { scrollProxy?.scrollTo("result", anchor: .top) }
            }
        }
    }

    private func submitFeedback(_ result: FeedbackResult, pred: KNNShapeModel.Prediction, actualLabel: ShapeLabel?) {
        withAnimation {
            feedbackGiven = result
            if result == .correct {
                correctStreak += 1
                store.recordCorrect()
            } else {
                correctStreak = 0
            }
        }
    }

    private func resetRound() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            stroke = []
            prediction = nil
            feedbackGiven = nil
            phase = .idle
            trickMode = false
        }
    }

    // MARK: - Helpers

    private func predictionColor(_ label: ShapeLabel?) -> Color {
        switch label {
        case .circle:   return .mbPrimary
        case .triangle: return .mbMint
        case .star:     return .mbCoral
        case nil:       return .secondary
        }
    }

    private func shapeEmoji(_ label: ShapeLabel?) -> String {
        switch label {
        case .circle:   return "⭕"
        case .triangle: return "🔺"
        case .star:     return "⭐"
        case nil:       return "❓"
        }
    }
}

// MARK: - Supporting Types

enum TestPhase { case idle, result }
enum FeedbackResult { case correct, wrong, corrected, tricked }

// MARK: - BrainStore extensions

extension BrainStore {
    nonisolated(unsafe) static var correctKey: UInt8 = 0
    nonisolated(unsafe) static var totalKey:   UInt8 = 0

    var correctCount: Int {
        get { objc_getAssociatedObject(self, &BrainStore.correctKey) as? Int ?? 0 }
        set { objc_setAssociatedObject(self, &BrainStore.correctKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }

    var testAccuracy: Double {
        let total   = objc_getAssociatedObject(self, &BrainStore.totalKey) as? Int ?? 0
        let correct = correctCount
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total)
    }

    func recordCorrect() {
        correctCount += 1
        let total = (objc_getAssociatedObject(self, &BrainStore.totalKey) as? Int ?? 0) + 1
        objc_setAssociatedObject(self, &BrainStore.totalKey, total, .OBJC_ASSOCIATION_RETAIN)
        xp += 15
    }

    func addCorrectedSample(label: ShapeLabel, features: [Double]) {
        samples.append(TrainingSample(label: label, features: features))
        xp += 20
    }
}

// MARK: - MLStep

struct MLStep: View {
    let number: String
    let icon: String
    let color: Color
    let title: String
    let detail: String
    let active: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(active ? 0.18 : 0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color.opacity(active ? 1.0 : 0.45))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(active ? .primary : .secondary)
                Text(detail)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(active ? color.opacity(0.06) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(active ? color.opacity(0.20) : Color.clear, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: active)
    }
}

// MARK: - Sub-components

struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).frame(height: 50)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(color.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 1)))
    }
}

struct ConfidenceRing: View {
    let confidence: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.14), lineWidth: 5)
            Circle()
                .trim(from: 0, to: confidence)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: confidence)
            Text("\(Int(confidence * 100))%")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
    }
}

struct NeighborChip: View {
    let label: ShapeLabel
    let distance: Double

    private var color: Color {
        switch label {
        case .circle:   return .mbPrimary
        case .triangle: return .mbMint
        case .star:     return .mbCoral
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color.opacity(0.80)).frame(width: 8, height: 8)
            Text(label.rawValue.capitalized)
                .font(.system(size: 11, weight: .bold, design: .rounded))
            Text(String(format: "d=%.2f", distance))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10).frame(height: 30)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(color.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(color.opacity(0.22), lineWidth: 1)))
    }
}

struct FeedbackButton: View {
    let title: String
    let subtitle: String
    let isCorrect: Bool
    let action: () -> Void

    @State private var pressed = false
    private var accent: Color { isCorrect ? .mbMint : .mbCoral }

    var body: some View {
        Button { action() } label: {
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
                Text(subtitle)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity).frame(height: 60)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(accent.opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(accent.opacity(0.30), lineWidth: 1.5)))
            .scaleEffect(pressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.03, pressing: { p in
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) { pressed = p }
        }, perform: {})
    }
}
