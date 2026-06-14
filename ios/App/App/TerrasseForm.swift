import SwiftUI

enum TerrasseForm: String, CaseIterable, Identifiable {
    case rektangel = "Rektangel"
    case lForm = "L-form"
    case uForm = "U-form"
    case eForm = "E-form"

    var id: String { rawValue }

    var ikon: String {
        switch self {
        case .rektangel: return "rectangle"
        case .lForm: return "rectangle.trailinghalf.inset.filled"
        case .uForm: return "rectangle.split.3x1"
        case .eForm: return "rectangle.split.3x3"
        }
    }

    var beskrivelse: String {
        switch self {
        case .rektangel: return "Enkel rektangulær terrasse"
        case .lForm: return "L-formet med én fløy"
        case .uForm: return "U-formet med to fløyer"
        case .eForm: return "E-formet med tre fløyer"
        }
    }

    var målefelt: [MåleFelt] {
        switch self {
        case .rektangel:
            return [.lengde, .bredde]
        case .lForm:
            return [.hovedLengde, .hovedBredde, .fløyLengde, .fløyBredde]
        case .uForm:
            return [.ytreLengde, .ytreBredde, .armBredde]
        case .eForm:
            return [.ryggLengde, .flensDybde, .flensBredde]
        }
    }
}

enum MåleFelt: String, CaseIterable, Identifiable {
    case lengde
    case bredde
    case hovedLengde
    case hovedBredde
    case fløyLengde
    case fløyBredde
    case ytreLengde
    case ytreBredde
    case armBredde
    case ryggLengde
    case flensDybde
    case flensBredde

    var id: String { rawValue }

    var navn: String {
        switch self {
        case .lengde: return "Lengde"
        case .bredde: return "Bredde"
        case .hovedLengde: return "Hovedlengde"
        case .hovedBredde: return "Hovedbredde"
        case .fløyLengde: return "Fløylengde"
        case .fløyBredde: return "Fløybredde"
        case .ytreLengde: return "Ytre lengde"
        case .ytreBredde: return "Ytre bredde"
        case .armBredde: return "Armbredde"
        case .ryggLengde: return "Rygglengde"
        case .flensDybde: return "Flensdybde"
        case .flensBredde: return "Flensbredde"
        }
    }

    var enhet: String { "m" }

    var hjelpetekst: String? {
        switch self {
        case .ytreLengde: return "Total lengde på U'en"
        case .ytreBredde: return "Total bredde på U'en"
        case .armBredde: return "Bredde på hver arm"
        case .ryggLengde: return "Lengde på ryggen"
        case .flensDybde: return "Dybde på flensene"
        case .flensBredde: return "Bredde på flensene"
        default: return nil
        }
    }
}
