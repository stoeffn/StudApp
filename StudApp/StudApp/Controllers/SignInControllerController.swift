//
//  SignInControllerController.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit
import StudKit

final class SignInControllerController : UITableViewController, UITextFieldDelegate {
    // MARK: - User Interface
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var paswordField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    private let signInErrorMessageIndexPath = IndexPath(row: 2, section: 0)
    
    var isLoading = false {
        didSet {
            guard isLoading != oldValue else { return }
            isSignInErrorCellHidden = isLoading
            signInButton.isEnabled = !isLoading
            navigationItem.setActivityIndicatorHidden(!isLoading)
        }
    }
    
    var isSignInErrorCellHidden = true {
        didSet {
            guard isSignInErrorCellHidden != oldValue else { return }
            tableView.performBatchUpdates({
                if self.isSignInErrorCellHidden {
                    self.tableView.deleteRows(at: [self.signInErrorMessageIndexPath], with: .fade)
                } else {
                    self.tableView.insertRows(at: [self.signInErrorMessageIndexPath], with: .fade)
                }
            }, completion: nil)
        }
    }

    // MARK: - User Interaction
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            paswordField.becomeFirstResponder()
        default:
            break
        }
        return false
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        if usernameField.text?.isEmpty ?? true || paswordField.text?.isEmpty ?? true { return }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.isLoading = false
            self.isSignInErrorCellHidden = false
        }
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellCount = super.tableView(tableView, numberOfRowsInSection: section)
        return isSignInErrorCellHidden ? cellCount - 1 : cellCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSignInErrorCellHidden && indexPath >= signInErrorMessageIndexPath {
            return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row + 1, section: indexPath.section))
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Needs to be overriden in order to activate dynamic row sizing. This value is not set in interface builder because it
        // would reset the rows' sizes to the default size in preview.
        return UITableViewAutomaticDimension
    }
}
