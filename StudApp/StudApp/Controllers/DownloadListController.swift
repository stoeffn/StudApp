//
//  DownloadListController.swift
//  StudApp
//
//  Created by Steffen Ryll on 17.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit
import StudKit

final class DownloadListController: UITableViewController, DataSourceSectionDelegate {
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
