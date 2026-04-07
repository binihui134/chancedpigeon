import SwiftUI

struct ContentView: View {
    @State private var selectedGame: GameType? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Game Pigeon Clone")
                        .font(.largeTitle.weight(.bold))
                    Text("A collection of classic party games inspired by GamePigeon.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                GameSelectionView(selectedGame: $selectedGame)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .background(Color.black.opacity(0.95)).ignoresSafeArea()
            .navigationTitle("Games")
            .navigationViewStyle(.stack)
            .sheet(item: $selectedGame) { game in
                switch game {
                case .miniGolf:
                    MiniGolfGameView()
                case .basketball:
                    BasketballGameView()
                case .cupPong:
                    CupPongGameView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
