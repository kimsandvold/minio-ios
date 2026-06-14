import SwiftUI
import SceneKit

/// Fullskjerm 3D-modell av terrassen med veksling mellom ferdig og konstruksjon.
struct Model3DView: View {
    let vm: TerrasseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var visKonstruksjon = false

    var body: some View {
        ZStack(alignment: .top) {
            TerrasseSceneView(vm: vm, visKonstruksjon: visKonstruksjon)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.35), in: Circle())
                    }
                    Spacer()
                }

                Picker("", selection: $visKonstruksjon) {
                    Text("Ferdig").tag(false)
                    Text("Konstruksjon").tag(true)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .padding()

            VStack {
                Spacer()
                Text("Dra for å rotere  ·  knip for å zoome")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.3), in: Capsule())
                    .padding(.bottom, 24)
            }
        }
        .background(Color.black)
    }
}

// MARK: - SceneKit-bro

struct TerrasseSceneView: UIViewRepresentable {
    let vm: TerrasseViewModel
    let visKonstruksjon: Bool

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.backgroundColor = UIColor(red: 0.82, green: 0.88, blue: 0.92, alpha: 1)
        let built = TerrasseSceneBuilder.build(vm: vm)
        view.scene = built.scene
        context.coordinator.finished = built.finished
        context.coordinator.framing = built.framing
        oppdater(context: context)
        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        oppdater(context: context)
    }

    private func oppdater(context: Context) {
        context.coordinator.finished?.isHidden = visKonstruksjon
        context.coordinator.framing?.isHidden = !visKonstruksjon
    }

    final class Coordinator {
        var finished: SCNNode?
        var framing: SCNNode?
    }
}

// MARK: - Scene-bygger

enum TerrasseSceneBuilder {
    // Faste mål (meter)
    static let deckTop: Float = 0.6
    static let boardThickness: Float = 0.028
    static let postSize: CGFloat = 0.07

    @MainActor
    static func build(vm: TerrasseViewModel) -> (scene: SCNScene, finished: SCNNode, framing: SCNNode) {
        let scene = SCNScene()
        let root = scene.rootNode

        let m = vm.normalizedDimensions()
        let modelW = Float(m.width)
        let modelH = Float(m.height)
        let rekter = vm.modellRekter()

        let jh = Float(vm.bjelkeDimensjon.høyde) / 1000
        let boardBottom = deckTop - boardThickness
        let joistTop = boardBottom
        let joistBottom = joistTop - jh

        func wx(_ mx: CGFloat) -> Float { Float(mx) - modelW / 2 }
        func wz(_ my: CGFloat) -> Float { Float(my) - modelH / 2 }

        // Materialer
        let wood = material(UIColor(red: 0.66, green: 0.46, blue: 0.27, alpha: 1))
        let woodTop = material(UIColor(red: 0.76, green: 0.56, blue: 0.34, alpha: 1))
        let beam = material(UIColor(red: 0.50, green: 0.34, blue: 0.20, alpha: 1))
        let metal = material(UIColor(white: 0.45, alpha: 1))

        let finished = SCNNode()
        let framing = SCNNode()
        let always = SCNNode()
        root.addChildNode(finished)
        root.addChildNode(framing)
        root.addChildNode(always)

        // Bakke
        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial = material(UIColor(red: 0.62, green: 0.72, blue: 0.55, alpha: 1))
        always.addChildNode(SCNNode(geometry: floor))

        // Per rektangel: planker (ferdig), bjelkeband (ferdig), bjelker + sidebjelker (konstruksjon), stolper
        for r in rekter {
            // Ferdig: solid bjelkeband (gir tykk terrassekant)
            let band = box(w: r.width, h: CGFloat(jh), l: r.height, mat: wood)
            band.position = SCNVector3(wx(r.midX), joistTop - jh / 2, wz(r.midY))
            finished.addChildNode(band)

            // Ferdig: terrassebord på langs (langs dybde / Z)
            let plankW = max(0.04, CGFloat(vm.bordbredde) / 1000)
            let gap = CGFloat(vm.bordavstand) / 1000
            var x = r.minX
            while x < r.maxX - 0.001 {
                let wActual = min(plankW, r.maxX - x)
                let plank = box(w: wActual, h: CGFloat(boardThickness), l: r.height, mat: woodTop)
                plank.position = SCNVector3(wx(x + wActual / 2), deckTop - boardThickness / 2, wz(r.midY))
                finished.addChildNode(plank)
                x += plankW + gap
            }

            // Konstruksjon: bjelker på tvers (langs X), med bjelkeavstand langs Z
            let dj = max(0.1, CGFloat(vm.bjelkeavstand) / 1000)
            var y = r.minY
            while y <= r.maxY + 0.001 {
                let joist = box(w: r.width, h: CGFloat(jh), l: 0.048, mat: beam)
                joist.position = SCNVector3(wx(r.midX), joistTop - jh / 2, wz(min(y, r.maxY)))
                framing.addChildNode(joist)
                y += dj
            }
            // Konstruksjon: sidebjelker (langs Z) ved hver langside
            for edgeX in [r.minX + 0.024, r.maxX - 0.024] {
                let side = box(w: 0.048, h: CGFloat(jh), l: r.height, mat: beam)
                side.position = SCNVector3(wx(edgeX), joistTop - jh / 2, wz(r.midY))
                framing.addChildNode(side)
            }

            // Stolper i hjørnene (konstruksjon)
            let postH = max(0.05, joistBottom)
            for cx in [r.minX + 0.1, r.maxX - 0.1] {
                for cy in [r.minY + 0.1, r.maxY - 0.1] {
                    let post = box(w: postSize, h: CGFloat(postH), l: postSize, mat: metal)
                    post.position = SCNVector3(wx(cx), postH / 2, wz(cy))
                    framing.addChildNode(post)
                }
            }
        }

        // Rekkverk (ferdig) – kun rektangel for korrekt plassering
        if vm.gjerdeType != .ingen, vm.valgtForm == .rektangel {
            let gh = Float(vm.gjerdeHøyde)
            byggRekkverk(on: finished, modelW: modelW, modelH: modelH, deckTop: deckTop, høyde: gh, wx: wx, wz: wz, mat: wood)
        }

        // Trapper (begge moduser)
        for trapp in vm.trapper {
            byggTrapp(trapp, vm: vm, modelW: modelW, modelH: modelH, on: always, mat: woodTop)
        }

        // Lys
        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 900
        sun.light?.castsShadow = true
        sun.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 5, 0)
        root.addChildNode(sun)

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 450
        root.addChildNode(ambient)

        // Kamera
        let maxDim = max(modelW, modelH, 2)
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.camera?.fieldOfView = 50
        cam.position = SCNVector3(maxDim * 0.9, maxDim * 0.85 + deckTop, maxDim * 1.15)
        cam.look(at: SCNVector3(0, deckTop * 0.4, 0))
        root.addChildNode(cam)

        return (scene, finished, framing)
    }

    // MARK: - Hjelpere

    private static func material(_ color: UIColor) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.roughness.contents = 0.9
        mat.lightingModel = .physicallyBased
        return mat
    }

    private static func box(w: CGFloat, h: CGFloat, l: CGFloat, mat: SCNMaterial) -> SCNNode {
        let g = SCNBox(width: max(w, 0.001), height: max(h, 0.001), length: max(l, 0.001), chamferRadius: 0.003)
        g.materials = [mat]
        return SCNNode(geometry: g)
    }

    private static func byggRekkverk(on parent: SCNNode, modelW: Float, modelH: Float, deckTop: Float, høyde: Float, wx: (CGFloat) -> Float, wz: (CGFloat) -> Float, mat: SCNMaterial) {
        let railY = deckTop + høyde
        // Topprekke langs de fire kantene
        let lang = box(w: CGFloat(modelW), h: 0.05, l: 0.05, mat: mat)
        lang.position = SCNVector3(0, railY, -modelH / 2)
        parent.addChildNode(lang)
        let lang2 = box(w: CGFloat(modelW), h: 0.05, l: 0.05, mat: mat)
        lang2.position = SCNVector3(0, railY, modelH / 2)
        parent.addChildNode(lang2)
        let tvers = box(w: 0.05, h: 0.05, l: CGFloat(modelH), mat: mat)
        tvers.position = SCNVector3(-modelW / 2, railY, 0)
        parent.addChildNode(tvers)
        let tvers2 = box(w: 0.05, h: 0.05, l: CGFloat(modelH), mat: mat)
        tvers2.position = SCNVector3(modelW / 2, railY, 0)
        parent.addChildNode(tvers2)
        // Hjørnestolper
        for sx in [-modelW / 2, modelW / 2] {
            for sz in [-modelH / 2, modelH / 2] {
                let stolpe = box(w: 0.06, h: CGFloat(høyde), l: 0.06, mat: mat)
                stolpe.position = SCNVector3(sx, deckTop + høyde / 2, sz)
                parent.addChildNode(stolpe)
            }
        }
    }

    @MainActor
    private static func byggTrapp(_ trapp: Trapp, vm: TerrasseViewModel, modelW: Float, modelH: Float, on parent: SCNNode, mat: SCNMaterial) {
        let m = vm.normalizedDimensions()
        let fr = vm.trappRektModell(trapp, modelSize: m)
        let n = max(1, trapp.antallTrinn)
        let riser = Float(vm.trappOpptrinn)
        let tread = Float(vm.trappInntrinn)
        let width = trapp.bredde

        func wx(_ mx: CGFloat) -> Float { Float(mx) - modelW / 2 }
        func wz(_ my: CGFloat) -> Float { Float(my) - modelH / 2 }

        for i in 0..<n {
            let topY = deckTop - Float(i + 1) * riser
            let centerY = topY + riser / 2
            let step: SCNNode
            switch trapp.side {
            case .front:
                step = box(w: width, h: CGFloat(riser), l: CGFloat(tread), mat: mat)
                step.position = SCNVector3(wx(fr.midX), centerY, wz(CGFloat(modelH) + CGFloat(Float(i) + 0.5) * CGFloat(tread)))
            case .bak:
                step = box(w: width, h: CGFloat(riser), l: CGFloat(tread), mat: mat)
                step.position = SCNVector3(wx(fr.midX), centerY, wz(-CGFloat(Float(i) + 0.5) * CGFloat(tread)))
            case .venstre:
                step = box(w: CGFloat(tread), h: CGFloat(riser), l: width, mat: mat)
                step.position = SCNVector3(wx(-CGFloat(Float(i) + 0.5) * CGFloat(tread)), centerY, wz(fr.midY))
            case .høyre:
                step = box(w: CGFloat(tread), h: CGFloat(riser), l: width, mat: mat)
                step.position = SCNVector3(wx(CGFloat(modelW) + CGFloat(Float(i) + 0.5) * CGFloat(tread)), centerY, wz(fr.midY))
            }
            parent.addChildNode(step)
        }
    }
}
