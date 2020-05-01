//
//  LoginViewController.swift
//  Journal
//
//  Created by Kerby Jean on 4/29/20.
//  Copyright © 2020 Kerby Jean. All rights reserved.
//

import UIKit
import SweetCurtain
import AuthenticationServices


class LoginViewController: UIViewController {
    
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let learnButton = UIButton()
    let imageView = UIImageView()
    let loginProviderStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    func setupViews() {
        
        view.backgroundColor = .systemGray6
        
        titleLabel.text = "Welcome to Journal"
        titleLabel.font = UIFont.systemFont(ofSize: 35, weight: .semibold)
        titleLabel.textColor = UIColor.label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.text = "A camera app design for keeping up with your thoughts."
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textColor = UIColor.secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 3
        
        learnButton.setTitle("Learn More", for: .normal)
        learnButton.setTitleColor(.label, for: .normal)
        learnButton.titleLabel?.font  = UIFont.systemFont(ofSize: 14)
        learnButton.translatesAutoresizingMaskIntoConstraints = false

        learnButton.addTarget(self, action: #selector(handleLearnMore), for: .touchUpInside)
        
        let imageConfiguration = UIImage.SymbolConfiguration(scale: .default)
        let image = UIImage(systemName: "book.circle.fill", withConfiguration: imageConfiguration)!
        let finalImage = image.withTintColor(UIColor.systemBlue, renderingMode: .alwaysOriginal)
        
        imageView.image = finalImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        loginProviderStackView.translatesAutoresizingMaskIntoConstraints = false
        loginProviderStackView.axis = .vertical
        loginProviderStackView.alignment = .fill
        loginProviderStackView.distribution = .fill
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(learnButton)
        view.addSubview(imageView)
        view.addSubview(loginProviderStackView)
        
        setupProviderLoginView()
    }
    
    
    @objc func handleLearnMore() {
        navigationController?.pushViewController(LearnMoreViewController(), animated: true)
    }
    
    
    
    /// - Tag: add_appleid_button
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    fileprivate var currentNonce: String?

    
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        self.currentNonce = AuthService.shared.randomNonceString()
        // Set the SHA256 hashed nonce to ASAuthorizationAppleIDRequest
        request.nonce = AuthService.shared.sha256(currentNonce!)

        // Present Apple authorization form
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        authorizationController.performRequests()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
        
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 150.0),
            titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48.0),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
            descriptionLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            learnButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16.0),
            learnButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: learnButton.bottomAnchor, constant: 40.0),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 150),
            imageView.heightAnchor.constraint(equalToConstant: 150),
            
            loginProviderStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80.0),
            loginProviderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginProviderStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
            loginProviderStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let givenName = appleIDCredential.fullName?.givenName
            let email = appleIDCredential.email ?? ""
            
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
            self.saveUserInKeychain(userIdentifier)
            
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }
            
            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }
            
            AuthService.shared.signIn(idTokenString: idTokenString, nonce: nonce, givenName: givenName, email: email, completion: { result in
                if let result = try? result.get() {
                    print("RESULT: \(result)")
                    // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
                    self.showResultViewController()
                }
            })
            
        case let passwordCredential as ASPasswordCredential:
            
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
            DispatchQueue.main.async {
                self.showPasswordCredentialAlert(username: username, password: password)
            }
            
        default:
            break
        }
    }
    
    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.example.apple-samplecode.juice", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            print("Unable to save userIdentifier to keychain.")
        }
    }
    
    private func showResultViewController() {
        
        let cameraViewController = CameraViewController()
        let entriesViewController = EntriesViewController()
        let navigationController = UINavigationController(rootViewController: entriesViewController)
        
        let curtainController = CurtainController(content:cameraViewController , curtain: navigationController)
        
        curtainController.curtain.maxHeightCoefficient = 1.0
        curtainController.curtain.midHeightCoefficient = 0.3
        curtainController.curtain.minHeightCoefficient = 0.1
        
        curtainController.curtain.handleIndicatorColor = .cloud
        
        curtainController.curtainDelegate = entriesViewController
        curtainController.modalPresentationStyle = .fullScreen
        
        self.present(curtainController, animated: true, completion: nil)
    }
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        
        
        
        return self.view.window!
    }
}
