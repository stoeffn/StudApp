//
//  SignInViewModel.swift
//  StudKit
//
//  Created by Steffen Ryll on 01.11.17.
//  Copyright © 2017 Steffen Ryll. All rights reserved.
//

public final class SignInViewModel {
    public enum State {
        case idle
        
        case loading
            
        case failure(String)
        
        case success
    }
    
    private let studIp = ServiceContainer.default[StudIpService.self]
    
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
        studIp.signIn(withUsername: username, password: password) { result in
            switch result {
            case .success:
                self.state = .success
            case let .failure(error):
                self.state = .failure(error?.localizedDescription ?? "There was an error signing in :/")
            }
        }
    }
}
