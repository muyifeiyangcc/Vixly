import UIKit
import SnapKit

class UserListViewController: BaseViewController {
    
    enum ListType {
        case followers
        case following
    }
    
    private let listType: ListType
    private let userId: String
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let usersStackView = UIStackView()
    
    private var users: [User] = []
    
    init(listType: ListType, userId: String) {
        self.listType = listType
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = setupAuthHeader(title: listType == .followers ? "FOLLOWERS" : "FOLLOWING")
        setupUI()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        loadData()
        addObservers()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(usersStackView)
        
        usersStackView.axis = .vertical
        usersStackView.spacing = 1
        usersStackView.backgroundColor = .white
        usersStackView.layer.cornerRadius = 0
        usersStackView.clipsToBounds = true
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        usersStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func loadData() {
        guard !userId.isEmpty else {
            users = []
            reloadUsers()
            return
        }
        users = listType == .followers
            ? DataRepository.shared.getFollowers(userId: userId)
            : DataRepository.shared.getFollowing(userId: userId)
        
        reloadUsers()
    }
    
    private func reloadUsers() {
        for subview in usersStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        if users.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = listType == .followers ? "No followers yet" : "Not following anyone"
            emptyLabel.font = AppFont.body()
            emptyLabel.textColor = AppTheme.textTertiary
            emptyLabel.textAlignment = .center
            emptyLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
            usersStackView.addArrangedSubview(emptyLabel)
            return
        }
        
        for user in users {
            let cell = createUserCell(user: user)
            usersStackView.addArrangedSubview(cell)
        }
    }
    
    private func createUserCell(user: User) -> UIView {
        let cell = UIView()
        cell.backgroundColor = .white
        cell.isUserInteractionEnabled = true
        cell.tag = 100
        
        let avatarImageView = UIImageView()
        avatarImageView.backgroundColor = AppTheme.secondaryColor
        avatarImageView.layer.cornerRadius = 28
        avatarImageView.clipsToBounds = true
        if let avatarUser = DataRepository.shared.getUser(byId: user.id) {
            avatarImageView.image = DataRepository.shared.avatarImage(for: avatarUser) ?? UIImage(named: avatarUser.avatar)
        }
        cell.addSubview(avatarImageView)
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = AppFont.h3(.bold)
        nameLabel.textColor = AppTheme.textPrimary
        cell.addSubview(nameLabel)
        
        let followButton = UIButton(type: .system)
        followButton.tag = 200
        cell.addSubview(followButton)
        
        let isFollowing = listType == .following || DataRepository.shared.isFollowing(userId: user.id)
        updateFollowButton(followButton, isFollowing: isFollowing)
        
        followButton.addTarget(self, action: #selector(followTapped(_:)), for: .touchUpInside)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }
        
        followButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(38)
            make.width.equalTo(85)
        }
        
        cell.snp.makeConstraints { make in
            make.height.equalTo(88)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    private func updateFollowButton(_ button: UIButton, isFollowing: Bool) {
        if isFollowing {
            button.setTitle("Following", for: .normal)
            button.setTitleColor(AppTheme.textSecondary, for: .normal)
            button.backgroundColor = AppTheme.backgroundColor
        } else {
            button.setTitle("Follow", for: .normal)
            button.setTitleColor(AppTheme.textPrimary, for: .normal)
            button.backgroundColor = AppTheme.primaryColor
        }
        button.titleLabel?.font = AppFont.subtitle(.semibold)
        button.layer.cornerRadius = 19
        button.layer.borderWidth = isFollowing ? 1 : 0
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(followChanged), name: .followStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlocked), name: .userBlocked, object: nil)
    }
    
    @objc private func followChanged() {
        loadData()
    }
    
    @objc private func userBlocked() {
        loadData()
    }
    
    @objc private func followTapped(_ sender: UIButton) {
        guard let cell = sender.superview,
              let index = usersStackView.arrangedSubviews.firstIndex(of: cell),
              index < users.count else { return }
        
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        let user = users[index]
        _ = DataRepository.shared.toggleFollow(userId: user.id)
    }
    
    @objc private func userTapped(_ gesture: UITapGestureRecognizer) {
        guard let cell = gesture.view,
              let index = usersStackView.arrangedSubviews.firstIndex(of: cell),
              index < users.count else { return }
        
        let user = users[index]
        let profileVC = UserProfileViewController(userId: user.id)
        profileVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileVC, animated: true)
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
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
