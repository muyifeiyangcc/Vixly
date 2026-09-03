import UIKit
import SnapKit

class PostCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PostCollectionViewCell"
    /// Total card height ratio used by the two-column grids.
    static let gridHeightRatio: CGFloat = 2.0
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let videoIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 4
        view.isHidden = true
        return view
    }()
    
    private let videoIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "play.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let videoDurationLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = .white
        return label
    }()
    
    private let authorStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private let authorInfoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        return stack
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 14
        iv.clipsToBounds = true
        return iv
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle(.semibold)
        label.textColor = AppTheme.textPrimary
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textTertiary
        return label
    }()
    
    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppTheme.textTertiary
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = .zero
        return button
    }()
    
    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textTertiary
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppTheme.textTertiary
        return button
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = AppTheme.textTertiary
        return button
    }()
    
    private let pageIndicatorLabel: PostMediaBadgeLabel = {
        let label = PostMediaBadgeLabel()
        label.font = AppFont.caption(.semibold)
        label.textColor = AppTheme.textPrimary
        label.backgroundColor = .white
        label.textAlignment = .center
        label.textInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        return label
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        button.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        button.layer.cornerRadius = 22
        button.isHidden = true
        return button
    }()
    
    var onMoreTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    var onSaveTapped: (() -> Void)?
    var onAuthorTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(videoIndicatorView)
        videoIndicatorView.addSubview(videoIcon)
        videoIndicatorView.addSubview(videoDurationLabel)
        containerView.addSubview(pageIndicatorLabel)
        containerView.addSubview(playButton)
        containerView.addSubview(authorStack)
        authorStack.addArrangedSubview(avatarImageView)
        authorStack.addArrangedSubview(authorInfoStack)
        authorInfoStack.addArrangedSubview(authorNameLabel)
        authorInfoStack.addArrangedSubview(locationLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(statsStack)
        
        let likeStack = UIStackView(arrangedSubviews: [likeButton, likeCountLabel])
        likeStack.axis = .horizontal
        likeStack.spacing = 4
        
        statsStack.addArrangedSubview(likeStack)
        statsStack.addArrangedSubview(saveButton)
        statsStack.addArrangedSubview(UIView())
        statsStack.addArrangedSubview(moreButton)
        
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        
        authorStack.isUserInteractionEnabled = true
        let authorTapGesture = UITapGestureRecognizer(target: self, action: #selector(authorTapped))
        authorStack.addGestureRecognizer(authorTapGesture)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(containerView.snp.width).multipliedBy(1.3)
        }
        
        videoIndicatorView.snp.makeConstraints { make in
            make.bottom.equalTo(imageView).offset(-8)
            make.trailing.equalTo(imageView).offset(-8)
            make.height.equalTo(24)
        }
        
        videoIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
        videoDurationLabel.snp.makeConstraints { make in
            make.left.equalTo(videoIcon.snp.right).offset(4)
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
        }
        
        pageIndicatorLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView).offset(8)
            make.trailing.equalTo(imageView).offset(-16)
        }

        playButton.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.height.equalTo(44)
        }
        
        authorStack.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(authorStack.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        
        statsStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        likeButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
    }
    
    func configure(with post: Post) {
        // A user's own posts do not expose report/block actions.
        moreButton.isHidden = post.userId == DataRepository.shared.currentUser?.id
        if let user = DataRepository.shared.getUser(byId: post.userId) {
            authorNameLabel.text = user.name
            avatarImageView.image = DataRepository.shared.avatarImage(for: user)
        } else {
            authorNameLabel.text = nil
            avatarImageView.image = nil
        }
        
        let captionParts = post.caption.components(separatedBy: "\n")
        titleLabel.text = captionParts.first ?? post.caption
        let style = post.primaryStyleTag ?? post.styleTags.first
        locationLabel.text = [post.location, style].compactMap { value in
            guard let value, !value.isEmpty else { return nil }
            return value
        }.joined(separator: " · ")
        likeCountLabel.text = "\(post.likesCount)"

        let firstMedia = post.media.first
        imageView.image = firstMedia.flatMap { PostMediaPreview.image(for: $0) }
        if let firstMedia {
            pageIndicatorLabel.isHidden = false
            if firstMedia.type == .video {
                let duration = PostMediaPreview.durationText(for: firstMedia).map { "VIDEO \($0)" } ?? "VIDEO"
                pageIndicatorLabel.text = duration
                playButton.isHidden = false
            } else {
                pageIndicatorLabel.text = "PHOTO \(post.media.count)"
                playButton.isHidden = true
            }
        } else {
            pageIndicatorLabel.text = nil
            pageIndicatorLabel.isHidden = true
            playButton.isHidden = true
        }
        
        let heartConfiguration = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        likeButton.setImage(UIImage(systemName: post.isLiked ? "heart.fill" : "heart", withConfiguration: heartConfiguration), for: .normal)
        likeButton.tintColor = post.isLiked ? .systemRed : AppTheme.textTertiary
        
        saveButton.setImage(UIImage(systemName: post.isSaved ? "bookmark.fill" : "bookmark"), for: .normal)
        saveButton.tintColor = post.isSaved ? AppTheme.primaryColor : AppTheme.textTertiary
        
        videoIndicatorView.isHidden = true
    }
    
    @objc private func likeTapped() {
        onLikeTapped?()
    }
    
    @objc private func saveTapped() {
        onSaveTapped?()
    }
    
    @objc private func moreTapped() {
        guard !moreButton.isHidden else { return }
        onMoreTapped?()
    }
    
    @objc private func authorTapped() {
        onAuthorTapped?()
    }
}

final class PostMediaBadgeLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}
