import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Flashing Light Test")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink(destination: FlashingTestView()) {
                    Text("Begin Test")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
//            .toolbar(.hidden, for: .navigationBar) // Hides navigation bar (removes back buttons)
        }
    }
}
