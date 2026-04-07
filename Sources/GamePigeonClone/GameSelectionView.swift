import SwiftUI

enum GameType: String, Identifiable, CaseIterable {
    case miniGolf = "Mini Golf"
    case basketball = "Basketball"
    case cupPong = "Cup Pong"

    var id: String { rawValue }
    var subtitle: String {
        switch self {
        case .miniGolf:
            return "Drag the ball to the hole in a relaxing mini golf round."
        case .basketball:
            return "Swipe to launch a shot through the hoop."
        case .cupPong:
            return "Aim for the cups and sink the ball." 
        }
    }
    var accent: Color {
        switch self {
        case .miniGolf:
            return Color.green
        case .basketball:
            return Color.orange
        case .cupPong:
            return Color.blue
        }
    }
    var systemImage: String {
        switch self {
        case .miniGolf:
            return "flag.checkered"
        case .basketball:
            return "sportscourt.fill"
        case .cupPong:
            return "cup.and.saucer.fill"
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
                                Image(systemName: game.systemImage)
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
