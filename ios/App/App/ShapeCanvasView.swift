import SwiftUI

struct ShapeCanvasView: View {
    let vm: TerrasseViewModel

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let fillColor: Color = Color(.displayP3, red: 0.55, green: 0.35, blue: 0.15).opacity(0.35)
            let strokeColor: Color = .brown

            let (path, _) = vm.shapePath(in: rect)

            context.fill(path, with: .color(fillColor))
            context.stroke(path, with: .color(strokeColor), lineWidth: 2.5)

            // Grid
            var gridPath = Path()
            let gridSize: CGFloat = 20
            for x in stride(from: 0, through: size.width, by: gridSize) {
                gridPath.move(to: CGPoint(x: x, y: 0))
                gridPath.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: gridSize) {
                gridPath.move(to: CGPoint(x: 0, y: y))
                gridPath.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(gridPath, with: .color(.brown.opacity(0.06)), lineWidth: 0.5)

            // Dimension labels
            let dims = dimensionLabels(in: size)
            for (text, pos) in dims {
                context.draw(Text(text).font(.caption2.weight(.medium)).foregroundColor(.brown), at: pos)
            }
        }
        .frame(height: 220)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.background.quaternary)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.quaternary, lineWidth: 1)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                vm.visRotert.toggle()
            } label: {
                Image(systemName: vm.visRotert ? "lock.rotation" : "lock.rotation.open")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
        }
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
