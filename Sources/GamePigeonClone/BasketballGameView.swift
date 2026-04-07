import SwiftUI

struct BasketballGameView: View {
    @StateObject private var model = BasketballGameModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Basketball")
                        .font(.title2.weight(.bold))
                    Text("Score a basket with one smooth swipe.")
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

            Text("Drag the ball backward, then release to shoot.")
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
                        LinearGradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(24)

                        VStack {
                            Spacer().frame(height: 40)

                            HStack {
                                Spacer()
                                HoopView()
                                    .frame(width: 160, height: 120)
                                Spacer()
                            }
                            Spacer()
                        }

                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)
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
                Text("Score: \(model.score)")
                    .font(.headline)
                Spacer()
                if model.hasScored {
                    Label("Nice shot!", systemImage: "star.fill")
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

private struct HoopView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange)
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.8))
                    .frame(height: 5)
            }
            .padding(.horizontal, 16)
        }
    }
}

private class BasketballGameModel: ObservableObject {
    @Published var ballPosition = CGPoint(x: 180, y: 460)
    @Published var ballVelocity = CGSize.zero
    @Published var aimTranslation = CGSize.zero
    @Published var aiming = false
    @Published var score = 0
    @Published var hasScored = false

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var isMoving: Bool {
        abs(ballVelocity.width) > 0.4 || abs(ballVelocity.height) > 0.4
    }

    var showAimLine: Bool {
        aiming && !isMoving && !hasScored
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
        } else {
            ballPosition = CGPoint(x: 180, y: 460)
        }
        ballVelocity = .zero
        aimTranslation = .zero
        aiming = false
        hasScored = false
    }

    func shoot(with translation: CGSize, in size: CGSize) {
        let capped = CGSize(width: max(-150, min(150, -translation.width)), height: max(-150, min(150, -translation.height)))
        ballVelocity = CGSize(width: capped.width * 0.12, height: capped.height * 0.12)
    }

    func update(in size: CGSize) {
        guard !hasScored else { return }
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

        let hoopCenter = CGPoint(x: size.width / 2, y: 80)
        let distance = hypot(ballPosition.x - hoopCenter.x, ballPosition.y - hoopCenter.y)
        if distance < 48 && ballVelocity.height < 1 {
            hasScored = true
            score += 1
            ballVelocity = .zero
        }
    }
}
