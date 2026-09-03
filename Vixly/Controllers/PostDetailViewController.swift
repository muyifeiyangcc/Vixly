import UIKit
import SnapKit
import AVKit

class PostDetailViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let postId: String
    private var post: Post?
    private var isItemsUnlocked = false
    private var pendingUnlockCategory: String?
    
    private let authorHeaderView = UIView()
    private let authorAvatar: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.bold)
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let authorInfoLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = UIColor(hex: "#AAAAAA")
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.layer.cornerRadius = 14
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "#111111")
        return button
    }()
    
    private let mediaContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.secondaryColor
        view.clipsToBounds = true
        return view
    }()
    private let mediaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private let mediaScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.bounces = false
        return scroll
    }()
    private let mediaStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

    private let mediaPlayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        button.layer.cornerRadius = 28
        button.isHidden = true
        return button
    }()
    
    private let mediaIndexLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = UIColor(hex: "#111111")
        label.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = AppTheme.primaryColor
        pc.pageIndicatorTintColor = UIColor.white
        pc.isUserInteractionEnabled = false
        return pc
    }()
    
    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .fill
        stack.distribution = .fill
        stack.layer.borderWidth = 1
        stack.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return stack
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(hex: "#111111")
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = UIColor(hex: "#111111")
        return button
    }()
    
    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(hex: "#111111")
        return button
    }()
    
    private let saveCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let postTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .black)
        label.textColor = UIColor(hex: "#111111")
        label.numberOfLines = 0
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.body()
        label.textColor = UIColor(hex: "#111111")
        label.numberOfLines = 0
        return label
    }()
    
    private let tagsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = UIColor(hex: "#AAAAAA")
        return label
    }()
    
    private let aiStylistBanner = UIView()
    
    private let itemBreakdownTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ITEM BREAKDOWN"
        label.font = UIFont.systemFont(ofSize: 25, weight: .black)
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = UIColor(hex: "#AAAAAA")
        return label
    }()
    
    private let itemsStackView = UIStackView()
    
    private let commentsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let commentsStackView = UIStackView()
    private var commentInputBarBottomConstraint: Constraint?
    
    private let commentInputBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let commentIconButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.backgroundColor = AppTheme.backgroundColor
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = .systemFont(ofSize: 14, weight: .regular)
        tf.textColor = UIColor(hex: "#111111")
        tf.backgroundColor = AppTheme.backgroundColor
        tf.layer.cornerRadius = 22
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = UIColor(hex: "#111111")
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 22
        button.isEnabled = false
        return button
    }()
    
    private var comments: [Comment] = []
    
    init(postId: String) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        title = ""
        setupBackButton()
        moreButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        if #available(iOS 14.0, *) { navigationItem.backButtonDisplayMode = .minimal }
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = UIColor(hex: "#111111")
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = nil
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor(hex: "#111111"),
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        setupUI()
        mediaScrollView.delegate = self
        loadData()
        addObservers()
        
        commentTextField.addTarget(self, action: #selector(commentTextChanged), for: .editingChanged)
        sendButton.addTarget(self, action: #selector(sendCommentTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        mediaPlayButton.addTarget(self, action: #selector(mediaTapped), for: .touchUpInside)
        mediaContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediaTapped)))
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(authorHeaderView)
        authorHeaderView.addSubview(authorAvatar)
        authorHeaderView.addSubview(authorNameLabel)
        authorHeaderView.addSubview(authorInfoLabel)
        authorHeaderView.addSubview(followButton)

        authorAvatar.isUserInteractionEnabled = true
        authorAvatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(authorAvatarTapped)))
        
        contentView.addSubview(mediaContainerView)
        mediaContainerView.addSubview(mediaScrollView)
        mediaScrollView.addSubview(mediaStackView)
        mediaStackView.addArrangedSubview(mediaImageView)
        mediaContainerView.addSubview(mediaIndexLabel)
        mediaContainerView.addSubview(pageControl)
        mediaContainerView.addSubview(mediaPlayButton)
        
        contentView.addSubview(statsStack)
        
        let likeStack = UIStackView(arrangedSubviews: [likeButton, likeCountLabel])
        let commentStack = UIStackView(arrangedSubviews: [commentButton, commentCountLabel])
        let saveStack = UIStackView(arrangedSubviews: [saveButton, saveCountLabel])
        [likeStack, commentStack, saveStack].forEach { stack in
            stack.axis = .horizontal
            stack.spacing = 8
            stack.alignment = .center
        }

        // Each metric occupies an equal-width column, with separators matching
        // the reference layout. The inner stack is centered in its column.
        let likeColumn = UIView()
        let commentColumn = UIView()
        let saveColumn = UIView()
        [(likeColumn, likeStack), (commentColumn, commentStack), (saveColumn, saveStack)].forEach { column, stack in
            column.addSubview(stack)
            stack.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        let firstDivider = UIView()
        let secondDivider = UIView()
        [firstDivider, secondDivider].forEach { divider in
            divider.backgroundColor = AppTheme.authFieldBorderColor
            divider.snp.makeConstraints { make in
                make.width.equalTo(1)
            }
        }
        statsStack.addArrangedSubview(likeColumn)
        statsStack.addArrangedSubview(firstDivider)
        statsStack.addArrangedSubview(commentColumn)
        statsStack.addArrangedSubview(secondDivider)
        statsStack.addArrangedSubview(saveColumn)
        likeColumn.snp.makeConstraints { make in
            make.width.equalTo(commentColumn)
            make.width.equalTo(saveColumn)
        }
        
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(tagsStackView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(aiStylistBanner)
        contentView.addSubview(itemBreakdownTitleLabel)
        contentView.addSubview(itemCountLabel)
        contentView.addSubview(itemsStackView)
        contentView.addSubview(commentsTitleLabel)
        contentView.addSubview(commentsStackView)
        
        view.addSubview(commentInputBar)
        commentInputBar.addSubview(commentIconButton)
        commentInputBar.addSubview(commentTextField)
        commentInputBar.addSubview(sendButton)
        
        setupAIStylistBanner()
        setupItemsSection()
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(commentInputBar.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        authorHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        authorAvatar.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        authorNameLabel.snp.makeConstraints { make in
            make.top.equalTo(authorAvatar.snp.top).offset(1)
            make.left.equalTo(authorAvatar.snp.right).offset(12)
        }
        
        authorInfoLabel.snp.makeConstraints { make in
            make.bottom.equalTo(authorAvatar.snp.bottom).offset(-1)
            make.left.equalTo(authorAvatar.snp.right).offset(12)
        }
        
        followButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(70)
        }
        
        mediaContainerView.snp.makeConstraints { make in
            make.top.equalTo(authorHeaderView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(390)
        }
        
        mediaIndexLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(26)
            make.width.greaterThanOrEqualTo(42)
        }
        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
        }
        
        mediaScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mediaStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(mediaScrollView)
        }
        mediaImageView.snp.makeConstraints { make in
            make.width.equalTo(mediaContainerView)
            make.height.equalTo(mediaScrollView)
        }

        mediaPlayButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        statsStack.snp.makeConstraints { make in
            make.top.equalTo(mediaContainerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        commentButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        saveButton.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        tagsStackView.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(tagsStackView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        aiStylistBanner.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(128)
        }
        
        itemBreakdownTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(aiStylistBanner.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(20)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(itemBreakdownTitleLabel)
            make.right.equalToSuperview().offset(-20)
        }
        
        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(itemBreakdownTitleLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
        
        commentsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(itemsStackView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        commentsStackView.snp.makeConstraints { make in
            make.top.equalTo(commentsTitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        commentInputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            self.commentInputBarBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.height.equalTo(76)
        }

        commentIconButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        commentTextField.snp.makeConstraints { make in
            make.left.equalTo(commentIconButton.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.height.equalTo(44)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        if #available(iOS 15.0, *) {
            commentInputBarBottomConstraint?.deactivate()
            commentInputBar.snp.makeConstraints { make in
                make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            }
        }
    }
    
    private func setupAIStylistBanner() {
        aiStylistBanner.backgroundColor = AppTheme.backgroundColor
        aiStylistBanner.layer.cornerRadius = 20
        aiStylistBanner.clipsToBounds = true
        
        // The aistyle asset already contains the copy, illustration and CTA
        // styling used on the home page. Do not overlay a second set of labels.
        let backgroundImage = UIImageView(image: UIImage(named: "aistyle"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        aiStylistBanner.addSubview(backgroundImage)

        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let actionButton = UIButton(type: .custom)
        actionButton.backgroundColor = .clear
        actionButton.addTarget(self, action: #selector(aiStylistTapped), for: .touchUpInside)
        aiStylistBanner.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupItemsSection() {
        itemsStackView.axis = .vertical
        itemsStackView.spacing = 0
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 16
    }
    
    private func loadData() {
        post = DataRepository.shared.getPost(byId: postId)
        comments = DataRepository.shared.getComments(for: postId)
        
        guard let post = post else { return }

        for view in mediaStackView.arrangedSubviews.dropFirst() { view.removeFromSuperview() }
        if let firstMedia = post.media.first {
            mediaImageView.image = PostMediaPreview.image(for: firstMedia)
            for media in post.media.dropFirst() {
                let imageView = UIImageView(image: PostMediaPreview.image(for: media))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                mediaStackView.addArrangedSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.width.equalTo(mediaContainerView)
                    make.height.equalTo(mediaScrollView)
                }
            }
            mediaPlayButton.isHidden = firstMedia.type != .video
        } else {
            mediaImageView.image = nil
            mediaPlayButton.isHidden = true
        }
        
        // pageControl
        pageControl.numberOfPages = max(1, post.media.count)
        pageControl.currentPage = 0
        pageControl.isHidden = post.media.count <= 1
        
        if let user = DataRepository.shared.getUser(byId: post.userId) {
            navigationItem.title = user.name.lowercased().replacingOccurrences(of: " ", with: ".")
            authorNameLabel.text = "@" + user.name.lowercased().replacingOccurrences(of: " ", with: ".")
            authorAvatar.image = DataRepository.shared.avatarImage(for: user)
            authorInfoLabel.text = "\(post.location) · \(formatTimeAgo(post.date))"
        }
        
        let isCurrentUser = post.userId == DataRepository.shared.currentUser?.id
        followButton.isHidden = isCurrentUser
        if isCurrentUser {
            navigationItem.rightBarButtonItem = nil
        } else {
            moreButton.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        }
        
        if !isCurrentUser {
            let isFollowing = DataRepository.shared.isFollowing(userId: post.userId)
            updateFollowButton(isFollowing: isFollowing)
        }
        
        likeButton.setImage(UIImage(systemName: post.isLiked ? "heart.fill" : "heart"), for: .normal)
        likeButton.tintColor = post.isLiked ? .systemRed : UIColor(hex: "#111111")
        likeCountLabel.text = "\(post.likesCount)"
        
        commentCountLabel.text = "\(post.commentsCount)"
        
        saveButton.setImage(UIImage(systemName: post.isSaved ? "bookmark.fill" : "bookmark"), for: .normal)
        saveButton.tintColor = post.isSaved ? AppTheme.primaryColor : UIColor(hex: "#111111")
        saveCountLabel.text = "\(post.savesCount)"
        
        // Post title + caption split
        let caption = post.caption
        var titleText = ""
        var bodyText = ""
        if caption.contains("\n") {
            let parts = caption.components(separatedBy: "\n")
            titleText = parts.first ?? ""
            bodyText = parts.dropFirst().joined(separator: "\n")
        } else if caption.count <= 50 {
            titleText = caption
            bodyText = ""
        } else {
            let endIdx = caption.index(caption.startIndex, offsetBy: min(40, caption.count), limitedBy: caption.endIndex) ?? caption.endIndex
            titleText = String(caption[..<endIdx])
            bodyText = caption
        }
        postTitleLabel.text = titleText
        postTitleLabel.isHidden = titleText.isEmpty
        captionLabel.text = bodyText.isEmpty ? caption : bodyText
        if bodyText.isEmpty {
            captionLabel.isHidden = true
        }
        
        for subview in tagsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for tag in post.styleTags {
            let tagView = UIView()
            tagView.backgroundColor = AppTheme.backgroundColor
            tagView.layer.cornerRadius = 13
            
            let tagLabel = UILabel()
            tagLabel.font = AppFont.caption(.semibold)
            tagLabel.textColor = UIColor(hex: "#111111")
            
            let capitalized = tag.prefix(1).uppercased() + tag.dropFirst().lowercased()
            tagLabel.text = capitalized
            
            tagView.addSubview(tagLabel)
            tagLabel.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(6)
                make.left.right.equalToSuperview().inset(12)
            }
            tagView.snp.makeConstraints { make in
                make.height.equalTo(26)
            }
            
            tagsStackView.addArrangedSubview(tagView)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateLabel.text = "\(dateFormatter.string(from: post.date)) · Public"
        
        // media index label
        if let firstMedia = post.media.first {
            mediaIndexLabel.isHidden = false
            if firstMedia.type == .video {
                mediaIndexLabel.text = PostMediaPreview.durationText(for: firstMedia).map { "VIDEO \($0)" } ?? "VIDEO"
            } else {
                mediaIndexLabel.text = "1/\(post.media.count)"
            }
        } else {
            mediaIndexLabel.isHidden = true
        }
        
        reloadItemsSection()
        reloadComments()
    }
    
    private func reloadItemsSection() {
        guard let post = post else { return }
        
        for subview in itemsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        itemCountLabel.text = "\(post.items.totalCount) items"
        let isUnlocked = isItemsUnlocked || DataRepository.shared.isPostItemUnlocked(postId: postId) || post.isItemUnlocked
        let categories: [(String, [PostItem], String, UIColor)] = [
            ("Top", post.items.tops, "cloth_blue", UIColor.clear),
            ("Bottom", post.items.bottoms, "Bottom", UIColor.clear),
            ("Shoes", post.items.shoes, "shoes_blue", UIColor.clear),
            ("Accessories", post.items.accessories, "Accessories", UIColor.clear)
        ]
        for (categoryName, items, iconName, catBgColor) in categories {
            for item in items {
                let row = UIView()
                row.backgroundColor = .white
                let innerView = UIView()
                innerView.backgroundColor = .white
                row.addSubview(innerView)
                let iconBackground = UIView()
                iconBackground.backgroundColor = catBgColor
                iconBackground.layer.cornerRadius = 12
                iconBackground.clipsToBounds = true
                innerView.addSubview(iconBackground)
                let icon = UIImageView(image: UIImage(named: iconName))
                icon.contentMode = .scaleAspectFit
                iconBackground.addSubview(icon)

                let title = UILabel()
                title.font = UIFont.systemFont(ofSize: 13, weight: .bold)
                title.textColor = UIColor(hex: "#111111")
                title.text = "\(categoryName) · \(item.product.isEmpty ? item.brand : item.product)"
                innerView.addSubview(title)
                let detail = UILabel()
                detail.font = AppFont.caption()
                detail.textColor = UIColor(hex: "#777777")
                let detailParts = [item.color.isEmpty ? nil : item.color, item.size.isEmpty ? nil : "Size \(item.size)"].compactMap { $0 }
                detail.text = detailParts.joined(separator: " · ")
                innerView.addSubview(detail)
                let action = UIImageView(image: UIImage(named: isUnlocked ? "right_arrow" : "lock") ?? UIImage(systemName: isUnlocked ? "chevron.right" : "lock"))
                action.tintColor = UIColor(hex: "#AAAAAA")
                innerView.addSubview(action)
                row.tag = isUnlocked ? 1 : 0
                row.accessibilityIdentifier = categoryName
                row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(itemRowTapped(_:))))
                row.isUserInteractionEnabled = true
                
                innerView.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.top.bottom.equalToSuperview()
                }
                
                iconBackground.snp.makeConstraints { make in
                    make.leading.equalToSuperview().offset(0)
                    make.centerY.equalToSuperview()
                    make.width.height.equalTo(44)
                }
                icon.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                title.snp.makeConstraints { make in
                    make.leading.equalTo(iconBackground.snp.trailing).offset(12)
                    make.top.equalToSuperview().offset(18)
                    make.trailing.equalTo(action.snp.leading).offset(-12)
                }
                detail.snp.makeConstraints { make in
                    make.leading.equalTo(title)
                    make.top.equalTo(title.snp.bottom).offset(4)
                    make.trailing.equalTo(title)
                }
                action.snp.makeConstraints { make in
                    make.trailing.equalToSuperview().offset(0)
                    make.centerY.equalToSuperview()
                    make.width.height.equalTo(20)
                }
                row.snp.makeConstraints { make in make.height.equalTo(80) }
                itemsStackView.addArrangedSubview(row)
            }
        }
    }
    
    private func reloadComments() {
        for subview in commentsStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        // Build COMMENTS · N attributed string
        let commentTitleAttr = NSMutableAttributedString(
            string: "COMMENTS",
            attributes: [
                .font: UIFont.systemFont(ofSize: 25, weight: .black),
                .foregroundColor: UIColor(hex: "#111111")
            ]
        )
        let countStr = NSAttributedString(
            string: " · \(comments.count)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor(hex: "#111111")
            ]
        )
        commentTitleAttr.append(countStr)
        commentsTitleLabel.attributedText = commentTitleAttr
        
        for comment in comments {
            let commentView = CommentItemView(comment: comment)
            
            // O-04: 设置 more 回调
            let commentUserId = comment.userId
            commentView.onMoreTapped = { [weak self] in
                self?.showCommentMoreOptions(userId: commentUserId)
            }
            commentView.onAvatarTapped = { [weak self] in
                self?.openProfile(for: commentUserId)
            }
            
            commentsStackView.addArrangedSubview(commentView)
        }
    }
    
    // O-04: 评论 more 选项
    private func showCommentMoreOptions(userId: String) {
        guard userId != DataRepository.shared.currentUser?.id else { return }
        let sheet = ReportBlockSheetViewController()
        sheet.onAction = { [weak self] action in
            switch action {
            case .report:
                let reportVC = ReportViewController(targetUserId: userId, postId: self?.postId, source: "Comment")
                self?.navigationController?.pushViewController(reportVC, animated: true)
            case .block:
                self?.showBlockConfirmation(userId: userId)
            }
        }
        present(sheet, animated: false)
    }
    
    private func updateFollowButton(isFollowing: Bool) {
        followButton.layer.borderWidth = 1.5
        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(UIColor(hex: "#888888"), for: .normal)
            followButton.backgroundColor = UIColor(hex: "#F5F7F6")
            followButton.layer.borderColor = UIColor(hex: "#DDDDDD").cgColor
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(UIColor(hex: "#111111"), for: .normal)
            followButton.backgroundColor = .white
            followButton.layer.borderColor = UIColor(hex: "#111111").cgColor
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .postUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(commentAdded), name: .commentAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(followChanged), name: .followStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        if #available(iOS 15.0, *) { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let frameInView = view.convert(keyboardFrame, from: nil)
        let safeBottom = view.bounds.maxY - view.safeAreaInsets.bottom
        let overlap = max(0, safeBottom - frameInView.minY)
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 7
        let options = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        commentInputBarBottomConstraint?.update(offset: -overlap)
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, options]) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func postUpdated(notification: Notification) {
        guard let updatedPostId = notification.userInfo?["postId"] as? String,
              updatedPostId == postId else { return }
        loadData()
    }
    
    @objc private func commentAdded(notification: Notification) {
        guard let updatedPostId = notification.userInfo?["postId"] as? String,
              updatedPostId == postId else { return }
        loadData()
    }
    
    @objc private func followChanged() {
        loadData()
    }
    
    @objc private func likeTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        _ = DataRepository.shared.toggleLike(postId: postId)
    }
    
    @objc private func saveTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        _ = DataRepository.shared.toggleSave(postId: postId)
    }
    
    @objc private func followTapped() {
        guard let post = post else { return }
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        _ = DataRepository.shared.toggleFollow(userId: post.userId)
    }

    @objc private func authorAvatarTapped() {
        guard let post else { return }
        openProfile(for: post.userId)
    }

    private func openProfile(for userId: String) {
        if userId == DataRepository.shared.currentUser?.id {
            // The signed-in user's avatar always returns to the Profile tab.
            let tabBarController = self.tabBarController
            navigationController?.popToRootViewController(animated: false)
            if let tabBarController {
                tabBarController.selectedIndex = 4
            } else if let mainTabBarController = AppRouter.shared.window?.rootViewController as? MainTabBarController {
                mainTabBarController.selectedIndex = 4
            } else {
                navigationController?.pushViewController(ProfileViewController(isGuest: false), animated: true)
            }
            return
        }

        let profileVC = UserProfileViewController(userId: userId)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func moreTapped() {
        guard let post = post else { return }
        let isCurrentUser = post.userId == DataRepository.shared.currentUser?.id
        guard !isCurrentUser else { return }

        let sheet = ReportBlockSheetViewController(includeUserActions: true)
        sheet.onAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .report:
                let reportVC = ReportViewController(targetUserId: post.userId, postId: post.id, source: "Post Detail")
                self.navigationController?.pushViewController(reportVC, animated: true)
            case .block:
                self.showBlockConfirmation(userId: post.userId)
            }
        }
        present(sheet, animated: false)
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

    @objc private func mediaTapped() {
        guard let post, !post.media.isEmpty else { return }
        let page = min(post.media.count - 1, max(0, Int(round(mediaScrollView.contentOffset.x / max(mediaScrollView.bounds.width, 1)))))
        let media = post.media[page]
        if media.type == .video, let mediaURL = PostMediaPreview.url(for: media) {
            let preview = AVPlayerViewController()
            preview.player = AVPlayer(url: mediaURL)
            present(preview, animated: true) { preview.player?.play() }
        } else {
            let preview = PhotoPreviewViewController(image: PostMediaPreview.image(for: media))
            preview.modalPresentationStyle = .fullScreen
            present(preview, animated: true)
        }
    }
    
    @objc private func unlockItemsTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        guard let coins = DataRepository.shared.currentUser?.coins else { return }
        
        if coins < 300 {
            showNotEnoughCoins()
            return
        }
        
        let alert = CommonAlertView(
            title: "Unlock Item Breakdown",
            message: "Get instant access to full item details for 300 coins.",
            cancelTitle: "Cancel",
            confirmTitle: "Unlock"
        )
        alert.onConfirm = { [weak self] in
            guard let self = self else { return }
            if DataRepository.shared.consumeCoins(amount: 300) {
                self.isItemsUnlocked = true
                DataRepository.shared.unlockPostItems(postId: self.postId)
                if let post = self.post {
                    let sheet: UIViewController
                    if let category = self.pendingUnlockCategory,
                       let item = self.itemForCategory(category, in: post.items) {
                        sheet = ItemEditorSheetViewController(category: category, item: item)
                    } else {
                        sheet = ReadonlyItemDetailsSheetViewController(items: post.items)
                    }
                    self.pendingUnlockCategory = nil
                    sheet.modalPresentationStyle = .overFullScreen
                    DispatchQueue.main.async { self.present(sheet, animated: false) }
                }
            }
        }
        alert.show()
    }

    @objc private func itemRowTapped(_ gesture: UITapGestureRecognizer) {
        guard let row = gesture.view else { return }
        if row.tag == 1, let post,
           let category = row.accessibilityIdentifier,
           let item = itemForCategory(category, in: post.items) {
            let sheet = ItemEditorSheetViewController(category: category, item: item)
            sheet.modalPresentationStyle = .overFullScreen
            present(sheet, animated: false)
        } else {
            pendingUnlockCategory = row.accessibilityIdentifier
            unlockItemsTapped()
        }
    }

    private func itemForCategory(_ category: String, in items: PostItems) -> PostItem? {
        switch category {
        case "Top": return items.tops.first
        case "Bottom": return items.bottoms.first
        case "Shoes": return items.shoes.first
        case "Accessories": return items.accessories.first
        default: return nil
        }
    }
    
    @objc private func commentTextChanged() {
        sendButton.isEnabled = !(commentTextField.text?.isEmpty ?? true)
    }
    
    @objc private func sendCommentTapped() {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        DataRepository.shared.addComment(postId: postId, content: text)
        commentTextField.text = ""
        sendButton.isEnabled = false
    }
    
    private func showSignInRequired() {
        let alert = CommonAlertView(
            title: "Sign In Required",
            message: "Please sign in to access this feature.",
            cancelTitle: "Cancel",
            confirmTitle: "Sign In"
        )
        alert.onConfirm = { [weak self] in
            AppRouter.shared.showSignIn(from: self ?? UIViewController())
        }
        alert.show()
    }
    
    private func showNotEnoughCoins() {
        let alert = CommonAlertView(
            title: "Not Enough Coins",
            message: "You don't have enough Coins to continue. Would you like to recharge?",
            cancelTitle: "Cancel",
            confirmTitle: "Recharge"
        )
        alert.onConfirm = { [weak self] in
            let rechargeVC = BuyCoinsViewController()
            rechargeVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(rechargeVC, animated: true)
        }
        alert.show()
    }
    
    private func showBlockConfirmation(userId: String) {
        let alert = CommonAlertView(
            title: "Block User",
            message: "Are you sure you want to block this user?",
            cancelTitle: "Cancel",
            confirmTitle: "Block"
        )
        alert.onConfirm = { [weak self] in
            DataRepository.shared.blockUser(userId: userId)
            self?.navigationController?.popViewController(animated: true)
        }
        alert.show()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "just now" }
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours) h ago" }
        let days = hours / 24
        if days < 7 { return "\(days) d ago" }
        return formatDate(date)
    }
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === mediaScrollView, mediaContainerView.bounds.width > 0 {
            let page = Int(round(scrollView.contentOffset.x / mediaContainerView.bounds.width))
            pageControl.currentPage = max(0, min(pageControl.numberOfPages - 1, page))
            // update mediaIndexLabel for non-video
            guard let post = post, let first = post.media.first, first.type != .video else { return }
            let current = max(1, min(post.media.count, page + 1))
            mediaIndexLabel.text = "\(current)/\(post.media.count)"
        }
    }
}

final class ReadonlyItemDetailsSheetViewController: UIViewController {
    private let items: PostItems
    private let category: String?
    private let selectedItem: PostItem?
    private let sheet = UIView()

    init(items: PostItems) {
        self.items = items
        self.category = nil
        self.selectedItem = nil
        super.init(nibName: nil, bundle: nil)
    }

    init(category: String, item: PostItem) {
        self.items = PostItems(tops: [], bottoms: [], shoes: [], accessories: [])
        self.category = category
        self.selectedItem = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 24
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sheet)
        sheet.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(500)
        }
        let handle = UIView()
        handle.backgroundColor = AppTheme.authFieldBorderColor
        handle.layer.cornerRadius = 2
        sheet.addSubview(handle)
        handle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        let title = UILabel()
        title.text = (category ?? "ITEM BREAKDOWN").uppercased()
        title.font = UIFont(name: "Impact", size: 26) ?? .systemFont(ofSize: 26, weight: .black)
        title.textColor = AppTheme.textPrimary
        sheet.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalTo(handle.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
        }
        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.tintColor = AppTheme.textPrimary
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        sheet.addSubview(close)
        close.snp.makeConstraints { make in
            make.top.equalTo(title)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(24)
        }
        let subtitle = UILabel()
        subtitle.text = selectedItem == nil ? "Item details from this OOTD" : "Item details shown with this OOTD"
        subtitle.font = AppFont.caption()
        subtitle.textColor = AppTheme.textSecondary
        sheet.addSubview(subtitle)
        subtitle.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        if let category, let selectedItem {
            let fields: [(String, String)] = [
                ("Brand", selectedItem.brand),
                ("Product", selectedItem.product),
                ("Color", selectedItem.color),
                ("Size", selectedItem.size)
            ]
            var previous: UIView = subtitle
            for (index, field) in fields.enumerated() {
                let label = UILabel()
                label.text = field.0
                label.font = AppFont.caption(.bold)
                label.textColor = AppTheme.textPrimary
                sheet.addSubview(label)
                label.snp.makeConstraints { make in
                    make.top.equalTo(previous.snp.bottom).offset(14)
                    make.leading.equalToSuperview().offset(16)
                }
                let value = UILabel()
                value.text = field.1.isEmpty ? "—" : field.1
                value.font = AppFont.caption()
                value.textColor = AppTheme.textSecondary
                value.backgroundColor = AppTheme.backgroundColor
                value.layer.cornerRadius = 10
                value.layer.borderWidth = 1
                value.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
                value.clipsToBounds = true
                value.textAlignment = .left
                sheet.addSubview(value)
                value.snp.makeConstraints { make in
                    make.top.equalTo(label.snp.bottom).offset(6)
                    make.leading.trailing.equalToSuperview().inset(16)
                    make.height.equalTo(46)
                }
                previous = value
                if index == fields.count - 1 {
                    let closeButton = PostFlowButton(title: "Close", filled: true)
                    closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
                    sheet.addSubview(closeButton)
                    closeButton.snp.makeConstraints { make in
                        make.top.equalTo(value.snp.bottom).offset(14)
                        make.leading.trailing.equalToSuperview().inset(16)
                        make.height.equalTo(44)
                    }
                }
            }
            return
        }
        let categories: [(String, [PostItem])]
        if let category, let selectedItem {
            categories = [(category, [selectedItem])]
        } else {
            categories = [("Top", items.tops), ("Bottom", items.bottoms), ("Shoes", items.shoes), ("Accessories", items.accessories)]
        }
        var previous: UIView = subtitle
        for (category, values) in categories where !values.isEmpty {
            let item = values[0]
            let row = UIView()
            row.backgroundColor = AppTheme.backgroundColor
            row.layer.cornerRadius = 12
            sheet.addSubview(row)
            let label = UILabel()
            label.font = AppFont.caption(.bold)
            label.textColor = AppTheme.textPrimary
            label.numberOfLines = 0
            label.text = "\(category) · \(item.product.isEmpty ? item.brand : item.product)\n\(item.brand) · \(item.color) · Size \(item.size)"
            row.addSubview(label)
            label.snp.makeConstraints { make in make.leading.trailing.equalToSuperview().inset(14); make.centerY.equalToSuperview() }
            row.snp.makeConstraints { make in
                make.top.equalTo(previous.snp.bottom).offset(10)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(58)
            }
            previous = row
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheet.transform = CGAffineTransform(translationX: 0, y: sheet.bounds.height)
        UIView.animate(withDuration: 0.25) { self.sheet.transform = .identity }
    }

    @objc private func closeTapped() { dismiss(animated: false) }
}

class CommentItemView: UIView {
    
    var onMoreTapped: (() -> Void)?
    var onAvatarTapped: (() -> Void)?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.bold)
        label.textColor = UIColor(hex: "#111111")
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(hex: "#111111")
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = UIColor(hex: "#AAAAAA")
        return label
    }()
    
    private let replyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reply", for: .normal)
        button.titleLabel?.font = AppFont.caption()
        button.setTitleColor(UIColor(hex: "#AAAAAA"), for: .normal)
        return button
    }()
    
    // O-04: 更多按钮
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor(hex: "#AAAAAA")
        return button
    }()
    
    private let comment: Comment!
    
    init(comment: Comment) {
        self.comment = comment
        super.init(frame: .zero)
        setupUI()
        configure(with: comment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(commentLabel)
        addSubview(timeLabel)
        addSubview(replyButton)
        addSubview(moreButton)
        
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        
        avatarImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
        }
        
        // O-04: more 按钮在名字一行最右边
        moreButton.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-24)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(commentLabel.snp.bottom).offset(6)
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.bottom.equalToSuperview()
        }
        
        replyButton.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.left.equalTo(timeLabel.snp.right).offset(16)
        }
    }
    
    // O-04: 更多选项
    @objc private func moreTapped() {
        guard comment.userId != DataRepository.shared.currentUser?.id else { return }
        onMoreTapped?()
    }

    @objc private func avatarTapped() {
        onAvatarTapped?()
    }
    
    private func configure(with comment: Comment) {
        moreButton.isHidden = comment.userId == DataRepository.shared.currentUser?.id
        if let user = DataRepository.shared.getUser(byId: comment.userId) {
            let lowerName = user.name.lowercased().replacingOccurrences(of: " ", with: ".")
            nameLabel.text = "@" + lowerName
            avatarImageView.image = DataRepository.shared.avatarImage(for: user)
        }
        commentLabel.text = comment.content
        timeLabel.text = formatCommentTime(comment.createdAt)
    }
    
    private func formatCommentTime(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "now" }
        if minutes < 60 { return "\(minutes)m" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h" }
        let days = hours / 24
        return "\(days)d"
    }
}
