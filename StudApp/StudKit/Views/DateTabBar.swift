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

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUserInterface()
    }

    // MARK: - User Interface

    public var startDate: Date = Date()

    public var endDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()

    public var selectedDate: Date = Date()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: bounds, collectionViewLayout: UICollectionViewFlowLayout())
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceHorizontal = true
        view.alwaysBounceVertical = false
        view.scrollsToTop = false
        view.isPagingEnabled = true
        view.backgroundColor = .clear
        view.register(DateTabBarCell.self, forCellWithReuseIdentifier: DateTabBarCell.typeIdentifier)
        view.dataSource = self
        return view
    }()

    private func initUserInterface() {
        backgroundColor = .clear
        addSubview(collectionView)
    }

    public func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - Collection View Data Source

extension DateTabBar: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return endDate.days(from: startDate)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateTabBarCell.typeIdentifier, for: indexPath)
        (cell as? DateTabBarCell)?.date = Calendar.current.date(byAdding: .day, value: indexPath.row, to: startDate)
        return cell
    }
}
