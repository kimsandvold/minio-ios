import Foundation

final class DesignArkiv {
    private static var _deler: [LagretDesign] = []
    private static let filNavn = "designarkiv.json"

    private static var arkivURL: URL {
        URL.documentsDirectory.appendingPathComponent(filNavn)
    }

    static func hentAlle() -> [LagretDesign] {
        if _deler.isEmpty {
            last()
        }
        return _deler
    }

    static func lagre(_ design: LagretDesign) throws {
        _deler.insert(design, at: 0)
        skrivTilFil()
    }

    static func slett(_ design: LagretDesign) throws {
        _deler.removeAll { $0.id == design.id }
        skrivTilFil()
    }

    private static func skrivTilFil() {
        do {
            let data = try JSONEncoder().encode(_deler)
            try data.write(to: arkivURL, options: .atomic)
        } catch {
            print("Klarte ikke skrive arkiv: \(error)")
        }
    }

    private static func last() {
        do {
            let data = try Data(contentsOf: arkivURL)
            _deler = try JSONDecoder().decode([LagretDesign].self, from: data)
        } catch {
            _deler = []
        }
    }
}
