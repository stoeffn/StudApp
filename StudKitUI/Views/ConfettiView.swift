//
//  StudApp—Stud.IP to Go
//  Copyright © 2018, Steffen Ryll
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/.
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
        layer.emitterShape = convertToCAEmitterLayerEmitterShape(convertFromCAEmitterLayerEmitterShape(CAEmitterLayerEmitterShape.line))
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAEmitterLayerEmitterShape(_ input: String) -> CAEmitterLayerEmitterShape {
	return CAEmitterLayerEmitterShape(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAEmitterLayerEmitterShape(_ input: CAEmitterLayerEmitterShape) -> String {
	return input.rawValue
}
