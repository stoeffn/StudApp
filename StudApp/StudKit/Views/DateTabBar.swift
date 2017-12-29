//
//  DateTabBar.swift
//  StudKit
//
//  Created by Steffen Ryll on 29.12.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

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
            guard let newValue = newValue, newValue.days(since: startsAt) <= endsAt.days(since: startsAt) else {
                if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                    collectionView.deselectItem(at: selectedIndexPath, animated: true)
                }
                return
            }
            let indexPath = IndexPath(row: max(newValue.days(since: startsAt), 0), section: 0)
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
        (cell as? DateTabBarCell)?.date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: startsAt)
        return cell
    }
}
