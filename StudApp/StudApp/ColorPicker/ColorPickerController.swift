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

        navigationController?.navigationBar.removeBackground()
        addBackgroundView(withEffect: UIBlurEffect(style: .light))
    }

    func prepareDependencies(for route: Routes) {
        guard case let .colorPicker(handler) = route else { fatalError() }

        viewModel = ColorPickerViewModel(handler: handler)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath)
        (cell as? ColorCell)?.color = viewModel[rowAt: indexPath.row].1
        return cell
    }

    // MARK: - Collection View Delegate

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectColor(atIndex: indexPath.row)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - User Interaction

    @IBAction
    func cancelButtonTapped(sender _: Any?) {
        dismiss(animated: true, completion: nil)
    }
}

extension ColorPickerController: UICollectionViewDelegateFlowLayout {
    private func numberOfCells(forCollectionViewWidth width: CGFloat) -> Int {
        return Int(width / 84)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let minimumSpacing = self.collectionView(collectionView, layout: collectionViewLayout,
                                                 minimumInteritemSpacingForSectionAt: indexPath.section)
        let insets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let width = collectionView.bounds.width - insets.left - insets.right
        let cellWidth = width / CGFloat(numberOfCells(forCollectionViewWidth: width)) - minimumSpacing
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
