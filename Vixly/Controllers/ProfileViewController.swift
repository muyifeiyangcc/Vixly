import UIKit
import SnapKit

class ProfileViewController: UIViewController {
    
    private let isGuest: Bool
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let pageHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let pageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PROFILE"
        label.font = UIFont(name: "Impact", size: 40) ?? .systemFont(ofSize: 40, weight: .black)
        label.textColor = AppTheme.textPrimary
        return label
    }()

    private let pageHeaderSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.authFieldBorderColor
        return view
    }()
    
    private let headerView = UIView()
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 44
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.h3(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle()
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private let statsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.backgroundColor = .white
        stack.layer.cornerRadius = 14
        stack.layer.borderWidth = 1
        stack.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        stack.clipsToBounds = true
        return stack
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.textPrimary.cgColor
        return button
    }()

    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Message", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textSecondary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return button
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "me_set"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        button.backgroundColor = .clear
        return button
    }()
    
    private let coinCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        return view
    }()

    private let coinBackgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "me_coin_bg"))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let coinTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "COIN BALANCE"
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let coinAmountLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.h2(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Calendar", "Posts", "Saved"]
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = .clear
        seg.backgroundColor = .white
        let clearDivider = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
        seg.setDividerImage(clearDivider, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        seg.setDividerImage(clearDivider, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        seg.setDividerImage(clearDivider, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        seg.setTitleTextAttributes([.foregroundColor: AppTheme.textPrimary, .font: AppFont.caption(.bold)], for: .selected)
        seg.setTitleTextAttributes([.foregroundColor: AppTheme.textSecondary, .font: AppFont.caption(.bold)], for: .normal)
        return seg
    }()

    private let tabsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let tabUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.textPrimary
        view.layer.cornerRadius = 1.5
        return view
    }()
    
    // S-06: Calendar 容器视图
    private let calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.backgroundColor
        view.isHidden = true
        return view
    }()
    
    private lazy var calendarMonthLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.bold)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var calendarPrevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        button.addTarget(self, action: #selector(prevMonthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var calendarNextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        button.addTarget(self, action: #selector(nextMonthTapped), for: .touchUpInside)
        return button
    }()

    private lazy var calendarWeekdayStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        let symbols = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        symbols.forEach {
            let label = UILabel()
            label.text = $0
            label.font = .systemFont(ofSize: 8, weight: .bold)
            label.textColor = AppTheme.textSecondary
            label.textAlignment = .center
            stack.addArrangedSubview(label)
        }
        return stack
    }()
    
    private var calendarDateComponents: DateComponents = {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: Date())
        return comps
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.reuseIdentifier)
        return cv
    }()

    private lazy var calendarGridCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 6
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        return cv
    }()
    
    private var posts: [Post] = []
    private var calendarDays: [Date] = []
    private var calendarContainerHeight: CGFloat = 340
    
    init(isGuest: Bool = false) {
        self.isGuest = isGuest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        contentView.backgroundColor = AppTheme.backgroundColor
        setupUI()
        loadData()
        addObservers()
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        editProfileButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        coinCardView.isUserInteractionEnabled = true
        coinCardView.accessibilityTraits = .button
        coinCardView.accessibilityLabel = "Coin balance"
        coinCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rechargeTapped)))
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCalendarContainerHeightIfNeeded()
        updateScrollViewBottomInset()
    }

    private func updateScrollViewBottomInset() {
        let tabBarHeight = tabBarController?.tabBar.isHidden == false
            ? tabBarController?.tabBar.bounds.height ?? 70
            : 0
        let bottomInset = tabBarHeight > 0 ? tabBarHeight + 16 : 16
        guard scrollView.contentInset.bottom != bottomInset else { return }

        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(pageHeaderView)
        pageHeaderView.addSubview(pageTitleLabel)
        pageHeaderView.addSubview(settingsButton)
        pageHeaderView.addSubview(pageHeaderSeparator)
        contentView.addSubview(headerView)
        headerView.addSubview(avatarImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(bioLabel)
        headerView.addSubview(statsStack)
        headerView.addSubview(editProfileButton)
        
        contentView.addSubview(tabsBackgroundView)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(tabUnderline)
        contentView.addSubview(coinCardView)
        coinCardView.addSubview(coinBackgroundImageView)
        coinCardView.addSubview(coinTitleLabel)
        coinCardView.addSubview(coinAmountLabel)
        contentView.addSubview(calendarContainerView)
        contentView.addSubview(collectionView)
        calendarContainerView.addSubview(calendarGridCollectionView)
        calendarContainerView.addSubview(calendarWeekdayStack)
        
        // S-06: Calendar 容器内部结构
        calendarContainerView.addSubview(calendarPrevButton)
        calendarContainerView.addSubview(calendarMonthLabel)
        calendarContainerView.addSubview(calendarNextButton)
        
        setupStatsStack()
        setupCalendarUI()
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        pageHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(74)
        }
        pageTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-10)
        }
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(pageTitleLabel)
            make.width.height.equalTo(28)
        }
        pageHeaderSeparator.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0)
        }

        headerView.backgroundColor = .white
        headerView.snp.makeConstraints { make in
            make.top.equalTo(pageHeaderView.snp.bottom)
            make.left.right.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(26)
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(88)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top).offset(8)
            make.left.equalTo(avatarImageView.snp.right).offset(16)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-15)
        }
        
        statsStack.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
        }
        
        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(11)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(45)
            make.bottom.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(coinCardView.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        tabsBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(segmentedControl)
        }
        tabUnderline.snp.makeConstraints { make in
            make.bottom.equalTo(segmentedControl.snp.bottom)
            make.left.equalTo(segmentedControl.snp.left)
            make.width.equalTo(segmentedControl.snp.width).multipliedBy(1.0 / 3.0)
            make.height.equalTo(3)
        }
        
        coinCardView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(11)
            make.height.equalTo(105)
        }
        coinBackgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        coinTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(158)
        }
        coinAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(coinTitleLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(158)
        }
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(340)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(600)
        }
    }
    
    // MARK: - S-06 Calendar UI
    private func setupCalendarUI() {
        calendarMonthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        
        calendarPrevButton.snp.makeConstraints { make in
            make.centerY.equalTo(calendarMonthLabel)
            make.right.equalTo(calendarMonthLabel.snp.left).offset(-24)
            make.width.height.equalTo(32)
        }
        
        calendarNextButton.snp.makeConstraints { make in
            make.centerY.equalTo(calendarMonthLabel)
            make.left.equalTo(calendarMonthLabel.snp.right).offset(24)
            make.width.height.equalTo(32)
        }
        
        calendarGridCollectionView.snp.makeConstraints { make in
            make.top.equalTo(calendarWeekdayStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
        }
        calendarWeekdayStack.snp.makeConstraints { make in
            make.top.equalTo(calendarMonthLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(12)
        }
        
        refreshCalendarMonthLabel()
    }
    
    private func refreshCalendarMonthLabel() {
        let cal = Calendar.current
        if let date = cal.date(from: calendarDateComponents) {
            let fmt = DateFormatter()
            fmt.dateFormat = "MMMM yyyy"
            calendarMonthLabel.text = fmt.string(from: date)
            calendarDays = cal.range(of: .day, in: .month, for: date).map { range in
                range.compactMap { day in
                    var components = calendarDateComponents
                    components.day = day
                    return cal.date(from: components)
                }
            } ?? []
            calendarGridCollectionView.reloadData()
            view.setNeedsLayout()
        }
    }

    private func updateCalendarContainerHeightIfNeeded() {
        let availableWidth = calendarGridCollectionView.bounds.width
        guard availableWidth > 24, !calendarDays.isEmpty else { return }

        let itemWidth = floor((availableWidth - 24) / 7)
        let rowCount = CGFloat(Int(ceil(Double(calendarDays.count) / 7.0)))
        let rowSpacing = max(0, rowCount - 1) * 6
        let requiredHeight = ceil(calendarGridCollectionView.frame.minY + rowCount * itemWidth + rowSpacing)
        let targetHeight = max(340, requiredHeight)
        guard abs(targetHeight - calendarContainerHeight) > 0.5 else { return }

        calendarContainerHeight = targetHeight
        calendarContainerView.snp.updateConstraints { make in
            make.height.equalTo(targetHeight)
        }
    }
    
    @objc private func prevMonthTapped() {
        calendarDateComponents.month = (calendarDateComponents.month ?? 1) - 1
        if calendarDateComponents.month! < 1 {
            calendarDateComponents.month = 12
            calendarDateComponents.year = (calendarDateComponents.year ?? 2024) - 1
        }
        refreshCalendarMonthLabel()
    }
    
    @objc private func nextMonthTapped() {
        calendarDateComponents.month = (calendarDateComponents.month ?? 1) + 1
        if calendarDateComponents.month! > 12 {
            calendarDateComponents.month = 1
            calendarDateComponents.year = (calendarDateComponents.year ?? 2024) + 1
        }
        refreshCalendarMonthLabel()
    }
    
    private func setupStatsStack() {
        let stats = [
            ("0", "Posts"),
            ("0", "Followers"),
            ("0", "Following")
        ]
        
        for (index, (count, title)) in stats.enumerated() {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .center
            stack.spacing = 0
            stack.isUserInteractionEnabled = true
            
            let countLabel = UILabel()
            countLabel.font = .systemFont(ofSize: 13, weight: .bold)
            countLabel.textColor = AppTheme.textPrimary
            countLabel.text = count
            countLabel.tag = index // O-10: 用于点击识别
            
            let titleLabel = UILabel()
            titleLabel.font = .systemFont(ofSize: 10, weight: .regular)
            titleLabel.textColor = AppTheme.textTertiary
            titleLabel.text = title
            
            stack.addArrangedSubview(countLabel)
            stack.addArrangedSubview(titleLabel)
            countLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
            }
            titleLabel.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-16)
            }
            
            // O-10: 点击手势
            let tap = UITapGestureRecognizer(target: self, action: #selector(statTapped(_:)))
            stack.addGestureRecognizer(tap)
            
            statsStack.addArrangedSubview(stack)
        }

        for index in 0..<2 {
            let separator = UIView()
            separator.backgroundColor = AppTheme.authFieldBorderColor
            statsStack.addSubview(separator)
            separator.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalTo(statsStack.arrangedSubviews[index].snp.right)
                make.width.equalTo(1)
            }
        }
    }
    
    // O-10: Stats 点击跳转
    @objc private func statTapped(_ gesture: UITapGestureRecognizer) {
        guard let stack = gesture.view as? UIStackView,
              let countLabel = stack.arrangedSubviews.first as? UILabel else { return }
        
        switch countLabel.tag {
        case 0: // Posts -> 切换到 Posts 分段
            segmentedControl.selectedSegmentIndex = 1
            loadData()
        case 1: // Followers
            pushUserList(type: .followers)
        case 2: // Following
            pushUserList(type: .following)
        default:
            break
        }
    }
    
    private func pushUserList(type: UserListViewController.ListType) {
        let userId = DataRepository.shared.currentUser?.id ?? ""
        let listVC = UserListViewController(listType: type, userId: userId)
        listVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    private func updateStats(posts: Int, followers: Int, following: Int) {
        for (index, subview) in statsStack.arrangedSubviews.enumerated() {
            guard let stack = subview as? UIStackView,
                  let countLabel = stack.arrangedSubviews.first as? UILabel else { continue }
            
            switch index {
            case 0: countLabel.text = "\(posts)"
            case 1: countLabel.text = "\(followers)"
            case 2: countLabel.text = "\(following)"
            default: break
            }
        }
    }
    
    private func loadData() {
        if isGuest {
            nameLabel.text = "Guest"
            bioLabel.text = "Sign in to access all features"
            avatarImageView.image = DataRepository.shared.defaultAvatarImage()
            updateCoinBalance(0)
            posts = []
            updateStats(posts: 0, followers: 0, following: 0)
        } else if let user = DataRepository.shared.currentUser {
            nameLabel.text = user.name
            bioLabel.text = user.bio
            avatarImageView.image = DataRepository.shared.avatarImage(for: user) ?? UIImage(named: user.avatar)
            updateCoinBalance(user.coins)
            updateStats(posts: user.postsCount, followers: user.followersCount, following: user.followingCount)
            switch segmentedControl.selectedSegmentIndex {
            case 1:
                posts = DataRepository.shared.getUserPosts(userId: user.id).filter { $0.isPublic }.sorted { $0.createdAt > $1.createdAt }
            case 2:
                posts = DataRepository.shared.getSavedPosts()
            default:
                posts = []
            }
        }
        
        let selectedIndex = segmentedControl.selectedSegmentIndex
        let isCalendar = selectedIndex == 0
        calendarContainerView.isHidden = !isCalendar
        collectionView.isHidden = isCalendar
        let tabWidth = segmentedControl.bounds.width / 3
        tabUnderline.snp.updateConstraints { make in
            make.left.equalTo(segmentedControl.snp.left).offset(tabWidth * CGFloat(selectedIndex))
        }
        if isCalendar {
            refreshCalendarMonthLabel()
        }
        
        if !isCalendar {
            collectionView.reloadData()
            let width = max(0, (view.bounds.width - 38) / 2)
            let height = CGFloat(ceil(Double(posts.count) / 2.0)) * (width * PostCollectionViewCell.gridHeightRatio + 8) + 20
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(max(height, 300))
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated), name: .userProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .postUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreated), name: .postCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(coinsUpdated), name: .coinsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(followChanged), name: .followStatusChanged, object: nil)
    }

    private func updateCoinBalance(_ value: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let amount = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        let text = NSMutableAttributedString(string: amount, attributes: [
            .font: AppFont.h2(.bold),
            .foregroundColor: AppTheme.textPrimary
        ])
        text.append(NSAttributedString(string: " Coins", attributes: [
            .font: AppFont.h3(.bold),
            .foregroundColor: AppTheme.textAccent
        ]))
        coinAmountLabel.attributedText = text
    }
    
    @objc private func profileUpdated() {
        loadData()
    }
    
    @objc private func postUpdated() {
        loadData()
    }
    
    @objc private func postCreated() {
        loadData()
    }
    
    @objc private func coinsUpdated() {
        loadData()
    }
    
    @objc private func followChanged() {
        loadData()
    }
    
    @objc private func segmentChanged() {
        loadData()
    }

    @objc private func followTapped() {
        guard !isGuest, let userId = DataRepository.shared.currentUser?.id else {
            showSignInRequired()
            return
        }
        _ = DataRepository.shared.toggleFollow(userId: userId)
    }

    @objc private func messageTapped() {
        guard !isGuest, let userId = DataRepository.shared.currentUser?.id else {
            showSignInRequired()
            return
        }
        let chatVC = ChatViewController(userId: userId)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func editProfileTapped() {
        if isGuest {
            showSignInRequired()
            return
        }
        
        let editVC = EditProfileViewController()
        editVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @objc private func settingsTapped() {
        if isGuest {
            showSignInRequired()
            return
        }
        
        let settingsVC = SettingsViewController()
        settingsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func rechargeTapped() {
        if isGuest {
            showSignInRequired()
            return
        }
        
        let rechargeVC = BuyCoinsViewController()
        rechargeVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(rechargeVC, animated: true)
    }
    
    private func showSignInRequired() {
        let alert = CommonAlertView(
            title: "Sign In Required",
            message: "Please sign in to access your profile.",
            cancelTitle: "Cancel",
            confirmTitle: "Sign In"
        )
        alert.onConfirm = { [weak self] in
            AppRouter.shared.showSignIn(from: self ?? UIViewController())
        }
        alert.show()
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView === calendarGridCollectionView ? calendarDays.count : posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === calendarGridCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as! CalendarDayCell
            let date = calendarDays[indexPath.item]
            let post = postsForCalendar().first { Calendar.current.isDate($0.date, inSameDayAs: date) }
            cell.configure(date: date, post: post)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        let post = posts[indexPath.item]
        cell.configure(with: post)
        
        cell.onLikeTapped = {
            _ = DataRepository.shared.toggleLike(postId: post.id)
        }
        
        cell.onSaveTapped = {
            _ = DataRepository.shared.toggleSave(postId: post.id)
        }
        
        cell.onAuthorTapped = {
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === calendarGridCollectionView {
            let width = floor((collectionView.bounds.width - 24) / 7)
            return CGSize(width: width, height: width)
        }
        let width = (collectionView.bounds.width - 8) / 2
        return CGSize(width: width, height: width * PostCollectionViewCell.gridHeightRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === calendarGridCollectionView {
            let date = calendarDays[indexPath.item]
            guard let post = postsForCalendar().first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else { return }
            let detailVC = PostDetailViewController(postId: post.id)
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(detailVC, animated: true)
            return
        }
        let post = posts[indexPath.item]
        let detailVC = PostDetailViewController(postId: post.id)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }

    private func postsForCalendar() -> [Post] {
        guard let userId = DataRepository.shared.currentUser?.id else { return [] }
        return DataRepository.shared.getUserPosts(userId: userId).filter { $0.isPublic }.sorted { $0.createdAt > $1.createdAt }
    }
}

final class CalendarDayCell: UICollectionViewCell {
    static let reuseIdentifier = "CalendarDayCell"

    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 8, weight: .bold)
        label.textColor = AppTheme.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    private let shadeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 9
        contentView.clipsToBounds = true
        contentView.backgroundColor = AppTheme.backgroundColor
        contentView.addSubview(imageView)
        contentView.addSubview(shadeView)
        contentView.addSubview(weekdayLabel)
        contentView.addSubview(dayLabel)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        shadeView.snp.makeConstraints { $0.edges.equalToSuperview() }
        dayLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        weekdayLabel.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(date: Date, post: Post?) {
        let calendar = Calendar.current
        dayLabel.text = "\(calendar.component(.day, from: date))"

        if let post, let image = post.media.first.flatMap({ PostMediaPreview.image(for: $0) }) {
            imageView.image = image
            imageView.isHidden = false
            shadeView.isHidden = false
            dayLabel.textColor = .white
        } else {
            imageView.image = nil
            imageView.isHidden = true
            shadeView.isHidden = true
            dayLabel.textColor = AppTheme.textPrimary
        }
    }
}
