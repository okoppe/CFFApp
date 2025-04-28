import SwiftUI
import SpriteKit

class FlashingManager: ObservableObject {
    @Published var scene: FlashingScene?
    @Published var detectedFrequencies: [Double] = []
    
    var currentTestCount = 0
    let totalTests = 7
    
    func startFlashing() {
        let newScene = FlashingScene(size: CGSize(width: 400, height: 400))
        newScene.scaleMode = .aspectFill
        self.scene = newScene

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scene?.isPaused = false
            self.scene?.startFlashing()
        }
    }

    func stopFlashing() {
        scene?.isPaused = true
        if let finalInterval = scene?.currentPulseInterval {
            let frequency = 1.0 / finalInterval
            detectedFrequencies.append(frequency)
        }
    }

    var isTestComplete: Bool {
        return detectedFrequencies.count >= totalTests
    }

    var medianFrequency: Double {
        guard !detectedFrequencies.isEmpty else { return 0.0 }
        let sorted = detectedFrequencies.sorted()
        let mid = sorted.count / 2

        if sorted.count % 2 == 0 {
            // If even, average the two middle elements
            return (sorted[mid - 1] + sorted[mid]) / 2
        } else {
            // If odd, return the middle element
            return sorted[mid]
        }
    }
}

class FlashingScene: SKScene {
    private var firstCircle: SKShapeNode?
    private var secondCircle: SKShapeNode?
    private var pulseSpeedFactor: Double = 0.992
    private let minPulseInterval: Double = 1.0 / 60.0
    var currentPulseInterval: Double = 0.3

    override func didMove(to view: SKView) {
        let radius: CGFloat = 80
        let spacing: CGFloat = 200

        firstCircle = SKShapeNode(circleOfRadius: radius)
        firstCircle?.fillColor = .white
        firstCircle?.position = CGPoint(x: size.width / 2 - spacing / 2, y: size.height / 2)
        if let firstCircle = firstCircle {
            addChild(firstCircle)
        }

        secondCircle = SKShapeNode(circleOfRadius: radius)
        secondCircle?.fillColor = .white
        secondCircle?.position = CGPoint(x: size.width / 2 + spacing / 2, y: size.height / 2)
        if let secondCircle = secondCircle {
            addChild(secondCircle)
        }

        startFlashing()
    }

    func startFlashing() {
        guard firstCircle != nil, secondCircle != nil else {
            print("Error: Circles not initialized before flashing started.")
            return
        }
        flashCycle()
    }

    private func flashCycle() {
        guard let firstCircle = firstCircle, let secondCircle = secondCircle, !isPaused else { return }

        let setInvisible = SKAction.run { firstCircle.alpha = 0.0 }
        let waitInvisible = SKAction.wait(forDuration: currentPulseInterval / 2)
        let setVisible = SKAction.run { firstCircle.alpha = 1.0 }
        let waitVisible = SKAction.wait(forDuration: currentPulseInterval / 2)

        let pulseSequence = SKAction.sequence([setInvisible, waitInvisible, setVisible, waitVisible])
        firstCircle.run(pulseSequence) {
            self.updatePulseSpeed()
            self.flashCycle()
        }

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let secondSetInvisible = SKAction.run { secondCircle.alpha = 0.0 }
            let secondSetVisible = SKAction.run { secondCircle.alpha = 1.0 }
            let secondPulseSequence = SKAction.sequence([secondSetVisible, waitInvisible, secondSetInvisible, waitVisible])

            secondCircle.run(secondPulseSequence)
        }
    }

    private func updatePulseSpeed() {
        currentPulseInterval *= pulseSpeedFactor
        if currentPulseInterval < minPulseInterval {
            currentPulseInterval = minPulseInterval
        }
    }
}

struct FlashingTestView: View {
    @StateObject private var flashingManager = FlashingManager()
    @State private var navigateToResults = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack {
                    Spacer()

                    if let scene = flashingManager.scene {
                        SpriteView(scene: scene)
                            .frame(width: 400, height: 400)
                    } else {
                        Text("Flashing will start soon...")
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: stopFlashing) {
                        Text("Flashing Synced")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .onAppear {
                flashingManager.startFlashing()
            }
            .onDisappear {
                flashingManager.stopFlashing()
            }
            .navigationDestination(isPresented: $navigateToResults) {
                ResultsView(frequencies: flashingManager.detectedFrequencies,
                            median: flashingManager.medianFrequency)
            }
        }
    }

    func stopFlashing() {
        flashingManager.stopFlashing()

        if flashingManager.isTestComplete {
            navigateToResults = true
        } else {
            // Clear current scene before starting a new one
            flashingManager.scene = nil

            // Delay to visually separate tests, then start next one
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                flashingManager.startFlashing()
            }
        }
    }

}


