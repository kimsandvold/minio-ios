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

            // minio-logo øverst til høyre
            let logoRect = CGRect(x: pageWidth - margin - 128, y: margin - 4, width: 128, height: 34)
            let logoBg = UIBezierPath(roundedRect: logoRect, cornerRadius: 17)
            UIColor(red: 0.14, green: 0.55, blue: 0.42, alpha: 1).setFill()
            logoBg.fill()
            let symCfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
            if let leaf = UIImage(systemName: "leaf.fill", withConfiguration: symCfg)?
                .withTintColor(.white, renderingMode: .alwaysOriginal) {
                leaf.draw(in: CGRect(x: logoRect.minX + 16, y: logoRect.midY - 9, width: 18, height: 18))
            }
            let logoAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
            ("minio.no" as NSString).draw(at: CGPoint(x: logoRect.minX + 42, y: logoRect.midY - 10), withAttributes: logoAttr)

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

            // Bord (oppgitt i løpemeter)
            let perBord = resultat.bordAntall > 0 ? resultat.bordLøpemeter / Double(resultat.bordAntall) : 0
            text("TERRASSEBORD", size: 13, bold: true, color: .systemBrown)
            y -= 4
            kvittekst("Løpemeter totalt", "\(String(format: "%.1f", resultat.bordLøpemeter)) lm")
            kvittekst("Bordlengde", "\(String(format: "%.1f", perBord)) m")
            kvittekst("Bordbredde", "\(Int(vm.bordbredde)) mm")
            kvittekst("Bordavstand", "\(Int(vm.bordavstand)) mm")
            linje()

            // Bjelker (oppgitt i løpemeter)
            text("BJELKELAG", size: 13, bold: true, color: .systemBrown)
            y -= 4
            kvittekst("Dimensjon", vm.bjelkeDimensjon.rawValue)
            kvittekst("Løpemeter totalt", "\(String(format: "%.1f", resultat.bjelkeLøpemeter)) lm")
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

            // Trapper (kan være flere)
            if !vm.trapper.isEmpty {
                text("TRAPPER", size: 13, bold: true, color: .systemBrown)
                y -= 4
                for (i, trapp) in vm.trapper.enumerated() {
                    kvittekst("Trapp \(i + 1)", "\(trapp.side.rawValue) · \(trapp.antallTrinn) trinn · \(String(format: "%.1f", trapp.bredde)) m")
                }
                kvittekst("Inntrinn", "\(String(format: "%.0f", vm.trappInntrinn * 1000)) mm")
                kvittekst("Opptrinn", "\(String(format: "%.0f", vm.trappOpptrinn * 1000)) mm")
                linje()
            }

            // Estimert kostnader
            text("Estimert kostnader", size: 13, bold: true, color: .systemGreen)
            y -= 4
            kostlinje("Terrassebord", resultat.bordKostnad)
            kostlinje("Bjelkelag", resultat.bjelkeKostnad)
            kostlinje("Skruer", resultat.skrueKostnad)
            if let g = resultat.gjerdeKostnad { kostlinje("Gjerde", g) }
            if let t = resultat.trappKostnad { kostlinje("Trapper", t) }
            linje()
            kostlinje("TOTAL KOSTNAD", resultat.totalKostnad)

            // Footer
            y = pageHeight - 40
            text("TerrassePlan — Minio Terasseplanlegger", size: 9, color: .tertiaryLabel)
        }

        return data
    }
}
