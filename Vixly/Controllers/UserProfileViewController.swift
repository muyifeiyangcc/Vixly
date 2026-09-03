import UIKit
import SnapKit

class UserProfileViewController: BaseViewController {
    
    private let userId: String
    private var user: User?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let tabUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.textPrimary
        view.layer.cornerRadius = 1.5
        return view
    }()
    
    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        return button
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 44
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Impact", size: 32) ?? AppFont.h4(.black)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
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
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.layer.cornerRadius = 22
        return button
    }()
    
    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Message", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return button
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Calendar", "Posts"]
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
    
    init(userId: String) {
        self.userId = userId
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
        setupUI()
        loadData()
        addObservers()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        messageButton.addTarget(self, action: #selector(messageTapped), for: .touchUpInside)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        configureNavigationBar()
    }

    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: AppTheme.textPrimary,
            .font: AppFont.subtitle(.bold)
        ]
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowColor = AppTheme.authFieldBorderColor
            appearance.titleTextAttributes = [
                .foregroundColor: AppTheme.textPrimary,
                .font: AppFont.subtitle(.bold)
            ]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let segmentWidth = segmentedControl.bounds.width / 2
        tabUnderline.snp.updateConstraints { make in
            make.left.equalTo(segmentedControl.snp.left).offset(19 + segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex))
        }
        updateCalendarContainerHeightIfNeeded()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(statsStack)
        
        let buttonStack = UIStackView(arrangedSubviews: [followButton, messageButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        contentView.addSubview(buttonStack)
        
        contentView.addSubview(segmentedControl)
        contentView.addSubview(tabUnderline)
        contentView.addSubview(calendarContainerView)
        contentView.addSubview(collectionView)
        
        // S-06: Calendar 容器内部结构
        calendarContainerView.addSubview(calendarPrevButton)
        calendarContainerView.addSubview(calendarMonthLabel)
        calendarContainerView.addSubview(calendarNextButton)
        calendarContainerView.addSubview(calendarGridCollectionView)
        
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
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(55)
        }
        
        statsStack.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
        }
        
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
        }
        tabUnderline.snp.makeConstraints { make in
            make.bottom.equalTo(segmentedControl.snp.bottom)
            make.left.equalTo(segmentedControl.snp.left).offset(19)
            make.width.equalTo(segmentedControl.snp.width).multipliedBy(0.397)
            make.height.equalTo(3)
        }
        
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(340)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(600)
        }
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
            // Stats on another user's profile are informational only.
            stack.isUserInteractionEnabled = false
            
            let countLabel = UILabel()
            countLabel.font = .systemFont(ofSize: 13, weight: .bold)
            countLabel.textColor = AppTheme.textPrimary
            countLabel.text = count
            
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
        guard let user = DataRepository.shared.getUser(byId: userId) else { return }
        self.user = user
        
        title = "@\(user.name)"
        nameLabel.text = user.name
        bioLabel.text = user.bio
        avatarImageView.image = DataRepository.shared.avatarImage(for: user) ?? UIImage(named: user.avatar)
        updateStats(posts: user.postsCount, followers: user.followersCount, following: user.followingCount)
        
        let isFollowing = DataRepository.shared.isFollowing(userId: userId)
        updateFollowButton(isFollowing: isFollowing)
        
        posts = DataRepository.shared.getUserPosts(userId: userId).filter { $0.isPublic }.sorted { $0.createdAt > $1.createdAt }
        
        // S-06: Calendar vs Posts 切换
        let isCalendar = segmentedControl.selectedSegmentIndex == 0
        calendarContainerView.isHidden = !isCalendar
        collectionView.isHidden = isCalendar
        
        if !isCalendar {
            collectionView.reloadData()
            let height = CGFloat(ceil(Double(posts.count) / 2.0)) * ((view.bounds.width - 48) / 2 * PostCollectionViewCell.gridHeightRatio) + 50
            collectionView.snp.updateConstraints { make in
                make.height.equalTo(max(height, 300))
            }
        }
    }
    
    // MARK: - S-06 Calendar UI
    private func setupCalendarUI() {
        calendarMonthLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
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
        
        let weekdayStack = UIStackView()
        weekdayStack.axis = .horizontal
        weekdayStack.distribution = .fillEqually
        ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"].forEach {
            let label = UILabel()
            label.text = $0
            label.font = .systemFont(ofSize: 8, weight: .bold)
            label.textColor = AppTheme.textSecondary
            label.textAlignment = .center
            weekdayStack.addArrangedSubview(label)
        }
        calendarContainerView.addSubview(weekdayStack)
        weekdayStack.snp.makeConstraints { make in
            make.top.equalTo(calendarMonthLabel.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(12)
        }
        calendarGridCollectionView.snp.makeConstraints { make in
            make.top.equalTo(weekdayStack.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
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
    
    private func updateFollowButton(isFollowing: Bool) {
        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(AppTheme.textSecondary, for: .normal)
            followButton.backgroundColor = .white
            followButton.layer.borderWidth = 1
            followButton.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(AppTheme.textPrimary, for: .normal)
            followButton.backgroundColor = AppTheme.primaryColor
            followButton.layer.borderWidth = 0
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated), name: .userProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(followChanged), name: .followStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .postUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlocked), name: .userBlocked, object: nil)
    }

    @objc private func profileUpdated() {
        loadData()
    }
    
    @objc private func followChanged() {
        loadData()
    }
    
    @objc private func postUpdated() {
        loadData()
    }
    
    @objc private func userBlocked() {
        if DataRepository.shared.isUserBlocked(userId: userId) {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func segmentChanged() {
        let segmentWidth = segmentedControl.bounds.width / 2
        tabUnderline.snp.updateConstraints { make in
            make.left.equalTo(segmentedControl.snp.left).offset(19 + segmentWidth * CGFloat(segmentedControl.selectedSegmentIndex))
        }
        loadData()
    }
    
    @objc private func followTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        _ = DataRepository.shared.toggleFollow(userId: userId)
    }
    
    @objc private func messageTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        if !DataRepository.shared.isMutualFollowing(userId: userId) {
            showConnectToChatAlert()
            return
        }
        
        let chatVC = ChatViewController(userId: userId)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc private func moreTapped() {
        let sheet = ReportBlockSheetViewController()
        sheet.onAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .report:
                let reportVC = ReportViewController(targetUserId: self.userId, postId: nil, source: "User Profile")
                self.navigationController?.pushViewController(reportVC, animated: true)
            case .block:
                self.showBlockConfirmation()
            }
        }
        present(sheet, animated: false)
    }
    
    private func showBlockConfirmation() {
        let alert = CommonAlertView(
            title: "Block User",
            message: "Are you sure you want to block this user?",
            cancelTitle: "Cancel",
            confirmTitle: "Block"
        )
        alert.onConfirm = { [weak self] in
            guard let self = self else { return }
            DataRepository.shared.blockUser(userId: self.userId)
            self.navigationController?.popViewController(animated: true)
        }
        alert.show()
    }
    
    private func showConnectToChatAlert() {
        let alert = CommonAlertView(
            title: "Connect to Chat",
            message: "Follow each other to unlock messages.",
            cancelTitle: "OK",
            confirmTitle: "OK"
        )
        alert.show()
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

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView === calendarGridCollectionView ? calendarDays.count : posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === calendarGridCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.reuseIdentifier, for: indexPath) as! CalendarDayCell
            let date = calendarDays[indexPath.item]
            let post = DataRepository.shared.getUserPosts(userId: userId)
                .filter { $0.isPublic && Calendar.current.isDate($0.date, inSameDayAs: date) }
                .max { $0.createdAt < $1.createdAt }
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
            guard let post = DataRepository.shared.getUserPosts(userId: userId)
                .filter({ $0.isPublic && Calendar.current.isDate($0.date, inSameDayAs: date) })
                .max(by: { $0.createdAt < $1.createdAt }) else { return }
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
}
