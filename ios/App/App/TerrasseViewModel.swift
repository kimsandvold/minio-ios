import SwiftUI
import Observation

@MainActor @Observable
final class TerrasseViewModel {
    // MARK: - Form
    var valgtForm: TerrasseForm = .rektangel {
        didSet { oppdaterResultat() }
    }

    // MARK: - Lengdemål (meter)
    var lengde: Double = 5.0 { didSet { oppdaterResultat() } }
    var bredde: Double = 3.0 { didSet { oppdaterResultat() } }
    var hovedLengde: Double = 5.0 { didSet { oppdaterResultat() } }
    var hovedBredde: Double = 3.0 { didSet { oppdaterResultat() } }
    var fløyLengde: Double = 2.5 { didSet { oppdaterResultat() } }
    var fløyBredde: Double = 2.0 { didSet { oppdaterResultat() } }
    var ytreLengde: Double = 6.0 { didSet { oppdaterResultat() } }
    var ytreBredde: Double = 4.0 { didSet { oppdaterResultat() } }
    var armBredde: Double = 1.0 { didSet { oppdaterResultat() } }
    var ryggLengde: Double = 5.0 { didSet { oppdaterResultat() } }
    var flensDybde: Double = 2.0 { didSet { oppdaterResultat() } }
    var flensBredde: Double = 0.5 { didSet { oppdaterResultat() } }

    // MARK: - Materialkonfigurasjon
    var bordbredde: Double = 120 { didSet { oppdaterResultat() } }
    var bordavstand: Double = 5 { didSet { oppdaterResultat() } }
    var bjelkeavstand: Double = 600 { didSet { oppdaterResultat() } }
    var skruerPerKryss: Double = 2 { didSet { oppdaterResultat() } }
    var bjelkeDimensjon: Bjelkedimensjon = .k48x148 { didSet { oppdaterResultat() } }

    // MARK: - Priser (veiledende markedspris, NOK)
    var prisBordPrLm: Double = 17 { didSet { oppdaterResultat() } }   // terrassebord kr/lm
    var prisBjelkePrLm: Double = 55 { didSet { oppdaterResultat() } } // konstruksjonsvirke kr/lm
    var prisSkrue: Double = 3 { didSet { oppdaterResultat() } }       // kr/stk
    var prisGjerdeBord: Double = 17 { didSet { oppdaterResultat() } } // kr/stk
    var prisLekt: Double = 14 { didSet { oppdaterResultat() } }       // lekt kr/lm
    var prisStolpe: Double = 89 { didSet { oppdaterResultat() } }     // kr/stk

    // MARK: - Gjerde
    var gjerdeType: Gjerdetype = .ingen { didSet { oppdaterResultat() } }
    var gjerdeHøyde: Double = 0.9 { didSet { oppdaterResultat() } }
    var gjerdePåAlleSider: Bool = true { didSet { oppdaterResultat() } }
    var stolpeAvstand: Double = 2.0 { didSet { oppdaterResultat() } }

    // MARK: - Trapp
    var harTrapp: Bool = false { didSet { oppdaterResultat() } }
    var trappAntallTrinn: Double = 3 { didSet { oppdaterResultat() } }
    var trappBredde: Double = 1.0 { didSet { oppdaterResultat() } }
    var trappInntrinn: Double = 0.30 { didSet { oppdaterResultat() } }
    var trappOpptrinn: Double = 0.18 { didSet { oppdaterResultat() } }

    // MARK: - Resultat
    private(set) var resultat: BeregnetResultat?

    // MARK: - Visning
    var visRotert: Bool = false

    // MARK: - Lagring
    private(set) var lagredeDesign: [LagretDesign] = []
    var visLagring: Bool = false
    var visLasting: Bool = false
    var lagringsNavn: String = ""

    init() {
        oppdaterResultat()
        oppdaterLagrede()
    }

    func oppdaterLagrede() {
        lagredeDesign = DesignArkiv.hentAlle()
    }

    func lagreDesign() {
        guard !lagringsNavn.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let design = LagretDesign(vm: self, navn: lagringsNavn.trimmingCharacters(in: .whitespaces))
        try? DesignArkiv.lagre(design)
        oppdaterLagrede()
        lagringsNavn = ""
    }

    func lastInn(_ design: LagretDesign) {
        design.gjenopprett(vm: self)
    }

    func slettDesign(_ design: LagretDesign) {
        try? DesignArkiv.slett(design)
        oppdaterLagrede()
    }

    /// Nullstiller geometri og konfigurasjon til standard for et nytt prosjekt.
    /// Priser beholdes slik at brukeren kan bekrefte dem i prisoppsettet.
    func nyttProsjekt() {
        valgtForm = .rektangel
        lengde = 5.0; bredde = 3.0
        hovedLengde = 5.0; hovedBredde = 3.0
        fløyLengde = 2.5; fløyBredde = 2.0
        ytreLengde = 6.0; ytreBredde = 4.0; armBredde = 1.0
        ryggLengde = 5.0; flensDybde = 2.0; flensBredde = 0.5
        bordbredde = 120; bordavstand = 5; bjelkeavstand = 600; skruerPerKryss = 2
        gjerdeType = .ingen; gjerdeHøyde = 0.9; gjerdePåAlleSider = true; stolpeAvstand = 2.0
        harTrapp = false; trappAntallTrinn = 3; trappBredde = 1.0
        trappInntrinn = 0.30; trappOpptrinn = 0.18
        visRotert = false
        oppdaterResultat()
    }

    // MARK: - Arealberegning

    private func beregnAreal() -> Double {
        switch valgtForm {
        case .rektangel:
            return lengde * bredde

        case .lForm:
            return (hovedLengde * hovedBredde) + (fløyLengde * fløyBredde)

        case .uForm:
            return (ytreLengde * ytreBredde) - ((ytreLengde - 2 * armBredde) * (ytreBredde - armBredde))

        case .eForm:
            return (ryggLengde * flensBredde) + 3 * (flensDybde * flensBredde)
        }
    }

    // MARK: - Perimeter for gjerde

    private func beregnOmkrets() -> Double {
        switch valgtForm {
        case .rektangel:
            return 2 * (lengde + bredde)
        case .lForm:
            return 2 * (hovedLengde + hovedBredde + fløyBredde)
        case .uForm:
            return ytreLengde + 2 * ytreBredde + (ytreLengde - 2 * armBredde)
        case .eForm:
            return 2 * (ryggLengde + flensDybde + flensBredde)
        }
    }

    // MARK: - Bredde for bord-retning

    private func beregnEffektivBordbredde() -> Double {
        (bordbredde + bordavstand) / 1000
    }

    // MARK: - Hovedberegning

    func oppdaterResultat() {
        let areal = beregnAreal()
        let omkrets = beregnOmkrets()
        let effBoardB = beregnEffektivBordbredde()

        // Antall bord
        let breddePåTvers: Double = {
            switch valgtForm {
            case .rektangel: return bredde
            case .lForm: return hovedBredde + fløyBredde
            case .uForm: return ytreBredde
            case .eForm: return flensDybde + flensBredde
            }
        }()
        let antallBord = max(1, Int(ceil(breddePåTvers / effBoardB)))

        // Total bordlengde
        let lengdeIRetning: Double = {
            switch valgtForm {
            case .rektangel: return lengde
            case .lForm: return hovedLengde
            case .uForm: return ytreLengde
            case .eForm: return ryggLengde
            }
        }()
        let bordLøpemeter = Double(antallBord) * lengdeIRetning

        // Bjelker
        let bjelkeAvstM = bjelkeavstand / 1000
        let antallBjelker = max(2, Int(ceil(lengdeIRetning / bjelkeAvstM)) + 1)
        let bjelkeLøpemeter = Double(antallBjelker) * breddePåTvers

        // Skruer
        let skrueAntall = antallBord * antallBjelker * Int(skruerPerKryss)

        // Kostnader
        let bordKostnad = bordLøpemeter * prisBordPrLm
        let bjelkeKostnad = bjelkeLøpemeter * prisBjelkePrLm
        let skrueKostnad = Double(skrueAntall) * prisSkrue

        // Gjerde
        let gjerdeLengde = gjerdePåAlleSider ? omkrets : omkrets / 2
        var gjerdeBordAntall: Int?
        var gjerdeStolper: Int?
        var gjerdeFormattert: String?
        var gjerdeKostnad: Double?

        if gjerdeType != .ingen {
            gjerdeStolper = max(4, Int(ceil(gjerdeLengde / stolpeAvstand)) + 1)

            switch gjerdeType {
            case .vannrett:
                let rader = max(1, Int(ceil(gjerdeHøyde / 0.12)))
                gjerdeBordAntall = rader * Int(ceil(gjerdeLengde / effBoardB))
            case .loddrett:
                gjerdeBordAntall = Int(ceil(gjerdeLengde / (bordbredde / 1000)))
            case .spiler:
                gjerdeBordAntall = Int(ceil(gjerdeLengde / 0.10))
            case .hel:
                gjerdeBordAntall = Int(ceil(gjerdeLengde / 1.8)) * Int(ceil(gjerdeHøyde / 1.8))
            case .ingen:
                break
            }

            let lektRader: Int = {
                switch gjerdeType {
                case .vannrett: return max(1, Int(ceil(gjerdeHøyde / 0.6)))
                case .loddrett, .spiler, .hel: return 2
                case .ingen: return 0
                }
            }()
            let lektLøpemeter = Double(lektRader) * gjerdeLengde
            gjerdeFormattert = "\(gjerdeType.beskrivelse): \(gjerdeBordAntall ?? 0) bord, \(lektLøpemeter.formatertLm()) lm lekt, \(gjerdeStolper ?? 0) stolper"
            gjerdeKostnad = (Double(gjerdeBordAntall ?? 0) * prisGjerdeBord) + (lektLøpemeter * prisLekt) + (Double(gjerdeStolper ?? 0) * prisStolpe)
        }

        // Trapp
        var trappTrinnAntall: Int?
        var trappVanger: Int?
        var trappFormattert: String?
        var trappKostnad: Double?

        if harTrapp {
            trappTrinnAntall = Int(trappAntallTrinn)
            trappVanger = 3
            trappFormattert = "\(Int(trappAntallTrinn)) trinn, \(trappBredde.format())m bredde"
            trappKostnad = Double(trappTrinnAntall ?? 0) * 500
        }

        let totalKostnad = bordKostnad + bjelkeKostnad + skrueKostnad + (gjerdeKostnad ?? 0) + (trappKostnad ?? 0)

        resultat = BeregnetResultat(
            areal: areal,
            arealFormattert: "\(areal.formatertAreal()) m²",
            bordAntall: antallBord,
            bordLøpemeter: bordLøpemeter,
            bordFormattert: "\(antallBord) stk × \(Int(lengdeIRetning * 1000))mm",
            bordKostnad: bordKostnad,
            bjelkeAntall: antallBjelker,
            bjelkeLøpemeter: bjelkeLøpemeter,
            bjelkeFormattert: "\(antallBjelker) stk \(bjelkeDimensjon.rawValue) × \(Int(breddePåTvers * 1000))mm",
            bjelkeKostnad: bjelkeKostnad,
            skrueAntall: skrueAntall,
            skrueFormattert: "\(skrueAntall) stk \(Int(skruerPerKryss)) per kryss",
            skrueKostnad: skrueKostnad,
            gjerdeBordAntall: gjerdeBordAntall,
            gjerdeStolper: gjerdeStolper,
            gjerdeFormattert: gjerdeFormattert,
            gjerdeKostnad: gjerdeKostnad,
            trappTrinnAntall: trappTrinnAntall,
            trappVanger: trappVanger,
            trappFormattert: trappFormattert,
            trappKostnad: trappKostnad,
            totalKostnad: totalKostnad
        )
    }

    // MARK: - Canvas-data

    func shapePath(in rect: CGRect) -> (Path, CGSize) {
        let dimensions = normalizedDimensions()
        let (drawW, drawH) = visRotert ? (dimensions.height, dimensions.width) : (dimensions.width, dimensions.height)
        let scale = min(
            (rect.width - 40) / max(drawW, 0.01),
            (rect.height - 40) / max(drawH, 0.01)
        )
        let scaledW = drawW * scale
        let scaledH = drawH * scale
        let xOff = rect.minX + (rect.width - scaledW) / 2
        let yOff = rect.minY + (rect.height - scaledH) / 2

        var t = CGAffineTransform(translationX: xOff, y: yOff).scaledBy(x: scale, y: scale)
        if visRotert {
            let cx = dimensions.width / 2
            let cy = dimensions.height / 2
            t = t.translatedBy(x: cx, y: cy).rotated(by: -.pi / 2).translatedBy(x: -cx, y: -cy)
        }

        var path = Path()

        switch valgtForm {
        case .rektangel:
            path.addRect(CGRect(x: 0, y: 0, width: bredde, height: lengde))

        case .lForm:
            let w1 = hovedBredde
            let h1 = hovedLengde
            let w2 = fløyBredde
            let h2 = fløyLengde
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: w1, y: 0))
            path.addLine(to: CGPoint(x: w1, y: h1 - h2))
            path.addLine(to: CGPoint(x: w1 + w2, y: h1 - h2))
            path.addLine(to: CGPoint(x: w1 + w2, y: h1))
            path.addLine(to: CGPoint(x: 0, y: h1))
            path.closeSubpath()

        case .uForm:
            let w = ytreBredde
            let h = ytreLengde
            let a = armBredde
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: w, y: 0))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w - a, y: h))
            path.addLine(to: CGPoint(x: w - a, y: a))
            path.addLine(to: CGPoint(x: a, y: a))
            path.addLine(to: CGPoint(x: a, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()

        case .eForm:
            let rl = ryggLengde
            let fd = flensDybde
            let fb = flensBredde
            let spacing = (rl - 3 * fb) / 2
            path.addRect(CGRect(x: 0, y: 0, width: fd, height: rl))
            for i in 0..<3 {
                let yPos = CGFloat(i) * (fb + spacing)
                path.addRect(CGRect(x: fd, y: yPos, width: fd, height: fb))
            }
        }

        return (path.applying(t), CGSize(width: scaledW, height: scaledH))
    }

    private func normalizedDimensions() -> CGSize {
        switch valgtForm {
        case .rektangel:
            return CGSize(width: bredde, height: lengde)
        case .lForm:
            return CGSize(width: hovedBredde + fløyBredde, height: hovedLengde)
        case .uForm:
            return CGSize(width: ytreBredde, height: ytreLengde)
        case .eForm:
            return CGSize(width: flensDybde * 2, height: ryggLengde)
        }
    }
}

private extension Double {
    func format() -> String {
        String(format: "%.1f", self)
    }

    func formatertAreal() -> String {
        String(format: "%.2f", self)
    }

    func formatertLm() -> String {
        String(format: "%.1f", self)
    }
}
