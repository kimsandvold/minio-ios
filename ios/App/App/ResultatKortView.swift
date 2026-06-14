import SwiftUI

struct ResultatKortView: View {
    let resultat: BeregnetResultat
    let gjerdeType: Gjerdetype

    var body: some View {
        VStack(spacing: 16) {
            if resultat.areal > 0 {
                hovedKort(title: "Totalt areal", verdi: resultat.arealFormattert, ikon: "square.grid.3x3.fill", color: .green)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                kort(ikon: "rectangle.split.2x2", tittel: "Terrassebord", verdi: "\(resultat.bordAntall) stk", sub: resultat.bordFormattert, color: .orange)
                kort(ikon: "rectangle.3.group", tittel: "Bjelker", verdi: "\(resultat.bjelkeAntall) stk", sub: resultat.bjelkeFormattert, color: .brown)
                kort(ikon: "gearshape.2", tittel: "Skruer", verdi: "\(resultat.skrueAntall)", sub: resultat.skrueFormattert, color: .blue)

                if gjerdeType != .ingen {
                    kort(ikon: "fence", tittel: gjerdeType.rawValue, verdi: "\(resultat.gjerdeBordAntall ?? 0) stk", sub: resultat.gjerdeFormattert ?? "", color: .green)
                }

                if let t = resultat.trappFormattert {
                    kort(ikon: "stairs", tittel: "Trapp", verdi: "\(resultat.trappTrinnAntall ?? 0) trinn", sub: t, color: .purple)
                }
            }

            Divider()

            // Kostnadsoversikt
            VStack(spacing: 8) {
                Text("Kostnadsoversikt")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                kostRad("Terrassebord", resultat.bordKostnad)
                kostRad("Bjelkelag", resultat.bjelkeKostnad)
                kostRad("Skruer", resultat.skrueKostnad)

                if let g = resultat.gjerdeKostnad {
                    kostRad("Gjerde", g)
                }

                if let t = resultat.trappKostnad {
                    kostRad("Trapp", t)
                }

                Divider()
                    .padding(.vertical, 4)

                HStack {
                    Text("Total kostnad")
                        .font(.title3.weight(.bold))
                    Spacer()
                    Text("\(resultat.totalKostnad, specifier: "%.0f") kr")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.green)
                        .contentTransition(.numericText())
                }
            }
            .padding()
            .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func kostRad(_ label: String, _ belop: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(belop, specifier: "%.0f") kr")
                .font(.subheadline.weight(.semibold))
                .contentTransition(.numericText())
        }
    }

    private func hovedKort(title: String, verdi: String, ikon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: ikon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(verdi)
                    .font(.title.weight(.bold))
                    .contentTransition(.numericText())
            }
            Spacer()
        }
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func kort(ikon: String, tittel: String, verdi: String, sub: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: ikon)
                    .font(.caption)
                    .foregroundStyle(color)
                    .frame(width: 24, height: 24)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
                Text(tittel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Text(verdi)
                .font(.callout.weight(.semibold))
                .contentTransition(.numericText())
            Text(sub)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    let r = BeregnetResultat(
        areal: 15.0,
        arealFormattert: "15.00 m²",
        bordAntall: 24,
        bordLøpemeter: 120,
        bordFormattert: "24 stk × 5000mm",
        bordKostnad: 18000,
        bjelkeAntall: 10,
        bjelkeLøpemeter: 30,
        bjelkeFormattert: "10 stk × 3000mm",
        bjelkeKostnad: 6000,
        skrueAntall: 480,
        skrueFormattert: "480 stk 2 per kryss",
        skrueKostnad: 1440,
        gjerdeBordAntall: 20,
        gjerdeStolper: 8,
        gjerdeFormattert: "Vannrett: 20 bord, 8 stolper",
        gjerdeKostnad: 4000,
        trappTrinnAntall: 3,
        trappVanger: 3,
        trappFormattert: "3 trinn, 1.0m bredde",
        trappKostnad: 1500,
        totalKostnad: 30940
    )
    ResultatKortView(resultat: r, gjerdeType: .vannrett)
        .padding()
}
