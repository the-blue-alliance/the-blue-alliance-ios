//
//  AuthHelper.swift
//  The Blue Alliance
//
//  Created by Zachary Orr on 11/11/23.
//  Copyright © 2023 The Blue Alliance. All rights reserved.
//

import GoogleSignIn
import FirebaseAuth
import Foundation

class AuthHelper {

    class func signInToGoogle(user: GIDGoogleUser?, completion: @escaping (Bool, Error?) -> Void) {
        guard let user = user, let idToken = user.idToken?.tokenString else {
            completion(false, nil)
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)

        Auth.auth().signIn(with: credential) { (_, error) in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

}
