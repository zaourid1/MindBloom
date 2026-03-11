/*
 CONTENT VIEW - home page, main view of MindBloom

Author: Zineb Aourid
Feb. 2026
 */

import SwiftUI

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var phase: Double = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                // Base gradient
                let baseGrad = Gradient(stops: [
                    .init(color: Color(red: 0.96, green: 0.94, blue: 1.00), location: 0.00),
                    .init(color: Color(red: 0.91, green: 0.88, blue: 1.00), location: 0.35),
                    .init(color: Color(red: 0.86, green: 0.94, blue: 0.99), location: 0.70),
                    .init(color: Color(red: 0.93, green: 0.98, blue: 1.00), location: 1.00),
                ])
                context.fill(
                    Path(CGRect(origin: .zero, size: size)),
                    with: .linearGradient(
                        baseGrad,
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: size.width, y: size.height)
                    )
                )

                // Dreamy floating orbs
                let orbs: [(cx: Double, cy: Double, r: Double, color: Color, speed: Double, phase: Double)] = [
                    (0.25, 0.20, 280, Color(red: 0.70, green: 0.55, blue: 1.00), 0.08, 0.0),
                    (0.78, 0.35, 240, Color(red: 0.50, green: 0.75, blue: 1.00), 0.07, 1.2),
                    (0.55, 0.75, 300, Color(red: 0.85, green: 0.60, blue: 1.00), 0.06, 2.4),
                    (0.10, 0.65, 200, Color(red: 0.55, green: 0.85, blue: 0.90), 0.09, 0.8),
                    (0.88, 0.80, 180, Color(red: 0.95, green: 0.70, blue: 0.85), 0.07, 3.1),
                ]

                for orb in orbs {
                    let dx = sin(t * orb.speed + orb.phase) * 40
                    let dy = cos(t * orb.speed * 0.8 + orb.phase + 1.0) * 30
                    let cx = orb.cx * size.width + dx
                    let cy = orb.cy * size.height + dy
                    let r = orb.r
                    context.fill(
                        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                        with: .radialGradient(
                            Gradient(stops: [
                                .init(color: orb.color.opacity(0.26), location: 0),
                                .init(color: orb.color.opacity(0.0), location: 1),
                            ]),
                            center: CGPoint(x: cx, y: cy),
                            startRadius: 0,
                            endRadius: r
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Brainy Speech Bubble

struct BrainySpeech: View {
    let text: String
    var fontSize: CGFloat = 15

    @State private var visible = false
    @State private var wobble = false

    var body: some View {
        VStack(spacing: 0) {
            // Bubble tail (pointing up toward brain)
            Triangle()
                .fill(.white.opacity(0.88))
                .frame(width: 18, height: 10)
                .shadow(color: Color.mbGlow.opacity(0.10), radius: 2, x: 0, y: -1)

            // Bubble body
            Text(text)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.mbPrimary, Color.mbPrimary2],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.88))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.mbGlow.opacity(0.40), Color.mbPrimary2.opacity(0.20)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.2
                                )
                        )
                        .shadow(color: Color.mbGlow.opacity(0.18), radius: 14, x: 0, y: 6)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
        }
        .rotationEffect(.degrees(wobble ? -1.2 : 1.0))
        .scaleEffect(visible ? 1.0 : 0.72)
        .opacity(visible ? 1.0 : 0.0)
        .animation(.spring(response: 0.55, dampingFraction: 0.70).delay(0.3), value: visible)
        .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: wobble)
        .onAppear {
            visible = true
            wobble = true
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

// MARK: - About Popup

struct AboutPopup: View {
    @Binding var isShowing: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isShowing = false } }

            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.mbPrimary, Color.mbPrimary2],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 42, height: 42)
                        Image(systemName: "sparkles")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("What is MindBloom?")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("Your AI intuition trainer")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.mbPrimary)
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isShowing = false }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.black.opacity(0.07)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 16)

                Divider().opacity(0.4)
                    .padding(.bottom, 14)

                VStack(alignment: .leading, spacing: 12) {
                    AboutRow(icon: "pencil.and.outline", color: Color.mbPrimary,
                             text: "Draw examples to teach your brain to recognize shapes and patterns.")
                    AboutRow(icon: "brain.head.profile", color: Color.mbMint,
                             text: "Test it with new drawings and watch it predict in real time.")
                    AboutRow(icon: "point.3.connected.trianglepath.dotted", color: Color.mbCoral,
                             text: "Explore each step: from raw data to features, model weights, and final prediction.")
                    AboutRow(icon: "arrow.up.heart", color: Color.mbGlow,
                             text: "Earn XP as you train. Watch your brain mascot evolve through four growth levels.")
                }

                Divider().opacity(0.4)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                Text("AI isn't magic — it's math. MindBloom makes that click.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                    )
                    .shadow(color: Color.mbPrimary.opacity(0.14), radius: 40, x: 0, y: 16)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
            )
            .padding(.horizontal, 26)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.88).combined(with: .opacity),
                removal: .scale(scale: 0.92).combined(with: .opacity)
            ))
        }
    }
}

struct AboutRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.14))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.primary.opacity(0.80))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @ObservedObject var store: BrainStore

    var onTrain: () -> Void = {}
    var onTest: () -> Void = {}
    var onExplore: () -> Void = {}

    @State private var showAbout = false

    var body: some View {
        ZStack {
            // Animated dreamy background — full height
            AnimatedGradientBackground()
                .ignoresSafeArea()

            GrainOverlay()
                .opacity(0.06)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            GeometryReader { geo in
                let isPad      = geo.size.width >= 700
                let isPortrait = geo.size.height > geo.size.width
                let hPad: CGFloat   = isPad ? (isPortrait ? 16 : 28) : 18
                let vPad: CGFloat   = isPad ? 22 : 18
                let colGap: CGFloat = isPortrait ? 14 : 22
                let sidebarW: CGFloat = isPad
                    ? min(isPortrait ? 300 : 400,
                          geo.size.width * (isPortrait ? 0.44 : 0.40))
                    : 0

                if isPad {
                    // Let SwiftUI own the sizing — the hero column gets all
                    // remaining space via maxWidth/maxHeight: .infinity.
                    // A nested GeometryReader passes the EXACT resolved size
                    // into gameHeroWorld so nothing is computed by hand.
                    HStack(alignment: .top, spacing: colGap) {

                        GeometryReader { heroGeo in
                            gameHeroWorld(size: heroGeo.size)
                        }
                        // .infinity makes it take all space the HStack leaves
                        // after the sidebar; no manual heroWidth calculation.
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14) {
                                header
                                featureButtons
                                progressCard
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 26)
                        }
                        .frame(width: sidebarW)
                        // Clip sidebar so it never pushes taller than its column
                        .clipped()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, hPad)
                    .padding(.vertical, vPad)

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 18) {
                            header
                            mascotHero
                            progressCard
                            featureButtons
                        }
                        .padding(.horizontal, hPad)
                        .padding(.top, vPad)
                        .padding(.bottom, 32)
                    }
                }
            }
            // Give the GeometryReader the full screen including safe areas
            .ignoresSafeArea(edges: .bottom)

            // Popup overlay
            if showAbout {
                AboutPopup(isShowing: $showAbout)
                    .zIndex(100)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: showAbout)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .center, spacing: 6) {
                Text("MindBloom")
                    .font(.system(size: 35, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.mbPrimary, Color.mbPrimary2],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                Text("Grow your own AI intuition! Help Brainy Learn.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(20)
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.80)) {
                    showAbout = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.mbPrimary.opacity(0.18), Color.mbPrimary2.opacity(0.12)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.mbPrimary.opacity(0.55), Color.mbPrimary2.opacity(0.35)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.mbPrimary, Color.mbPrimary2],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: Color.mbPrimary.opacity(0.20), radius: 10, x: 0, y: 6)
            }
            .buttonStyle(.plain)
        }
    }

    private var mascotHero: some View {
        VStack(spacing: 0) {
            ZStack {
                // Outer dreamy halo
                Circle()
                    .fill(RadialGradient(
                        colors: [Color.mbGlow.opacity(0.32), Color.mbPrimary2.opacity(0.14), Color.clear],
                        center: .center, startRadius: 10, endRadius: 185
                    ))
                    .frame(width: 370, height: 370)
                    .blur(radius: 4)

                // Inner soft glow ring
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [Color.mbGlow.opacity(0.30), Color.mbMint.opacity(0.20), Color.mbPrimary2.opacity(0.25), Color.mbGlow.opacity(0.30)],
                            center: .center
                        ),
                        lineWidth: 1
                    )
                    .frame(width: 270, height: 270)
                    .blur(radius: 1)

                BrainMascotView(level: store.level)
                    .frame(width: 220, height: 220)
                    .shadow(color: Color.mbGlow.opacity(0.25), radius: 28, x: 0, y: 12)
                    .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 14)

                OrbitSparkles(orbitRadius: 120)
                    .frame(width: 250, height: 250)
                    .allowsHitTesting(false)

                // Ground shadow
                Ellipse()
                    .fill(Color.mbGlow.opacity(0.10))
                    .frame(width: 160, height: 22)
                    .blur(radius: 10)
                    .offset(y: 96)
            }

            BrainySpeech(text: "Hey, I'm Brainy!\nHelp me learn shapes 🧠✨", fontSize: 15)
                .padding(.horizontal, 32)
                .padding(.top, 2)
        }
        .padding(.top, 6)
        .padding(.bottom, 2)
    }

    private func gameHeroWorld(size: CGSize) -> some View {
        // Scale everything relative to the smaller dimension so nothing overflows
        // in either portrait OR landscape — previously only height was accounted for.
        let unit = min(size.width, size.height)
        let brainSize      = unit * 0.52
        let innerGlowSize  = unit * 0.74
        let orbitSize      = unit * 0.64
        let outerHaloSize  = unit * 1.10
        let ringSize       = unit * 0.76
        let orbitRadius    = orbitSize * 0.50
        let shadowYOffset  = brainSize * 0.42

        return ZStack {
            // Atmospheric outer halo
            Circle()
                .fill(RadialGradient(
                    colors: [Color.mbGlow.opacity(0.20), Color.mbPrimary2.opacity(0.10), .clear],
                    center: .center, startRadius: 20, endRadius: outerHaloSize / 2
                ))
                .frame(width: outerHaloSize, height: outerHaloSize)
                .blur(radius: 4)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [Color.mbGlow.opacity(0.22), Color.mbMint.opacity(0.14),
                                 Color.mbPrimary2.opacity(0.20), Color.mbGlow.opacity(0.22)],
                        center: .center
                    ),
                    lineWidth: 1
                )
                .frame(width: ringSize, height: ringSize)
                .blur(radius: 1.5)

            SoftParticles()
                .opacity(0.28)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color.mbGlow.opacity(0.16), .clear],
                            center: .center, startRadius: 8, endRadius: innerGlowSize / 2
                        ))
                        .frame(width: innerGlowSize, height: innerGlowSize)
                        .blur(radius: 2)

                    BrainMascotView(level: store.level)
                        .frame(width: brainSize, height: brainSize)
                        .shadow(color: Color.mbGlow.opacity(0.28), radius: 36, x: 0, y: 10)
                        .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 14)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                store.xp += 10
                            }
                        }

                    OrbitSparkles(orbitRadius: orbitRadius)
                        .frame(width: orbitSize, height: orbitSize)
                        .opacity(0.35)
                        .allowsHitTesting(false)

                    Ellipse()
                        .fill(Color.mbGlow.opacity(0.12))
                        .frame(width: brainSize * 0.75, height: 34)
                        .blur(radius: 14)
                        .offset(y: shadowYOffset)
                }

                BrainySpeech(
                    text: "Hey, I'm Brainy!\nHelp me learn shapes 🧠✨",
                    fontSize: min(16, unit * 0.038)
                )
                .frame(maxWidth: min(320, unit * 0.72))
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .overlay(
            RadialGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.07)],
                center: .center, startRadius: 10, endRadius: 900
            )
            .blendMode(.multiply)
        )
    }

    private var progressCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Brain Growth")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(store.level.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(store.xp) XP")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.mbPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.mbPrimary.opacity(0.14)))
            }

            ProgressView(value: store.progress)
                .tint(
                    LinearGradient(
                        colors: [Color.mbPrimary, Color.mbPrimary2],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .scaleEffect(x: 1, y: 1.35, anchor: .center)

            HStack {
                Text("Feed it examples to grow.")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        store.xp += 30
                    }
                } label: {
                    Text("Quick +XP")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.mbPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Color.mbPrimary.opacity(0.10))
                                .overlay(Capsule().stroke(Color.mbPrimary.opacity(0.25), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.74))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.90), Color.mbGlow.opacity(0.20)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.mbPrimary.opacity(0.08), radius: 20, x: 0, y: 8)
                .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }

    private var featureButtons: some View {
        VStack(spacing: 14) {
            FeatureButton(
                title: "Train",
                subtitle: "Draw examples and feed your brain data",
                icon: "pencil.and.outline",
                gradient: [Color.mbPrimary, Color.mbPrimary2],
                action: onTrain
            )
            FeatureButton(
                title: "Test",
                subtitle: "Draw something new — can it predict?",
                icon: "brain.head.profile",
                gradient: [Color.mbMint, Color.mbMint2],
                action: onTest
            )
            FeatureButton(
                title: "Explore",
                subtitle: "Tap through: Data → Features → Model → Prediction",
                icon: "point.3.connected.trianglepath.dotted",
                gradient: [Color.mbCoral, Color.mbCoral2],
                action: onExplore
            )
        }
        .padding(.top, 6)
    }
}

// MARK: - GrowthLevel

enum GrowthLevel: Int, CaseIterable {
    case seed, sprout, bloom, radiance

    var title: String {
        switch self {
        case .seed:      return "Seed Brain (just born)"
        case .sprout:    return "Sprout Brain (spotting patterns)"
        case .bloom:     return "Bloom Brain (getting confident)"
        case .radiance:  return "Radiant Brain (near mastery)"
        }
    }

    static func forProgress(_ p: Double) -> GrowthLevel {
        if p < 0.25 { return .seed }
        if p < 0.60 { return .sprout }
        if p < 0.90 { return .bloom }
        return .radiance
    }
}

// MARK: - FeatureButton

struct FeatureButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button { action() } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                        .shadow(color: gradient.first?.opacity(0.35) ?? .clear, radius: 12, x: 0, y: 8)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.76))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.90), gradient.first?.opacity(0.18) ?? .clear],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: gradient.first?.opacity(0.10) ?? .clear, radius: 16, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.985 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.03, pressing: { pressing in
            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) { isPressed = pressing }
        }, perform: {})
    }
}

// MARK: - BrainMascotView

struct BrainMascotView: View {
    let level: GrowthLevel

    @State private var float = false
    @State private var blink = false

    // All four level-driven values in one place
    private var levelProps: (scale: CGFloat, glowOpacity: Double, foldsOpacity: Double, crownIntensity: Double) {
        switch level {
        case .seed:      return (0.86, 0.12, 0.12, 0.0)
        case .sprout:    return (0.98, 0.18, 0.30, 0.4)
        case .bloom:     return (1.06, 0.26, 0.42, 0.7)
        case .radiance:  return (1.12, 0.34, 0.55, 1.0)
        }
    }

    var body: some View {
        let p = levelProps
        ZStack {
            BrainShape()
                .fill(Color.mbGlow.opacity(p.glowOpacity))
                .blur(radius: 14)
                .scaleEffect(1.05)

            BrainShape()
                .fill(LinearGradient(
                    colors: [Color.mbBrainTop, Color.mbBrainBottom],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .overlay(BrainShape().stroke(.white.opacity(0.55), lineWidth: 2).blendMode(.overlay))

            BrainFolds()
                .stroke(Color.white.opacity(0.40), lineWidth: 3)
                .blendMode(.overlay)
                .padding(26)
                .opacity(p.foldsOpacity)

            HStack(spacing: 28) {
                Eye(blink: blink)
                Eye(blink: blink)
            }
            .offset(y: 18)

            if level != .seed {
                SparkleCrown(intensity: p.crownIntensity)
                    .offset(y: -70)
            }
        }
        .scaleEffect(p.scale)
        .offset(y: float ? -8 : 8)
        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: float)
        .onAppear {
            float = true
            Task {
                while true {
                    try? await Task.sleep(nanoseconds: 2_200_000_000)
                    withAnimation(.easeInOut(duration: 0.10)) { blink = true }
                    try? await Task.sleep(nanoseconds: 140_000_000)
                    withAnimation(.easeInOut(duration: 0.12)) { blink = false }
                }
            }
        }
    }
}

// MARK: - Shapes

struct BrainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0.50*w, y: 0.10*h))
        p.addCurve(to: CGPoint(x: 0.90*w, y: 0.36*h),
                   control1: CGPoint(x: 0.72*w, y: 0.02*h),
                   control2: CGPoint(x: 0.96*w, y: 0.18*h))
        p.addCurve(to: CGPoint(x: 0.82*w, y: 0.78*h),
                   control1: CGPoint(x: 0.96*w, y: 0.56*h),
                   control2: CGPoint(x: 0.92*w, y: 0.78*h))
        p.addCurve(to: CGPoint(x: 0.50*w, y: 0.92*h),
                   control1: CGPoint(x: 0.72*w, y: 0.95*h),
                   control2: CGPoint(x: 0.56*w, y: 0.96*h))
        p.addCurve(to: CGPoint(x: 0.18*w, y: 0.78*h),
                   control1: CGPoint(x: 0.44*w, y: 0.96*h),
                   control2: CGPoint(x: 0.28*w, y: 0.95*h))
        p.addCurve(to: CGPoint(x: 0.10*w, y: 0.36*h),
                   control1: CGPoint(x: 0.08*w, y: 0.78*h),
                   control2: CGPoint(x: 0.04*w, y: 0.56*h))
        p.addCurve(to: CGPoint(x: 0.50*w, y: 0.10*h),
                   control1: CGPoint(x: 0.04*w, y: 0.18*h),
                   control2: CGPoint(x: 0.28*w, y: 0.02*h))
        p.closeSubpath()
        return p
    }
}

struct BrainFolds: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        p.move(to: CGPoint(x: 0.18*w, y: 0.40*h))
        p.addCurve(to: CGPoint(x: 0.52*w, y: 0.30*h),
                   control1: CGPoint(x: 0.28*w, y: 0.18*h),
                   control2: CGPoint(x: 0.42*w, y: 0.18*h))
        p.move(to: CGPoint(x: 0.26*w, y: 0.62*h))
        p.addCurve(to: CGPoint(x: 0.58*w, y: 0.54*h),
                   control1: CGPoint(x: 0.34*w, y: 0.46*h),
                   control2: CGPoint(x: 0.52*w, y: 0.46*h))
        p.move(to: CGPoint(x: 0.54*w, y: 0.42*h))
        p.addCurve(to: CGPoint(x: 0.84*w, y: 0.50*h),
                   control1: CGPoint(x: 0.64*w, y: 0.28*h),
                   control2: CGPoint(x: 0.82*w, y: 0.30*h))
        p.move(to: CGPoint(x: 0.50*w, y: 0.70*h))
        p.addCurve(to: CGPoint(x: 0.82*w, y: 0.72*h),
                   control1: CGPoint(x: 0.62*w, y: 0.62*h),
                   control2: CGPoint(x: 0.76*w, y: 0.62*h))
        return p
    }
}

// MARK: - Decorative Views

struct Eye: View {
    let blink: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(.white.opacity(0.85))
                .frame(width: 34, height: 22)
                .overlay(Capsule().stroke(.white.opacity(0.55), lineWidth: 1))

            Circle()
                .fill(Color.black.opacity(0.80))
                .frame(width: 10, height: 10)
                .offset(y: blink ? 7 : 0)
                .scaleEffect(blink ? 0.1 : 1.0)
                .animation(.easeInOut(duration: 0.10), value: blink)
        }
        .scaleEffect(y: blink ? 0.22 : 1.0)
        .animation(.easeInOut(duration: 0.10), value: blink)
    }
}

struct SparkleCrown: View {
    let intensity: Double
    @State private var spin = false

    var body: some View {
        ZStack {
            ForEach(0..<6) { i in
                Image(systemName: "sparkle")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.mbGlow.opacity(0.9))
                    .offset(x: 0, y: -26)
                    .rotationEffect(.degrees(Double(i) * 60))
            }
        }
        .opacity(0.25 + 0.55 * intensity)
        .rotationEffect(.degrees(spin ? 360 : 0))
        .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: spin)
        .onAppear { spin = true }
    }
}

struct OrbitSparkles: View {
    var orbitRadius: CGFloat = 120
    @State private var t = false

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.10), lineWidth: 1)
            ForEach(0..<5) { i in
                Circle()
                    .fill(Color.white.opacity(0.65))
                    .frame(width: 5, height: 5)
                    .offset(x: 0, y: -orbitRadius)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
        }
        .rotationEffect(.degrees(t ? 360 : 0))
        .animation(.linear(duration: 16).repeatForever(autoreverses: false), value: t)
        .onAppear { t = true }
    }
}

struct GrainOverlay: View {
    var body: some View {
        Canvas { context, size in
            let count = Int((size.width * size.height) / 1800)
            for _ in 0..<count {
                let x = Double.random(in: 0..<Double(size.width))
                let y = Double.random(in: 0..<Double(size.height))
                let r = Double.random(in: 0.4...1.2)
                let color = Color.black.opacity(Double.random(in: 0.05...0.16))
                context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)), with: .color(color))
            }
        }
        .blendMode(.overlay)
    }
}

struct SoftParticles: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let count = Int((size.width * size.height) / 24000)
                for i in 0..<count {
                    let seed = CGFloat(i) * 37.0
                    var rngX = PseudoRandom(seed: seed)
                    var rngY = PseudoRandom(seed: seed + 11)
                    var rngR = PseudoRandom(seed: seed + 23)
                    var rngA = PseudoRandom(seed: seed + 29)
                    let x = CGFloat.random(in: 0...size.width, using: &rngX)
                    let y = CGFloat.random(in: 0...size.height, using: &rngY)
                    let dx = CGFloat(sin(t * 0.12 + Double(seed) * 0.02)) * 8
                    let dy = CGFloat(cos(t * 0.10 + Double(seed) * 0.015)) * 8
                    let r = CGFloat.random(in: 0.8...1.8, using: &rngR)
                    let color = Color.white.opacity(Double.random(in: 0.05...0.18, using: &rngA))
                    context.fill(Path(ellipseIn: CGRect(x: x + dx, y: y + dy, width: r, height: r)), with: .color(color))
                }
            }
        }
    }
}

// MARK: - Utilities

private struct PseudoRandom: RandomNumberGenerator {
    private var state: UInt64
    init(seed: CGFloat) { self.state = UInt64(bitPattern: Int64(seed * 10_000)) ^ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

// MARK: - Colors

extension Color {
    static let mbBackgroundTop    = Color(red: 1,    green: 0.992, blue: 0.968)
    static let mbBackgroundBottom = Color(red: 0.94, green: 0.98,  blue: 0.99)
    static let mbPrimary          = Color(red: 0.43, green: 0.33,  blue: 0.95)
    static let mbPrimary2         = Color(red: 0.70, green: 0.34,  blue: 0.92)
    static let mbMint             = Color(red: 0.22, green: 0.78,  blue: 0.62)
    static let mbMint2            = Color(red: 0.12, green: 0.64,  blue: 0.86)
    static let mbCoral            = Color(red: 0.98, green: 0.49,  blue: 0.52)
    static let mbCoral2           = Color(red: 0.98, green: 0.72,  blue: 0.44)
    static let mbBrainTop         = Color(red: 0.98, green: 0.90,  blue: 0.98)
    static let mbBrainBottom      = Color(red: 0.88, green: 0.80,  blue: 1.00)
    static let mbGlow             = Color(red: 0.70, green: 0.55,  blue: 1.00)
}
