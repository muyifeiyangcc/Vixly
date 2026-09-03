import UIKit
import SnapKit

class CommonAlertView: UIView {
    
    var onCancel: (() -> Void)?
    var onConfirm: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        return view
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "alert_bg"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Impact", size: 36) ?? .systemFont(ofSize: 36, weight: .black)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return button
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 22
        return button
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    init(title: String, message: String, cancelTitle: String = "Cancel", confirmTitle: String = "Confirm") {
        super.init(frame: .zero)
        setupUI(title: title, message: message, cancelTitle: cancelTitle, confirmTitle: confirmTitle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String, message: String, cancelTitle: String, confirmTitle: String) {
        backgroundColor = UIColor.black.withAlphaComponent(0.48)
        
        addSubview(containerView)
        containerView.addSubview(backgroundImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(buttonStackView)
        
        titleLabel.text = title
        messageLabel.text = message
        cancelButton.setTitle(cancelTitle, for: .normal)
        confirmButton.setTitle(confirmTitle, for: .normal)
        if !cancelTitle.isEmpty {
            buttonStackView.addArrangedSubview(cancelButton)
        }
        if !confirmTitle.isEmpty {
            buttonStackView.addArrangedSubview(confirmButton)
        }
        
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.width.lessThanOrEqualTo(336)
        }

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(28)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(260)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(17)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss()
        onCancel?()
    }
    
    @objc private func confirmTapped() {
        dismiss()
        onConfirm?()
    }
    
    func show() {
        guard let window = UIApplication.shared.keyWindow else { return }
        frame = window.bounds
        window.addSubview(self)
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

/// Shared custom action sheet for report/block actions.
final class ReportBlockSheetViewController: UIViewController {
    enum Action {
        case report
        case block
    }

    var onAction: ((Action) -> Void)?
    private let includeUserActions: Bool
    private let sheet = UIView()

    init(includeUserActions: Bool = true) {
        self.includeUserActions = includeUserActions
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 24
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheet.clipsToBounds = true
        view.addSubview(sheet)
        sheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(includeUserActions ? 250 : 150)
        }

        let handle = UIView()
        handle.backgroundColor = AppTheme.authFieldBorderColor
        handle.layer.cornerRadius = 2.5
        sheet.addSubview(handle)
        handle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }

        let title = UILabel()
        title.text = "More options"
        title.font = AppFont.h3(.bold)
        title.textColor = AppTheme.textPrimary
        title.textAlignment = .center
        sheet.addSubview(title)
        title.snp.makeConstraints {
            $0.top.equalTo(handle.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(28)
        }

        var buttons = [UIButton]()
        if includeUserActions {
            buttons.append(actionButton(title: "Report", tag: 0))
            buttons.append(actionButton(title: "Block User", tag: 1))
        }
        buttons.append(actionButton(title: "Cancel", tag: 2))

        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        sheet.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheet.transform = CGAffineTransform(translationX: 0, y: sheet.bounds.height)
        UIView.animate(withDuration: 0.25) {
            self.sheet.transform = .identity
        }
    }

    private func actionButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.titleLabel?.font = AppFont.body(.semibold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func actionTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let callback = onAction
            dismiss(animated: false) { callback?(.report) }
        case 1:
            let callback = onAction
            dismiss(animated: false) { callback?(.block) }
        default:
            dismiss(animated: false)
        }
    }

}
