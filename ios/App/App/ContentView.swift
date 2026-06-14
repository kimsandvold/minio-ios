import SwiftUI

struct ContentView: View {
    @State private var vm = TerrasseViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ShapeCanvasView(vm: vm)
                    ShapeSelectorView(valgtForm: $vm.valgtForm)
                    MaleInnView(vm: vm)

                    if let resultat = vm.resultat {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Beregning")
                                .font(.title2.weight(.bold))
                            ResultatKortView(resultat: resultat, gjerdeType: vm.gjerdeType)
                        }
                        PDFForhandsvisningView(vm: vm)
                    }

                    Link(destination: URL(string: "https://minio.no")!) {
                        HStack(spacing: 6) {
                            Text("Levert av")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text("minio.no")
                                .font(.caption.weight(.semibold))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .navigationTitle("TerrassePlan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        vm.visLagring = true
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                    }

                    Button {
                        vm.oppdaterLagrede()
                        vm.visLasting = true
                    } label: {
                        Image(systemName: "folder")
                    }
                }
            }
            .sheet(isPresented: $vm.visLagring) {
                lagreArk
            }
            .sheet(isPresented: $vm.visLasting) {
                lastInnArk
            }
        }
    }

    private var lagreArk: some View {
        NavigationStack {
            Form {
                Section("Gi designet et navn") {
                    TextField("Navn", text: $vm.lagringsNavn)
                }
                Section {
                    Button("Lagre") {
                        vm.lagreDesign()
                        vm.visLagring = false
                    }
                    .disabled(vm.lagringsNavn.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Lagre design")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { vm.visLagring = false }
                }
            }
        }
        .presentationDetents([.height(200)])
    }

    private var lastInnArk: some View {
        NavigationStack {
            Group {
                if vm.lagredeDesign.isEmpty {
                    ContentUnavailableView(
                        "Ingen lagrede design",
                        systemImage: "folder",
                        description: Text("Dine lagrede terrassedesign vises her.")
                    )
                } else {
                    List {
                        ForEach(vm.lagredeDesign) { design in
                            Button {
                                vm.lastInn(design)
                                vm.visLasting = false
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(design.navn)
                                        .font(.headline)
                                    HStack(spacing: 12) {
                                        Text(design.formRawValue)
                                            .font(.caption)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
                                        Text(design.dato, style: .date)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .onDelete { indexSet in
                            for i in indexSet {
                                vm.slettDesign(vm.lagredeDesign[i])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Last inn design")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Lukk") { vm.visLasting = false }
                }
            }
        }
    }
}
