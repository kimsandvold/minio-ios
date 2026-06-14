import SwiftUI

struct ShapeCanvasView: View {
    let vm: TerrasseViewModel

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let (path, _) = vm.shapePath(in: rect)
            let bounds = path.boundingRect

            // Rutenett
            var gridPath = Path()
            let gridSize: CGFloat = 22
            for x in stride(from: 0, through: size.width, by: gridSize) {
                gridPath.move(to: CGPoint(x: x, y: 0))
                gridPath.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: gridSize) {
                gridPath.move(to: CGPoint(x: 0, y: y))
                gridPath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(gridPath, with: .color(.white.opacity(0.14)), lineWidth: 0.5)

            // Terrasseflate med tregradient
            context.fill(
                path,
                with: .linearGradient(
                    Theme.deck,
                    startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                    endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)
                )
            )
            context.stroke(path, with: .color(.white.opacity(0.9)), lineWidth: 2.5)

            // Målelabels
            for (text, pos) in dimensionLabels(in: size) {
                context.draw(
                    Text(text).font(.caption2.weight(.bold)).foregroundColor(.white),
                    at: pos
                )
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.12))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func dimensionLabels(in size: CGSize) -> [(String, CGPoint)] {
        let w = size.width
        let h = size.height
        switch vm.valgtForm {
        case .rektangel:
            return [
                ("\(vm.lengde.format())m", CGPoint(x: w * 0.12, y: h * 0.08)),
                ("\(vm.bredde.format())m", CGPoint(x: w * 0.85, y: h * 0.5)),
            ]
        case .lForm:
            return [
                ("\(vm.hovedLengde.format())m", CGPoint(x: w * 0.12, y: h * 0.08)),
                ("\(vm.fløyLengde.format())m", CGPoint(x: w * 0.7, y: h * 0.65)),
            ]
        case .uForm:
            return [
                ("\(vm.ytreLengde.format())m", CGPoint(x: w * 0.12, y: h * 0.08)),
                ("\(vm.ytreBredde.format())m", CGPoint(x: w * 0.82, y: h * 0.5)),
            ]
        case .eForm:
            return [
                ("\(vm.ryggLengde.format())m", CGPoint(x: w * 0.12, y: h * 0.08)),
                ("\(vm.flensDybde.format())m", CGPoint(x: w * 0.72, y: h * 0.5)),
            ]
        }
    }
}

private extension Double {
    func format() -> String {
        String(format: "%.1f", self)
    }
}
