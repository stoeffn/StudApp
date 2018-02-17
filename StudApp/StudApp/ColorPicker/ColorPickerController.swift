//
//  ColorPickerController.swift
//  StudApp
//
//  Created by Steffen Ryll on 11.09.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

final class ColorPickerController: UICollectionViewController, Routable {
    private var viewModel: ColorPickerViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Choose Color".localized

        addBackgroundView(withEffect: UIBlurEffect(style: .light))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        preferredContentSize = collectionView?.contentSize ?? preferredContentSize
    }

    func prepareDependencies(for route: Routes) {
        guard case let .colorPicker(_, handler) = route else { fatalError() }

        viewModel = ColorPickerViewModel(completion: handler)
    }

    // MARK: - User Interface

    public func addBackgroundView(withEffect effect: UIVisualEffect) {
        let backgroundView = UIVisualEffectView(effect: effect)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    // MARK: - Collection View Data Source

    override func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel.numberOfRows
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.typeIdentifier, for: indexPath)
        (cell as? ColorCell)?.color = viewModel[rowAt: indexPath.row].1
        return cell
    }

    // MARK: - Collection View Delegate

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectColor(atIndex: indexPath.row)
    }
}

extension ColorPickerController: UICollectionViewDelegateFlowLayout {
    private static let inset: CGFloat = 4
    private static let colorsPerRow = 4

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: ColorPickerController.inset, left: ColorPickerController.inset,
                            bottom: ColorPickerController.inset, right: ColorPickerController.inset)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        let effectiveWidth = collectionView.bounds.width - ColorPickerController.inset * 2
        let cellWidth = effectiveWidth / CGFloat(ColorPickerController.colorsPerRow)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
