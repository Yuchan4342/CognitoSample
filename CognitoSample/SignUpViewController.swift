//
//  SignUpViewController.swift
//  CognitoSample
//
//  Created by 岩田裕登 on 2020/03/22.
//  Copyright © 2020 Yuto Iwata. All rights reserved.
//

import AWSCognitoIdentityProvider
import UIKit

/// サインアップ画面の ViewController.
class SignUpViewController: UIViewController {
    /// ユーザ名入力用 TextField.
    @IBOutlet weak var usernameField: UITextField!
    /// メールアドレス入力用 TextField.
    @IBOutlet weak var emailField: UITextField!
    /// パスワード入力用 TextField.
    @IBOutlet weak var passwordField: UITextField!
    /// 「サインイン」ボタン.
    @IBOutlet weak var signInButton: UIButton!
    
    /// サインアップする.
    @IBAction func signUp(_ sender: UIButton) {
        guard let username: String = self.usernameField.text,
            let email: String = self.emailField.text,
            let password: String = self.passwordField.text else {
                print("Missing username, email or password.")
                self.presentErrorAlert(title: "ユーザ名、メールアドレスまたはパスワードが入力されていません。", message: nil)
                return
        }
        let name: AWSCognitoIdentityUserAttributeType = AWSCognitoIdentityUserAttributeType(name: "name", value: username)
        let emailAttribute: AWSCognitoIdentityUserAttributeType = AWSCognitoIdentityUserAttributeType(name: "email", value: email)
        let attributes: [AWSCognitoIdentityUserAttributeType] = [name, emailAttribute]
        let pool: AWSCognitoIdentityUserPool = AWSCognitoIdentityUserPool(forKey: CognitoConstants.SignInProviderKey)
        pool.signUp(username, password: password, userAttributes: attributes, validationData: nil).continueWith { task in
            if let error: NSError = task.error as NSError? {
                self.presentErrorAlert(title: error.userInfo["__type"] as? String,
                                       message: error.userInfo["message"] as? String)
            } else {
                if let result: AWSCognitoIdentityUserPoolSignUpResponse = task.result {
                    // ユーザがメールやSMSでの認証を必要とするかどうかで処理を分ける.
                    if (result.user.confirmedStatus != .confirmed) {
//                        self.useCaseOutput?.needConfirmSignUp(username: username,
//                                                              sentTo: result.codeDeliveryDetails?.destination,
//                                                              password: password)
                    } else {
                        // 確認コード認証が不要な場合は自動でサインインを試みる.
//                        self.signIn(username: username, password: password)
                    }
                }
            }
            return task
        }
    }
    
    /// エラーを示すアラートを表示する.
    /// - Parameter title:   アラートのタイトル.
    /// - Parameter message: アラートのメッセージ.
    func presentErrorAlert(title: String?, message: String?) {
        /// エラーを表示するアラート.
        let errorAlert: UIAlertController
            = UIAlertController(title: title,
                                message: message,
                                preferredStyle: .alert)
        // アラートに「OK」ボタンを追加.
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(errorAlert, animated: true)
    }
}

