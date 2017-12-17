//
//  ConfettiView.swift
//  StudKit
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

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    // MARK: - User Interface

    private lazy var emitterLayer: CAEmitterLayer = {
        let layer = CAEmitterLayer()
        layer.emitterShape = kCAEmitterLayerLine
        layer.emitterCells = UI.Colors.pickerColors.values.map(confetto)
        return layer
    }()

    public override var frame: CGRect {
        didSet { updateEmitterLayerFrame() }
    }

    @IBInspectable public var intensity: Float = 1

    private func initUserInterface() {
        layer.addSublayer(emitterLayer)
        updateEmitterLayerFrame()
    }

    private func updateEmitterLayerFrame() {
        emitterLayer.emitterPosition = CGPoint(x: frame.size.width / 2, y: 0)
        emitterLayer.emitterSize = CGSize(width: frame.size.width, height: 1)
    }

    private func confetto(withColor color: UIColor) -> CAEmitterCell {
        let confetto = CAEmitterCell()
        confetto.birthRate = 8.0 * intensity
        confetto.lifetime = 8.0 * intensity
        confetto.lifetimeRange = 0
        confetto.color = color.cgColor
        confetto.velocity = CGFloat(360.0 * intensity)
        confetto.velocityRange = CGFloat(42.0 * intensity)
        confetto.emissionLongitude = .pi
        confetto.emissionRange = .pi / 4.0
        confetto.spin = CGFloat(2.0 * intensity)
        confetto.spinRange = CGFloat(2.0 * intensity)
        confetto.scale = 0.3
        confetto.scaleRange = CGFloat(0.5 * intensity)
        confetto.scaleSpeed = CGFloat(-0.1 * intensity)
        confetto.contents = #imageLiteral(resourceName: "Confetto").cgImage
        return confetto
    }
}
