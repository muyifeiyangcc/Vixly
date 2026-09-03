import UIKit
import SnapKit

class ForgotPasswordViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter Email Address",
            attributes: [.foregroundColor: AppTheme.textSecondary, .font: AppFont.authField()]
        )
        tf.font = AppFont.authField()
        tf.textColor = AppTheme.textPrimary
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Enter Password",
            attributes: [.foregroundColor: AppTheme.textSecondary, .font: AppFont.authField()]
        )
        tf.font = AppFont.authField()
        tf.textColor = AppTheme.textPrimary
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Please Enter The Password Again",
            attributes: [.foregroundColor: AppTheme.textSecondary, .font: AppFont.authField()]
        )
        tf.font = AppFont.authField()
        tf.textColor = AppTheme.textPrimary
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf.leftViewMode = .always
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.authButtonColor
        button.layer.cornerRadius = 22
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        let headerView = setupAuthHeader(title: "FORGOT PASSWORD")
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(saveButton)
        scrollView.showsVerticalScrollIndicator = false
        
        let emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.font = AppFont.authLabel()
        emailLabel.textColor = AppTheme.textPrimary
        
        let newPasswordLabel = UILabel()
        newPasswordLabel.text = "New Password"
        newPasswordLabel.text = "Password"
        newPasswordLabel.font = AppFont.authLabel()
        newPasswordLabel.textColor = AppTheme.textPrimary
        
        let confirmPasswordLabel = UILabel()
        confirmPasswordLabel.text = "Confirm Password"
        confirmPasswordLabel.text = "Password"
        confirmPasswordLabel.font = AppFont.authLabel()
        confirmPasswordLabel.textColor = AppTheme.textPrimary
        
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(newPasswordLabel)
        contentView.addSubview(newPasswordTextField)
        contentView.addSubview(confirmPasswordLabel)
        contentView.addSubview(confirmPasswordTextField)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-18)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(38)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
        }
        
        newPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        newPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(newPasswordLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
        }
        
        confirmPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        confirmPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(confirmPasswordLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(44)
        }
    }
    
    @objc private func saveTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email.")
            return
        }
        
        guard let newPassword = newPasswordTextField.text, !newPassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter a new password.")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please confirm your password.")
            return
        }
        
        let result = DataRepository.shared.resetPassword(email: email, newPassword: newPassword, confirmPassword: confirmPassword)
        
        switch result {
        case .success:
            showAlert(title: "Success", message: "Password has been reset successfully.")
        case .failure(let error):
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
}
