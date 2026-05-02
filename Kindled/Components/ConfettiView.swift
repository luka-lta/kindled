import SwiftUI
import UIKit

struct ConfettiView: UIViewRepresentable {
    let fireID: UUID?

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let id = fireID, id != context.coordinator.lastFiredID else { return }
        context.coordinator.lastFiredID = id
        fire(in: uiView)
    }

    private func fire(in view: UIView) {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.midX, y: -20)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        emitter.emitterCells = makeCells()
        view.layer.addSublayer(emitter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            emitter.removeFromSuperlayer()
        }
    }

    private func makeCells() -> [CAEmitterCell] {
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow,
            .systemPurple, .systemOrange, .systemPink, .cyan
        ]
        return colors.flatMap { color in
            [makeCell(color: color, rect: true), makeCell(color: color, rect: false)]
        }
    }

    private func makeCell(color: UIColor, rect: Bool) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 4
        cell.lifetime = 5
        cell.velocity = 230
        cell.velocityRange = 90
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 5
        cell.spin = 4
        cell.spinRange = 8
        cell.scale = 0.07
        cell.scaleRange = 0.04
        cell.alphaSpeed = -0.18
        cell.color = color.cgColor
        cell.contents = makeImage(rect: rect)?.cgImage
        return cell
    }

    private func makeImage(rect: Bool) -> UIImage? {
        let size = rect ? CGSize(width: 14, height: 7) : CGSize(width: 9, height: 9)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor.white.setFill()
            if rect {
                ctx.fill(CGRect(origin: .zero, size: size))
            } else {
                ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            }
        }
    }

    class Coordinator {
        var lastFiredID: UUID?
    }
}

struct ConfettiOverlay: View {
    let fireID: UUID?

    var body: some View {
        ConfettiView(fireID: fireID)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
