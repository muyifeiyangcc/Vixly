import UIKit
import SnapKit

class ReportViewController: BaseViewController {
    
    private let targetUserId: String
    private let postId: String?
    private let source: String
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Why are you reporting this?"
        label.font = AppFont.subtitle(.semibold)
        label.textColor = AppTheme.textPrimary
        label.numberOfLines = 0
        return label
    }()
    
    private let optionsStackView = UIStackView()
    private var selectedIndex: Int?
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 23
        return button
    }()
    
    private let reasons = [
        "Spam or scam",
        "Harassment or bullying",
        "Hate speech",
        "Nudity or sexual content",
        "Dangerous activity",
        "False water or safety information",
        "Other"
    ]
    
    init(targetUserId: String, postId: String?, source: String) {
        self.targetUserId = targetUserId
        self.postId = postId
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = setupAuthHeader(title: "REPORT")
        setupUI()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(questionLabel)
        contentView.addSubview(optionsStackView)
        view.addSubview(saveButton)
        
        optionsStackView.axis = .vertical
        optionsStackView.spacing = 1
        optionsStackView.backgroundColor = AppTheme.authFieldBorderColor
        optionsStackView.layer.cornerRadius = 14
        optionsStackView.layer.borderWidth = 1
        optionsStackView.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        optionsStackView.clipsToBounds = true
        
        for (index, reason) in reasons.enumerated() {
            let optionView = createOptionView(title: reason, index: index)
            optionsStackView.addArrangedSubview(optionView)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        questionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview().inset(16)
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-32)
            make.height.equalTo(45)
        }
    }
    
    private func createOptionView(title: String, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0
        view.tag = index
        view.isUserInteractionEnabled = true
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFont.caption(.semibold)
        titleLabel.textColor = AppTheme.textPrimary
        titleLabel.tag = index
        view.addSubview(titleLabel)
        
        let radioButton = UIButton(type: .custom)
        radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        radioButton.tintColor = AppTheme.textTertiary
        radioButton.tag = index
        view.addSubview(radioButton)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        radioButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        view.snp.makeConstraints { make in
            make.height.equalTo(51)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(optionTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    @objc private func optionTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        selectedIndex = view.tag
        updateOptionsUI()
    }
    
    private func updateOptionsUI() {
        for (index, subview) in optionsStackView.arrangedSubviews.enumerated() {
            guard let optionView = subview as? UIView else { continue }
            
            if let radioButton = optionView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                if index == selectedIndex {
                    radioButton.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
                    radioButton.tintColor = AppTheme.primaryColor
                    optionView.backgroundColor = AppTheme.secondaryColor
                } else {
                    radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
                    radioButton.tintColor = AppTheme.textTertiary
                    optionView.backgroundColor = .white
                }
            }
        }
    }
    
    @objc private func saveTapped() {
        guard let selectedIndex = selectedIndex else {
            showAlert(title: "Error", message: "Please select a reason for reporting.")
            return
        }
        
        let reason = reasons[selectedIndex]
        DataRepository.shared.reportUser(userId: targetUserId, postId: postId, reason: reason, source: source)

        let alert = CommonAlertView(
            title: "Reported",
            message: "Thank you for your report. We'll review it as soon as possible.",
            cancelTitle: "",
            confirmTitle: "OK"
        )
        alert.onConfirm = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.show()
    }
}
