import SwiftUI
import QuickLook

/// Ren ark-basert PDF-eksport. Genererer PDF og lar brukeren forhåndsvise og dele.
struct PDFExportSheet: View {
    let vm: TerrasseViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var pdfURL: URL?

    var body: some View {
        NavigationStack {
            Group {
                if let url = pdfURL {
                    QuickLookPreview(url: url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack(spacing: 14) {
                        ProgressView()
                        Text("Lager PDF …")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Materialliste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Lukk") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let url = pdfURL {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .task {
            let data = PDFGenerator.genererPDF(vm: vm)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("TerrassePlan.pdf")
            try? data.write(to: url)
            pdfURL = url
        }
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: QLPreviewController, context: Context) {
        context.coordinator.url = url
        controller.reloadData()
    }

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    class Coordinator: QLPreviewControllerDataSource {
        var url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}
