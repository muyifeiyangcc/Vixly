import UIKit
import SnapKit

class PostDetailsViewController: UIViewController {
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        return button
    }()
    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.authFieldBorderColor
        return view
    }()
    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "POST DETAILS"
        label.font = UIFont(name: "Impact", size: 40) ?? AppFont.h1(.black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Describe the outfit and select its style."
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private let captionTextView: UITextView = {
        let tv = UITextView()
        tv.font = AppFont.caption()
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()

    private let captionPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell the story behind this fit"
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        return label
    }()
    
    private let captionCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/500"
        label.font = AppFont.caption()
        label.textColor = AppTheme.textTertiary
        label.textAlignment = .right
        return label
    }()

    private let captionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Caption"
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let styleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Style tags"
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()

    private let styleHintLabel: UILabel = {
        let label = UILabel()
        label.text = "1 primary + up to 2 secondary"
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.textAlignment = .right
        return label
    }()
    
    private let styleTagsContainer = UIView()
    
    private let locationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "City or country"
        tf.font = AppFont.caption()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    private let locationOptionalLabel: UILabel = {
        let label = UILabel()
        label.text = "Optional"
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.textAlignment = .right
        return label
    }()
    
    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textSecondary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next: Review", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 25
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private let styleTags = ["Cityboy", "Vibe", "Gorpcore", "Y2K", "Vintage", "Streetwear"]
    private var selectedTags: [String] = []
    private let progressView = PostProgressView(currentStep: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.backgroundColor = AppTheme.backgroundColor
        contentView.backgroundColor = AppTheme.backgroundColor
        let draft = PostDraftManager.shared
        selectedTags = draft.styleTags
        setupUI()
        setupStyleTags()
        captionTextView.text = draft.caption
        captionPlaceholderLabel.isHidden = !draft.caption.isEmpty
        captionCountLabel.text = "\(draft.caption.count)/500"
        locationTextField.text = draft.location
        updateTagUI()
        updateNextButtonState()
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        captionTextView.delegate = self
        locationTextField.addTarget(self, action: #selector(locationChanged), for: .editingChanged)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(progressView)
        view.addSubview(closeButton)
        view.addSubview(topSeparator)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        contentView.addSubview(captionTitleLabel)
        
        contentView.addSubview(captionTextView)
        contentView.addSubview(captionPlaceholderLabel)
        contentView.addSubview(captionCountLabel)
        contentView.addSubview(styleTitleLabel)
        contentView.addSubview(styleHintLabel)
        contentView.addSubview(styleTagsContainer)
        
        let locationLabel = UILabel()
        locationLabel.text = "Location"
        locationLabel.font = AppFont.caption(.bold)
        locationLabel.textColor = AppTheme.textPrimary
        contentView.addSubview(locationLabel)
        contentView.addSubview(locationOptionalLabel)
        
        contentView.addSubview(locationTextField)
        
        view.addSubview(bottomBar)
        bottomBar.addSubview(bottomStack)
        bottomStack.addArrangedSubview(backButton)
        bottomStack.addArrangedSubview(nextButton)
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(68)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        topSeparator.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top).offset(-20)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        captionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(15)
        }
        
        captionTextView.snp.makeConstraints { make in
            make.top.equalTo(captionTitleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(114)
        }
        captionPlaceholderLabel.snp.makeConstraints { make in
            make.top.equalTo(captionTextView).offset(14)
            make.leading.equalTo(captionTextView).offset(14)
        }
        
        captionCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(captionTitleLabel)
            make.right.equalToSuperview().offset(-15)
        }
        
        styleTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(captionTextView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(15)
        }
        styleHintLabel.snp.makeConstraints { make in
            make.centerY.equalTo(styleTitleLabel)
            make.right.equalToSuperview().offset(-15)
        }
        
        styleTagsContainer.snp.makeConstraints { make in
            make.top.equalTo(styleTitleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(92)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(styleTagsContainer.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(15)
        }
        locationOptionalLabel.snp.makeConstraints { make in
            make.centerY.equalTo(locationLabel)
            make.right.equalToSuperview().offset(-15)
        }
        
        locationTextField.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(47)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(78)
        }
        bottomStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }
        backButton.snp.makeConstraints { make in
            make.width.equalTo(108)
        }
    }
    
    private func setupStyleTags() {
        let rowGroups = [Array(styleTags.prefix(4)), Array(styleTags.dropFirst(4))]
        let rows: [UIStackView] = rowGroups.map { tags in
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .fill
            row.distribution = .fill
            tags.map { createTagButton(title: $0) }.forEach { button in
                button.setContentHuggingPriority(.required, for: .horizontal)
                button.setContentCompressionResistancePriority(.required, for: .horizontal)
                row.addArrangedSubview(button)
            }
            // UIStackView.fill otherwise stretches the final chip to consume
            // the unused row width. Keep that space outside the chips so each
            // button remains its title width plus 16pt on both sides.
            let trailingSpacer = UIView()
            trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            trailingSpacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            row.addArrangedSubview(trailingSpacer)
            return row
        }
        
        let verticalStack = UIStackView(arrangedSubviews: rows)
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        
        styleTagsContainer.addSubview(verticalStack)
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func createTagButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.accessibilityIdentifier = title
        button.titleLabel?.font = AppFont.caption(.semibold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 21
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.height.equalTo(40)
            // Keep each chip at its title width plus the 16pt inset on both sides.
            make.width.equalTo(button.intrinsicContentSize.width)
        }
        return button
    }
    
    @objc private func tagTapped(_ sender: UIButton) {
        guard let tag = sender.accessibilityIdentifier else { return }
        
        if let index = selectedTags.firstIndex(of: tag) {
            selectedTags.remove(at: index)
            updateTagUI()
        } else if selectedTags.count < 3 {
            selectedTags.append(tag)
            updateTagUI()
        }
        PostDraftManager.shared.styleTags = selectedTags
        
        updateNextButtonState()
    }
    
    private func updateTagUI() {
        for subview in styleTagsContainer.subviews {
            guard let verticalStack = subview as? UIStackView else { continue }
            for rowStack in verticalStack.arrangedSubviews {
                guard let rowStack = rowStack as? UIStackView else { continue }
                for case let button as UIButton in rowStack.arrangedSubviews {
                    guard let tag = button.accessibilityIdentifier else { continue }
                    button.setAttributedTitle(nil, for: .normal)
                    
                    if let index = selectedTags.firstIndex(of: tag) {
                        button.backgroundColor = index == 0 ? AppTheme.textPrimary : AppTheme.secondaryColor
                        button.layer.borderWidth = 0
                        if index == 0 {
                            let title = NSMutableAttributedString(string: tag, attributes: [
                                .font: AppFont.caption(.bold),
                                .foregroundColor: UIColor.white
                            ])
                            title.append(NSAttributedString(string: "  PRIMARY", attributes: [
                                .font: AppFont.caption(.bold),
                                .foregroundColor: AppTheme.primaryColor
                            ]))
                            button.setAttributedTitle(title, for: .normal)
                        } else {
                            button.setTitle(tag, for: .normal)
                        }
                    } else {
                        button.backgroundColor = .white
                        button.layer.borderWidth = 1
                        button.setTitle(tag, for: .normal)
                    }

                    // The primary tag adds an attributed "PRIMARY" suffix, so
                    // refresh the width after every title/state change.
                    button.invalidateIntrinsicContentSize()
                    button.snp.updateConstraints { make in
                        make.width.equalTo(button.intrinsicContentSize.width)
                    }
                }
            }
        }
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func closeTapped() {
        let alert = CommonAlertView(
            title: "Discard Draft",
            message: "Are you sure you want to discard your draft?",
            cancelTitle: "Keep Editing",
            confirmTitle: "Discard"
        )
        alert.onConfirm = { [weak self] in
            PostDraftManager.shared.clear()
            self?.dismiss(animated: true)
        }
        alert.show()
    }
    
    @objc private func nextTapped() {
        // 写入 PostDraftManager（Step 3: Details）
        PostDraftManager.shared.caption = captionTextView.text ?? ""
        PostDraftManager.shared.styleTags = selectedTags
        PostDraftManager.shared.location = locationTextField.text ?? ""
        PostDraftManager.shared.transition(to: .reviewPublish)
        
        let reviewVC = ReviewPublishViewController()
        navigationController?.pushViewController(reviewVC, animated: true)
    }

    private func updateNextButtonState() {
        let caption = captionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let valid = !caption.isEmpty && caption.count <= 500 && !selectedTags.isEmpty
        nextButton.isEnabled = valid
        nextButton.alpha = valid ? 1 : 0.5
    }

    @objc private func locationChanged() {
        PostDraftManager.shared.location = locationTextField.text ?? ""
    }
}

extension PostDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        PostDraftManager.shared.caption = textView.text ?? ""
        captionCountLabel.text = "\(count)/500"
        captionPlaceholderLabel.isHidden = !textView.text.isEmpty
        captionCountLabel.textColor = count > 500 ? AppTheme.textDanger : AppTheme.textTertiary
        updateNextButtonState()
    }
}
