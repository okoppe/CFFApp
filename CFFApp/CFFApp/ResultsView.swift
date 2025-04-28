import SwiftUI

struct ResultsView: View {
    var frequencies: [Double]
    var median: Double

    var body: some View {
        VStack(spacing: 20) {
            Text("Test Completed")
                .font(.largeTitle)
                .padding()

            ForEach(frequencies.indices, id: \.self) { index in
                Text("Test \(index + 1): \(String(format: "%.2f", frequencies[index])) Hz")
                    .font(.title2)
            }

            Divider()

            Text("Median Frequency:")
                .font(.title2)
            Text("\(String(format: "%.2f", median)) Hz")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.blue)

            NavigationLink(destination: ContentView()) {
                Text("Retry Test")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

