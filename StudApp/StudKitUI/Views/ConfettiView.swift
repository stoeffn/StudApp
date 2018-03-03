//
//  ConfettiView.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 17.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class ConfettiView: UIView {

    // MARK: - Life Cycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    // MARK: - User Interface

    private lazy var emitterLayer: CAEmitterLayer = {
        let layer = CAEmitterLayer()
        layer.emitterShape = kCAEmitterLayerLine
        layer.emitterCells = UI.Colors.pickerColors.values.map { confetto(withColor: $0.color) }
        return layer
    }()

    public override var bounds: CGRect {
        didSet { updateEmitterLayerFrame() }
    }

    @IBInspectable public var intensity: CGFloat = 1.0 {
        didSet { updateIntensity() }
    }

    private func initUserInterface() {
        layer.addSublayer(emitterLayer)
        updateEmitterLayerFrame()
        updateIntensity()
    }

    private func updateEmitterLayerFrame() {
        emitterLayer.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
        emitterLayer.emitterSize = CGSize(width: frame.size.width, height: 0)
    }

    private func confetto(withColor color: UIColor) -> CAEmitterCell {
        let confetto = CAEmitterCell()
        confetto.lifetimeRange = 0
        confetto.color = color.cgColor
        confetto.emissionLongitude = .pi
        confetto.emissionRange = .pi / 4.0
        confetto.scale = 0.3
        confetto.contents = #imageLiteral(resourceName: "ConfettoGlyph").cgImage
        return confetto
    }

    private func updateIntensity() {
        for confetto in emitterLayer.emitterCells ?? [] {
            confetto.birthRate = 8.0 * Float(intensity)
            confetto.lifetime = 8.0 * Float(intensity)
            confetto.velocity = 360.0 * intensity
            confetto.velocityRange = 42.0 * intensity
            confetto.spin = 2.0 * intensity
            confetto.spinRange = 2.0 * intensity
            confetto.scaleRange = 0.5 * intensity
            confetto.scaleSpeed = -0.1 * intensity
        }
    }
}
