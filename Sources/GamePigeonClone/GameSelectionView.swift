import SwiftUI

enum GameType: String, Identifiable, CaseIterable {
    case miniGolf = "Mini Golf"

    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .miniGolf:
            return "Tap and drag to shoot your ball toward the hole."
        }
    }
    var accent: Color {
        switch self {
        case .miniGolf:
            return Color.green
        }
    }
}

struct GameSelectionView: View {
    @Binding var selectedGame: GameType?

    var body: some View {
        VStack(spacing: 16) {
            ForEach(GameType.allCases) { game in
                Button {
                    selectedGame = game
                } label: {
                    HStack(alignment: .top, spacing: 16) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(game.accent.opacity(0.2))
                            .frame(width: 72, height: 72)
                            .overlay(
                                Image(systemName: "flag.checkered")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(game.accent)
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(game.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(game.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground).opacity(0.14))
                    .cornerRadius(18)
                }
            }
        }
    }
}

struct GameSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GameSelectionView(selectedGame: .constant(.miniGolf))
            .padding()
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
