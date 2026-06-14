import Foundation

struct LagretDesign: Codable, Identifiable {
    let id: UUID
    var navn: String
    let dato: Date
    let formRawValue: String

    let lengde: Double
    let bredde: Double
    let hovedLengde: Double
    let hovedBredde: Double
    let floyLengde: Double
    let floyBredde: Double
    let ytreLengde: Double
    let ytreBredde: Double
    let armBredde: Double
    let ryggLengde: Double
    let flensDybde: Double
    let flensBredde: Double

    let bordbredde: Double
    let bordavstand: Double
    let bjelkeavstand: Double
    let skruerPerKryss: Double

    let prisBordPrLm: Double
    let prisBjelkePrLm: Double
    let prisSkrue: Double
    let prisGjerdeBord: Double
    let prisLekt: Double
    let prisStolpe: Double

    let gjerdeTypeRawValue: String
    let gjerdeHoyde: Double
    let gjerdePaAlleSider: Bool
    let stolpeAvstand: Double

    let harTrapp: Bool
    let trappAntallTrinn: Double
    let trappBredde: Double
    let trappInntrinn: Double
    let trappOpptrinn: Double

    let visRotert: Bool

    @MainActor init(vm: TerrasseViewModel, navn: String) {
        self.id = UUID()
        self.navn = navn
        self.dato = Date()
        self.formRawValue = vm.valgtForm.rawValue

        self.lengde = vm.lengde
        self.bredde = vm.bredde
        self.hovedLengde = vm.hovedLengde
        self.hovedBredde = vm.hovedBredde
        self.floyLengde = vm.fløyLengde
        self.floyBredde = vm.fløyBredde
        self.ytreLengde = vm.ytreLengde
        self.ytreBredde = vm.ytreBredde
        self.armBredde = vm.armBredde
        self.ryggLengde = vm.ryggLengde
        self.flensDybde = vm.flensDybde
        self.flensBredde = vm.flensBredde

        self.bordbredde = vm.bordbredde
        self.bordavstand = vm.bordavstand
        self.bjelkeavstand = vm.bjelkeavstand
        self.skruerPerKryss = vm.skruerPerKryss

        self.prisBordPrLm = vm.prisBordPrLm
        self.prisBjelkePrLm = vm.prisBjelkePrLm
        self.prisSkrue = vm.prisSkrue
        self.prisGjerdeBord = vm.prisGjerdeBord
        self.prisLekt = vm.prisLekt
        self.prisStolpe = vm.prisStolpe

        self.gjerdeTypeRawValue = vm.gjerdeType.rawValue
        self.gjerdeHoyde = vm.gjerdeHøyde
        self.gjerdePaAlleSider = vm.gjerdePåAlleSider
        self.stolpeAvstand = vm.stolpeAvstand

        self.harTrapp = vm.harTrapp
        self.trappAntallTrinn = vm.trappAntallTrinn
        self.trappBredde = vm.trappBredde
        self.trappInntrinn = vm.trappInntrinn
        self.trappOpptrinn = vm.trappOpptrinn

        self.visRotert = vm.visRotert
    }

    @MainActor func gjenopprett(vm: TerrasseViewModel) {
        vm.valgtForm = TerrasseForm(rawValue: formRawValue) ?? .rektangel
        vm.lengde = lengde
        vm.bredde = bredde
        vm.hovedLengde = hovedLengde
        vm.hovedBredde = hovedBredde
        vm.fløyLengde = floyLengde
        vm.fløyBredde = floyBredde
        vm.ytreLengde = ytreLengde
        vm.ytreBredde = ytreBredde
        vm.armBredde = armBredde
        vm.ryggLengde = ryggLengde
        vm.flensDybde = flensDybde
        vm.flensBredde = flensBredde

        vm.bordbredde = bordbredde
        vm.bordavstand = bordavstand
        vm.bjelkeavstand = bjelkeavstand
        vm.skruerPerKryss = skruerPerKryss

        vm.prisBordPrLm = prisBordPrLm
        vm.prisBjelkePrLm = prisBjelkePrLm
        vm.prisSkrue = prisSkrue
        vm.prisGjerdeBord = prisGjerdeBord
        vm.prisLekt = prisLekt
        vm.prisStolpe = prisStolpe

        vm.gjerdeType = Gjerdetype(rawValue: gjerdeTypeRawValue) ?? .ingen
        vm.gjerdeHøyde = gjerdeHoyde
        vm.gjerdePåAlleSider = gjerdePaAlleSider
        vm.stolpeAvstand = stolpeAvstand

        vm.harTrapp = harTrapp
        vm.trappAntallTrinn = trappAntallTrinn
        vm.trappBredde = trappBredde
        vm.trappInntrinn = trappInntrinn
        vm.trappOpptrinn = trappOpptrinn

        vm.visRotert = visRotert
    }
}
