//
//  LoginView.swift
//  See
//
//  Created by Khater on 3/25/23.
//

import UIKit

@objc protocol LoginViewDelegate: AnyObject {
    func loginView(buttonDidPressed button: UIButton)
}

class LoginView: UIView {
    
    // MARK: - Variables
    weak var delegate: LoginViewDelegate?
    
    public var username: String {
        self.usernameTextField.text ?? ""
    }
    
    public var password: String {
        self.passwordTextField.text ?? ""
    }
    
    
    // MARK: - UI Components
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login"
        label.textColor = .label
        label.textAlignment = .left
        label.font = UIFont(name: "Inter-Bold", size: 27)
        return label
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Username"
        textField.backgroundColor = .systemGray5
        textField.backgroundColor = .systemGray5
        textField.cornerRadius = 10
        textField.textContentType = .username
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        return textField
    }()
    
    private lazy var showTextEntryButton: UIButton = {
        let button = UIButton()
        button.setImage(Constant.eyeImage, for: .normal)
        button.tintColor = .systemGray3
        button.addTarget(self, action: #selector(showTextEntryButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.backgroundColor = .systemGray5
        textField.backgroundColor = .systemGray5
        textField.cornerRadius = 10
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        
        
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 55))
        let button = showTextEntryButton
        button.frame = rightView.bounds
        rightView.addSubview(button)
        textField.rightViewMode = .always
        textField.rightView = rightView
        return textField
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicatore = UIActivityIndicatorView()
        indicatore.translatesAutoresizingMaskIntoConstraints = false
        indicatore.hidesWhenStopped = true
        indicatore.style = .medium
        indicatore.color = .label
        indicatore.startAnimating()
        return indicatore
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.cornerRadius = 10
        button.addTarget(delegate, action: #selector(delegate?.loginView(buttonDidPressed:)), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - LifeCycle
    init(viewDelegate: LoginViewDelegate){
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        addSubviews()
        setupLayoutConstraints()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        delegate = viewDelegate
    }
    
    required init?(coder: NSCoder) {
        // This will make fatal error if we try to use This View in storyboard
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - AddSubviews
    private func addSubviews(){
        [loginLabel, usernameTextField, passwordTextField, loadingIndicator, loginButton].forEach({ addSubview($0) })
    }
    
    
    
    // MARK: - Layout Constraints
    private func setupLayoutConstraints() {
        setupPasswordTextFieldConstraints()
        setupUsernameTextConstraints()
        setupLoginLabelConstraints()
        setupLoginButtonConstraints()
        setupLoadingIndicatoreConstraints()
    }
    
    
    private func setupPasswordTextFieldConstraints() {
        NSLayoutConstraint.activate([
            passwordTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupUsernameTextConstraints() {
        NSLayoutConstraint.activate([
            usernameTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -16),
            usernameTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            usernameTextField.heightAnchor.constraint(equalTo: passwordTextField.heightAnchor)
        ])
    }
    
    private func setupLoginLabelConstraints() {
        NSLayoutConstraint.activate([
            loginLabel.bottomAnchor.constraint(equalTo: usernameTextField.topAnchor, constant: -32),
            loginLabel.leadingAnchor.constraint(equalTo: usernameTextField.leadingAnchor)
        ])
    }
    
    private func setupLoadingIndicatoreConstraints() {
        NSLayoutConstraint.activate([
            loadingIndicator.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 36),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupLoginButtonConstraints() {
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalTo: passwordTextField.heightAnchor)
        ])
    }
    
    
    // MARK: - UPDATE UI
    @objc private func showTextEntryButtonPressed(_ button: UIButton) {
        let isSecureTextEntry = passwordTextField.isSecureTextEntry
        passwordTextField.isSecureTextEntry = !isSecureTextEntry
        showTextEntryButton.tintColor = (isSecureTextEntry) ? .systemGray : .systemGray3
    }
    
    public func startLoading(_ isLoading: Bool) {
        usernameTextField.isEnabled = !isLoading
        passwordTextField.isEnabled = !isLoading
        loginButton.isEnabled = !isLoading
        
        UIView.animate(withDuration: 0.5) {
            if isLoading {
                self.loginButton.transform.ty = 55
            }else{
                self.loginButton.transform = .identity
            }
        }
    }
}


extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
