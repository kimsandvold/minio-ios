import SwiftUI

struct ShapeSelectorView: View {
    @Binding var valgtForm: TerrasseForm

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TerrasseForm.allCases) { form in
                    Button {
                        withAnimation(.spring(response: 0.35)) {
                            valgtForm = form
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: form.ikon)
                                .font(.title2)
                                .frame(width: 32, height: 32)
                            Text(form.rawValue)
                                .font(.caption.weight(.medium))
                            Text(form.beskrivelse)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        .frame(width: 100)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background {
                            if valgtForm == form {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.tint.opacity(0.12))
                                    .stroke(.tint, lineWidth: 1.5)
                            } else {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(.fill.quaternary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    ShapeSelectorView(valgtForm: .constant(.rektangel))
        .padding()
}
