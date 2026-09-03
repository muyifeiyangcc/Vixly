import UIKit
import SnapKit

class ItemBreakdownViewController: UIViewController {
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "ITEM BREAKDOWN"
        label.font = UIFont(name: "Impact", size: 40) ?? AppFont.h1(.black)
        label.textColor = AppTheme.textPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Item details are optional; adding at least one item is recommended."
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private let categoriesStackView = UIStackView()
    
    private let bottomNoteLabel: UILabel = {
        let label = UILabel()
        label.text = "ⓘ   Each category can contain multiple items. Purchase link\nand price are optional."
        label.font = AppFont.caption()
        label.textColor = AppTheme.textTertiary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.layer.cornerRadius = 12
        label.layer.borderWidth = 1
        label.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        label.clipsToBounds = true
        return label
    }()
    
    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = AppFont.caption(.semibold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next: Details", for: .normal)
        button.titleLabel?.font = AppFont.caption(.bold)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 22
        button.isEnabled = false
        button.alpha = 0.45
        return button
    }()
    
    private struct CategoryConfig {
        let name: String
        let icon: String
        let keyPath: WritableKeyPath<PostItems, [PostItem]>
    }
    private let categories: [CategoryConfig] = [
        CategoryConfig(name: "Top", icon: "top", keyPath: \.tops),
        CategoryConfig(name: "Bottom", icon: "Bottom", keyPath: \.bottoms),
        CategoryConfig(name: "Shoes", icon: "Shoes", keyPath: \.shoes),
        CategoryConfig(name: "Accessories", icon: "Accessories", keyPath: \.accessories)
    ]
    private var items = PostItems(tops: [], bottoms: [], shoes: [], accessories: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        items = PostDraftManager.shared.items
        setupUI()
        updateNextButton()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        let progress = PostProgressView(currentStep: 1)
        let topNavigationBackground = UIView()
        topNavigationBackground.backgroundColor = .white
        let bottomBar = UIView()
        bottomBar.backgroundColor = .white
        view.insertSubview(topNavigationBackground, at: 0)
        view.addSubview(closeButton)
        view.addSubview(progress)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(categoriesStackView)
        view.addSubview(bottomNoteLabel)
        view.addSubview(bottomBar)
        bottomBar.addSubview(bottomStack)
        
        bottomStack.addArrangedSubview(backButton)
        bottomStack.addArrangedSubview(nextButton)
        
        categoriesStackView.axis = .vertical
        categoriesStackView.spacing = 8
        
        for (index, category) in categories.enumerated() {
            let categoryItems = items[keyPath: category.keyPath]
            let categoryView = createCategoryView(category: category, items: categoryItems, index: index)
            categoriesStackView.addArrangedSubview(categoryView)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(28)
        }
        progress.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }
        topNavigationBackground.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(progress.snp.bottom)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(15)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(15)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(15)
        }
        
        bottomNoteLabel.snp.makeConstraints { make in
            make.top.equalTo(categoriesStackView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
        }

        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(78)
        }
        bottomStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(44)
        }
        backButton.snp.makeConstraints { make in make.width.equalTo(108) }
    }
    
    private func createCategoryView(category: CategoryConfig, items: [PostItem], index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        view.tag = index
        view.isUserInteractionEnabled = true
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: category.icon)
        iconImageView.contentMode = .scaleAspectFit
        view.addSubview(iconImageView)
        
        let nameLabel = UILabel()
        nameLabel.text = category.name
        nameLabel.font = AppFont.subtitle(.semibold)
        nameLabel.textColor = AppTheme.textPrimary
        view.addSubview(nameLabel)
        
        let countLabel = UILabel()
        countLabel.text = itemSummary(for: category.name, items: items)
        countLabel.font = AppFont.caption()
        countLabel.textColor = items.isEmpty ? AppTheme.textTertiary : AppTheme.textSecondary
        countLabel.tag = 100
        view.addSubview(countLabel)
        
        let arrowImageView = UIImageView()
        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = AppTheme.textTertiary
        view.addSubview(arrowImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        
        countLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalTo(iconImageView.snp.right).offset(12)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
        
        view.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }

    private func itemSummary(for category: String, items: [PostItem]) -> String {
        guard let item = items.first else { return "Not added" }
        let name = item.product.isEmpty ? (item.brand.isEmpty ? "\(category) item" : item.brand) : item.product
        return "\(name) added · Brand / product / color / size"
    }
    
    @objc private func categoryTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        showItemEditor(categoryIndex: index)
    }
    
    private func showItemEditor(categoryIndex: Int) {
        let category = categories[categoryIndex]
        let sheet = ItemEditorSheetViewController(category: category.name)
        sheet.modalPresentationStyle = .overFullScreen
        sheet.onSave = { [weak self] brand, product, color, size in
            guard let self = self else { return }
            guard !brand.isEmpty || !product.isEmpty || !color.isEmpty || !size.isEmpty else { return }
            let newItem = PostItem(
                id: "\(category.name.lowercased())_\(UUID().uuidString.prefix(8))",
                brand: brand,
                product: product,
                color: color,
                size: size
            )
            var arr = self.items[keyPath: category.keyPath]
            arr.append(newItem)
            self.items[keyPath: category.keyPath] = arr
            
            // 刷新 count label
            let arranged = self.categoriesStackView.arrangedSubviews
            if categoryIndex >= 0 && categoryIndex < arranged.count {
                let categoryItems = self.items[keyPath: category.keyPath]
                if let label = arranged[categoryIndex].viewWithTag(100) as? UILabel {
                    label.text = self.itemSummary(for: category.name, items: categoryItems)
                    label.textColor = categoryItems.isEmpty ? AppTheme.textTertiary : AppTheme.textSecondary
                }
            }
            self.updateNextButton()
        }
        present(sheet, animated: false)
    }

    private func updateNextButton() {
        nextButton.isEnabled = items.totalCount > 0
        nextButton.alpha = nextButton.isEnabled ? 1 : 0.45
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func closeTapped() {
        let alert = CommonAlertView(
            title: "Discard Draft",
            message: "Are you sure you want to discard your draft?",
            cancelTitle: "Keep Editing",
            confirmTitle: "Discard"
        )
        alert.onConfirm = { [weak self] in
            PostDraftManager.shared.clear()
            self?.dismiss(animated: true)
        }
        alert.show()
    }
    
    @objc private func nextTapped() {
        PostDraftManager.shared.items = items
        PostDraftManager.shared.transition(to: .postDetails)
        let postDetailsVC = PostDetailsViewController()
        navigationController?.pushViewController(postDetailsVC, animated: true)
    }
}

final class ItemEditorSheetViewController: UIViewController {
    var onSave: ((String, String, String, String) -> Void)?
    private let category: String
    private let readOnlyItem: PostItem?
    private let sheet = UIView()
    private let fields = (0..<4).map { _ in UITextField() }

    init(category: String) {
        self.category = category
        self.readOnlyItem = nil
        super.init(nibName: nil, bundle: nil)
    }

    init(category: String, item: PostItem) {
        self.category = category
        self.readOnlyItem = item
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 24
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sheet)
        sheet.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview(); $0.height.equalTo(428) }

        let handle = UIView()
        handle.backgroundColor = AppTheme.authFieldBorderColor
        handle.layer.cornerRadius = 2.5
        sheet.addSubview(handle)
        handle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(9)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        let title = UILabel()
        title.text = category.uppercased()
        title.font = UIFont(name: "Impact", size: 28) ?? AppFont.h3(.black)
        title.textColor = AppTheme.textPrimary
        sheet.addSubview(title)
        title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(35)
            make.leading.equalToSuperview().offset(15)
        }

        let close = UIButton(type: .system)
        close.setImage(UIImage(systemName: "xmark"), for: .normal)
        close.tintColor = AppTheme.textPrimary
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        sheet.addSubview(close)
        close.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(39)
            make.trailing.equalToSuperview().offset(-26)
            make.width.height.equalTo(20)
        }

        let hint = UILabel()
        hint.text = "Add the optional item details shown with this OOTD."
        hint.font = AppFont.caption()
        hint.textColor = AppTheme.textSecondary
        sheet.addSubview(hint)
        hint.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(15)
        }

        let names = ["Brand", "Product", "Color", "Size"]
        let placeholders = ["Brand name", "Product name", "Color", "Size"]
        let labels = names.map { name -> UILabel in
            let label = UILabel()
            label.text = name
            label.font = AppFont.caption(.bold)
            label.textColor = AppTheme.textPrimary
            sheet.addSubview(label)
            return label
        }
        let optionalLabels = names.map { _ -> UILabel in
            let label = UILabel()
            label.text = "Optional"
            label.font = AppFont.caption()
            label.textColor = AppTheme.textSecondary
            label.textAlignment = .right
            sheet.addSubview(label)
            return label
        }

        for (index, field) in fields.enumerated() {
            field.placeholder = placeholders[index]
            if let readOnlyItem {
                field.text = [readOnlyItem.brand, readOnlyItem.product, readOnlyItem.color, readOnlyItem.size][index]
                field.textColor = AppTheme.textSecondary
                field.isUserInteractionEnabled = false
            }
            field.font = AppFont.caption()
            field.backgroundColor = .white
            field.layer.cornerRadius = 12
            field.layer.borderWidth = 1
            field.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
            field.leftViewMode = .always
            sheet.addSubview(field)
        }

        labels[0].snp.makeConstraints { make in
            make.top.equalTo(hint.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(15)
        }
        optionalLabels[0].snp.makeConstraints { make in
            make.centerY.equalTo(labels[0])
            make.trailing.equalToSuperview().offset(-15)
        }
        fields[0].snp.makeConstraints { make in
            make.top.equalTo(labels[0].snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(46)
        }

        labels[1].snp.makeConstraints { make in
            make.top.equalTo(fields[0].snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(15)
        }
        optionalLabels[1].snp.makeConstraints { make in
            make.centerY.equalTo(labels[1])
            make.trailing.equalToSuperview().offset(-15)
        }
        fields[1].snp.makeConstraints { make in
            make.top.equalTo(labels[1].snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(46)
        }

        labels[2].snp.makeConstraints { make in
            make.top.equalTo(fields[1].snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(15)
        }
        optionalLabels[2].snp.makeConstraints { make in
            make.centerY.equalTo(labels[2])
            make.trailing.equalTo(view.snp.centerX).offset(-8)
        }
        labels[3].snp.makeConstraints { make in
            make.centerY.equalTo(labels[2])
            make.leading.equalTo(view.snp.centerX).offset(8)
        }
        optionalLabels[3].snp.makeConstraints { make in
            make.centerY.equalTo(labels[3])
            make.trailing.equalToSuperview().offset(-15)
        }
        fields[2].snp.makeConstraints { make in
            make.top.equalTo(labels[2].snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(view.snp.centerX).offset(-5)
            make.height.equalTo(46)
        }
        fields[3].snp.makeConstraints { make in
            make.top.equalTo(labels[3].snp.bottom).offset(10)
            make.leading.equalTo(view.snp.centerX).offset(5)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(46)
        }

        let actionButton = PostFlowButton(title: readOnlyItem == nil ? "Save \(category)" : "Close", filled: true)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        sheet.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-19)
            make.height.equalTo(44)
        }
    }

    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); sheet.transform = CGAffineTransform(translationX: 0, y: sheet.bounds.height); UIView.animate(withDuration: 0.25) { self.sheet.transform = .identity } }
    @objc private func closeTapped() { dismiss(animated: false) }
    @objc private func actionTapped() {
        guard readOnlyItem == nil else {
            closeTapped()
            return
        }
        let callback = onSave
        let values = fields.map { $0.text ?? "" }
        dismiss(animated: false) { callback?(values[0], values[1], values[2], values[3]) }
    }
}
