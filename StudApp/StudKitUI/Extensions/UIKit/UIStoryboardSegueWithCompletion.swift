//
//  UIStoryboardSegueWithCompletion.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 25.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

public final class UIStoryboardSegueWithCompletion: UIStoryboardSegue {
    public var completion: (() -> Void)?

    public override func perform() {
        super.perform()

        destination.transitionCoordinator?.animate(alongsideTransition: nil, completion: { context in
            if !context.isCancelled {
                self.completion?()
            }
        })
    }
}
