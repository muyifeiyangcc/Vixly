import UIKit
import SnapKit

class ReviewPublishViewController: UIViewController {
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
    private var summaryRowViews: [UIView] = []
    private var publishedPostId: String?
    private var isAwaitingPromotion = false
    private let progressView = PostProgressView(currentStep: 3)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "REVIEW & PUBLISH"
        label.font = UIFont(name: "Impact", size: 40) ?? AppFont.h1(.black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm your post content and visibility."
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private let coverView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()
    
    private let coverLabel: UILabel = {
        let label = UILabel()
        label.text = "COVER"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = AppTheme.textPrimary
        label.backgroundColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.borderWidth = 1
        label.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        label.clipsToBounds = true
        return label
    }()
    
    private let summaryStackView = UIStackView()
    
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
    
    private let publishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Publish", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 25
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.backgroundColor = AppTheme.backgroundColor
        contentView.backgroundColor = AppTheme.backgroundColor
        setupUI()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        publishButton.addTarget(self, action: #selector(publishTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(coinsUpdated), name: .coinsUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        updatePublishButtonState()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        let draft = PostDraftManager.shared
        view.addSubview(scrollView)
        view.addSubview(progressView)
        view.addSubview(closeButton)
        view.addSubview(topSeparator)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(coverView)
        coverView.addSubview(coverLabel)
        let coverImageView = UIImageView(image: draft.media.first.flatMap { PostMediaPreview.image(for: $0) })
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverView.insertSubview(coverImageView, at: 0)
        coverImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.addSubview(summaryStackView)
        
        view.addSubview(bottomBar)
        bottomBar.addSubview(bottomStack)
        bottomStack.addArrangedSubview(backButton)
        bottomStack.addArrangedSubview(publishButton)
        
        summaryStackView.axis = .vertical
        summaryStackView.spacing = 0
        summaryStackView.backgroundColor = .white
        summaryStackView.layer.cornerRadius = 14
        summaryStackView.clipsToBounds = true
        
        let photoCount = draft.media.filter { $0.type == .photo }.count
        let videoCount = draft.media.filter { $0.type == .video }.count
        let mediaDesc: String
        if videoCount > 0 {
            mediaDesc = "\(photoCount) photo\(photoCount != 1 ? "s" : ""), 1 video"
        } else {
            mediaDesc = "\(photoCount) photo\(photoCount != 1 ? "s" : "")"
        }
        
        let itemTypes: [(String, [PostItem])] = [
            ("Top", draft.items.tops),
            ("Bottom", draft.items.bottoms),
            ("Shoes", draft.items.shoes),
            ("Accessories", draft.items.accessories)
        ]
        let itemDesc = itemTypes.filter { !$0.1.isEmpty }.map { $0.0 }.joined(separator: ", ")
        let itemSummary = itemDesc.isEmpty ? "Not added" : itemDesc
        
        let styleSummary = draft.styleTags.isEmpty ? "Not selected" : draft.styleTags.joined(separator: ", ")
        
        let summaryItems = [
            ("Media", mediaDesc),
            ("Items", itemSummary),
            ("Style", styleSummary),
            ("Calendar date", "Today · \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))")
        ]
        
        for (title, value) in summaryItems {
            let row = createSummaryRow(title: title, value: value)
            summaryStackView.addArrangedSubview(row)
        }
        
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
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        coverView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(216)
        }
        
        coverLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(25)
            make.width.equalTo(52)
        }
        
        summaryStackView.snp.makeConstraints { make in
            make.top.equalTo(coverView.snp.bottom).offset(13)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
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
    
    private func createSummaryRow(title: String, value: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        let separator = UIView()
        separator.backgroundColor = AppTheme.authFieldBorderColor
        view.addSubview(separator)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.caption()
        titleLabel.textColor = AppTheme.textTertiary
        view.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = AppFont.caption(.bold)
        valueLabel.textColor = AppTheme.textPrimary
        valueLabel.textAlignment = .right
        view.addSubview(valueLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        separator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        view.snp.makeConstraints { make in
            make.height.equalTo(46)
        }
        
        return view
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
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func publishTapped() {
        guard publishedPostId == nil || isAwaitingPromotion else { return }
        let draft = PostDraftManager.shared
        
        // 基本校验
        guard draft.hasMedia else {
            let alert = CommonAlertView(title: "Missing Media", message: "Please add at least one photo or video.", cancelTitle: "OK")
            alert.show()
            return
        }
        
        if publishedPostId == nil {
            let post = DataRepository.shared.createPost(
                media: draft.media,
                items: draft.items,
                caption: draft.caption,
                styleTags: draft.styleTags,
                location: draft.location
            )
            publishedPostId = post.id
        }

        publishButton.isEnabled = false
        publishButton.alpha = 0.5
        showPromotionPopup()
    }
    
    private func showPromotionPopup() {
        let sheet = ExposureSheetViewController()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.onChoice = { [weak self] confirm in
            guard let self else { return }
            if confirm {
                if DataRepository.shared.currentUser?.coins ?? 0 >= 300, let postId = self.publishedPostId {
                    _ = DataRepository.shared.promotePost(postId: postId)
                    self.isAwaitingPromotion = false
                    self.finishPublish()
                } else {
                    self.isAwaitingPromotion = true
                    self.updatePublishButtonState()
                    let alert = CommonAlertView(title: "Not Enough Coins", message: "You don't have enough Coins to continue.", cancelTitle: "Cancel", confirmTitle: "Recharge")
                    alert.onConfirm = { [weak self] in
                        guard let self else { return }
                        let rechargeVC = BuyCoinsViewController()
                        rechargeVC.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(rechargeVC, animated: true)
                    }
                    alert.show()
                }
            } else { self.finishPublish() }
        }
        present(sheet, animated: false)
    }

    private func finishPublish() {
        PostDraftManager.shared.clear()
        dismiss(animated: true)
    }

    @objc private func coinsUpdated() {
        DispatchQueue.main.async { [weak self] in
            self?.updatePublishButtonState()
        }
    }

    private func updatePublishButtonState() {
        guard isAwaitingPromotion else { return }
        let hasEnoughCoins = (DataRepository.shared.currentUser?.coins ?? 0) >= 300
        publishButton.isEnabled = hasEnoughCoins
        publishButton.alpha = hasEnoughCoins ? 1 : 0.5
    }
}

final class ExposureSheetViewController: UIViewController {
    var onChoice: ((Bool) -> Void)?
    private let sheet = UIView()
    override func viewDidLoad() {
        super.viewDidLoad(); view.backgroundColor = UIColor.black.withAlphaComponent(0.35); sheet.backgroundColor = .white; sheet.layer.cornerRadius = 24; sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]; view.addSubview(sheet); sheet.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview(); $0.height.equalTo(232) }
        let title = UILabel(); title.text = "GET MORE EXPOSURE"; title.font = AppFont.h2(.black); sheet.addSubview(title); title.snp.makeConstraints { $0.top.equalToSuperview().offset(34); $0.leading.equalToSuperview().offset(15) }
        let message = UILabel(); message.text = "Spend 300 coins to feature your post under\nTop Fits and get discovered by more users."; message.font = AppFont.body(); message.textColor = AppTheme.textSecondary; message.numberOfLines = 0; sheet.addSubview(message); message.snp.makeConstraints { $0.top.equalTo(title.snp.bottom).offset(18); $0.leading.trailing.equalToSuperview().inset(15) }
        let no = PostFlowButton(title: "No", filled: false); let confirm = PostFlowButton(title: "Confirm", filled: true); let stack = UIStackView(arrangedSubviews: [no, confirm]); stack.axis = .horizontal; stack.spacing = 10; stack.distribution = .fillEqually; sheet.addSubview(stack); stack.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(15); $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-14); $0.height.equalTo(44) }; no.addTarget(self, action: #selector(noTapped), for: .touchUpInside); confirm.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); sheet.transform = CGAffineTransform(translationX: 0, y: sheet.bounds.height); UIView.animate(withDuration: 0.25) { self.sheet.transform = .identity } }
    @objc private func noTapped() { let callback = onChoice; dismiss(animated: false) { callback?(false) } }
    @objc private func confirmTapped() { let callback = onChoice; dismiss(animated: false) { callback?(true) } }
}
