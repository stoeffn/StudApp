//
//  OrganizationBulletinItem.swift
//  StudKit
//
//  Created by Steffen Ryll on 08.02.18.
//  Copyright © 2018 Steffen Ryll. All rights reserved.
//

import BulletinBoard

final class OrganizationBulletinItem: BulletinItem {
    private var viewModel: SignInViewModel!

    var manager: BulletinManager?

    lazy var interfaceFactory = BulletinInterfaceFactory()

    var isDismissable = true

    var dismissalHandler: ((BulletinItem) -> Void)?

    var nextItem: BulletinItem?

    var organization: OrganizationRecord? {
        didSet {
            guard var organization = organization else { return }

            viewModel = SignInViewModel(organization: organization)
            viewModel.organizationIcon { self.iconView.image = $0.value ?? self.iconView.image }

            titleLabel.text = organization.title
            iconView.image = organization.iconThumbnail
        }
    }

    // MARK: - Life Cycle

    init() {}

    func tearDown() {}

    // MARK: - User Interface

    lazy var titleLabel = interfaceFactory.makeTitleLabel(reading: "")

    lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UI.defaultCornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .lightGray
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }()

    lazy var activityIndicatorView: StudIpActivityIndicatorView = {
        let view = StudIpActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 42).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }()

    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconView)
        view.addSubview(activityIndicatorView)
        iconView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 32).isActive = true
        activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return view
    }()

    func makeArrangedSubviews() -> [UIView] {
        return [titleLabel, contentView]
    }
}
