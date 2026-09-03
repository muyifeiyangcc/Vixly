import UIKit
import SnapKit

class TodayViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "VIXLY"
        label.font = .systemFont(ofSize: 28, weight: .black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle(.semibold)
        label.textColor = AppTheme.textSecondary
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TODAY'S FIT"
        label.font = AppFont.h4(.black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let streakView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.secondaryColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let streakLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let streakDot: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.primaryColor
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let weekDaysStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private var dayViews: [DayView] = []
    
    private let ootdCardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.secondaryColor
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let aiStylistView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private let creatorsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "RECENT FROM CREATORS"
        label.font = AppFont.h5(.bold)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.dataSource = self
        cv.delegate = self
        cv.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.reuseIdentifier)
        return cv
    }()
    
    private var posts: [Post] = []
    private var selectedDate = Date()
    
    // O-09: 分页状态
    private var currentPage = 0
    private let pageSize = 10
    private var isLoadingMore = false
    private var hasMorePosts = true
    private let guestInteractionBlocker = UIControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        setupUI()
        setupWeekDays()
        loadData()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setupWeekDays()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(brandLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(streakView)
        streakView.addSubview(streakDot)
        streakView.addSubview(streakLabel)
        contentView.addSubview(weekDaysStackView)
        contentView.addSubview(ootdCardView)
        contentView.addSubview(aiStylistView)
        contentView.addSubview(creatorsTitleLabel)
        contentView.addSubview(collectionView)
        
        setupOOTDCard()
        setupAIStylistView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE · MMM d"
        dateLabel.text = dateFormatter.string(from: Date()).uppercased()
        
        let streak = DataRepository.shared.getStreakDays()
        streakLabel.text = "STREAK · \(streak) DAYS"
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        brandLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(brandLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(20)
        }
        
        streakView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
        streakDot.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        
        streakLabel.snp.makeConstraints { make in
            make.left.equalTo(streakDot.snp.right).offset(6)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        weekDaysStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
        
        ootdCardView.snp.makeConstraints { make in
            make.top.equalTo(weekDaysStackView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        aiStylistView.snp.makeConstraints { make in
            make.top.equalTo(ootdCardView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(122)
        }
        
        creatorsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(aiStylistView.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(creatorsTitleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(800)
        }

        if DataRepository.shared.isGuest {
            setupGuestInteractionBlocker()
        }
    }

    private func setupGuestInteractionBlocker() {
        guestInteractionBlocker.backgroundColor = .clear
        guestInteractionBlocker.addTarget(self, action: #selector(guestInteractionTapped), for: .touchUpInside)
        view.addSubview(guestInteractionBlocker)
        guestInteractionBlocker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupOOTDCard() {
        let selectedPost = DataRepository.shared.getPost(for: selectedDate)
        let hasOOTD = selectedPost != nil
        
        for subview in ootdCardView.subviews {
            subview.removeFromSuperview()
        }
        
        if hasOOTD {
            let coverView = UIImageView()
            coverView.image = selectedPost?.media.first.flatMap { PostMediaPreview.image(for: $0) }
            coverView.backgroundColor = AppTheme.secondaryColor
            coverView.contentMode = .scaleAspectFill
            coverView.clipsToBounds = true
            ootdCardView.addSubview(coverView)

            let shadeView = UIView()
            shadeView.backgroundColor = UIColor.black.withAlphaComponent(0.22)
            coverView.addSubview(shadeView)
            
            let statusLabel = UILabel()
            statusLabel.text = Calendar.current.isDateInToday(selectedDate) ? "TODAY'S FIT IS\nLIVE" : "OOTD IS\nLIVE"
            statusLabel.font = AppFont.h2(.black)
            statusLabel.textColor = .white
            statusLabel.numberOfLines = 0
            ootdCardView.addSubview(statusLabel)
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Posted to your calendar and the community"
            subtitleLabel.font = AppFont.subtitle()
            subtitleLabel.textColor = .white
            subtitleLabel.numberOfLines = 0
            ootdCardView.addSubview(subtitleLabel)
            
            let viewButton = UIButton(type: .system)
            viewButton.setTitle("View today's OOTD", for: .normal)
            viewButton.titleLabel?.font = AppFont.body(.bold)
            viewButton.setTitleColor(AppTheme.textPrimary, for: .normal)
            viewButton.backgroundColor = AppTheme.primaryColor
            viewButton.layer.cornerRadius = 25
            viewButton.addTarget(self, action: #selector(viewTodayOOTD), for: .touchUpInside)
            ootdCardView.addSubview(viewButton)
            
            coverView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(180)
            }
            shadeView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            statusLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(24)
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(statusLabel.snp.bottom).offset(12)
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
            }
            
            viewButton.snp.makeConstraints { make in
                make.top.equalTo(coverView.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
                make.height.equalTo(50)
                make.bottom.equalToSuperview().offset(-24)
            }
        } else {
            let noRecordLabel = UILabel()
            noRecordLabel.text = "NO OOTD\nRECORDED\nTODAY"
            noRecordLabel.font = AppFont.h4(.black)
            noRecordLabel.textColor = AppTheme.textPrimary
            noRecordLabel.numberOfLines = 0
            ootdCardView.addSubview(noRecordLabel)
            
            let plusButton = UIButton(type: .system)
            plusButton.setImage(UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)), for: .normal)
            plusButton.tintColor = AppTheme.textPrimary
            plusButton.backgroundColor = AppTheme.primaryColor
            plusButton.layer.cornerRadius = 40
            plusButton.addTarget(self, action: #selector(addTodayFitTapped), for: .touchUpInside)
            ootdCardView.addSubview(plusButton)
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = "Private calendar record or public community post"
            subtitleLabel.font = AppFont.body()
            subtitleLabel.textColor = AppTheme.textSecondary
            subtitleLabel.numberOfLines = 0
            ootdCardView.addSubview(subtitleLabel)
            
            let addButton = UIButton(type: .system)
            addButton.setTitle("Add Today's Fit", for: .normal)
            addButton.titleLabel?.font = AppFont.body(.bold)
            addButton.setTitleColor(AppTheme.textPrimary, for: .normal)
            addButton.backgroundColor = AppTheme.primaryColor
            addButton.layer.cornerRadius = 28
            addButton.addTarget(self, action: #selector(addTodayFitTapped), for: .touchUpInside)
            ootdCardView.addSubview(addButton)
            
            let bottomInfoLabel = UILabel()
            bottomInfoLabel.text = "Photo / video · item tags · style tags"
            bottomInfoLabel.font = AppFont.subtitle()
            bottomInfoLabel.textColor = AppTheme.textTertiary
            bottomInfoLabel.textAlignment = .center
            ootdCardView.addSubview(bottomInfoLabel)
            
            let bottomView = UIView()
            bottomView.backgroundColor = .white
            ootdCardView.addSubview(bottomView)
            
            bottomView.addSubview(addButton)
            bottomView.addSubview(bottomInfoLabel)
            
            noRecordLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(32)
                make.left.equalToSuperview().offset(24)
            }
            
            plusButton.snp.makeConstraints { make in
                make.centerY.equalTo(noRecordLabel)
                make.right.equalToSuperview().offset(-24)
                make.width.height.equalTo(80)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(noRecordLabel.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(24)
                make.right.equalTo(plusButton.snp.left).offset(-12)
            }
            
            bottomView.snp.makeConstraints { make in
                make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
                make.left.right.bottom.equalToSuperview()
            }
            
            addButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.left.equalToSuperview().offset(24)
                make.right.equalToSuperview().offset(-24)
                make.height.equalTo(56)
            }
            
            bottomInfoLabel.snp.makeConstraints { make in
                make.top.equalTo(addButton.snp.bottom).offset(12)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-16)
            }
        }
    }
    
    private func setupAIStylistView() {
        let imageView = UIImageView(image: UIImage(named: "aistyle"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        aiStylistView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let actionButton = UIButton(type: .custom)
        actionButton.backgroundColor = .clear
        actionButton.addTarget(self, action: #selector(aiStylistTapped), for: .touchUpInside)
        aiStylistView.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupWeekDays() {
        dayViews.removeAll()
        weekDaysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - 1
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return }
        
        let dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) else { continue }
            let dayComponent = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            let hasRecord = DataRepository.shared.hasRecordForDate(date)
            
            let dayView = DayView()
            dayView.configure(dayName: dayNames[i], dayNumber: "\(dayComponent)", isToday: isToday, isSelected: calendar.isDate(date, inSameDayAs: selectedDate), hasRecord: hasRecord)
            dayView.onTapped = { [weak self] in
                guard let self else { return }
                self.selectedDate = date
                self.dateLabel.text = self.dayLabelFormatter.string(from: date).uppercased()
                self.refreshSelectedDay()
            }
            weekDaysStackView.addArrangedSubview(dayView)
            dayViews.append(dayView)
        }
    }

    private let dayLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE · MMM d"
        return formatter
    }()

    private func refreshSelectedDay() {
        let calendar = Calendar.current
        for (index, dayView) in dayViews.enumerated() {
            guard let date = calendar.date(byAdding: .day, value: index, to: weekStartDate()) else { continue }
            dayView.setSelected(calendar.isDate(date, inSameDayAs: selectedDate), isToday: calendar.isDateInToday(date))
        }
        setupOOTDCard()
    }

    private func weekStartDate() -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return calendar.date(byAdding: .day, value: -(weekday - 1), to: Date()) ?? Date()
    }
    
    private func loadData() {
        // O-09: 重置分页
        currentPage = 0
        hasMorePosts = true
        posts = DataRepository.shared.getCreatorPosts(page: currentPage, pageSize: pageSize)
        collectionView.reloadData()
        setupOOTDCard()
        
        let streak = DataRepository.shared.getStreakDays()
        streakLabel.text = "STREAK · \(streak) DAYS"
        
        // O-03: collectionView 高度自适应
        let itemHeight = (view.bounds.width - 52) / 2 * PostCollectionViewCell.gridHeightRatio
        let rows = CGFloat(ceil(Double(posts.count) / 2.0))
        let height = rows * itemHeight + (rows - 1) * 16
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(max(height, 300))
        }
    }
    
    // O-09: 加载更多
    private func loadMorePosts() {
        guard !isLoadingMore && hasMorePosts else { return }
        isLoadingMore = true
        currentPage += 1
        
        let more = DataRepository.shared.getCreatorPosts(page: currentPage, pageSize: pageSize)
        if more.isEmpty {
            hasMorePosts = false
        } else {
            let startIndex = posts.count
            posts.append(contentsOf: more)
            var indexPaths: [IndexPath] = []
            for i in 0..<more.count {
                indexPaths.append(IndexPath(item: startIndex + i, section: 0))
            }
            collectionView.performBatchUpdates({
                collectionView.insertItems(at: indexPaths)
            }) { [weak self] _ in
                // 更新高度
                guard let self = self else { return }
                let itemHeight = (self.view.bounds.width - 52) / 2 * PostCollectionViewCell.gridHeightRatio
                let rows = CGFloat(ceil(Double(self.posts.count) / 2.0))
                let height = rows * itemHeight + (rows - 1) * 16
                self.collectionView.snp.updateConstraints { make in
                    make.height.equalTo(max(height, 300))
                }
            }
        }
        isLoadingMore = false
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .postUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreated), name: .postCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlocked), name: .userBlocked, object: nil)
    }
    
    @objc private func postUpdated() {
        loadData()
    }
    
    @objc private func postCreated() {
        setupWeekDays()
        loadData()
    }
    
    @objc private func userBlocked() {
        loadData()
    }
    
    @objc private func addTodayFitTapped() {
        if DataRepository.shared.isGuest {
            showSignInRequired()
            return
        }
        
        let postVC = AddMediaViewController()
        let nav = UINavigationController(rootViewController: postVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func viewTodayOOTD() {
        guard let post = DataRepository.shared.getPost(for: selectedDate) else { return }
        let detailVC = PostDetailViewController(postId: post.id)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
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

    @objc private func guestInteractionTapped() {
        showSignInRequired()
    }
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        let post = posts[indexPath.item]
        cell.configure(with: post)
        
        cell.onLikeTapped = { [weak self] in
            _ = DataRepository.shared.toggleLike(postId: post.id)
        }
        
        cell.onSaveTapped = { [weak self] in
            _ = DataRepository.shared.toggleSave(postId: post.id)
        }
        
        cell.onAuthorTapped = { [weak self] in
            let profileVC = UserProfileViewController(userId: post.userId)
            profileVC.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        cell.onMoreTapped = { [weak self] in
            self?.showMoreOptions(for: post)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: width * PostCollectionViewCell.gridHeightRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !DataRepository.shared.isLoggedIn {
            showPostSignInRequired()
            return
        }
        let post = posts[indexPath.item]
        let detailVC = PostDetailViewController(postId: post.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // O-09: 滚动到底部触发加载更多
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let thresholdIndex = posts.count - 3
        if indexPath.item == thresholdIndex {
            loadMorePosts()
        }
    }
    
    private func showPostSignInRequired() {
        let alert = CommonAlertView(
            title: "Sign In Required",
            message: "Please sign in to view post details.",
            cancelTitle: "Cancel",
            confirmTitle: "Sign In"
        )
        alert.onConfirm = { [weak self] in
            AppRouter.shared.showSignIn(from: self ?? UIViewController())
        }
        alert.show()
    }
    
    private func showMoreOptions(for post: Post) {
        guard post.userId != DataRepository.shared.currentUser?.id else { return }
        let sheet = ReportBlockSheetViewController()
        sheet.onAction = { [weak self] action in
            switch action {
            case .report:
                let reportVC = ReportViewController(targetUserId: post.userId, postId: post.id, source: "Post")
                self?.navigationController?.pushViewController(reportVC, animated: true)
            case .block:
                self?.showBlockConfirmation(userId: post.userId)
            }
        }
        present(sheet, animated: false)
    }
    
    private func showBlockConfirmation(userId: String) {
        let alert = CommonAlertView(
            title: "Block User",
            message: "Are you sure you want to block this user? They will no longer be able to interact with you.",
            cancelTitle: "Cancel",
            confirmTitle: "Block"
        )
        alert.onConfirm = {
            DataRepository.shared.blockUser(userId: userId)
        }
        alert.show()
    }
}

class DayView: UIView {

    var onTapped: (() -> Void)?
    
    private let dayNameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let dayNumberLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.h3(.bold)
        label.textAlignment = .center
        return label
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = AppTheme.backgroundColor
        layer.cornerRadius = 16
        
        addSubview(dayNameLabel)
        addSubview(dayNumberLabel)
        addSubview(dotView)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        dayNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview()
        }
        
        dayNumberLabel.snp.makeConstraints { make in
            make.top.equalTo(dayNameLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        
        dotView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-8)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(6)
        }
    }
    
    func configure(dayName: String, dayNumber: String, isToday: Bool, isSelected: Bool, hasRecord: Bool) {
        dayNameLabel.text = dayName
        dayNumberLabel.text = dayNumber

        setSelected(isSelected, isToday: isToday)
        dotView.backgroundColor = hasRecord ? AppTheme.textAccent : .clear
    }

    func setSelected(_ selected: Bool, isToday: Bool) {
        if selected {
            backgroundColor = AppTheme.textPrimary
            dayNameLabel.textColor = .white
            dayNumberLabel.textColor = .white
        } else {
            backgroundColor = AppTheme.backgroundColor
            dayNameLabel.textColor = AppTheme.textSecondary
            dayNumberLabel.textColor = AppTheme.textPrimary
        }
        if isToday && !selected {
            dayNameLabel.textColor = AppTheme.textPrimary
        }
    }

    @objc private func tapped() {
        onTapped?()
    }
}
