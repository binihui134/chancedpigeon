import SwiftUI

struct MiniGolfGameView: View {
    @StateObject private var model = MiniGolfGameModel()

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mini Golf")
                        .font(.title2.weight(.bold))
                    Text("Stroke count: \(model.strokeCount)")
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

            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 12)

                GeometryReader { geo in
                    let boardBounds = CGRect(origin: .zero, size: geo.size)
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.green.opacity(0.85), Color.green.opacity(0.65)], startPoint: .top, endPoint: .bottom))
                            .cornerRadius(24)

                        Circle()
                            .fill(Color.black.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .position(model.holePosition(in: geo.size))

                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .shadow(radius: 7)
                            .position(model.ballPosition)
                            .gesture(dragGesture(in: geo.size))

                        if model.showAimLine {
                            Path { path in
                                path.move(to: model.ballPosition)
                                path.addLine(to: model.aimTarget(in: geo.size))
                            }
                            .stroke(Color.white.opacity(0.8), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 6]))
                        }
                    }
                    .padding(24)
                    .onReceive(model.timer) { _ in
                        model.update(in: boardBounds)
                    }
                }
            }
            .frame(height: 520)
            .padding(.horizontal)

            if model.hasWon {
                VStack(spacing: 10) {
                    Text("Hole in one!")
                        .font(.title2.weight(.bold))
                    Text("You finished in \(model.strokeCount) strokes.")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(18)
                .padding(.horizontal)
            }

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
                model.aimDrag = value.translation
                model.ballPosition = model.ballPosition
            }
            .onEnded { value in
                guard !model.isMoving else { return }
                model.shoot(with: value.translation, in: size)
            }
    }
}

private class MiniGolfGameModel: ObservableObject {
    @Published var ballPosition = CGPoint(x: 190, y: 440)
    @Published var ballVelocity = CGSize.zero
    @Published var aimDrag = CGSize.zero
    @Published var aiming = false
    @Published var strokeCount = 0
    @Published var hasWon = false

    let timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    var isMoving: Bool {
        abs(ballVelocity.width) > 0.5 || abs(ballVelocity.height) > 0.5
    }

    var showAimLine: Bool {
        aiming && !isMoving && !hasWon
    }

    func holePosition(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * 0.82, y: size.height * 0.18)
    }

    func aimTarget(in size: CGSize) -> CGPoint {
        CGPoint(x: max(32, min(size.width - 32, ballPosition.x - aimDrag.width)),
                y: max(32, min(size.height - 32, ballPosition.y - aimDrag.height)))
    }

    func shoot(with translation: CGSize, in size: CGSize) {
        guard !hasWon else { return }
        aiming = false
        let capped = CGSize(width: max(-130, min(130, -translation.width)),
                            height: max(-130, min(130, -translation.height)))
        ballVelocity = CGSize(width: capped.width * 0.12, height: capped.height * 0.12)
        strokeCount += 1
        aimDrag = .zero
    }

    func update(in bounds: CGRect) {
        guard !hasWon else { return }
        ballPosition.x += ballVelocity.width
        ballPosition.y += ballVelocity.height

        ballVelocity.width *= 0.96
        ballVelocity.height *= 0.96

        if abs(ballVelocity.width) < 0.2 { ballVelocity.width = 0 }
        if abs(ballVelocity.height) < 0.2 { ballVelocity.height = 0 }

        let minX = bounds.minX + 32
        let maxX = bounds.maxX - 32
        let minY = bounds.minY + 32
        let maxY = bounds.maxY - 32

        if ballPosition.x < minX {
            ballPosition.x = minX
            ballVelocity.width *= -0.5
        }
        if ballPosition.x > maxX {
            ballPosition.x = maxX
            ballVelocity.width *= -0.5
        }
        if ballPosition.y < minY {
            ballPosition.y = minY
            ballVelocity.height *= -0.5
        }
        if ballPosition.y > maxY {
            ballPosition.y = maxY
            ballVelocity.height *= -0.5
        }

        let goal = holePosition(in: bounds.size)
        let distance = hypot(ballPosition.x - goal.x, ballPosition.y - goal.y)
        if distance < 24 {
            hasWon = true
            ballVelocity = .zero
            ballPosition = goal
        }
    }

    func reset() {
        ballPosition = CGPoint(x: 90, y: 420)
        ballVelocity = .zero
        aimDrag = .zero
        aiming = false
        strokeCount = 0
        hasWon = false
    }
}

struct MiniGolfGameView_Previews: PreviewProvider {
    static var previews: some View {
        MiniGolfGameView()
    }
}
