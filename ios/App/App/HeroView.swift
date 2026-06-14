import SwiftUI

/// Iøynefallende toppkort som viser terrasseformen og live areal.
struct HeroView: View {
    let vm: TerrasseViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Din terrasse")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                    Text(vm.valgtForm.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        vm.visRotert.toggle()
                    }
                } label: {
                    Image(systemName: "rotate.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.18), in: Circle())
                }
                .buttonStyle(.plain)
            }

            ShapeCanvasView(vm: vm)
                .frame(height: 230)

            HStack(spacing: 10) {
                StatBadge(icon: "square.dashed", label: "Areal", value: vm.resultat?.arealFormattert ?? "–")
                if let r = vm.resultat {
                    StatBadge(icon: "rectangle.split.2x2", label: "Terrassebord", value: "\(r.bordAntall) stk")
                }
                Spacer()
            }
        }
        .padding(18)
        .background(Theme.hero, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: Theme.accentDeep.opacity(0.35), radius: 20, x: 0, y: 10)
    }
}
