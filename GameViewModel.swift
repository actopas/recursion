import SwiftUI

class GameViewModel: ObservableObject {
    @Published var currentShape: RecursiveShape
    @Published var baseShape: BaseShape = .triangle
    @Published var depth: Double = 3
    @Published var scale: Double = 0.5
    @Published var rotation: Double = 30
    @Published var color: Color = .blue
    @Published var colorScheme: ColorScheme = .rainbow
    @Published var animationSpeed: Double = 1.0
    
    @Published var score: Int = 0
    @Published var showingChallengeComplete = false
    @Published var currentAlert: AlertItem?
    
    private var targetShape: RecursiveShape?
    private var challengeTimer: Timer?
    
    init() {
        currentShape = RecursiveShape(baseShape: .triangle, depth: 3, scale: 0.5, rotation: .degrees(30), offset: .zero, color: .blue, colorScheme: .rainbow)
    }
    
    func generateNewShape() {
        currentShape = RecursiveShape(
            baseShape: baseShape,
            depth: Int(depth),
            scale: CGFloat(scale),
            rotation: .degrees(rotation),
            offset: .zero,
            color: color,
            colorScheme: colorScheme
        )
    }
    
    func startChallenge() {
        targetShape = generateRandomShape()
        score = 0
        showingChallengeComplete = false
        
        challengeTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { _ in
            self.endChallenge()
        }
        
        currentAlert = AlertItem(title: "Challenge Started", message: "You have 60 seconds to match the target shape. Are you ready?")
    }
    
    func endChallenge() {
        challengeTimer?.invalidate()
        showingChallengeComplete = true
        calculateScore()
    }
    
    func resetChallenge() {
        showingChallengeComplete = false
        startChallenge()
    }
    
    private func generateRandomShape() -> RecursiveShape {
        RecursiveShape(
            baseShape: BaseShape.allCases.randomElement()!,
            depth: Int.random(in: 1...5),
            scale: CGFloat.random(in: 0.1...0.9),
            rotation: .degrees(Double.random(in: 0...360)),
            offset: .zero,
            color: Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)),
            colorScheme: [ColorScheme.rainbow, ColorScheme.monochrome].randomElement()!
        )
    }
    
    private func calculateScore() {
        let baseShapeMatch = currentShape.baseShape == targetShape?.baseShape ? 20 : 0
        let depthMatch = abs(currentShape.depth - (targetShape?.depth ?? 0)) <= 1 ? 20 : 0
        let scaleMatch = abs(currentShape.scale - (targetShape?.scale ?? 0)) < 0.1 ? 20 : 0
        let rotationMatch = abs(currentShape.rotation.degrees - (targetShape?.rotation.degrees ?? 0)) < 30 ? 20 : 0
        let colorMatch = currentShape.color.description == targetShape?.color.description ? 20 : 0
        
        score = baseShapeMatch + depthMatch + scaleMatch + rotationMatch + colorMatch
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

extension BaseShape: CaseIterable {
    static var allCases: [BaseShape] = [.triangle, .square, .hexagon]
    
    var description: String {
        switch self {
        case .triangle: return "Triangle"
        case .square: return "Square"
        case .hexagon: return "Hexagon"
        case .star: return "Star"
        case .spiral: return "Spiral"
        }
    }
}

enum ColorScheme {
    case rainbow
    case monochrome
}