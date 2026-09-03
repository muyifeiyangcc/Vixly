import UIKit
import SnapKit

class BaseViewController: UIViewController {
    private var usesAuthHeader = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if usesAuthHeader {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if usesAuthHeader, navigationController?.topViewController !== self {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = AppTheme.navBarBackgroundColor
        navigationController?.navigationBar.tintColor = AppTheme.textPrimary
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: AppTheme.textPrimary,
            .font: AppFont.h3(.bold)
        ]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = AppTheme.navBarBackgroundColor
            appearance.titleTextAttributes = [
                .foregroundColor: AppTheme.textPrimary,
                .font: AppFont.h3(.bold)
            ]
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.textPrimary
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    /// The auth designs use a full-width blue header instead of a standard
    /// UINavigationBar. Navigation remains unchanged; only its presentation
    /// is replaced with this in-content header.
    @discardableResult
    func setupAuthHeader(title: String) -> UIView {
        usesAuthHeader = true
        navigationController?.setNavigationBarHidden(true, animated: false)

        let headerView = UIView()
        headerView.backgroundColor = AppTheme.authHeaderColor

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.textPrimary
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.authTitle()
        titleLabel.textColor = AppTheme.textPrimary
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        headerView.addSubview(titleLabel)

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(184)
        }
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(7)
            make.width.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-13)
            make.height.equalTo(64)
        }

        return headerView
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title: String, message: String, buttonTitle: String = "OK") {
        let alert = CommonAlertView(
            title: title,
            message: message,
            cancelTitle: "",
            confirmTitle: buttonTitle
        )
        alert.show()
    }
    
    func showLoading() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        indicator.tag = 999
        indicator.startAnimating()
        view.addSubview(indicator)
    }
    
    func hideLoading() {
        view.viewWithTag(999)?.removeFromSuperview()
    }
    
    // MARK: - O-01 Empty & Error States
    
    private struct EmptyStateTag { static let tag = 1001 }
    private struct ErrorStateTag { static let tag = 1002 }
    
    func showEmpty(message: String = "No content yet") {
        hideEmpty()
        hideError()
        
        let container = UIView()
        container.tag = EmptyStateTag.tag
        container.backgroundColor = .clear
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        let label = UILabel()
        label.text = message
        label.font = AppFont.subtitle()
        label.textColor = AppTheme.textTertiary
        label.textAlignment = .center
        label.numberOfLines = 0
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func hideEmpty() {
        view.viewWithTag(EmptyStateTag.tag)?.removeFromSuperview()
    }
    
    func showError(message: String, retry: (() -> Void)? = nil) {
        hideEmpty()
        hideError()
        
        let container = UIView()
        container.tag = ErrorStateTag.tag
        container.backgroundColor = .clear
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        let label = UILabel()
        label.text = message
        label.font = AppFont.subtitle()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        container.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        if let retry = retry {
            let retryButton = UIButton(type: .system)
            retryButton.setTitle("Retry", for: .normal)
            retryButton.titleLabel?.font = AppFont.body(.bold)
            retryButton.setTitleColor(AppTheme.textPrimary, for: .normal)
            retryButton.backgroundColor = AppTheme.primaryColor
            retryButton.layer.cornerRadius = 20
            retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
            container.addSubview(retryButton)
            
            retryButton.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
                make.width.equalTo(120)
                make.bottom.equalToSuperview()
            }
            
            self.retryHandler = retry
        } else {
            label.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
            }
        }
    }
    
    private var retryHandler: (() -> Void)?
    
    func hideError() {
        retryHandler = nil
        view.viewWithTag(ErrorStateTag.tag)?.removeFromSuperview()
    }
    
    @objc private func retryTapped() {
        retryHandler?()
    }
}
