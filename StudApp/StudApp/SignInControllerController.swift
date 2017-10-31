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
    
    // MARK: Table View Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Needs to be overriden in order to activate dynamic row sizing. This value is not set in interface builder because it
        // would reset the rows' sizes to the default size in preview.
        return UITableViewAutomaticDimension
    }
}
