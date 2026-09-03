import UIKit
import SnapKit

class BlockedUsersViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let usersStackView = UIStackView()
    
    private var blockedUsers: [BlockedUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = setupAuthHeader(title: "BLOCKED USERS")
        setupUI()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        loadData()
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
        blockedUsers = DataRepository.shared.getBlockedUsers()
        reloadUsers()
    }
    
    private func reloadUsers() {
        for subview in usersStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        if blockedUsers.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No blocked users"
            emptyLabel.font = AppFont.body()
            emptyLabel.textColor = AppTheme.textTertiary
            emptyLabel.textAlignment = .center
            emptyLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
            usersStackView.addArrangedSubview(emptyLabel)
            return
        }
        
        for blockedUser in blockedUsers {
            let cell = createBlockedUserCell(blockedUser: blockedUser)
            usersStackView.addArrangedSubview(cell)
        }
    }
    
    private func createBlockedUserCell(blockedUser: BlockedUser) -> UIView {
        let cell = UIView()
        cell.backgroundColor = .white
        
        let avatarImageView = UIImageView()
        avatarImageView.backgroundColor = AppTheme.secondaryColor
        avatarImageView.layer.cornerRadius = 28
        avatarImageView.clipsToBounds = true
        if let user = DataRepository.shared.getUser(byId: blockedUser.userId) {
            avatarImageView.image = DataRepository.shared.avatarImage(for: user) ?? UIImage(named: user.avatar)
        }
        cell.addSubview(avatarImageView)
        
        let nameLabel = UILabel()
        nameLabel.font = AppFont.h3(.bold)
        nameLabel.textColor = AppTheme.textPrimary
        if let user = DataRepository.shared.getUser(byId: blockedUser.userId) {
            nameLabel.text = user.name
        }
        cell.addSubview(nameLabel)
        
        let unblockButton = UIButton(type: .system)
        unblockButton.setTitle("Unblock", for: .normal)
        unblockButton.titleLabel?.font = AppFont.subtitle(.semibold)
        unblockButton.setTitleColor(AppTheme.textPrimary, for: .normal)
        unblockButton.backgroundColor = .white
        unblockButton.layer.cornerRadius = 19
        unblockButton.layer.borderWidth = 1
        unblockButton.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        unblockButton.tag = 100
        unblockButton.addTarget(self, action: #selector(unblockTapped(_:)), for: .touchUpInside)
        cell.addSubview(unblockButton)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(14)
            make.centerY.equalToSuperview()
        }
        
        unblockButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(85)
            make.height.equalTo(38)
        }
        
        cell.snp.makeConstraints { make in
            make.height.equalTo(88)
        }
        
        return cell
    }
    
    @objc private func unblockTapped(_ sender: UIButton) {
        guard let cell = sender.superview,
              let index = usersStackView.arrangedSubviews.firstIndex(of: cell),
              index < blockedUsers.count else { return }
        
        let blockedUser = blockedUsers[index]
        
        let alert = CommonAlertView(
            title: "Unblock User",
            message: "Are you sure you want to unblock this user?",
            cancelTitle: "Cancel",
            confirmTitle: "Unblock"
        )
        alert.onConfirm = { [weak self] in
            DataRepository.shared.unblockUser(userId: blockedUser.userId)
            self?.loadData()
        }
        alert.show()
    }
}
