import UIKit
import SnapKit

class EditProfileViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var selectedAvatarImage: UIImage?
    
    private let avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = AppTheme.secondaryColor
        button.layer.cornerRadius = 50
        button.clipsToBounds = true
        return button
    }()
    
    private let cameraIconView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "camera")
        iv.backgroundColor = AppTheme.primaryColor
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.contentMode = .center
        return iv
    }()
    
    private let uploadPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload photo"
        label.font = AppFont.caption(.bold)
        label.textColor = UIColor(hex: "#23677A")
        label.textAlignment = .center
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Your name"
        tf.font = AppFont.subtitle()
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 11
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    private let bioTextView: UITextView = {
        let tv = UITextView()
        tv.font = AppFont.subtitle()
        tv.backgroundColor = .white
        tv.layer.cornerRadius = 11
        tv.layer.borderWidth = 1
        tv.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return tv
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 23
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = setupAuthHeader(title: "EDIT PROFILE")
        setupUI()
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        loadUserData()
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(avatarButton)
        contentView.addSubview(cameraIconView)
        contentView.addSubview(uploadPhotoLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = "Name"
        nameLabel.font = AppFont.caption(.semibold)
        nameLabel.textColor = AppTheme.textPrimary
        
        let bioLabel = UILabel()
        bioLabel.text = "Bio"
        bioLabel.font = AppFont.caption(.semibold)
        bioLabel.textColor = AppTheme.textPrimary
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(bioLabel)
        contentView.addSubview(bioTextView)
        view.addSubview(saveButton)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        avatarButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        cameraIconView.snp.makeConstraints { make in
            make.bottom.equalTo(avatarButton).offset(4)
            make.trailing.equalTo(avatarButton).offset(4)
            make.width.height.equalTo(36)
        }
        
        uploadPhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(uploadPhotoLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(15)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(15)
        }
        
        bioTextView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(132)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().offset(-32)
            make.height.equalTo(45)
        }
    }
    
    private func loadUserData() {
        guard let user = DataRepository.shared.currentUser else { return }
        nameTextField.text = user.name
        bioTextView.text = user.bio
        let image = DataRepository.shared.avatarImage(for: user) ?? DataRepository.shared.defaultAvatarImage()
        avatarButton.setImage(image, for: .normal)
        avatarButton.imageView?.contentMode = .scaleAspectFill
    }
    
    @objc private func avatarTapped() {
        let sheet = PhotoSourceSheetViewController()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        sheet.onSourceSelected = { [weak self] sourceType in
            self?.presentPicker(sourceType: sourceType)
        }
        present(sheet, animated: false)
    }

    private func presentPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter your name.")
            return
        }
        
        DataRepository.shared.updateProfile(name: name, bio: bioTextView.text, avatar: selectedAvatarImage == nil ? nil : "avatar_default")
        if let selectedAvatarImage {
            DataRepository.shared.setCurrentUserAvatarImage(selectedAvatarImage)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        if let image {
            selectedAvatarImage = image
            avatarButton.setImage(image, for: .normal)
            avatarButton.imageView?.contentMode = .scaleAspectFill
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
