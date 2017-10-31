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
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUserInterface()
    }
    
    // MARK: - User Interface
    
    private func initUserInterface() {
        navigationController?.navigationBar.removeBackground()
    }
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var paswordField: UITextField!

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
}
