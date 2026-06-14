import Foundation

struct MaterialKonfigurasjon {
    var bordbredde: Double = 120
    var bordavstand: Double = 5
    var bjelkeavstand: Double = 600
    var bjelkeBredde: Double = 48
    var bjelkehøyde: Double = 198
    var skruerPerKryss: Double = 2
}

/// Konstruksjonsvirke-dimensjoner med veiledende markedspris per løpemeter (NOK).
enum Bjelkedimensjon: String, CaseIterable, Identifiable {
    case k48x98 = "48×98"
    case k48x148 = "48×148"
    case k48x198 = "48×198"

    var id: String { rawValue }

    /// Veiledende pris i kr/lm.
    var standardpris: Double {
        switch self {
        case .k48x98: return 40
        case .k48x148: return 55
        case .k48x198: return 65
        }
    }

    /// Høyde i mm – brukes til bjelkelag-beskrivelse.
    var høyde: Int {
        switch self {
        case .k48x98: return 98
        case .k48x148: return 148
        case .k48x198: return 198
        }
    }
}

enum Gjerdetype: String, CaseIterable, Identifiable {
    case ingen = "Ingen"
    case vannrett = "Vannrett"
    case loddrett = "Loddrett"
    case spiler = "Spiler"
    case hel = "Hel"

    var id: String { rawValue }

    var beskrivelse: String {
        switch self {
        case .ingen: return "Ingen gjerde"
        case .vannrett: return "Vannrette bord"
        case .loddrett: return "Loddrette bord"
        case .spiler: return "Spiler med luft"
        case .hel: return "Sammenhengende panel"
        }
    }
}

struct GjerdeConfig {
    var type: Gjerdetype = .ingen
    var høyde: Double = 0.9
    var påAlleSider: Bool = true
    var antallSider: Int = 0
    var stolpeAvstand: Double = 2.0
}

struct TrappConfig {
    var harTrapp: Bool = false
    var antallTrinn: Int = 3
    var bredde: Double = 1.0
    var inntrinn: Double = 0.30
    var opptrinn: Double = 0.18
    var medRekkverk: Bool = true
}

struct BeregnetResultat: Identifiable {
    let id = UUID()
    let areal: Double
    let arealFormattert: String

    let bordAntall: Int
    let bordLøpemeter: Double
    let bordFormattert: String
    let bordKostnad: Double

    let bjelkeAntall: Int
    let bjelkeLøpemeter: Double
    let bjelkeFormattert: String
    let bjelkeKostnad: Double

    let skrueAntall: Int
    let skrueFormattert: String
    let skrueKostnad: Double

    let gjerdeBordAntall: Int?
    let gjerdeStolper: Int?
    let gjerdeFormattert: String?
    let gjerdeKostnad: Double?

    let trappTrinnAntall: Int?
    let trappVanger: Int?
    let trappFormattert: String?
    let trappKostnad: Double?

    let totalKostnad: Double
}
