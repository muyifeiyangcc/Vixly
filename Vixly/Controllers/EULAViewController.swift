import UIKit
import SnapKit

final class EULAViewController: UIViewController {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        return view
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "alert_bg"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let containerGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(hex: "#D0F0F9").cgColor,
            UIColor(hex: "#E7FF63").cgColor,
            UIColor.white.cgColor
        ]
        layer.locations = [0, 0.3, 1]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.authFieldBorderColor
        view.layer.cornerRadius = 2.5
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "EULA"
        label.font = UIFont(name: "Impact", size: 30) ?? .systemFont(ofSize: 30, weight: .black)
        label.textColor = AppTheme.textPrimary
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        button.adjustsImageWhenHighlighted = false
        return button
    }()

    private let textScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()

    private let textContentView = UIView()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = """
        This End User License Agreement (EULA) governs your use of the Vixly Application. By downloading, accessing or using the App, you agree to be bound by this Agreement. If you do not agree to these terms, you may not use this application.

        1. Eligibility
        By using the Vixly App (the "App"), you confirm that you are at least 18 years of age. You agree to provide true and accurate age information during registration or use. If you are under the age of 18, you need the express consent of a parent or legal guardian to use the App.

        2. User Generated Content
        This app allows users to post and share fashion and outfit related content (such as outfit photos, style lookbooks, trend notes, etc.).
        By posting and publishing any content on Vixly, you fully agree to the following binding terms:

        2.1 Prohibited Content
        You may not post any content that is offensive, harmful or illegal, including but not limited to:

        Hate speech, abuse, harassment or personal attacks;

        Pornographic, explicit or vulgar content;

        Content that promotes violence, discrimination, illegal activities or violations of the rights of others;

        Any content that does not fit the community atmosphere or violates public order and good customs.

        2.2 Content Licensing
        You retain ownership of the content posted, but by Posting, you grant Vixly a non-exclusive license to use, distribute, display, and provide content-based fashion suggestions within the App.

        3. Reporting and Response Mechanism
        3.1 User Reporting Responsibilities
        If you become aware of User content that violates this EULA, you agree to report it immediately through Vixly's reporting mechanism.

        3.2 Platform Response Measures
        We will review the reported content within 24 hours and take appropriate measures, including but not limited to removing the offending content, warning or banning the offending user. Users who repeatedly violate the rules may face permanent suspension.

        4. Privacy Policy
        By using the App, you acknowledge that you have read and understood our [Privacy Policy], which details how we collect, use and protect your personal information.

        5. Account Termination and Suspension
        We may terminate or suspend your access to Vixly at any time for any reason, with or without prior notice. You can also stop using Vixly and delete your account at any time.

        6. Agreement Modification and Update
        We may amend this Agreement at any time. Changes will be announced in the App, and your continued use of the App means your acceptance of the revised terms.

        7. Disclaimer of Warranties
        Vixly is provided "AS IS" without warranties of any kind, express or implied. We do not guarantee that the application will always be interruption-free, error-free or completely secure;

        8. Limitation of Liability
        To the fullest extent permitted by law, we are not liable for any damage caused by your use of Vixly.
        """
        return label
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return button
    }()

    private let agreeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Agree", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 18
        return button
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor.black.withAlphaComponent(0.48)
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerGradientLayer.frame = containerView.bounds
    }

    private func setupUI() {
        view.addSubview(containerView)
        containerView.layer.insertSublayer(containerGradientLayer, at: 0)
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(handleView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(textScrollView)
        containerView.addSubview(buttonStackView)
        textScrollView.addSubview(textContentView)
        textContentView.addSubview(textLabel)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(agreeButton)

        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)

        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
            make.width.lessThanOrEqualTo(345)
            make.height.equalTo(540).priority(.high)
            make.top.greaterThanOrEqualTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(36)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
        }

        buttonStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }

        textScrollView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(buttonStackView.snp.top).offset(-10)
        }

        textContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(textScrollView)
        }

        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func closeTapped() {
        cancelTapped()
    }

    @objc private func cancelTapped() {
        exit(0)
    }

    @objc private func agreeTapped() {
        UserDefaults.standard.set(true, forKey: "EULA_AGREED")
        if presentingViewController != nil {
            dismiss(animated: false) {
                AppRouter.shared.showOnboarding()
            }
        } else {
            AppRouter.shared.showOnboarding()
        }
    }
}
