import SwiftUI

struct ContentView: View {
    @State private var vm = TerrasseViewModel()
    @State private var visPDF = false
    @State private var visPrisoppsett = false
    @AppStorage("harSettPrisoppsett") private var harSettPrisoppsett = false

    private let minioURL = URL(string: "https://minio.no")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HeroView(vm: vm)
                    ShapeSelectorView(valgtForm: $vm.valgtForm)
                    MaleInnView(vm: vm)

                    if let resultat = vm.resultat {
                        SectionCard(icon: "list.bullet.clipboard", title: "Beregning", subtitle: "Materialer og kostnad") {
                            ResultatKortView(resultat: resultat, gjerdeType: vm.gjerdeType)
                        }
                    }

                    minioFooter
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
            .background(bakgrunn)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("TerrassePlan")
            .navigationBarTitleDisplayMode(.large)
            .safeAreaInset(edge: .bottom) {
                if let resultat = vm.resultat {
                    kostnadsBjelke(resultat)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Link(destination: minioURL) {
                        HStack(spacing: 5) {
                            Image(systemName: "leaf.fill")
                                .font(.caption2.weight(.bold))
                            Text("minio.no")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(Theme.minio, in: Capsule())
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        vm.oppdaterLagrede()
                        vm.visLasting = true
                    } label: {
                        Image(systemName: "folder")
                    }
                    Menu {
                        Button {
                            vm.nyttProsjekt()
                            visPrisoppsett = true
                        } label: {
                            Label("Nytt prosjekt", systemImage: "square.and.pencil")
                        }
                        Button {
                            vm.visLagring = true
                        } label: {
                            Label("Lagre prosjekt", systemImage: "square.and.arrow.down")
                        }
                        Button {
                            visPrisoppsett = true
                        } label: {
                            Label("Materialpriser", systemImage: "tag")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $vm.visLagring) { lagreArk }
            .sheet(isPresented: $vm.visLasting) { lastInnArk }
            .sheet(isPresented: $visPDF) {
                PDFExportSheet(vm: vm)
            }
            .sheet(isPresented: $visPrisoppsett) {
                PrisoppsettSheet(vm: vm)
            }
            .onAppear {
                if !harSettPrisoppsett {
                    harSettPrisoppsett = true
                    visPrisoppsett = true
                }
            }
        }
    }

    private var bakgrunn: some View {
        LinearGradient(
            colors: [Theme.accent.opacity(0.06), Color(.systemGroupedBackground)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Sticky kostnadsbjelke

    private func kostnadsBjelke(_ resultat: BeregnetResultat) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 1) {
                Text("Estimert kostnad")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(resultat.totalKostnad, specifier: "%.0f") kr")
                    .font(.title3.weight(.bold))
                    .contentTransition(.numericText())
            }

            Spacer()

            Button {
                visPDF = true
            } label: {
                Label("Eksporter PDF", systemImage: "doc.text")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Theme.cost, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    // MARK: - minio.no footer

    private var minioFooter: some View {
        Link(destination: minioURL) {
            HStack(spacing: 14) {
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Levert av minio.no")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Besøk nettsiden for terrasse og materialer")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(18)
            .background(Theme.minio, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Theme.accent.opacity(0.3), radius: 14, x: 0, y: 8)
        }
        .padding(.top, 4)
    }

    // MARK: - Lagre / last inn

    private var lagreArk: some View {
        NavigationStack {
            Form {
                Section("Gi prosjektet et navn") {
                    TextField("F.eks. Terrasse sørvest", text: $vm.lagringsNavn)
                }
                Section {
                    Button {
                        vm.lagreDesign()
                        vm.visLagring = false
                    } label: {
                        Label("Lagre prosjekt", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(vm.lagringsNavn.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Lagre prosjekt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { vm.visLagring = false }
                }
            }
        }
        .presentationDetents([.height(220)])
    }

    private var lastInnArk: some View {
        NavigationStack {
            Group {
                if vm.lagredeDesign.isEmpty {
                    ContentUnavailableView(
                        "Ingen lagrede prosjekter",
                        systemImage: "tray.and.arrow.down",
                        description: Text("Lagre terrasseprosjektene dine, så finner du dem igjen her.")
                    )
                } else {
                    List {
                        ForEach(vm.lagredeDesign) { design in
                            Button {
                                vm.lastInn(design)
                                vm.visLasting = false
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: "square.dashed.inset.filled")
                                        .font(.title3)
                                        .foregroundStyle(Theme.accent)
                                        .frame(width: 40, height: 40)
                                        .background(Theme.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(design.navn)
                                            .font(.headline)
                                        HStack(spacing: 8) {
                                            Text(design.formRawValue)
                                                .font(.caption.weight(.medium))
                                                .padding(.horizontal, 7)
                                                .padding(.vertical, 2)
                                                .background(Theme.accent.opacity(0.12), in: Capsule())
                                                .foregroundStyle(Theme.accent)
                                            Text(design.dato, style: .date)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.tertiary)
                                }
                                .foregroundStyle(.primary)
                                .padding(.vertical, 4)
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
            .navigationTitle("Mine prosjekter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Lukk") { vm.visLasting = false }
                }
            }
        }
    }
}
