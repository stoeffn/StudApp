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

@IBDesignable
public final class DateTabBarView: UIView {

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

    public var startsAt: Date = Date()

    public var endsAt: Date = Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date()

    public var selectedDate: Date? {
        didSet { updateSelection() }
    }

    private var isScrolling = false

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        let view = UICollectionView(frame: bounds, collectionViewLayout: layout)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        view.alwaysBounceVertical = false
        view.scrollsToTop = false
        view.backgroundColor = .clear
        view.register(DateTabBarCell.self, forCellWithReuseIdentifier: DateTabBarCell.typeIdentifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    private func initUserInterface() {
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        backgroundColor = .clear
        addSubview(collectionView)

        isAccessibilityElement = true
    }

    private func updateSelection(forced: Bool = false) {
        let selectedIndexPath = IndexPath(row: selectedDate?.days(since: startsAt) ?? 0, section: 0)
        let currentIndexPath = collectionView.indexPathsForSelectedItems?.first

        guard
            selectedIndexPath.row >= 0,
            selectedIndexPath.row < collectionView.numberOfItems(inSection: selectedIndexPath.section)
        else {
            guard let currentIndexPath = currentIndexPath else { return }
            return collectionView.deselectItem(at: currentIndexPath, animated: true)
        }

        guard forced || !isScrolling else {
            return collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: [])
        }

        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }

    public func reloadData() {
        collectionView.reloadData()
    }

    public func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Accessibility

    public override var accessibilityValue: String? {
        get { return selectedDate?.formatted(using: .longDate) }
        set {}
    }

    public override func accessibilityDecrement() {
        guard
            let selectedDate = selectedDate,
            let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate),
            newDate >= startsAt
        else { return self.selectedDate = endsAt }

        self.selectedDate = newDate

        guard let isDateEnabled = self.isDateEnabled, !isDateEnabled(newDate) else { return }
        accessibilityDecrement()
    }

    public override func accessibilityIncrement() {
        guard
            let selectedDate = selectedDate,
            let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
            newDate <= endsAt
        else { return self.selectedDate = startsAt }

        self.selectedDate = newDate

        guard let isDateEnabled = self.isDateEnabled, !isDateEnabled(newDate) else { return }
        accessibilityIncrement()
    }

    // MARK: - Delegate

    public var isDateEnabled: ((Date) -> Bool)?

    public var didSelectDate: ((Date) -> Void)?
}

// MARK: - Collection View Data Source

extension DateTabBarView: UICollectionViewDataSource {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return endsAt.startOfDay.days(since: startsAt.startOfDay) + 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateTabBarCell.typeIdentifier, for: indexPath)
        if let date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: startsAt) {
            (cell as? DateTabBarCell)?.date = date
            (cell as? DateTabBarCell)?.isEnabled = isDateEnabled?(date) ?? false
        }
        return cell
    }
}

// MARK: - Collection View Delegate

extension DateTabBarView: UICollectionViewDelegateFlowLayout {
    public func scrollViewDidScroll(_: UIScrollView) {
        isScrolling = true
    }

    public func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        isScrolling = false
        updateSelection()
    }

    public func scrollViewWillBeginDecelerating(_: UIScrollView) {
        updateSelection(forced: false)
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        isScrolling = false
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? DateTabBarCell,
            let date = cell.date,
            date != selectedDate
        else { return }

        selectedDate = date
        didSelectDate?(date)
        updateSelection()
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout,
                               insetForSectionAt _: Int) -> UIEdgeInsets {
        let totalWidth = CGFloat(self.collectionView(collectionView, numberOfItemsInSection: 0) - 1) * bounds.height
        let inset = max((collectionView.bounds.width - totalWidth) / 2, 0)
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
