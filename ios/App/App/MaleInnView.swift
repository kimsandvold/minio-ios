import SwiftUI

struct MaleInnView: View {
    let vm: TerrasseViewModel

    var body: some View {
        VStack(spacing: 16) {
            SectionCard(icon: "ruler", title: "Mål", subtitle: vm.valgtForm.rawValue) {
                VStack(spacing: 18) {
                    ForEach(vm.valgtForm.målefelt) { felt in
                        MåleFeltRad(verdi: binding(for: felt), felt: felt)
                    }
                }
            }

            SectionCard(icon: "shippingbox", title: "Materialer", tint: Theme.wood, initiallyExpanded: false) {
                MaterialConfigView(vm: vm)
            }

            SectionCard(icon: "tag", title: "Priser", subtitle: "Per meter / per stk", initiallyExpanded: false) {
                PrisConfigView(vm: vm)
            }

            SectionCard(icon: "fence", title: "Gjerde", tint: Theme.accent, initiallyExpanded: false) {
                GjerdeConfigView(vm: vm)
            }

            SectionCard(icon: "stairs", title: "Trapp / utgang", tint: .purple, subtitle: vm.trapper.isEmpty ? nil : "\(vm.trapper.count) trapp(er)", initiallyExpanded: false) {
                TrappConfigView(vm: vm)
            }
        }
    }

    private func binding(for felt: MåleFelt) -> Binding<Double> {
        switch felt {
        case .lengde: return Binding(get: { vm.lengde }, set: { vm.lengde = $0 })
        case .bredde: return Binding(get: { vm.bredde }, set: { vm.bredde = $0 })
        case .hovedLengde: return Binding(get: { vm.hovedLengde }, set: { vm.hovedLengde = $0 })
        case .hovedBredde: return Binding(get: { vm.hovedBredde }, set: { vm.hovedBredde = $0 })
        case .fløyLengde: return Binding(get: { vm.fløyLengde }, set: { vm.fløyLengde = $0 })
        case .fløyBredde: return Binding(get: { vm.fløyBredde }, set: { vm.fløyBredde = $0 })
        case .ytreLengde: return Binding(get: { vm.ytreLengde }, set: { vm.ytreLengde = $0 })
        case .ytreBredde: return Binding(get: { vm.ytreBredde }, set: { vm.ytreBredde = $0 })
        case .armBredde: return Binding(get: { vm.armBredde }, set: { vm.armBredde = $0 })
        case .ryggLengde: return Binding(get: { vm.ryggLengde }, set: { vm.ryggLengde = $0 })
        case .flensDybde: return Binding(get: { vm.flensDybde }, set: { vm.flensDybde = $0 })
        case .flensBredde: return Binding(get: { vm.flensBredde }, set: { vm.flensBredde = $0 })
        }
    }
}

struct MåleFeltRad: View {
    @Binding var verdi: Double
    let felt: MåleFelt

    private var range: ClosedRange<Double> {
        switch felt {
        case .armBredde, .flensBredde: return 0.3...5.0
        case .flensDybde: return 0.5...10.0
        default: return 1.0...30.0
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(felt.navn)
                        .font(.subheadline.weight(.medium))
                    if let hjelp = felt.hjelpetekst {
                        Text(hjelp)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("\(verdi, specifier: "%.1f") \(felt.enhet)")
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText())
                    .frame(minWidth: 60, alignment: .trailing)
            }
            Slider(value: $verdi, in: range, step: 0.5)
                .tint(Theme.accent)
        }
    }
}

struct MaterialConfigView: View {
    let vm: TerrasseViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Bjelkedimensjon")
                    .font(.subheadline)
                Spacer()
                Picker("", selection: Binding(get: { vm.bjelkeDimensjon }, set: { vm.bjelkeDimensjon = $0 })) {
                    ForEach(Bjelkedimensjon.allCases) { dim in
                        Text(dim.rawValue).tag(dim)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
            ConfigRad(verdi: Binding(get: { vm.bordbredde }, set: { vm.bordbredde = $0 }),
                      label: "Bordbredde", enhet: "mm", range: 60...198)
            ConfigRad(verdi: Binding(get: { vm.bordavstand }, set: { vm.bordavstand = $0 }),
                      label: "Bordavstand", enhet: "mm", range: 2...20)
            ConfigRad(verdi: Binding(get: { vm.bjelkeavstand }, set: { vm.bjelkeavstand = $0 }),
                      label: "Bjelkeavstand", enhet: "mm", range: 300...1200, step: 100)
            ConfigRad(verdi: Binding(get: { vm.skruerPerKryss }, set: { vm.skruerPerKryss = $0 }),
                      label: "Skruer per kryss", enhet: "stk", range: 1...4)
        }
    }
}

struct ConfigRad: View {
    @Binding var verdi: Double
    let label: String
    let enhet: String
    let range: ClosedRange<Double>
    var step: Double = 1

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(Int(verdi))")
                .font(.subheadline.weight(.semibold))
                .frame(width: 40, alignment: .trailing)
                .contentTransition(.numericText())
            Text(enhet)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            Stepper("", value: $verdi, in: range, step: step)
                .labelsHidden()
        }
    }
}

struct PrisConfigView: View {
    let vm: TerrasseViewModel

    var body: some View {
        VStack(spacing: 12) {
            PrisRad(verdi: Binding(get: { vm.prisBordPrLm }, set: { vm.prisBordPrLm = $0 }),
                    label: "Terrassebord", enhet: "kr/lm")
            PrisRad(verdi: Binding(get: { vm.prisBjelkePrLm }, set: { vm.prisBjelkePrLm = $0 }),
                    label: "Bjelker (\(vm.bjelkeDimensjon.rawValue))", enhet: "kr/lm")
            PrisRad(verdi: Binding(get: { vm.prisSkrue }, set: { vm.prisSkrue = $0 }),
                    label: "Skruer", enhet: "kr/stk")
            PrisRad(verdi: Binding(get: { vm.prisGjerdeBord }, set: { vm.prisGjerdeBord = $0 }),
                    label: "Gjerdebord", enhet: "kr/stk")
            PrisRad(verdi: Binding(get: { vm.prisLekt }, set: { vm.prisLekt = $0 }),
                    label: "Lekt", enhet: "kr/lm")
            PrisRad(verdi: Binding(get: { vm.prisStolpe }, set: { vm.prisStolpe = $0 }),
                    label: "Stolper", enhet: "kr/stk")
        }
    }
}

struct PrisRad: View {
    @Binding var verdi: Double
    let label: String
    let enhet: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(verdi, specifier: "%.0f")")
                .font(.subheadline.weight(.semibold))
                .contentTransition(.numericText())
            Text(enhet)
                .font(.caption)
                .foregroundStyle(.secondary)
            Stepper("", value: $verdi, in: 0...9999, step: 1)
                .labelsHidden()
        }
    }
}

struct GjerdeConfigView: View {
    let vm: TerrasseViewModel

    var body: some View {
        VStack(spacing: 12) {
            Picker("Type", selection: Binding(get: { vm.gjerdeType }, set: { vm.gjerdeType = $0 })) {
                ForEach(Gjerdetype.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)

            if vm.gjerdeType != .ingen {
                ConfigRad(verdi: Binding(get: { vm.gjerdeHøyde }, set: { vm.gjerdeHøyde = $0 }),
                          label: "Høyde", enhet: "m", range: 0.3...2.0, step: 0.1)
                Toggle(isOn: Binding(get: { vm.gjerdePåAlleSider }, set: { vm.gjerdePåAlleSider = $0 })) {
                    Text("På alle sider")
                        .font(.subheadline)
                }
                ConfigRad(verdi: Binding(get: { vm.stolpeAvstand }, set: { vm.stolpeAvstand = $0 }),
                          label: "Stolpeavstand", enhet: "m", range: 1.0...3.0, step: 0.5)
            }
        }
    }
}

struct TrappConfigView: View {
    let vm: TerrasseViewModel

    var body: some View {
        VStack(spacing: 14) {
            if vm.trapper.isEmpty {
                Text("Ingen trapper. Legg til en og velg hvilken kant den skal stå på.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(vm.trapper) { trapp in
                TrappRad(trapp: vm.bindingForTrapp(trapp)) {
                    withAnimation { vm.fjernTrapp(trapp) }
                }
            }

            Button {
                withAnimation { vm.leggTilTrapp() }
            } label: {
                Label("Legg til trapp", systemImage: "plus.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            if !vm.trapper.isEmpty {
                Divider()
                TrinnGeometriRad(label: "Inntrinn (dybde)", verdi: Binding(get: { vm.trappInntrinn }, set: { vm.trappInntrinn = $0 }), range: 0.20...0.40)
                TrinnGeometriRad(label: "Opptrinn (høyde)", verdi: Binding(get: { vm.trappOpptrinn }, set: { vm.trappOpptrinn = $0 }), range: 0.10...0.25)
            }
        }
    }
}

struct TrappRad: View {
    @Binding var trapp: Trapp
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Picker("Kant", selection: $trapp.side) {
                    ForEach(Terrasseside.allCases) { side in
                        Text(side.rawValue).tag(side)
                    }
                }
                .pickerStyle(.segmented)

                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }

            VStack(spacing: 4) {
                HStack {
                    Text("Plassering langs kanten")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(plasseringTekst)
                        .font(.caption.weight(.semibold))
                }
                Slider(value: $trapp.posisjon, in: 0...1)
                    .tint(Theme.accent)
            }

            HStack {
                Text("Bredde").font(.subheadline)
                Spacer()
                Text("\(trapp.bredde, specifier: "%.1f") m")
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText())
                Stepper("", value: $trapp.bredde, in: 0.5...4.0, step: 0.1)
                    .labelsHidden()
            }

            HStack {
                Text("Antall trinn").font(.subheadline)
                Spacer()
                Text("\(trapp.antallTrinn)")
                    .font(.subheadline.weight(.semibold))
                    .contentTransition(.numericText())
                Stepper("", value: $trapp.antallTrinn, in: 1...20)
                    .labelsHidden()
            }
        }
        .padding(12)
        .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var plasseringTekst: String {
        switch trapp.posisjon {
        case ..<0.34: return "Mot start"
        case ..<0.67: return "Midt"
        default: return "Mot slutt"
        }
    }
}

struct TrinnGeometriRad: View {
    let label: String
    @Binding var verdi: Double
    let range: ClosedRange<Double>

    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            Text("\(Int(verdi * 1000)) mm")
                .font(.subheadline.weight(.semibold))
                .contentTransition(.numericText())
            Stepper("", value: $verdi, in: range, step: 0.01)
                .labelsHidden()
        }
    }
}
