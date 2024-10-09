import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack {
            RecursiveShapeGenerator(shape: viewModel.currentShape)
                .frame(height: 300)
            
            controls
        }
        .padding()
    }
    
    private var controls: some View {
        VStack {
            Picker("Base Shape", selection: $viewModel.baseShape) {
                ForEach(BaseShape.allCases, id: \.self) { shape in
                    Text(shape.description).tag(shape)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Slider(value: $viewModel.depth, in: 1...5, step: 1) {
                Text("Depth: \(Int(viewModel.depth))")
            }
            
            Slider(value: $viewModel.scale, in: 0.1...0.9) {
                Text("Scale: \(viewModel.scale, specifier: "%.2f")")
            }
            
            Button("Generate New Shape") {
                viewModel.generateNewShape()
            }
            
            Picker("Color Scheme", selection: $viewModel.colorScheme) {
                Text("Rainbow").tag(ColorScheme.rainbow)
                Text("Monochrome").tag(ColorScheme.monochrome)
            }
            
            Slider(value: $viewModel.animationSpeed, in: 0.1...2.0) {
                Text("Animation Speed: \(viewModel.animationSpeed, specifier: "%.1f")")
            }
        }
    }
}