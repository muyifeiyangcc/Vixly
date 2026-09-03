import UIKit
import SnapKit

final class CompleteProfileViewController: BaseViewController {

    private let headerView = UIView()
    private let profileCard = UIView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "COMPLETE YOUR\nPROFILE"
        label.numberOfLines = 2
        label.font = UIFont(name: "Impact", size: 40) ?? .systemFont(ofSize: 40, weight: .black)
        label.textColor = AppTheme.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "A few details before\nyour first fit."
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(hex: "#60747A")
        return label
    }()

    private let avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = AppTheme.backgroundColor
        button.layer.cornerRadius = 52
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.clipsToBounds = false
        button.tintColor = UIColor(hex: "#2A6878")
        button.setImage(
            UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)),
            for: .normal
        )
        return button
    }()

    private let cameraButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = AppTheme.onboardingButtonColor
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.setImage(UIImage(named: "camera"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private let uploadPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload photo"
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = UIColor(hex: "#1F6576")
        label.textAlignment = .center
        return label
    }()

    private let nameTextField: UITextField = CompleteProfileViewController.makeTextField(placeholder: "Your name")
    private let birthdayTextField: UITextField = CompleteProfileViewController.makeTextField(placeholder: "MM / DD / YYYY")
    private let maleButton = GenderOptionButton(title: "Male")
    private let femaleButton = GenderOptionButton(title: "Female")
    private var selectedAvatarImage: UIImage?

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.backgroundColor = AppTheme.authButtonColor
        button.layer.cornerRadius = 22
        return button
    }()

    private var selectedGenderIndex = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        // Keep the navigation affordance icon-only if the navigation bar is
        // briefly visible during the push transition.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if #available(iOS 14.0, *) {
            navigationItem.backButtonDisplayMode = .minimal
        }
        setupBackButton()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        updateGenderButtons()
    }

    private func setupUI() {
        view.backgroundColor = .white

        headerView.backgroundColor = AppTheme.authHeaderColor
        profileCard.backgroundColor = .white
        profileCard.layer.cornerRadius = 22
        profileCard.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        profileCard.clipsToBounds = true

        view.addSubview(headerView)
        view.addSubview(profileCard)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        view.addSubview(avatarButton)
        view.addSubview(cameraButton)
        view.addSubview(uploadPhotoLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(saveButton)

        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
        profileCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(219)
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(18)
            make.leading.equalToSuperview().offset(19)
            make.trailing.equalToSuperview().offset(-19)
            make.height.equalTo(70)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(19)
        }
        avatarButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(168)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }
        cameraButton.snp.makeConstraints { make in
            make.trailing.equalTo(avatarButton.snp.trailing).offset(5)
            make.bottom.equalTo(avatarButton.snp.bottom).offset(3)
            make.width.height.equalTo(36)
        }
        uploadPhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarButton.snp.bottom).offset(7)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }

        scrollView.showsVerticalScrollIndicator = false
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(uploadPhotoLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(saveButton.snp.top).offset(-18)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        let nameLabel = makeFieldLabel(text: "Name")
        let birthdayLabel = makeFieldLabel(text: "Birthday")
        let genderLabel = makeFieldLabel(text: "Gender")
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(birthdayLabel)
        contentView.addSubview(birthdayTextField)
        contentView.addSubview(genderLabel)
        contentView.addSubview(maleButton)
        contentView.addSubview(femaleButton)

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        birthdayLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        birthdayTextField.snp.makeConstraints { make in
            make.top.equalTo(birthdayLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(48)
        }
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(birthdayTextField.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        maleButton.snp.makeConstraints { make in
            make.top.equalTo(genderLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.width.equalTo(168)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-24)
        }
        femaleButton.snp.makeConstraints { make in
            make.top.equalTo(maleButton)
            make.leading.equalTo(maleButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(maleButton)
        }

        avatarButton.addTarget(self, action: #selector(photoPickerTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(photoPickerTapped), for: .touchUpInside)
        maleButton.addTarget(self, action: #selector(maleTapped), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(femaleTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        birthdayTextField.delegate = self
        saveButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(44)
        }
    }

    private func makeFieldLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = AppFont.authLabel()
        label.textColor = AppTheme.textPrimary
        return label
    }

    private static func makeTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: AppTheme.textSecondary, .font: AppFont.authField()]
        )
        textField.font = AppFont.authField()
        textField.textColor = AppTheme.textPrimary
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        textField.leftViewMode = .always
        return textField
    }

    private func updateGenderButtons() {
        maleButton.setOptionSelected(selectedGenderIndex == 0)
        femaleButton.setOptionSelected(selectedGenderIndex == 1)
    }

    @objc private func photoPickerTapped() {
        let sheet = PhotoSourceSheetViewController()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        sheet.onSourceSelected = { [weak self] sourceType in
            self?.presentPicker(sourceType: sourceType)
        }
        present(sheet, animated: false)
    }

    private func presentBirthdayPicker() {
        let sheet = DatePickerSheetViewController()
        sheet.modalPresentationStyle = .overFullScreen
        sheet.modalTransitionStyle = .crossDissolve
        if let text = birthdayTextField.text,
           let date = CompleteProfileViewController.birthdayFormatter.date(from: text) {
            sheet.initialDate = date
        }
        sheet.onDateSelected = { [weak self] date in
            self?.birthdayTextField.text = CompleteProfileViewController.birthdayFormatter.string(from: date)
        }
        present(sheet, animated: false)
    }

    private static let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM / dd / yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private func presentPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func maleTapped() {
        selectedGenderIndex = 0
        updateGenderButtons()
    }

    @objc private func femaleTapped() {
        selectedGenderIndex = 1
        updateGenderButtons()
    }

    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter your name.")
            return
        }

        let gender = selectedGenderIndex == 0 ? "Male" : "Female"
        DataRepository.shared.completeProfile(
            name: name,
            avatar: "avatar_default",
            birthday: birthdayTextField.text ?? "",
            location: "",
            gender: gender
        )
        DataRepository.shared.setCurrentUserAvatarImage(selectedAvatarImage)
        AppRouter.shared.showMainTabBar()
    }
}

final class GenderOptionButton: UIControl {
    private let iconView = UIImageView(image: UIImage(named: "unselect")?.withRenderingMode(.alwaysOriginal))
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = AppTheme.textPrimary
        iconView.contentMode = .scaleAspectFit
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        addSubview(iconView)
        addSubview(titleLabel)
        accessibilityTraits = [.button]
        accessibilityLabel = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOptionSelected(_ selected: Bool) {
        backgroundColor = selected ? AppTheme.authButtonColor : .white
        let imageName = selected ? "select" : "unselect"
        iconView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        accessibilityTraits = selected ? [.button, .selected] : [.button]
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let iconSize: CGFloat = 16
        let gap: CGFloat = 8
        let titleSize = titleLabel.intrinsicContentSize
        let totalWidth = iconSize + gap + titleSize.width
        let startX = (bounds.width - totalWidth) / 2
        iconView.frame = CGRect(x: startX, y: (bounds.height - iconSize) / 2, width: iconSize, height: iconSize)
        titleLabel.frame = CGRect(x: iconView.frame.maxX + gap, y: 0, width: titleSize.width, height: bounds.height)
    }
}

final class PhotoSourceSheetViewController: UIViewController {
    var onSourceSelected: ((UIImagePickerController.SourceType) -> Void)?

    private let dimView = UIView()
    private let sheetView = UIView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload photo"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        view.addSubview(dimView)
        view.addSubview(sheetView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 24
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        sheetView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(248)
        }

        let libraryButton = makeActionButton(title: "Choose from Library", background: .white, titleColor: AppTheme.textPrimary)
        let cameraButton = makeActionButton(title: "Take Photo", background: .white, titleColor: AppTheme.textPrimary)
        let cancelButton = makeActionButton(title: "Cancel", background: .white, titleColor: AppTheme.textPrimary)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(libraryButton)
        sheetView.addSubview(cameraButton)
        sheetView.addSubview(cancelButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }
        libraryButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        cameraButton.snp.makeConstraints { make in
            make.top.equalTo(libraryButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(cameraButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        [libraryButton, cameraButton, cancelButton].forEach {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        }

        libraryButton.addTarget(self, action: #selector(libraryTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView.transform = CGAffineTransform(translationX: 0, y: sheetView.bounds.height)
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.sheetView.transform = .identity
        }
    }

    private func makeActionButton(title: String, background: UIColor, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = background
        button.layer.cornerRadius = 20
        return button
    }

    private func close(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.22, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.sheetView.bounds.height)
            self.dimView.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    @objc private func libraryTapped() {
        close { [weak self] in
            self?.onSourceSelected?(.photoLibrary)
        }
    }

    @objc private func cameraTapped() {
        close { [weak self] in
            self?.onSourceSelected?(.camera)
        }
    }

    @objc private func cancelTapped() {
        close()
    }
}

extension CompleteProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        if let image {
            selectedAvatarImage = image
            avatarButton.setImage(image, for: .normal)
            avatarButton.imageView?.contentMode = .scaleAspectFill
            avatarButton.clipsToBounds = true
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension CompleteProfileViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === birthdayTextField {
            presentBirthdayPicker()
            return false
        }
        return true
    }
}

final class DatePickerSheetViewController: UIViewController {
    var initialDate: Date?
    var onDateSelected: ((Date) -> Void)?

    private let dimView = UIView()
    private let sheetView = UIView()
    private let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        view.addSubview(dimView)
        view.addSubview(sheetView)
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

        sheetView.backgroundColor = .white
        sheetView.layer.cornerRadius = 24
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.clipsToBounds = true
        sheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(360)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Birthday"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = AppTheme.textPrimary
        titleLabel.textAlignment = .center

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        if let initialDate {
            datePicker.date = min(initialDate, datePicker.maximumDate ?? initialDate)
        } else if let maximumDate = datePicker.maximumDate {
            datePicker.date = maximumDate
        }

        let cancelButton = makeButton(title: "Cancel", background: .white, titleColor: AppTheme.textPrimary)
        let doneButton = makeButton(title: "Done", background: AppTheme.onboardingButtonColor, titleColor: AppTheme.textPrimary)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(datePicker)
        sheetView.addSubview(cancelButton)
        sheetView.addSubview(doneButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(28)
        }
        datePicker.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(216)
        }
        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-14)
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
        doneButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-14)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(12)
            $0.height.equalTo(44)
        }

        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = AppTheme.authFieldBorderColor.cgColor

        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sheetView.transform = CGAffineTransform(translationX: 0, y: sheetView.bounds.height)
        UIView.animate(withDuration: 0.28, delay: 0, options: [.curveEaseOut]) {
            self.sheetView.transform = .identity
        }
    }

    private func makeButton(title: String, background: UIColor, titleColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = background
        button.layer.cornerRadius = 20
        return button
    }

    private func close(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.22, animations: {
            self.sheetView.transform = CGAffineTransform(translationX: 0, y: self.sheetView.bounds.height)
            self.dimView.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    @objc private func cancelTapped() { close() }

    @objc private func doneTapped() {
        let date = datePicker.date
        let callback = onDateSelected
        close { callback?(date) }
    }
}
