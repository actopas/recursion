import SwiftUI

struct RecursiveShape {
    let baseShape: BaseShape
    let depth: Int
    let scale: CGFloat
    let rotation: Angle
    let offset: CGSize
    let color: Color
    let colorScheme: ColorScheme
}

enum BaseShape {
    case triangle
    case square
    case hexagon
    case star
    case spiral
}

struct RecursiveShapeGenerator: View {
    @State private var animationPhase: CGFloat = 0
    
    let shape: RecursiveShape
    
    var body: some View {
        generateShapeRecursively(shape, currentDepth: 0)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animationPhase)
            .onAppear {
                animationPhase = 1
            }
    }
    
    private func generateShapeRecursively(_ shape: RecursiveShape, currentDepth: Int) -> some View {
        Group {
            if currentDepth == shape.depth {
                baseShapeView(for: shape.baseShape)
                    .fill(colorGradient(for: currentDepth))
            } else {
                baseShapeView(for: shape.baseShape)
                    .fill(colorGradient(for: currentDepth))
                    .overlay(
                        ForEach(0..<numberOfSubShapes(for: shape.baseShape), id: \.self) { index in
                            generateShapeRecursively(
                                subShape(of: shape, at: index, currentDepth: currentDepth),
                                currentDepth: currentDepth + 1
                            )
                        }
                    )
            }
        }
        .frame(width: 100 * pow(shape.scale, CGFloat(currentDepth)),
               height: 100 * pow(shape.scale, CGFloat(currentDepth)))
        .rotationEffect(shape.rotation * CGFloat(currentDepth) + .degrees(360 * animationPhase))
        .offset(shape.offset)
    }
    
    private func colorGradient(for depth: Int) -> AnyShapeStyle {
        switch shape.colorScheme {
        case .rainbow:
            return AnyShapeStyle(AngularGradient(
                gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
                center: .center,
                startAngle: .degrees(Double(depth) * 60),
                endAngle: .degrees(Double(depth + 1) * 60)
            ))
        case .monochrome:
            return AnyShapeStyle(LinearGradient(
                gradient: Gradient(colors: [
                    shape.color.opacity(0.7),
                    shape.color
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
        }
    }
    
    private func baseShapeView(for shape: BaseShape) -> some Shape {
        switch shape {
        case .triangle:
            return AnyShape(Triangle())
        case .square:
            return AnyShape(Rectangle())
        case .hexagon:
            return AnyShape(Hexagon())
        case .star:
            return AnyShape(Star())
        case .spiral:
            return AnyShape(Spiral())
        }
    }
    
    private func numberOfSubShapes(for shape: BaseShape) -> Int {
        switch shape {
        case .triangle: return 3
        case .square: return 4
        case .hexagon: return 6
        case .star: return 5
        case .spiral: return 1
        }
    }
    
    private func subShape(of shape: RecursiveShape, at index: Int, currentDepth: Int) -> RecursiveShape {
        RecursiveShape(
            baseShape: shape.baseShape,
            depth: shape.depth,
            scale: shape.scale,
            rotation: shape.rotation,
            offset: calculateOffset(for: shape.baseShape, at: index, scale: shape.scale, depth: CGFloat(currentDepth)),
            color: shape.color.opacity(0.8),
            colorScheme: shape.colorScheme
        )
    }
    
    private func calculateOffset(for shape: BaseShape, at index: Int, scale: CGFloat, depth: CGFloat) -> CGSize {
        let angle = (2 * .pi / CGFloat(numberOfSubShapes(for: shape))) * CGFloat(index)
        let distance = 50 * scale * pow(scale, depth)
        return CGSize(
            width: cos(angle) * distance,
            height: sin(angle) * distance
        )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let angles = stride(from: 0, to: 360, by: 60).map { CGFloat($0) * .pi / 180 }
        
        var path = Path()
        path.move(to: CGPoint(x: center.x + radius * cos(angles[0]),
                              y: center.y + radius * sin(angles[0])))
        
        for angle in angles.dropFirst() {
            path.addLine(to: CGPoint(x: center.x + radius * cos(angle),
                                     y: center.y + radius * sin(angle)))
        }
        
        path.closeSubpath()
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        // 实现星形路径
        // 这里只是一个简单的实现，你可能需要调整以获得更好的效果
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let path = Path { p in
            for i in 0..<5 {
                let angle = Double(i) * 4 * .pi / 5
                let point = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * outerRadius,
                    y: center.y + CGFloat(sin(angle)) * outerRadius
                )
                if i == 0 {
                    p.move(to: point)
                } else {
                    p.addLine(to: point)
                }
                let innerAngle = angle + .pi / 5
                let innerPoint = CGPoint(
                    x: center.x + CGFloat(cos(innerAngle)) * innerRadius,
                    y: center.y + CGFloat(sin(innerAngle)) * innerRadius
                )
                p.addLine(to: innerPoint)
            }
            p.closeSubpath()
        }
        return path
    }
}

struct Spiral: Shape {
    func path(in rect: CGRect) -> Path {
        // 实现螺旋路径
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let path = Path { p in
            p.move(to: center)
            for i in 0...720 {
                let angle = Angle(degrees: Double(i) / 2).radians
                let distance = CGFloat(i) / 720 * radius
                let x = center.x + distance * CGFloat(cos(angle))
                let y = center.y + distance * CGFloat(sin(angle))
                p.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}