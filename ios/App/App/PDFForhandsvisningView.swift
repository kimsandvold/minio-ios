import SwiftUI
import QuickLook

struct PDFForhandsvisningView: View {
    let vm: TerrasseViewModel

    @State private var pdfURL: URL?

    var body: some View {
        VStack(spacing: 16) {
            if let url = pdfURL {
                QuickLookPreview(url: url)
                    .frame(maxHeight: .infinity)

                ShareLink(item: url) {
                    Label("Del PDF", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 8)
            } else {
                ProgressView()
                    .task {
                        let data = PDFGenerator.genererPDF(vm: vm)
                    let url = FileManager.default.temporaryDirectory.appendingPathComponent("TerrassePlan.pdf")
                    try? data.write(to: url)
                    pdfURL = url
                    }
            }
        }
        .onChange(of: vm.valgtForm) { _ in pdfURL = nil }
        .onChange(of: vm.lengde) { _ in pdfURL = nil }
        .onChange(of: vm.bredde) { _ in pdfURL = nil }
        .padding()
    }
}

struct QuickLookPreview: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return UINavigationController(rootViewController: controller)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        if let controller = uiViewController.topViewController as? QLPreviewController {
            controller.dataSource = context.coordinator
            controller.reloadData()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(url: url) }

    class Coordinator: QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}
