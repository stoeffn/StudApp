//
//  SignInViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class SignInViewModel {
    public enum State {
        case idle, loading, failure(String), success
    }
    
    public var state: State = .idle {
        didSet { stateChanged?(state) }
    }
    
    public var stateChanged: ((State) -> Void)?
    
    public init() { }
    
    public func attemptSignIn(withUsername username: String, password: String) {
        guard !username.isEmpty && !password.isEmpty else {
            state = .failure("Please enter your Stud.IP credentials")
            return
        }
        
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.state = .failure("Please check your credentials for typos")
        }
    }
}
