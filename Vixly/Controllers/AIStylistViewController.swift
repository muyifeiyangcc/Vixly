import UIKit
import SnapKit

final class AIStylistViewController: BaseViewController {
    private static let paymentPromptShownKeyPrefix = "AI_STYLIST_PAYMENT_PROMPT_SHOWN_"

    private let headerView = UIView()
    private let coinPill = UIView()
    private let coinCountLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let messagesStackView = UIStackView()
    private let exampleQuestionsStack = UIStackView()
    private let inputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var inputBarBottomConstraint: Constraint?
    private var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        setupUI()
        loadData()
        addObservers()
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        updateCoinDisplay()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController !== self {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.backgroundColor
        setupHeader()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(inputBar)
        inputBar.backgroundColor = .white

        let artworkContainer = UIView()
        artworkContainer.clipsToBounds = false
        artworkContainer.backgroundColor = .clear
        let artwork = UIImageView(image: UIImage(named: "ai_header"))
        artwork.contentMode = .scaleAspectFit
        artworkContainer.addSubview(artwork)

        let introTitle = UILabel()
        introTitle.text = "YOUR PERSONAL STYLING\nASSISTANT"
        introTitle.font = UIFont(name: "Impact", size: 27) ?? .systemFont(ofSize: 27, weight: .black)
        introTitle.textColor = AppTheme.textPrimary
        introTitle.textAlignment = .center
        introTitle.numberOfLines = 2

        let introSubtitle = UILabel()
        introSubtitle.text = "Ask about color, proportions, matching, outfit\nimprovements, or shopping direction."
        introSubtitle.font = .systemFont(ofSize: 11, weight: .regular)
        introSubtitle.textColor = AppTheme.textSecondary
        introSubtitle.textAlignment = .center
        introSubtitle.numberOfLines = 2

        let exampleLabel = UILabel()
        exampleLabel.text = "EXAMPLE QUESTIONS"
        exampleLabel.font = .systemFont(ofSize: 9, weight: .bold)
        exampleLabel.textColor = AppTheme.textSecondary

        contentView.addSubview(artworkContainer)
        contentView.addSubview(introTitle)
        contentView.addSubview(introSubtitle)
        contentView.addSubview(exampleLabel)
        contentView.addSubview(exampleQuestionsStack)
        contentView.addSubview(messagesStackView)

        artworkContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(96)
        }
        artwork.snp.makeConstraints { make in
            make.width.equalTo(96)
            make.height.equalTo(110)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        introTitle.snp.makeConstraints { make in
            make.top.equalTo(artworkContainer.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
        }
        introSubtitle.snp.makeConstraints { make in
            make.top.equalTo(introTitle.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        exampleLabel.snp.makeConstraints { make in
            make.top.equalTo(introSubtitle.snp.bottom).offset(34)
            make.left.right.equalToSuperview().inset(16)
        }

        exampleQuestionsStack.axis = .vertical
        exampleQuestionsStack.spacing = 9
        exampleQuestionsStack.alignment = .fill
        exampleQuestionsStack.snp.makeConstraints { make in
            make.top.equalTo(exampleLabel.snp.bottom).offset(11)
            make.left.right.equalToSuperview().inset(16)
        }
        [
            "How can I improve my outfit proportions?",
            "What shoes work with wide trousers?",
            "Build a Gorpcore fit under $200"
        ].forEach { question in
            let button = UIButton(type: .system)
            button.setTitle(question, for: .normal)
            button.setTitleColor(AppTheme.textPrimary, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 11, weight: .regular)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            button.backgroundColor = .white
            button.layer.cornerRadius = 14
            button.layer.borderWidth = 1
            button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
            button.addTarget(self, action: #selector(exampleQuestionTapped(_:)), for: .touchUpInside)
            button.snp.makeConstraints { make in make.height.equalTo(48) }
            exampleQuestionsStack.addArrangedSubview(button)
        }

        messagesStackView.axis = .vertical
        messagesStackView.spacing = 10
        messagesStackView.alignment = .fill
        messagesStackView.snp.makeConstraints { make in
            make.top.equalTo(exampleQuestionsStack.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-18)
        }

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar.snp.top)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        setupInputBar()
    }

    private func setupHeader() {
        headerView.backgroundColor = .white
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(65)
        }
        let separator = UIView()
        separator.backgroundColor = AppTheme.authFieldBorderColor
        headerView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.textPrimary
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        let title = UILabel()
        title.text = "AI Stylist"
        title.font = .systemFont(ofSize: 14, weight: .semibold)
        title.textColor = AppTheme.textPrimary
        title.textAlignment = .center
        headerView.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(14)
        }

        let subtitle = UILabel()
        subtitle.text = "Text only · paid sessions"
        subtitle.font = .systemFont(ofSize: 9, weight: .regular)
        subtitle.textColor = AppTheme.textTertiary
        subtitle.textAlignment = .center
        headerView.addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(2)
        }

        coinPill.backgroundColor = AppTheme.secondaryColor
        coinPill.layer.cornerRadius = 15
        coinPill.isUserInteractionEnabled = true
        coinPill.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinTapped)))
        headerView.addSubview(coinPill)
        coinPill.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            // Keep the compact default width while allowing the pill to grow
            // with larger coin balances instead of compressing the value.
            make.width.greaterThanOrEqualTo(62)
            make.height.equalTo(30)
        }
        let coinImageView = UIImageView(image: UIImage(named: "coin"))
        coinImageView.contentMode = .scaleAspectFit
        coinPill.addSubview(coinImageView)
        coinImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }
        coinCountLabel.font = .systemFont(ofSize: 13, weight: .bold)
        coinCountLabel.textColor = AppTheme.textPrimary
        coinCountLabel.setContentHuggingPriority(.required, for: .horizontal)
        coinCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        coinPill.addSubview(coinCountLabel)
        coinCountLabel.snp.makeConstraints { make in
            make.left.equalTo(coinImageView.snp.right).offset(3)
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        updateCoinDisplay()
    }

    private func setupInputBar() {
        let separator = UIView()
        separator.backgroundColor = AppTheme.authFieldBorderColor
        inputBar.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            self.inputBarBottomConstraint = make.bottom.equalToSuperview().constraint
            make.height.equalTo(74)
        }

        textField.placeholder = "10 coins per message"
        textField.font = .systemFont(ofSize: 12, weight: .regular)
        textField.textColor = AppTheme.textPrimary
        textField.backgroundColor = AppTheme.backgroundColor
        textField.layer.cornerRadius = 21
        textField.layer.borderWidth = 1
        textField.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        textField.leftViewMode = .always
        inputBar.addSubview(textField)

        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(AppTheme.textPrimary, for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
        sendButton.backgroundColor = AppTheme.primaryColor
        sendButton.layer.cornerRadius = 21
        sendButton.isEnabled = false
        inputBar.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(textField)
            make.width.equalTo(56)
            make.height.equalTo(42)
        }
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(42)
        }

        if #available(iOS 15.0, *) {
            inputBarBottomConstraint?.deactivate()
            inputBar.snp.makeConstraints { make in
                make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            }
        }
    }

    private func loadData() {
        messages = DataRepository.shared.getAIMessages().reversed()
        reloadMessages()
    }

    private func reloadMessages() {
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for message in messages {
            messagesStackView.addArrangedSubview(AIStylistMessageRow(message: message))
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(aiMessageReceived), name: .aiMessageReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(coinsUpdated), name: .coinsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func updateCoinDisplay() {
        coinCountLabel.text = "\(DataRepository.shared.currentUser?.coins ?? 0)"
    }

    @objc private func aiMessageReceived() { loadData() }
    @objc private func coinsUpdated() { updateCoinDisplay() }
    @objc private func coinTapped() {
        let rechargeVC = BuyCoinsViewController()
        rechargeVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(rechargeVC, animated: true)
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        if #available(iOS 15.0, *) { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let frameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - frameInView.minY)
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 7
        let options = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        inputBarBottomConstraint?.update(offset: -overlap)
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, options]) {
            self.view.layoutIfNeeded()
        }
    }
    @objc private func textChanged() { sendButton.isEnabled = !(textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) }

    @objc private func exampleQuestionTapped(_ sender: UIButton) {
        textField.text = sender.title(for: .normal)
        textChanged()
    }

    @objc private func sendTapped() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        guard let coins = DataRepository.shared.currentUser?.coins else { return }
        guard coins >= 10 else { showNotEnoughCoins(); return }

        if shouldShowPaymentPrompt {
            markPaymentPromptShown()
            let alert = CommonAlertView(title: "Send Message", message: "This will cost 10 coins. Continue?", cancelTitle: "Cancel", confirmTitle: "Send")
            alert.onConfirm = { [weak self] in
                self?.sendAIMessage(text)
            }
            alert.show()
        } else {
            sendAIMessage(text)
        }
    }

    private var shouldShowPaymentPrompt: Bool {
        guard let userId = DataRepository.shared.currentUser?.id else { return true }
        return !UserDefaults.standard.bool(forKey: Self.paymentPromptShownKeyPrefix + userId)
    }

    private func markPaymentPromptShown() {
        guard let userId = DataRepository.shared.currentUser?.id else { return }
        UserDefaults.standard.set(true, forKey: Self.paymentPromptShownKeyPrefix + userId)
    }

    private func sendAIMessage(_ text: String) {
        guard DataRepository.shared.consumeCoins(amount: 10) else {
            showNotEnoughCoins()
            return
        }
        DataRepository.shared.sendAIMessage(content: text)
        textField.text = ""
        textChanged()
    }

    private func showNotEnoughCoins() {
        let alert = CommonAlertView(title: "Not Enough Coins", message: "You don't have enough Coins to continue. Would you like to recharge?", cancelTitle: "Cancel", confirmTitle: "Recharge")
        alert.onConfirm = { [weak self] in
            let rechargeVC = BuyCoinsViewController()
            rechargeVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(rechargeVC, animated: true)
        }
        alert.show()
    }
}

private final class AIStylistMessageRow: UIView {
    init(message: Message) {
        super.init(frame: .zero)
        let isFromMe = message.senderId == DataRepository.shared.currentUser?.id
        let bubble = UIView()
        bubble.backgroundColor = isFromMe ? AppTheme.secondaryColor : .white
        bubble.layer.cornerRadius = 14
        bubble.layer.borderWidth = isFromMe ? 0 : 1
        bubble.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        addSubview(bubble)

        if !isFromMe {
            let avatar = UIImageView(image: UIImage(named: "ai_header"))
            avatar.contentMode = .scaleAspectFit
            avatar.clipsToBounds = true
            avatar.layer.cornerRadius = 12
            addSubview(avatar)
            avatar.snp.makeConstraints { make in
                make.left.bottom.equalToSuperview()
                make.width.height.equalTo(24)
            }
            bubble.snp.makeConstraints { make in
                make.left.equalTo(avatar.snp.right).offset(8)
                make.right.lessThanOrEqualToSuperview().offset(-56)
                make.top.bottom.equalToSuperview()
            }
        } else {
            bubble.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview().offset(56)
                make.top.bottom.equalToSuperview()
            }
        }

        let textLabel = UILabel()
        textLabel.text = message.content
        textLabel.font = .systemFont(ofSize: 12, weight: .regular)
        textLabel.textColor = AppTheme.textPrimary
        textLabel.numberOfLines = 0
        bubble.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
        }

        let timeLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: message.createdAt)
        timeLabel.font = .systemFont(ofSize: 9, weight: .regular)
        timeLabel.textColor = AppTheme.textTertiary
        bubble.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(textLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
