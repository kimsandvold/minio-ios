import Foundation

struct MaterialKonfigurasjon {
    var bordbredde: Double = 120
    var bordavstand: Double = 5
    var bjelkeavstand: Double = 600
    var bjelkeBredde: Double = 48
    var bjelkehøyde: Double = 198
    var skruerPerKryss: Double = 2
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
