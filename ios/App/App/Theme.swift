import SwiftUI

/// Sentralt designsystem for TerrassePlan – farger, gradienter og gjenbrukbare kort.
enum Theme {
    // MARK: - Farger
    static let accent = Color(red: 0.14, green: 0.55, blue: 0.42)      // skog-grønn
    static let accentDeep = Color(red: 0.09, green: 0.36, blue: 0.40)  // dyp teal
    static let wood = Color(red: 0.64, green: 0.43, blue: 0.24)        // varmt tre
    static let woodLight = Color(red: 0.80, green: 0.60, blue: 0.36)

    // MARK: - Gradienter
    static let hero = LinearGradient(
        colors: [accent, accentDeep],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let cost = LinearGradient(
        colors: [accent, accentDeep],
        startPoint: .leading, endPoint: .trailing
    )

    static let deck = Gradient(colors: [woodLight, wood])

    static let minio = LinearGradient(
        colors: [Color(red: 0.20, green: 0.62, blue: 0.50), accentDeep],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - Kort-stil

private struct CardModifier: ViewModifier {
    var padding: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 6)
    }
}

extension View {
    func card(padding: CGFloat = 18) -> some View {
        modifier(CardModifier(padding: padding))
    }
}

// MARK: - Seksjonskort med sammenslåing

struct SectionCard<Content: View>: View {
    let icon: String
    let title: String
    var tint: Color = Theme.accent
    var subtitle: String? = nil
    @State private var expanded: Bool
    @ViewBuilder var content: () -> Content

    init(
        icon: String,
        title: String,
        tint: Color = Theme.accent,
        subtitle: String? = nil,
        initiallyExpanded: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.tint = tint
        self.subtitle = subtitle
        self._expanded = State(initialValue: initiallyExpanded)
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    expanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 38, height: 38)
                        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 11, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(expanded ? 0 : -90))
                }
            }
            .buttonStyle(.plain)

            if expanded {
                content()
                    .padding(.top, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .card()
    }
}

// MARK: - Liten statusmerke-pille

struct StatBadge: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline.weight(.bold))
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
