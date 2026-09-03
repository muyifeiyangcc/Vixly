import UIKit
import SnapKit

class InboxViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "INBOX"
        label.font = AppFont.h1(.black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let aiStylistBanner = UIView()
    
    private let recentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "RECENT CONVERSATIONS"
        label.font = AppFont.subtitle(.regular)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let conversationsStackView = UIStackView()
    
    private var conversations: [Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        setupUI()
        loadData()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(aiStylistBanner)
        contentView.addSubview(recentTitleLabel)
        contentView.addSubview(conversationsStackView)
        
        setupAIStylistBanner()
        
        conversationsStackView.axis = .vertical
        conversationsStackView.spacing = 0
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
        }
        
        aiStylistBanner.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }

        recentTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(aiStylistBanner.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        conversationsStackView.snp.makeConstraints { make in
            make.top.equalTo(recentTitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupAIStylistBanner() {
        aiStylistBanner.backgroundColor = .white
        aiStylistBanner.layer.cornerRadius = 16
        aiStylistBanner.layer.borderWidth = 0
        aiStylistBanner.clipsToBounds = true
        let imageView = UIImageView(image: UIImage(named: "aistyle"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        aiStylistBanner.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(aiStylistTapped))
        aiStylistBanner.addGestureRecognizer(tapGesture)
        aiStylistBanner.isUserInteractionEnabled = true
        
    }
    
    private func loadData() {
        if DataRepository.shared.isGuest {
            conversations = []
        } else {
            // Without a Chats/Requests filter, show all recent conversations
            // in one time-ordered list.
            conversations = DataRepository.shared.getConversations(includeRequests: false)
                + DataRepository.shared.getConversations(includeRequests: true)
            conversations.sort { $0.lastMessageTime > $1.lastMessageTime }
        }
        
        reloadConversations()
    }
    
    private func reloadConversations() {
        for subview in conversationsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for conv in conversations {
            let cell = ConversationCell(conversation: conv)
            cell.onTapped = { [weak self] in
                self?.openConversation(conv)
            }
            conversationsStackView.addArrangedSubview(cell)
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(messageSent), name: .messageSent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated), name: .userProfileUpdated, object: nil)
    }
    
    @objc private func messageSent() {
        loadData()
    }

    @objc private func profileUpdated() {
        loadData()
    }
    
    @objc private func aiStylistTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        let aiVC = AIStylistViewController()
        aiVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(aiVC, animated: true)
    }
    
    private func openConversation(_ conversation: Conversation) {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        DataRepository.shared.markConversationRead(userId: conversation.userId)
        let chatVC = ChatViewController(userId: conversation.userId)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func showSignInRequired() {
        let alert = CommonAlertView(
            title: "Sign In Required",
            message: "Please sign in to access messages.",
            cancelTitle: "Cancel",
            confirmTitle: "Sign In"
        )
        alert.onConfirm = { [weak self] in
            AppRouter.shared.showSignIn(from: self ?? UIViewController())
        }
        alert.show()
    }
}

class ConversationCell: UIView {
    
    var onTapped: (() -> Void)?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body(.semibold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle()
        label.textColor = AppTheme.textSecondary
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textTertiary
        label.textAlignment = .right
        return label
    }()
    
    private let unreadBadge: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.primaryColor
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    init(conversation: Conversation) {
        super.init(frame: .zero)
        setupUI()
        configure(with: conversation)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(lastMessageLabel)
        addSubview(timeLabel)
        addSubview(unreadBadge)
        unreadBadge.addSubview(unreadCountLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
        }
        
        lastMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.right.equalTo(unreadBadge.snp.left).offset(-8)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-12)
        }
        
        unreadBadge.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        
        unreadCountLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(6)
        }
    }
    
    private func configure(with conversation: Conversation) {
        if let user = DataRepository.shared.getUser(byId: conversation.userId) {
            nameLabel.text = user.name
            avatarImageView.image = DataRepository.shared.avatarImage(for: user)
        }
        
        lastMessageLabel.text = conversation.lastMessage
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        timeLabel.text = formatter.string(from: conversation.lastMessageTime)
        
        if conversation.unreadCount > 0 {
            backgroundColor = UIColor(hex: "#FBFFE7")
            unreadBadge.isHidden = false
            unreadCountLabel.text = "\(conversation.unreadCount)"
        } else {
            backgroundColor = .white
            unreadBadge.isHidden = true
        }
    }
    
    @objc private func cellTapped() {
        onTapped?()
    }
}
