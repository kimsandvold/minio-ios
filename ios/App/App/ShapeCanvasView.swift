import SwiftUI

/// Topp-ned konstruksjonstegning: terrasseflate, bjelker og bord i motsatt
/// retning, kantbjelker (sidebjelker) og trapper på valgte kanter.
struct ShapeCanvasView: View {
    let vm: TerrasseViewModel

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            let k = vm.konstruksjon(in: rect)
            let shape = k.shape
            let t = k.transform
            let m = k.modelSize
            let bounds = shape.boundingRect

            drawGrid(in: &context, size: size)

            // Terrasseflate
            context.fill(
                shape,
                with: .linearGradient(
                    Theme.deck,
                    startPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                    endPoint: CGPoint(x: bounds.maxX, y: bounds.maxY)
                )
            )

            // Bjelker og bord, klippet til formen
            var inner = context
            inner.clip(to: shape)

            // Bjelker (bærende, på tvers) – horisontale modell-linjer
            var bjelker = Path()
            let dj = max(0.08, vm.bjelkeavstand / 1000)
            var y = 0.0
            while y <= m.height + 0.001 {
                bjelker.move(to: CGPoint(x: 0, y: y))
                bjelker.addLine(to: CGPoint(x: m.width, y: y))
                y += dj
            }
            inner.stroke(bjelker.applying(t), with: .color(.white.opacity(0.45)), lineWidth: 2.5)

            // Terrassebord (overflate, på langs) – vertikale modell-linjer
            var bord = Path()
            let db = max(0.04, (vm.bordbredde + vm.bordavstand) / 1000)
            var x = 0.0
            while x <= m.width + 0.001 {
                bord.move(to: CGPoint(x: x, y: 0))
                bord.addLine(to: CGPoint(x: x, y: m.height))
                x += db
            }
            inner.stroke(bord.applying(t), with: .color(.black.opacity(0.16)), lineWidth: 1)

            // Kantbjelker / sidebjelker = tykk omriss
            context.stroke(shape, with: .color(Theme.wood), lineWidth: 4.5)
            context.stroke(shape, with: .color(.white.opacity(0.9)), lineWidth: 1.5)

            // Trapper
            for trapp in vm.trapper {
                drawTrapp(trapp, modelSize: m, transform: t, in: &context)
            }

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

    private func drawGrid(in context: inout GraphicsContext, size: CGSize) {
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
        context.stroke(gridPath, with: .color(.white.opacity(0.12)), lineWidth: 0.5)
    }

    private func drawTrapp(_ trapp: Trapp, modelSize m: CGSize, transform t: CGAffineTransform, in context: inout GraphicsContext) {
        let r = vm.trappRektModell(trapp, modelSize: m)
        var rectPath = Path()
        rectPath.addRect(r)
        let tRect = rectPath.applying(t)

        context.fill(tRect, with: .color(Theme.woodLight.opacity(0.85)))
        context.stroke(tRect, with: .color(.white.opacity(0.9)), lineWidth: 1.5)

        // Trinn-linjer på tvers av utgangsretningen
        var treads = Path()
        let n = max(1, trapp.antallTrinn)
        let langsKortside = (trapp.side == .front || trapp.side == .bak)
        for i in 1..<max(2, n) {
            let f = Double(i) / Double(n)
            if langsKortside {
                let yy = r.minY + r.height * f
                treads.move(to: CGPoint(x: r.minX, y: yy))
                treads.addLine(to: CGPoint(x: r.maxX, y: yy))
            } else {
                let xx = r.minX + r.width * f
                treads.move(to: CGPoint(x: xx, y: r.minY))
                treads.addLine(to: CGPoint(x: xx, y: r.maxY))
            }
        }
        context.stroke(treads.applying(t), with: .color(.white.opacity(0.65)), lineWidth: 1)
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
