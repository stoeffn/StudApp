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

import StudKit
import StudKitUI

final class ColorPickerController: UICollectionViewController, Routable {
    private var viewModel: ColorPickerViewModel<UIColor>!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 256, height: 256)
        navigationItem.title = Strings.Actions.chooseColor.localized
    }

    func prepareContent(for route: Routes) {
        guard case let .colorPicker(_, completion) = route else { fatalError() }
        viewModel = ColorPickerViewModel(colors: UI.Colors.pickerColors, completion: completion)
    }

    // MARK: - User Interaction

    @IBAction
    func cancelButtonTapped(_: Any) {
        dismiss(animated: true, completion: nil)
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
        (cell as? ColorCell)?.color = viewModel[rowAt: indexPath.row].value.color
        (cell as? ColorCell)?.title = viewModel[rowAt: indexPath.row].value.title
        return cell
    }

    // MARK: - Collection View Delegate

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectColor(atIndex: indexPath.row)
    }
}

extension ColorPickerController: UICollectionViewDelegateFlowLayout {
    private static let inset: CGFloat = 4
    private static let colorsPerRow = 3

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: ColorPickerController.inset, left: ColorPickerController.inset,
                            bottom: ColorPickerController.inset, right: ColorPickerController.inset)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let effectiveWidth = preferredContentSize.width - ColorPickerController.inset * 2
        let cellWidth = effectiveWidth / CGFloat(ColorPickerController.colorsPerRow)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
