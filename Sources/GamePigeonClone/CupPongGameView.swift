import SwiftUI

struct CupPongGameView: View {
    @StateObject private var model = CupPongGameModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cup Pong")
                        .font(.title2.weight(.bold))
                    Text("Sink the ball into one of the cups.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: model.reset) {
                    Label("Restart", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)

            Text("Drag the ball backward and release to aim for the cups.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 12)

                GeometryReader { geo in
                    let size = geo.size
                    ZStack {
                        LinearGradient(colors: [Color.green.opacity(0.92), Color.green.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(24)

                        ForEach(model.cupCenters, id: \ .self) { center in
                            CupView()
                                .position(center)
                        }

                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(radius: 8)
                            .position(model.ballPosition)
                            .gesture(dragGesture(in: size))

                        if model.showAimLine {
                            Path { path in
                                path.move(to: model.ballPosition)
                                path.addLine(to: model.aimTarget(in: size))
                            }
                            .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 6]))
                        }
                    }
                    .padding(24)
                    .onAppear { model.reset(size: size) }
                    .onReceive(model.timer) { _ in model.update(in: size) }
                }
            }
            .frame(height: 520)
            .padding(.horizontal)

            HStack {
                Text("Hits: \(model.hits)")
                    .font(.headline)
                Spacer()
                if model.didScore {
                    Label("Sunk!", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .background(Color.black.opacity(0.95)).ignoresSafeArea()
    }

    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !model.isMoving else { return }
                model.aiming = true
                model.aimTranslation = value.translation
            }
            .onEnded { value in
                guard !model.isMoving else { return }
                model.aiming = false
                model.shoot(with: value.translation, in: size)
            }
    }
}

private struct CupView: View {
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.88))
            .frame(width: 56, height: 56)
            .overlay(
                Circle()
                    .stroke(Color.orange, lineWidth: 4)
            )
            .shadow(radius: 4)
    }
}

private class CupPongGameModel: ObservableObject {
    @Published var ballPosition = CGPoint(x: 180, y: 460)
    @Published var ballVelocity = CGSize.zero
    @Published var aimTranslation = CGSize.zero
    @Published var aiming = false
    @Published var hits = 0
    @Published var didScore = false
    @Published var cupCenters: [CGPoint] = []

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var isMoving: Bool {
        abs(ballVelocity.width) > 0.4 || abs(ballVelocity.height) > 0.4
    }

    var showAimLine: Bool {
        aiming && !isMoving && !didScore
    }

    func aimTarget(in size: CGSize) -> CGPoint {
        CGPoint(
            x: max(32, min(size.width - 32, ballPosition.x - aimTranslation.width)),
            y: max(32, min(size.height - 32, ballPosition.y - aimTranslation.height))
        )
    }

    func reset(size: CGSize? = nil) {
        if let size = size {
            ballPosition = CGPoint(x: size.width / 2, y: size.height - 70)
            cupCenters = [
                CGPoint(x: size.width * 0.28, y: 120),
                CGPoint(x: size.width * 0.50, y: 80),
                CGPoint(x: size.width * 0.72, y: 120)
            ]
        } else {
            ballPosition = CGPoint(x: 180, y: 460)
            cupCenters = [CGPoint(x: 100, y: 120), CGPoint(x: 180, y: 80), CGPoint(x: 260, y: 120)]
        }
        ballVelocity = .zero
        aimTranslation = .zero
        aiming = false
        hits = 0
        didScore = false
    }

    func shoot(with translation: CGSize, in size: CGSize) {
        let capped = CGSize(width: max(-140, min(140, -translation.width)), height: max(-140, min(140, -translation.height)))
        ballVelocity = CGSize(width: capped.width * 0.10, height: capped.height * 0.10)
    }

    func update(in size: CGSize) {
        guard !didScore else { return }
        ballPosition.x += ballVelocity.width
        ballPosition.y += ballVelocity.height

        ballVelocity.width *= 0.98
        ballVelocity.height *= 0.98

        if abs(ballVelocity.width) < 0.3 { ballVelocity.width = 0 }
        if abs(ballVelocity.height) < 0.3 { ballVelocity.height = 0 }

        if ballPosition.x < 32 { ballPosition.x = 32; ballVelocity.width *= -0.4 }
        if ballPosition.x > size.width - 32 { ballPosition.x = size.width - 32; ballVelocity.width *= -0.4 }
        if ballPosition.y < 32 { ballPosition.y = 32; ballVelocity.height *= -0.6 }
        if ballPosition.y > size.height - 32 { ballPosition.y = size.height - 32; ballVelocity.height = 0; ballVelocity.width = 0 }

        for cup in cupCenters {
            let distance = hypot(ballPosition.x - cup.x, ballPosition.y - cup.y)
            if distance < 30 {
                didScore = true
                hits += 1
                ballVelocity = .zero
                break
            }
        }
    }
}
