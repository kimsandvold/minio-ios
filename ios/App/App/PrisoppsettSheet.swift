import SwiftUI

/// Prisoppsett som vises når man starter et nytt prosjekt – bekreft dagens
/// materialpriser per meter før beregning.
struct PrisoppsettSheet: View {
    let vm: TerrasseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "tag.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(Theme.cost, in: RoundedRectangle(cornerRadius: 10))
                        Text("Bekreft dagens priser. Alt regnes om automatisk.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Terrassebord") {
                    prisFelt("Terrassebord", verdi: Binding(get: { vm.prisBordPrLm }, set: { vm.prisBordPrLm = $0 }), enhet: "kr/lm")
                }

                Section("Konstruksjonsvirke (bjelker)") {
                    Picker("Dimensjon", selection: Binding(get: { vm.bjelkeDimensjon }, set: { vm.bjelkeDimensjon = $0 })) {
                        ForEach(Bjelkedimensjon.allCases) { dim in
                            Text(dim.rawValue).tag(dim)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: vm.bjelkeDimensjon) { _, ny in
                        vm.prisBjelkePrLm = ny.standardpris
                    }
                    prisFelt("Pris", verdi: Binding(get: { vm.prisBjelkePrLm }, set: { vm.prisBjelkePrLm = $0 }), enhet: "kr/lm")
                }

                Section("Lekt") {
                    prisFelt("Lekt", verdi: Binding(get: { vm.prisLekt }, set: { vm.prisLekt = $0 }), enhet: "kr/lm")
                }

                Section("Festemateriell og gjerde") {
                    prisFelt("Skruer", verdi: Binding(get: { vm.prisSkrue }, set: { vm.prisSkrue = $0 }), enhet: "kr/stk")
                    prisFelt("Gjerdebord", verdi: Binding(get: { vm.prisGjerdeBord }, set: { vm.prisGjerdeBord = $0 }), enhet: "kr/stk")
                    prisFelt("Stolper", verdi: Binding(get: { vm.prisStolpe }, set: { vm.prisStolpe = $0 }), enhet: "kr/stk")
                }

                Section {
                    Button {
                        dismiss()
                    } label: {
                        Label("Start prosjekt", systemImage: "arrow.right.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
            .navigationTitle("Materialpriser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
    }

    private func prisFelt(_ navn: String, verdi: Binding<Double>, enhet: String) -> some View {
        HStack {
            Text(navn)
            Spacer()
            TextField("0", value: verdi, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                .font(.body.weight(.semibold))
            Text(enhet)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .leading)
        }
    }
}
