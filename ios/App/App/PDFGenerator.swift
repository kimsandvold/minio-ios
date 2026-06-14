import SwiftUI
import PDFKit

struct PDFGenerator {
    @MainActor static func genererPDF(vm: TerrasseViewModel) -> Data {
        guard let resultat = vm.resultat else { return Data() }

        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 40
        var y: CGFloat = margin

        let fmt = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: fmt)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()

            let left = margin
            let contentW = pageWidth - 2 * margin

            func text(_ s: String, size: CGFloat, bold: Bool = false, color: UIColor = .label) {
                let font: UIFont = bold ? .boldSystemFont(ofSize: size) : .systemFont(ofSize: size)
                let attr: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                s.draw(at: CGPoint(x: left, y: y), withAttributes: attr)
                y += size * 1.5
            }

            func kvittekst(_ label: String, _ verdi: String) {
                let lblFont = UIFont.systemFont(ofSize: 11)
                let lblAttr: [NSAttributedString.Key: Any] = [.font: lblFont, .foregroundColor: UIColor.secondaryLabel]
                let valFont = UIFont.boldSystemFont(ofSize: 13)
                let valAttr: [NSAttributedString.Key: Any] = [.font: valFont, .foregroundColor: UIColor.label]

                let labelW = (contentW * 0.4)
                let rect1 = CGRect(x: left, y: y, width: labelW, height: 18)
                (label as NSString).draw(in: rect1, withAttributes: lblAttr)

                let rect2 = CGRect(x: left + labelW, y: y, width: contentW - labelW, height: 18)
                (verdi as NSString).draw(in: rect2, withAttributes: valAttr)
                y += 20
            }

            func kostlinje(_ label: String, _ belop: Double) {
                let lblFont = UIFont.systemFont(ofSize: 11)
                let lblAttr: [NSAttributedString.Key: Any] = [.font: lblFont, .foregroundColor: UIColor.secondaryLabel]
                let valFont = UIFont.boldSystemFont(ofSize: 13)
                let valAttr: [NSAttributedString.Key: Any] = [.font: valFont, .foregroundColor: UIColor.systemGreen]

                let labelW = (contentW * 0.6)
                let rect1 = CGRect(x: left, y: y, width: labelW, height: 18)
                (label as NSString).draw(in: rect1, withAttributes: lblAttr)

                let rect2 = CGRect(x: left + labelW, y: y, width: contentW - labelW, height: 18)
                ("\(String(format: "%.0f", belop)) kr" as NSString).draw(in: rect2, withAttributes: valAttr)
                y += 20
            }

            func linje() {
                y += 4
                let path = UIBezierPath()
                path.move(to: CGPoint(x: left, y: y))
                path.addLine(to: CGPoint(x: left + contentW, y: y))
                UIColor.separator.setStroke()
                path.stroke()
                y += 8
            }

            // Tittel
            text("TerrassePlan", size: 24, bold: true)
            text("Materialberegning", size: 14, color: .secondaryLabel)
            y += 4
            linje()

            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "nb_NO")
            kvittekst("Dato", formatter.string(from: Date()))
            kvittekst("Terrasseform", vm.valgtForm.rawValue)
            linje()

            // Areal
            text("TERRASSEAREAL", size: 13, bold: true, color: .systemGreen)
            y -= 4
            kvittekst("Totalt areal", resultat.arealFormattert)
            linje()

            // Bord
            text("TERRASSEBORD", size: 13, bold: true, color: .systemBrown)
            y -= 4
            kvittekst("Antall bord", "\(resultat.bordAntall) stk")
            kvittekst("Total lengde", "\(String(format: "%.1f", resultat.bordLøpemeter)) lm")
            kvittekst("Bordbredde", "\(Int(vm.bordbredde)) mm")
            kvittekst("Bordavstand", "\(Int(vm.bordavstand)) mm")
            linje()

            // Bjelker
            text("BJELKELAG", size: 13, bold: true, color: .systemBrown)
            y -= 4
            kvittekst("Antall bjelker", "\(resultat.bjelkeAntall) stk")
            kvittekst("Total lengde", "\(String(format: "%.1f", resultat.bjelkeLøpemeter)) lm")
            kvittekst("Bjelkeavstand", "\(Int(vm.bjelkeavstand)) mm")
            linje()

            // Skruer
            text("SKRUER OG FESTEMATERIELL", size: 13, bold: true, color: .systemBrown)
            y -= 4
            kvittekst("Antall skruer", resultat.skrueFormattert)
            linje()

            // Gjerde
            if vm.gjerdeType != .ingen, let g = resultat.gjerdeFormattert {
                text("GJERDE", size: 13, bold: true, color: .systemBrown)
                y -= 4
                kvittekst("Type", vm.gjerdeType.rawValue)
                kvittekst("Høyde", "\(String(format: "%.1f", vm.gjerdeHøyde)) m")
                if let b = resultat.gjerdeBordAntall { kvittekst("Antall bord", "\(b) stk") }
                if let s = resultat.gjerdeStolper { kvittekst("Antall stolper", "\(s) stk") }
                linje()
            }

            // Trapp
            if vm.harTrapp, let t = resultat.trappFormattert {
                text("TRAPP", size: 13, bold: true, color: .systemBrown)
                y -= 4
                kvittekst("Antall trinn", "\(Int(vm.trappAntallTrinn)) stk")
                kvittekst("Bredde", "\(String(format: "%.2f", vm.trappBredde)) m")
                kvittekst("Inntrinn", "\(String(format: "%.0f", vm.trappInntrinn * 1000)) mm")
                kvittekst("Opptrinn", "\(String(format: "%.0f", vm.trappOpptrinn * 1000)) mm")
                linje()
            }

            // Kostnadsoversikt
            text("KOSTNADSOVERSIKT", size: 13, bold: true, color: .systemGreen)
            y -= 4
            kostlinje("Terrassebord", resultat.bordKostnad)
            kostlinje("Bjelkelag", resultat.bjelkeKostnad)
            kostlinje("Skruer", resultat.skrueKostnad)
            if let g = resultat.gjerdeKostnad { kostlinje("Gjerde", g) }
            if let t = resultat.trappKostnad { kostlinje("Trapp", t) }
            linje()
            kostlinje("TOTAL KOSTNAD", resultat.totalKostnad)

            // Footer
            y = pageHeight - 40
            text("TerrassePlan — Minio Terasseplanlegger", size: 9, color: .tertiaryLabel)
        }

        return data
    }
}
