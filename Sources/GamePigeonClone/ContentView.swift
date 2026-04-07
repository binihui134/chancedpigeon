import SwiftUI

struct ContentView: View {
    @State private var selectedGame: GameType? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chanced Pigeon")
                        .font(.largeTitle.weight(.bold))
                    Text("A GamePigeon-style party game launcher")
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
            .sheet(item: $selectedGame) { game in
                switch game {
                case .miniGolf:
                    MiniGolfGameView()
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
