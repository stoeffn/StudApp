//
//  DateTabBar.swift
//  StudKitUI
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import StudKit

@IBDesignable
public final class DateTabBar: UIView {
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

    public var endsAt: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    public var selectedDate: Date? {
        get {
            guard
                let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first,
                let selectedCell = collectionView.cellForItem(at: selectedIndexPath) as? DateTabBarCell
            else { return nil }
            return selectedCell.date
        }
        set {
            guard newValue != selectedDate else { return }
            let index = newValue?.days(since: startsAt) ?? 0
            guard index >= 0 && index < collectionView.numberOfItems(inSection: 0) else {
                if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                    collectionView.deselectItem(at: selectedIndexPath, animated: true)
                }
                return
            }
            let indexPath = IndexPath(row: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
    }

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
    }

    public func reloadData() {
        collectionView.reloadData()
    }

    // MARK: - Delegate

    public var isDateEnabled: ((Date) -> Bool)?

    public var didSelectDate: ((Date) -> Void)?
}

// MARK: - Collection View Data Source

extension DateTabBar: UICollectionViewDataSource {
    public func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return endsAt.days(since: startsAt)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateTabBarCell.typeIdentifier, for: indexPath)
        if let date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: startsAt) {
            (cell as? DateTabBarCell)?.date = date
            (cell as? DateTabBarCell)?.isEnabled = isDateEnabled?(date) ?? true
        }
        return cell
    }
}

// MARK: - Collection View Delegate

extension DateTabBar: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DateTabBarCell, let date = cell.date else { return }
        didSelectDate?(date)
    }
}
