//
//  StudIpActivityButton.swift
//  StudKit
//
//  Created by Steffen Ryll on 09.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

@IBDesignable
public final class StudIpActivityButton: UIButton {
    public enum ActivityState {
        case idle, inProgress
    }

    // MARK: - Life Cycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUserInterface()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    public override var frame: CGRect {
        didSet {
            activityIndicator.frame = frame
        }
    }

    // MARK: - User Interface

    private let animationDuration = 0.3
    private let disabledTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    private let activityIndicator = StudIpActivityIndicatorView()

    private func initUserInterface() {
        addSubview(activityIndicator)
    }

    public override var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }

            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.setButtonHidden(!self.isEnabled)
            }, completion: nil)
        }
    }

    public var activityState: ActivityState = .idle {
        didSet {
            guard activityState != oldValue else { return }

            switch activityState {
            case .idle:
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    self.setButtonHidden(false)
                }, completion: nil)
            case .inProgress:
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                    self.setButtonHidden(true)
                }, completion: nil)
            }
        }
    }

    private func setButtonHidden(_ hidden: Bool) {
        imageView?.alpha = hidden ? 0 : 1
        imageView?.transform = hidden ? disabledTransform : .identity
        titleLabel?.alpha = hidden ? 0 : 1
        titleLabel?.transform = hidden ? disabledTransform : .identity
    }

    private func setActivityIndicatorHidden(_ hidden: Bool) {
        activityIndicator.alpha = hidden ? 0 : 1
        activityIndicator.transform = hidden ? disabledTransform : .identity
    }
}
