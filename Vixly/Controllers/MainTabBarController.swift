import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private let isGuest: Bool
    private let customTabBar = VixlyTabBarView()
    
    init(isGuest: Bool = false) {
        self.isGuest = isGuest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupTabBar()
        setupViewControllers()
        setupCustomTabBar()
        let didShowNotification = Notification.Name("UINavigationControllerDidShowViewControllerNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(navigationDidShow(_:)), name: didShowNotification, object: nil)
        updateRootTabVisibility()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let tabBarHeight: CGFloat = 70
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = tabBarHeight
        // The design floats 14pt from each side and sits just above the home indicator.
        tabBarFrame.origin.y = view.frame.height - tabBarHeight - view.safeAreaInsets.bottom + 5
        tabBar.frame = tabBarFrame
        tabBar.bringSubviewToFront(customTabBar)
        updateRootTabVisibility()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        updateRootTabVisibility()
    }

    @objc private func navigationDidShow(_ notification: Notification) {
        guard let navigationController = notification.object as? UINavigationController,
              let tabNavigationControllers = viewControllers?.compactMap({ $0 as? UINavigationController }),
              tabNavigationControllers.contains(navigationController) else { return }
        updateRootTabVisibility()
    }

    private func updateRootTabVisibility() {
        let isSecondaryPage: Bool
        if let navigationController = selectedViewController as? UINavigationController {
            isSecondaryPage = navigationController.viewControllers.count > 1
        } else {
            isSecondaryPage = false
        }
        tabBar.isHidden = isSecondaryPage
        customTabBar.isHidden = isSecondaryPage
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard isGuest || !DataRepository.shared.isLoggedIn else { return true }
        
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }
        
        // Guests can keep browsing the Today shell, but protected tabs must
        // show the sign-in prompt instead of switching away from it.
        // Explore is index 1, Inbox is index 3, and Profile is index 4.
        if selectedIndex == 1 || selectedIndex == 3 || selectedIndex == 4 {
            showSignInRequired()
            return false
        }
        
        return true
    }
    
    private func setupTabBar() {
        // Keep UITabBarController's selection/routing, but replace its visual
        // presentation with the custom floating bar below.
        tabBar.backgroundColor = .clear
        tabBar.tintColor = .clear
        tabBar.unselectedItemTintColor = .clear
        tabBar.isTranslucent = true
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
    }

    private func setupCustomTabBar() {
        tabBar.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: 14),
            customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: -14),
            customTabBar.topAnchor.constraint(equalTo: tabBar.topAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
        customTabBar.onItemTapped = { [weak self] index in
            self?.customTabTapped(index)
        }
        customTabBar.setSelectedIndex(selectedIndex)
    }
    
    private func setupViewControllers() {
        let todayVC = TodayViewController()
        let todayNav = UINavigationController(rootViewController: todayVC)
        todayNav.tabBarItem = UITabBarItem(
            title: "Today",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        
        let exploreVC = ExploreViewController()
        let exploreNav = UINavigationController(rootViewController: exploreVC)
        exploreNav.tabBarItem = UITabBarItem(
            title: "Explore",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 1
        )
        
        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem = UITabBarItem(title: "", image: UIImage(), tag: 2)
        
        let inboxVC = InboxViewController()
        let inboxNav = UINavigationController(rootViewController: inboxVC)
        inboxNav.tabBarItem = UITabBarItem(
            title: "Inbox",
            image: UIImage(systemName: "message.fill"),
            tag: 3
        )
        
        let profileVC = ProfileViewController(isGuest: isGuest)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.fill"),
            tag: 4
        )
        
        viewControllers = [todayNav, exploreNav, placeholderVC, inboxNav, profileNav]
        selectedIndex = 0
    }
    
    private func customTabTapped(_ index: Int) {
        guard index != 2 else {
            centerButtonTapped()
            return
        }
        guard let viewController = viewControllers?[index],
              tabBarController(self, shouldSelect: viewController) else {
            customTabBar.setSelectedIndex(selectedIndex)
            return
        }
        selectedIndex = index
        customTabBar.setSelectedIndex(index)
    }

    private func centerButtonTapped() {
        if isGuest {
            showSignInRequired()
            return
        }
        
        let postVC = AddMediaViewController()
        let nav = UINavigationController(rootViewController: postVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
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

private final class VixlyTabBarView: UIView {
    var onItemTapped: ((Int) -> Void)?

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.10
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowRadius = 14
        return view
    }()

    private let itemsStack = UIStackView()
    private var items: [VixlyTabBarItemView] = []
    private(set) var selectedIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        itemsStack.axis = .horizontal
        itemsStack.alignment = .fill
        itemsStack.distribution = .fillEqually
        itemsStack.spacing = 0
        addSubview(itemsStack)
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemsStack.topAnchor.constraint(equalTo: topAnchor),
            itemsStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let titles = ["Today", "Explore", "Post", "Inbox", "Profile"]
        for index in 0..<titles.count {
            let item = VixlyTabBarItemView(index: index, title: titles[index])
            item.addTarget(self, action: #selector(itemTapped(_:)), for: .touchUpInside)
            itemsStack.addArrangedSubview(item)
            items.append(item)
        }
        setSelectedIndex(0)
    }

    @objc private func itemTapped(_ sender: VixlyTabBarItemView) {
        onItemTapped?(sender.index)
    }

    func setSelectedIndex(_ index: Int) {
        guard items.indices.contains(index) else { return }
        selectedIndex = index
        for item in items {
            item.isSelected = item.index == index
        }
    }
}

private final class VixlyTabBarItemView: UIControl {
    let index: Int

    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    init(index: Int, title: String) {
        self.index = index
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    private func setup() {
        backgroundColor = .clear
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        titleLabel.font = .systemFont(ofSize: 9, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false

        addSubview(iconView)
        addSubview(titleLabel)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            iconView.widthAnchor.constraint(equalToConstant: 37),
            iconView.heightAnchor.constraint(equalToConstant: 33),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 0),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -2),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
        ])
        updateAppearance()
    }

    private func updateAppearance() {
        let baseName = "tab\(index + 1)"
        let imageName = isSelected && index != 2 ? "\(baseName)_sel" : baseName
        iconView.image = UIImage(named: imageName) ?? UIImage(named: baseName)
        titleLabel.textColor = isSelected ? AppTheme.textPrimary : AppTheme.textSecondary
    }
}
