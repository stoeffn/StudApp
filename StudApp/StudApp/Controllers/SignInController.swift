//
//  SignInController.swift
//  StudApp
//
//  Created by Steffen Ryll on 31.10.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

import UIKit
import StudKit

final class SignInController : UITableViewController, UITextFieldDelegate, Routable {
    private var viewModel: SignInViewModel!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = SignInViewModel()
        viewModel.stateChanged = setState
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow, object: nil)
    }

    func prepareDependencies(for route: Routes) {
        // TODO
    }
    
    // MARK: - User Interface
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signInButton: UIButton!
    
    private let errorMessageIndexPath = IndexPath(row: 2, section: 0)
    
    var isLoading = false {
        didSet {
            guard isLoading != oldValue else { return }
            isErrorCellHidden = isLoading
            usernameField.isEnabled = !isLoading
            passwordField.isEnabled = !isLoading
            signInButton.isEnabled = !isLoading
            navigationItem.setActivityIndicatorHidden(!isLoading)
        }
    }
    
    var isErrorCellHidden = true {
        didSet {
            guard isErrorCellHidden != oldValue else { return }
            tableView.performBatchUpdates({
                if self.isErrorCellHidden {
                    self.tableView.deleteRows(at: [self.errorMessageIndexPath], with: .fade)
                } else {
                    self.tableView.insertRows(at: [self.errorMessageIndexPath], with: .fade)
                }
            }, completion: nil)
        }
    }
    
    func setState(_ state: SignInViewModel.State) {
        switch state {
        case .idle:
            isLoading = false
            isErrorCellHidden = true
        case .loading:
            isLoading = true
            isErrorCellHidden = true
        case let .failure(message):
            errorLabel.text = message
            isLoading = false
            isErrorCellHidden = false
        case .success:
            isLoading = true
            isErrorCellHidden = true
        }
    }
    
    func scrollToBottom() {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        let lastIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        tableView.scrollToRow(at: lastIndexPath, at: .top, animated: true)
    }
    
    @objc
    private dynamic func keyboardDidShow() {
        scrollToBottom()
    }

    // MARK: - User Interaction
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            passwordField.becomeFirstResponder()
            scrollToBottom()
        default:
            break
        }
        return false
    }
    
    @IBAction
    private func signInButtonTapped(_ sender: Any) {
        guard let username = usernameField.text, let password = passwordField.text else { return }
        viewModel.attemptSignIn(withUsername: username, password: password)
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellCount = super.tableView(tableView, numberOfRowsInSection: section)
        return isErrorCellHidden ? cellCount - 1 : cellCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isErrorCellHidden && indexPath >= errorMessageIndexPath {
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
