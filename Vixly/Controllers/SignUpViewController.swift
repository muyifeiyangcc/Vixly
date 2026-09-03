import UIKit
import SnapKit

class SignUpViewController: BaseViewController {
    
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
    
    private let passwordTextField: UITextField = {
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
    
    private let termsCheckboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.tintColor = AppTheme.textTertiary
        return button
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private var isTermsAccepted = false
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.authButtonColor
        button.layer.cornerRadius = 22
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // The next screen uses an icon-only back affordance.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if #available(iOS 14.0, *) {
            navigationItem.backButtonDisplayMode = .minimal
        }
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        let headerView = setupAuthHeader(title: "SIGN UP")
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(signUpButton)
        scrollView.showsVerticalScrollIndicator = false
        
        let emailLabel = UILabel()
        emailLabel.text = "Email"
        emailLabel.font = AppFont.authLabel()
        emailLabel.textColor = AppTheme.textPrimary
        
        let passwordLabel = UILabel()
        passwordLabel.text = "Password"
        passwordLabel.font = AppFont.authLabel()
        passwordLabel.textColor = AppTheme.textPrimary
        
        let confirmPasswordLabel = UILabel()
        confirmPasswordLabel.text = "Password"
        confirmPasswordLabel.font = AppFont.authLabel()
        confirmPasswordLabel.textColor = AppTheme.textPrimary
        
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordLabel)
        contentView.addSubview(confirmPasswordTextField)
        
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(signUpButton.snp.top).offset(-18)
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
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(48)
        }
        
        confirmPasswordLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(14)
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

        signUpButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(44)
        }
    }
    
    @objc private func termsToggled() {
        isTermsAccepted.toggle()
        let imageName = isTermsAccepted ? "checkmark.square.fill" : "square"
        termsCheckboxButton.setImage(UIImage(systemName: imageName), for: .normal)
        termsCheckboxButton.tintColor = isTermsAccepted ? AppTheme.primaryColor : AppTheme.textTertiary
    }
    
    @objc private func signUpTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email.")
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password.")
            return
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Please confirm your password.")
            return
        }
        
        let result = DataRepository.shared.signup(email: email, password: password, confirmPassword: confirmPassword)
        
        switch result {
        case .success:
            let completeVC = CompleteProfileViewController()
            navigationController?.pushViewController(completeVC, animated: true)
        case .failure(let error):
            showAlert(title: "Sign Up Failed", message: error.localizedDescription)
        }
    }
}
