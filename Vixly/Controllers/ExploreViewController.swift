import UIKit
import SnapKit

class ExploreViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "EXPLORE"
        label.font = AppFont.h1(.black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let searchBar: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.backgroundColor
        view.layer.cornerRadius = 22
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return view
    }()
    
    private let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search style, item or brand"
        tf.font = AppFont.body()
        tf.backgroundColor = .clear
        tf.returnKeyType = .search
        return tf
    }()
    
    private let searchIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "magnifyingglass")
        iv.tintColor = AppTheme.textTertiary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["For You", "Following", "Top Fits"]
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = 0
        seg.selectedSegmentTintColor = .clear
        // The design uses a white tab strip; the custom indicator is the only
        // selected-state decoration.
        seg.backgroundColor = .white
        let clearDivider = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
        seg.setDividerImage(clearDivider, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        seg.setDividerImage(clearDivider, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        seg.setDividerImage(clearDivider, forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        seg.setTitleTextAttributes([.foregroundColor: AppTheme.textPrimary, .font: AppFont.subtitle(.semibold)], for: .selected)
        seg.setTitleTextAttributes([.foregroundColor: AppTheme.textSecondary, .font: AppFont.subtitle()], for: .normal)
        return seg
    }()

    private let tabsBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let segmentIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.textPrimary
        view.layer.cornerRadius = 1.5
        return view
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
    
    private var allPosts: [Post] = []
    private var posts: [Post] = []
    private var currentSegment: String = "For You"
    private var searchKeyword: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        setupUI()
        loadData()
        addObservers()
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
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(searchBar)
        searchBar.addSubview(searchIcon)
        searchBar.addSubview(searchTextField)
        contentView.addSubview(tabsBackgroundView)
        contentView.addSubview(segmentedControl)
        contentView.addSubview(segmentIndicator)
        contentView.addSubview(collectionView)
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        searchTextField.delegate = self
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(20)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        searchIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(8)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(48)
        }

        tabsBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(segmentedControl)
        }

        segmentIndicator.snp.makeConstraints { make in
            make.bottom.equalTo(segmentedControl.snp.bottom)
            make.height.equalTo(3)
            make.width.equalTo(72)
            make.left.equalTo(segmentedControl.snp.left).offset(17)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(1000)
        }
    }
    
    private func loadData() {
        let type: String
        switch segmentedControl.selectedSegmentIndex {
        case 0: type = "For You"
        case 1: type = "Following"
        case 2: type = "Top Fits"
        default: type = "For You"
        }
        currentSegment = type
        allPosts = DataRepository.shared.getExplorePosts(type: type)
        
        // O-08: 根据搜索关键词过滤
        if !searchKeyword.isEmpty {
            let keyword = searchKeyword.lowercased()
            posts = allPosts.filter { post in
                post.caption.lowercased().contains(keyword) ||
                post.styleTags.contains { $0.lowercased().contains(keyword) } ||
                post.location.lowercased().contains(keyword) ||
                post.items.tops.contains { $0.brand.lowercased().contains(keyword) || $0.product.lowercased().contains(keyword) } ||
                post.items.bottoms.contains { $0.brand.lowercased().contains(keyword) || $0.product.lowercased().contains(keyword) } ||
                post.items.shoes.contains { $0.brand.lowercased().contains(keyword) || $0.product.lowercased().contains(keyword) } ||
                post.items.accessories.contains { $0.brand.lowercased().contains(keyword) || $0.product.lowercased().contains(keyword) }
            }
        } else {
            posts = allPosts
        }
        
        collectionView.reloadData()
        
        let height = CGFloat(ceil(Double(posts.count) / 2.0)) * (view.bounds.width - 52) / 2 * PostCollectionViewCell.gridHeightRatio + 100
        collectionView.snp.updateConstraints { make in
            make.height.equalTo(max(height, 400))
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(postUpdated), name: .postUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(postCreated), name: .postCreated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlocked), name: .userBlocked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(followChanged), name: .followStatusChanged, object: nil)
    }
    
    @objc private func postUpdated() {
        loadData()
    }
    
    @objc private func postCreated() {
        loadData()
    }
    
    @objc private func userBlocked() {
        loadData()
    }
    
    @objc private func followChanged() {
        loadData()
    }
    
    @objc private func segmentChanged() {
        updateSegmentIndicator()
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSegmentIndicator()
    }

    private func updateSegmentIndicator() {
        guard segmentedControl.bounds.width > 0 else { return }
        let segmentWidth = segmentedControl.bounds.width / 3
        segmentIndicator.snp.remakeConstraints { make in
            make.bottom.equalTo(segmentedControl.snp.bottom)
            make.height.equalTo(3)
            make.width.equalTo(72)
            make.centerX.equalTo(segmentedControl.snp.left).offset(segmentWidth * (CGFloat(segmentedControl.selectedSegmentIndex) + 0.5))
        }
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

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.reuseIdentifier, for: indexPath) as! PostCollectionViewCell
        let post = posts[indexPath.item]
        cell.configure(with: post)
        
        cell.onLikeTapped = {
            _ = DataRepository.shared.toggleLike(postId: post.id)
        }
        
        cell.onSaveTapped = {
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
                let reportVC = ReportViewController(targetUserId: post.userId, postId: post.id, source: "Explore")
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
            message: "Are you sure you want to block this user?",
            cancelTitle: "Cancel",
            confirmTitle: "Block"
        )
        alert.onConfirm = {
            DataRepository.shared.blockUser(userId: userId)
        }
        alert.show()
    }
}

extension ExploreViewController: UITextFieldDelegate {
    @objc private func searchTextChanged(_ textField: UITextField) {
        searchKeyword = textField.text ?? ""
        loadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchKeyword = textField.text ?? ""
        loadData()
        return true
    }
}
