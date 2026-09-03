import UIKit
import SnapKit
import StoreKit

class BuyCoinsViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let balanceCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        return view
    }()

    private let balanceBackgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "coin_bg"))
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "COIN BALANCE"
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let balanceAmountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.h2(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let selectPackageLabel: UILabel = {
        let label = UILabel()
        label.text = "SELECT A PACKAGE"
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let packagesStackView = UIStackView()

    private let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let rechargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Recharge", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.setTitleColor(AppTheme.textTertiary, for: .disabled)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        button.isEnabled = false
        return button
    }()
    
    private var products: [SKProduct] = []
    private var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = setupAuthHeader(title: "BUY COINS")
        setupUI()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomBar.snp.top)
        }
        loadProducts()
        updateBalance()
        rechargeButton.addTarget(self, action: #selector(rechargeTapped), for: .touchUpInside)
        addObservers()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(balanceCardView)
        balanceCardView.addSubview(balanceBackgroundImageView)
        balanceCardView.addSubview(balanceTitleLabel)
        balanceCardView.addSubview(balanceAmountLabel)
        
        contentView.addSubview(selectPackageLabel)
        contentView.addSubview(packagesStackView)
        view.addSubview(bottomBar)
        bottomBar.addSubview(rechargeButton)
        
        packagesStackView.axis = .vertical
        packagesStackView.spacing = 8
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        balanceCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(22)
            make.left.right.equalToSuperview().inset(11)
            make.height.equalTo(105)
        }

        balanceBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        balanceTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.left.equalToSuperview().offset(153)
        }
        
        balanceAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceTitleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(177)
        }
        
        selectPackageLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceCardView.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(16)
        }
        
        packagesStackView.snp.makeConstraints { make in
            make.top.equalTo(selectPackageLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(82)
        }

        rechargeButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(48)
        }
    }
    
    private func loadProducts() {
        showLoading()
        IAPManager.shared.loadProducts { [weak self] products in
            guard let self = self else { return }
            self.hideLoading()
            self.products = products
            self.reloadPackages()
        }
    }
    
    private func reloadPackages() {
        selectedIndex = nil
        rechargeButton.isEnabled = false

        for subview in packagesStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for (index, product) in products.enumerated() {
            let coins = IAPManager.shared.getCoinAmount(for: product)
            let price = IAPManager.shared.formatPrice(product)
            
            let packageView = createPackageView(coins: coins, price: price, index: index)
            packagesStackView.addArrangedSubview(packageView)
        }
    }
    
    private func createPackageView(coins: Int, price: String, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 13
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        view.tag = index
        view.isUserInteractionEnabled = true
        
        let coinContainerView = UIView()
        coinContainerView.backgroundColor = AppTheme.secondaryColor
        coinContainerView.layer.cornerRadius = 20
        coinContainerView.tag = 998
        view.addSubview(coinContainerView)

        let coinImageView = UIImageView(image: UIImage(named: "coin"))
        coinImageView.contentMode = .scaleAspectFit
        coinContainerView.addSubview(coinImageView)
        
        let coinsLabel = UILabel()
        coinsLabel.text = "\(formattedCoins(coins)) Coins"
        coinsLabel.font = AppFont.subtitle(.semibold)
        coinsLabel.textColor = AppTheme.textPrimary
        view.addSubview(coinsLabel)
        
        let priceLabel = UILabel()
        priceLabel.text = price
        priceLabel.font = AppFont.subtitle(.bold)
        priceLabel.textColor = AppTheme.textPrimary
        priceLabel.textAlignment = .right
        view.addSubview(priceLabel)
        
        coinContainerView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        coinImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        coinsLabel.snp.makeConstraints { make in
            make.left.equalTo(coinContainerView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        view.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(packageTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    @objc private func packageTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        selectedIndex = view.tag
        updatePackagesUI()
        
        rechargeButton.isEnabled = true
    }

    private func formattedCoins(_ coins: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: coins)) ?? "\(coins)"
    }
    
    private func updatePackagesUI() {
        for (index, subview) in packagesStackView.arrangedSubviews.enumerated() {
            guard let packageView = subview as? UIView else { continue }
            
            if index == selectedIndex {
                packageView.layer.borderWidth = 1
                packageView.layer.borderColor = AppTheme.textPrimary.cgColor
                packageView.backgroundColor = .white
                packageView.viewWithTag(998)?.backgroundColor = AppTheme.primaryColor
            } else {
                packageView.layer.borderWidth = 1
                packageView.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
                packageView.backgroundColor = .white
                packageView.viewWithTag(998)?.backgroundColor = AppTheme.secondaryColor
            }
        }
    }
    
    private func updateBalance() {
        let value = DataRepository.shared.currentUser?.coins ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let amount = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        let text = NSMutableAttributedString(
            string: amount,
            attributes: [.font: AppFont.h2(.bold), .foregroundColor: AppTheme.textPrimary]
        )
        text.append(NSAttributedString(
            string: " Coins",
            attributes: [.font: AppFont.h3(.bold), .foregroundColor: AppTheme.textAccent]
        ))
        balanceAmountLabel.attributedText = text
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(coinsUpdated), name: .coinsUpdated, object: nil)
    }
    
    @objc private func coinsUpdated() {
        updateBalance()
    }
    
    @objc private func rechargeTapped() {
        guard let selectedIndex = selectedIndex else { return }
        
        showLoading()
        IAPManager.shared.purchaseProduct(at: selectedIndex) { [weak self] result in
            guard let self = self else { return }
            self.hideLoading()
            
            switch result {
            case .success:
                self.showAlert(title: "Success", message: "Coins have been added to your account.")
            case .failure(let error):
                self.showAlert(title: "Purchase Failed", message: error.localizedDescription)
            }
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
