import UIKit
import SnapKit

class SettingsViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let settingsStackView = UIStackView()
    private let accountStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = setupAuthHeader(title: "SETTINGS")
        setupUI()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let settingsTitleLabel = UILabel()
        settingsTitleLabel.text = "SETTINGS"
        settingsTitleLabel.font = AppFont.caption(.bold)
        settingsTitleLabel.textColor = UIColor(hex: "#23677A")
        
        let accountTitleLabel = UILabel()
        accountTitleLabel.text = "ACCOUNT"
        accountTitleLabel.font = AppFont.caption(.bold)
        accountTitleLabel.textColor = AppTheme.textPrimary
        
        contentView.addSubview(settingsTitleLabel)
        contentView.addSubview(settingsStackView)
        contentView.addSubview(accountTitleLabel)
        contentView.addSubview(accountStackView)
        
        settingsStackView.axis = .vertical
        settingsStackView.spacing = 1
        settingsStackView.backgroundColor = AppTheme.backgroundColor
        settingsStackView.layer.cornerRadius = 12
        settingsStackView.layer.borderWidth = 1
        settingsStackView.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        settingsStackView.clipsToBounds = true
        
        accountStackView.axis = .vertical
        accountStackView.spacing = 1
        accountStackView.backgroundColor = AppTheme.backgroundColor
        accountStackView.layer.cornerRadius = 12
        accountStackView.layer.borderWidth = 1
        accountStackView.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        accountStackView.clipsToBounds = true
        
        let settingsItems = [
            ("BlockList", "normal", #selector(blockListTapped)),
            ("Privacy Policy", "normal", #selector(privacyPolicyTapped)),
            ("Terms of Service", "normal", #selector(termsOfServiceTapped))
        ]
        
        for (title, style, action) in settingsItems {
            let cell = createSettingsCell(title: title, style: style, action: action)
            settingsStackView.addArrangedSubview(cell)
        }
        
        let accountItems = [
            ("Log Out", "normal", #selector(logoutTapped)),
            ("Delete Account", "destructive", #selector(deleteAccountTapped))
        ]
        
        for (title, style, action) in accountItems {
            let cell = createSettingsCell(title: title, style: style, action: action)
            accountStackView.addArrangedSubview(cell)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        settingsTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(19)
        }
        
        settingsStackView.snp.makeConstraints { make in
            make.top.equalTo(settingsTitleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(15)
        }
        
        accountTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(settingsStackView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(24)
        }
        
        accountStackView.snp.makeConstraints { make in
            make.top.equalTo(accountTitleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func createSettingsCell(title: String, style: String, action: Selector) -> UIView {
        let cell = UIView()
        cell.backgroundColor = .white
        cell.isUserInteractionEnabled = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.subtitle(.semibold)
        titleLabel.textColor = style == "destructive" ? AppTheme.textDanger : AppTheme.textPrimary
        cell.addSubview(titleLabel)

        let iconView = UIImageView(image: UIImage(systemName: iconName(for: title)))
        iconView.tintColor = style == "destructive" ? AppTheme.textDanger : UIColor(hex: "#23677A")
        iconView.backgroundColor = style == "destructive" ? UIColor(hex: "#FBE7E8") : AppTheme.secondaryColor
        iconView.contentMode = .center
        iconView.layer.cornerRadius = 11
        iconView.clipsToBounds = true
        cell.addSubview(iconView)
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = AppTheme.textTertiary
        cell.addSubview(arrowImageView)
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        cell.snp.makeConstraints { make in
            make.height.equalTo(65)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }

    private func iconName(for title: String) -> String {
        switch title {
        case "BlockList": return "person.2"
        case "Privacy Policy": return "shield"
        case "Terms of Service": return "doc.text"
        case "Log Out": return "rectangle.portrait.and.arrow.right"
        default: return "trash"
        }
    }
    
    @objc private func blockListTapped() {
        let blockedVC = BlockedUsersViewController()
        blockedVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(blockedVC, animated: true)
    }
    
    @objc private func privacyPolicyTapped() {
        let webVC = WebViewController(url: "https://sites.google.com/view/vixly/privacy", pageTitle: "Privacy Policy")
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @objc private func termsOfServiceTapped() {
        let webVC = WebViewController(url: "https://sites.google.com/view/vixly/users", pageTitle: "Terms of Service")
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = CommonAlertView(
            title: "Sign Out",
            message: "Are you sure you want to sign out of your account?",
            cancelTitle: "Cancel",
            confirmTitle: "Sure"
        )
        alert.onConfirm = { [weak self] in
            DataRepository.shared.logout()
            AppRouter.shared.showOnboarding()
        }
        alert.show()
    }
    
    @objc private func deleteAccountTapped() {
        let alert = CommonAlertView(
            title: "Delete Account",
            message: "Are you sure you want to delete this account? All data will be cleared after deletion and cannot be recovered.",
            cancelTitle: "Cancel",
            confirmTitle: "Delete"
        )
        alert.onConfirm = { [weak self] in
            DataRepository.shared.deleteAccount()
            AppRouter.shared.showOnboarding()
        }
        alert.show()
    }
}
