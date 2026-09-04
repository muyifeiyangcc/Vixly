import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
    private let newUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("I'm New", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.onboardingButtonColor
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 2
        button.layer.borderColor = AppTheme.textPrimary.cgColor
        return button
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In By Email", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(AppTheme.onboardingButtonColor, for: .normal)
        button.backgroundColor = AppTheme.onboardingDarkColor
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 2
        button.layer.borderColor = AppTheme.onboardingButtonColor.cgColor
        return button
    }()
    
    private let signupLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .regular)
        button.setTitleColor(AppTheme.textAccent, for: .normal)
        button.titleLabel?.attributedText = NSAttributedString(
            string: "Sign up",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: AppTheme.textAccent,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        return button
    }()
    
    private let checkboxButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "unselect")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage(named: "select")?.withRenderingMode(.alwaysOriginal), for: .selected)
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let termsTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        let fullText = "By continuing you agree to our Terms of Service and Privacy Policy"
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 11, weight: .regular), range: NSRange(location: 0, length: fullText.count))
        attributedString.addAttribute(.foregroundColor, value: AppTheme.textPrimary, range: NSRange(location: 0, length: fullText.count))
        
        if let termsRange = fullText.range(of: "Terms of Service") {
            let nsRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.link, value: "terms", range: nsRange)
        }
        if let privacyRange = fullText.range(of: "Privacy Policy") {
            let nsRange = NSRange(privacyRange, in: fullText)
            attributedString.addAttribute(.link, value: "privacy", range: nsRange)
        }
        
        textView.attributedText = attributedString
        textView.linkTextAttributes = [
            .foregroundColor: AppTheme.textAccent,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.textAlignment = .center
        return textView
    }()
    
    private var isCheckboxSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.secondaryColor
        setupUI()
        termsTextView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        let backgroundImageView = UIImageView(image: UIImage(named: "login_bg"))
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.isUserInteractionEnabled = false
        view.insertSubview(backgroundImageView, at: 0)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(newUserButton)
        view.addSubview(signInButton)
        
        let bottomStack = UIStackView(arrangedSubviews: [signupLabel, signupButton])
        bottomStack.axis = .horizontal
        bottomStack.spacing = 4
        view.addSubview(bottomStack)
        
        view.addSubview(checkboxButton)
        view.addSubview(termsTextView)
        
        newUserButton.addTarget(self, action: #selector(newUserTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        checkboxButton.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        
        newUserButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
            make.bottom.equalTo(signInButton.snp.top).offset(-20)
            make.height.equalTo(44)
        }
        
        signInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(45)
            make.trailing.equalToSuperview().offset(-45)
            make.bottom.equalTo(bottomStack.snp.top).offset(-14)
            make.height.equalTo(44)
        }

        checkboxButton.snp.makeConstraints { make in
            make.centerY.equalTo(termsTextView)
            make.leading.equalToSuperview().offset(58)
            make.width.height.equalTo(18)
        }

        termsTextView.snp.makeConstraints { make in
            make.leading.equalTo(checkboxButton.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-38)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.greaterThanOrEqualTo(34)
            make.height.equalTo(34).priority(UILayoutPriority.defaultLow)
        }
        
        bottomStack.snp.makeConstraints { make in
            make.bottom.equalTo(termsTextView.snp.top).offset(-11)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
    }
    
    @objc private func newUserTapped() {
        AppRouter.shared.showMainTabBar(asGuest: true)
    }
    
    @objc private func signInTapped() {
        guard ensureTermsAccepted() else { return }
        
        let signInVC = SignInViewController()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    
    @objc private func signupTapped() {
        guard ensureTermsAccepted() else { return }

        let signUpVC = SignUpViewController()
        navigationController?.pushViewController(signUpVC, animated: true)
    }

    private func ensureTermsAccepted() -> Bool {
        guard !isCheckboxSelected else { return true }

        let alert = CommonAlertView(
            title: "Please Agree",
            message: "You must agree to the Terms of Service and Privacy Policy to continue.",
            cancelTitle: "Cancel",
            confirmTitle: "OK"
        )
        alert.show()
        return false
    }
    
    @objc private func checkboxTapped() {
        isCheckboxSelected.toggle()
        checkboxButton.isSelected = isCheckboxSelected
    }
}

extension OnboardingViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "terms" {
            let webVC = WebViewController(url: "https://sites.google.com/view/vixly/users", pageTitle: "Terms of Service")
            webVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webVC, animated: true)
            return false
        } else if URL.absoluteString == "privacy" {
            let webVC = WebViewController(url: "https://sites.google.com/view/vixly/privacy", pageTitle: "Privacy Policy")
            webVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(webVC, animated: true)
            return false
        }
        return true
    }
}
