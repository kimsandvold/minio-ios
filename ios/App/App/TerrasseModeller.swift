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

/// Hvilken kant av terrassen noe plasseres på (sett ovenfra).
enum Terrasseside: String, CaseIterable, Codable, Identifiable {
    case front = "Front"
    case bak = "Bak"
    case venstre = "Venstre"
    case høyre = "Høyre"

    var id: String { rawValue }

    var ikon: String {
        switch self {
        case .front: return "arrow.down.to.line"
        case .bak: return "arrow.up.to.line"
        case .venstre: return "arrow.left.to.line"
        case .høyre: return "arrow.right.to.line"
        }
    }
}

/// En trapp plassert på en valgt kant av terrassen.
struct Trapp: Identifiable, Codable, Equatable {
    var id = UUID()
    var side: Terrasseside = .front
    var posisjon: Double = 0.5   // 0…1 langs kanten
    var bredde: Double = 1.0     // meter
    var antallTrinn: Int = 3
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
