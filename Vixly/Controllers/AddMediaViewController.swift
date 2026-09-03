import UIKit
import SnapKit
import PhotosUI
import UniformTypeIdentifiers
import AVKit

final class AddMediaViewController: UIViewController {
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = AppTheme.textPrimary
        return button
    }()
    private let titleLabel = PostFlowTitleLabel(text: "ADD MEDIA")
    private let subtitleLabel = PostFlowSubtitleLabel(text: "Choose 1–6 photos or one short video for today’s OOTD.")
    private let mediaCard = UIView()
    private let emptyPreviewView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.secondaryColor
        return view
    }()
    private let emptyLeftCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "#BED4D9").cgColor
        return view
    }()
    private let emptyRightCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "#BED4D9").cgColor
        return view
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = AppTheme.secondaryColor
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.register(PostMediaPickerCell.self, forCellWithReuseIdentifier: PostMediaPickerCell.reuseIdentifier)
        return view
    }()
    private let emptyTitleLabel: UILabel = {
        let label = UILabel(); label.text = "No media selected"; label.font = AppFont.subtitle(.bold); label.textAlignment = .center; return label
    }()
    private let emptySubtitleLabel: UILabel = {
        let label = UILabel(); label.text = "Camera or device library"; label.font = AppFont.caption(); label.textColor = AppTheme.textSecondary; label.textAlignment = .center; return label
    }()
    private let emptyIconView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "photo.on.rectangle"))
        view.tintColor = .white
        view.backgroundColor = AppTheme.textPrimary
        view.contentMode = .center
        view.layer.cornerRadius = 36
        return view
    }()
    private let chooseButton = PostFlowButton(title: "Choose photo / video", filled: true)
    private let rulesLabel: UILabel = {
        let label = UILabel(); label.text = "ⓘ   Photos: up to 6 · Video: one file · A cover is required."; label.font = AppFont.caption(); label.textColor = AppTheme.textSecondary; label.textAlignment = .center; label.backgroundColor = .white; label.layer.cornerRadius = 12; label.layer.borderWidth = 1; label.layer.borderColor = AppTheme.authFieldBorderColor.cgColor; label.clipsToBounds = true; return label
    }()
    private let cancelButton = PostFlowButton(title: "Cancel", filled: false)
    private let nextButton = PostFlowButton(title: "Next: Items", filled: true)
    private var media: [PostMedia] = []
    private var cameraMediaType: MediaType = .photo

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.backgroundColor
        media = PostDraftManager.shared.media
        setupUI(); updateMediaState()
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        chooseButton.addTarget(self, action: #selector(chooseTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupUI() {
        let progress = PostProgressView(currentStep: 0)
        let topNavigationBackground = UIView()
        topNavigationBackground.backgroundColor = .white
        let bottomBar = UIView(); bottomBar.backgroundColor = .white
        let bottomStack = UIStackView(arrangedSubviews: [cancelButton, nextButton]); bottomStack.axis = .horizontal; bottomStack.spacing = 8; bottomStack.distribution = .fillProportionally
        view.insertSubview(topNavigationBackground, at: 0)
        [closeButton, progress, titleLabel, subtitleLabel, mediaCard, rulesLabel, bottomBar].forEach(view.addSubview)
        mediaCard.addSubview(emptyPreviewView)
        mediaCard.addSubview(collectionView)
        [emptyLeftCard, emptyRightCard, emptyIconView].forEach(emptyPreviewView.addSubview)
        [emptyTitleLabel, emptySubtitleLabel, chooseButton].forEach(mediaCard.addSubview)
        bottomBar.addSubview(bottomStack)
        mediaCard.backgroundColor = .white; mediaCard.layer.cornerRadius = 22; mediaCard.clipsToBounds = true
        closeButton.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(12); $0.leading.equalToSuperview().offset(20); $0.width.height.equalTo(28) }
        progress.snp.makeConstraints { $0.top.equalTo(closeButton.snp.bottom).offset(12); $0.leading.trailing.equalToSuperview(); $0.height.equalTo(56) }
        topNavigationBackground.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview(); $0.bottom.equalTo(progress.snp.bottom) }
        titleLabel.snp.makeConstraints { $0.top.equalTo(progress.snp.bottom).offset(18); $0.leading.equalToSuperview().offset(15) }
        subtitleLabel.snp.makeConstraints { $0.top.equalTo(titleLabel.snp.bottom).offset(5); $0.leading.trailing.equalToSuperview().inset(15) }
        mediaCard.snp.makeConstraints { $0.top.equalTo(subtitleLabel.snp.bottom).offset(18); $0.leading.trailing.equalToSuperview().inset(15); $0.height.equalTo(348) }
        emptyPreviewView.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview(); $0.height.equalTo(228) }
        collectionView.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview(); $0.height.equalTo(228) }
        emptyLeftCard.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(34)
            make.centerY.equalToSuperview().offset(4)
            make.width.equalTo(108)
            make.height.equalTo(142)
        }
        emptyRightCard.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-28)
            make.centerY.equalToSuperview().offset(-2)
            make.width.equalTo(108)
            make.height.equalTo(142)
        }
        emptyLeftCard.transform = CGAffineTransform(rotationAngle: -.pi / 18)
        emptyRightCard.transform = CGAffineTransform(rotationAngle: .pi / 24)
        emptyIconView.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(72) }
        emptyTitleLabel.snp.makeConstraints { $0.top.equalTo(collectionView.snp.bottom).offset(14); $0.leading.trailing.equalToSuperview().inset(16) }
        emptySubtitleLabel.snp.makeConstraints { $0.top.equalTo(emptyTitleLabel.snp.bottom).offset(5); $0.leading.trailing.equalToSuperview().inset(16) }
        chooseButton.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(15); $0.bottom.equalToSuperview().offset(-14); $0.height.equalTo(44) }
        rulesLabel.snp.makeConstraints { $0.top.equalTo(mediaCard.snp.bottom).offset(12); $0.leading.trailing.equalToSuperview().inset(15); $0.height.equalTo(42) }
        bottomBar.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview(); $0.height.equalTo(78) }
        bottomStack.snp.makeConstraints { $0.top.equalToSuperview().offset(10); $0.leading.trailing.equalToSuperview().inset(15); $0.height.equalTo(44) }
        cancelButton.snp.makeConstraints { $0.width.equalTo(108) }
    }

    private func updateMediaState() {
        media = media.enumerated().map { PostMedia(id: $0.element.id, type: $0.element.type, url: $0.element.url, isCover: $0.offset == 0) }
        PostDraftManager.shared.media = media
        emptyTitleLabel.text = media.isEmpty ? "No media selected" : "\(media.count) media selected"
        emptyPreviewView.isHidden = !media.isEmpty
        collectionView.isHidden = media.isEmpty
        let canAddMedia = media.isEmpty || (media.first?.type != .video && media.count < 6)
        chooseButton.isEnabled = canAddMedia
        chooseButton.alpha = canAddMedia ? 1 : 0.45
        nextButton.isEnabled = !media.isEmpty; nextButton.alpha = media.isEmpty ? 0.45 : 1
        collectionView.reloadData()
    }

    @objc private func chooseTapped() { presentSourceSheet() }
    private func presentSourceSheet() {
        let sheet = PostMediaSourceSheetViewController(); sheet.modalPresentationStyle = .overFullScreen
        sheet.onAction = { [weak self] action in
            switch action { case .library: self?.presentLibrary(); case .photo: self?.presentCamera(type: .photo); case .video: self?.presentCamera(type: .video) }
        }
        present(sheet, animated: false)
    }
    private func presentLibrary() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .any(of: [.images, .videos]); configuration.selectionLimit = media.first?.type == .video ? 1 : max(1, 6 - media.count)
        let picker = PHPickerViewController(configuration: configuration); picker.delegate = self; present(picker, animated: true)
    }
    private func presentCamera(type: MediaType) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        cameraMediaType = type
        let picker = UIImagePickerController(); picker.sourceType = .camera; picker.mediaTypes = [type == .photo ? UTType.image.identifier : UTType.movie.identifier]; picker.videoQuality = .typeHigh; picker.delegate = self; present(picker, animated: true)
    }
    private func addPhoto(_ image: UIImage) {
        guard !media.contains(where: { $0.type == .video }), media.count < 6, let path = PostMediaStorage.saveImage(image) else { return }
        media.append(PostMedia(id: UUID().uuidString, type: .photo, url: path, isCover: media.isEmpty)); updateMediaState()
    }
    private func addVideo(from url: URL) {
        guard media.isEmpty, let path = PostMediaStorage.saveVideo(from: url) else { return }
        media = [PostMedia(id: UUID().uuidString, type: .video, url: path, isCover: true)]; updateMediaState()
    }
    private func showPreview(for media: PostMedia) {
        if media.type == .video {
            let vc = AVPlayerViewController(); vc.player = AVPlayer(url: URL(fileURLWithPath: media.url)); present(vc, animated: true) { vc.player?.play() }
        } else {
            let vc = PhotoPreviewViewController(image: PostMediaPreview.image(for: media)); vc.modalPresentationStyle = .fullScreen; present(vc, animated: true)
        }
    }
    @objc private func closeTapped() {
        let alert = CommonAlertView(title: "Discard Draft", message: "Are you sure you want to discard your draft?", cancelTitle: "Keep Editing", confirmTitle: "Discard")
        alert.onConfirm = { [weak self] in PostDraftManager.shared.clear(); self?.dismiss(animated: true) }; alert.show()
    }
    @objc private func nextTapped() { guard !media.isEmpty else { return }; PostDraftManager.shared.transition(to: .itemBreakdown); navigationController?.pushViewController(ItemBreakdownViewController(), animated: true) }
}

extension AddMediaViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { media.count + ((media.first?.type != .video && media.count < 6) ? 1 : 0) }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostMediaPickerCell.reuseIdentifier, for: indexPath) as! PostMediaPickerCell
        if indexPath.item == media.count { cell.configureAsAdd() }
        else { let item = media[indexPath.item]; cell.configure(media: item); cell.onDelete = { [weak self] in self?.media.remove(at: indexPath.item); self?.updateMediaState() } }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { indexPath.item == media.count ? presentSourceSheet() : showPreview(for: media[indexPath.item]) }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize { CGSize(width: 140, height: 188) }
}

extension AddMediaViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            let provider = result.itemProvider
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                guard media.isEmpty else { continue }
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, _ in guard let url else { return }; let path = PostMediaStorage.saveVideo(from: url); DispatchQueue.main.async { guard let path else { return }; self?.media = [PostMedia(id: UUID().uuidString, type: .video, url: path, isCover: true)]; self?.updateMediaState() } }; break
            } else if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in guard let image = object as? UIImage else { return }; DispatchQueue.main.async { self?.addPhoto(image) } }
            }
        }
    }
}

extension AddMediaViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) { if cameraMediaType == .video, let url = info[.mediaURL] as? URL { addVideo(from: url) } else if let image = info[.originalImage] as? UIImage { addPhoto(image) }; picker.dismiss(animated: true) }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
}

final class PostMediaPickerCell: UICollectionViewCell {
    static let reuseIdentifier = "PostMediaPickerCell"; var onDelete: (() -> Void)?
    private let imageView = UIImageView(); private let iconView = UIImageView(); private let deleteButton = UIButton(type: .system)
    override init(frame: CGRect) {
        super.init(frame: frame); contentView.layer.cornerRadius = 12; contentView.clipsToBounds = true; imageView.contentMode = .scaleAspectFill; imageView.clipsToBounds = true
        [imageView, iconView, deleteButton].forEach(contentView.addSubview); imageView.snp.makeConstraints { $0.edges.equalToSuperview() }; iconView.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(36) }; deleteButton.snp.makeConstraints { $0.top.trailing.equalToSuperview().inset(8); $0.width.height.equalTo(28) }
        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal); deleteButton.tintColor = .white; deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.55); deleteButton.layer.cornerRadius = 8; deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func prepareForReuse() { super.prepareForReuse(); onDelete = nil }
    func configure(media: PostMedia) { imageView.image = PostMediaPreview.image(for: media); imageView.backgroundColor = AppTheme.secondaryColor; iconView.image = media.type == .video ? UIImage(systemName: "play.circle.fill") : nil; iconView.tintColor = .white; deleteButton.isHidden = false }
    func configureAsAdd() { imageView.image = nil; imageView.backgroundColor = UIColor.white.withAlphaComponent(0.7); iconView.image = UIImage(systemName: "plus"); iconView.tintColor = AppTheme.textPrimary; deleteButton.isHidden = true }
    @objc private func deleteTapped() { onDelete?() }
}

final class PhotoPreviewViewController: UIViewController {
    private let image: UIImage?
    init(image: UIImage?) { self.image = image; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func viewDidLoad() { super.viewDidLoad(); view.backgroundColor = .black; let imageView = UIImageView(image: image); imageView.contentMode = .scaleAspectFit; view.addSubview(imageView); imageView.snp.makeConstraints { $0.edges.equalToSuperview() }; let close = UIButton(type: .system); close.setImage(UIImage(systemName: "xmark"), for: .normal); close.tintColor = .white; close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside); view.addSubview(close); close.snp.makeConstraints { $0.top.equalTo(view.safeAreaLayoutGuide).offset(12); $0.trailing.equalToSuperview().offset(-16); $0.width.height.equalTo(36) } }
    @objc private func closeTapped() { dismiss(animated: true) }
}

final class PostFlowButton: UIButton {
    init(title: String, filled: Bool) { super.init(frame: .zero); setTitle(title, for: .normal); titleLabel?.font = AppFont.caption(.bold); setTitleColor(AppTheme.textPrimary, for: .normal); backgroundColor = filled ? AppTheme.primaryColor : .white; layer.cornerRadius = 22; layer.borderWidth = filled ? 0 : 1; layer.borderColor = AppTheme.authFieldBorderColor.cgColor }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
final class PostFlowTitleLabel: UILabel { init(text: String) { super.init(frame: .zero); self.text = text; font = UIFont(name: "Impact", size: 40) ?? AppFont.h1(.black); textColor = AppTheme.textPrimary }; required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") } }
final class PostFlowSubtitleLabel: UILabel { init(text: String) { super.init(frame: .zero); self.text = text; font = AppFont.caption(); textColor = AppTheme.textSecondary; numberOfLines = 0 }; required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") } }

final class PostProgressView: UIView {
    private var connectorViews: [UIView] = []
    private var iconViews: [UIImageView] = []

    init(currentStep: Int) {
        super.init(frame: .zero)
        backgroundColor = .white

        let names = ["Media", "Items", "Details", "Review"]
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        for _ in 0..<3 {
            let connector = UIView()
            connector.backgroundColor = AppTheme.authFieldBorderColor
            insertSubview(connector, belowSubview: stack)
            connectorViews.append(connector)
        }

        for index in 0..<4 {
            let column = UIStackView()
            column.axis = .vertical
            column.alignment = .center
            column.spacing = 3
            column.isLayoutMarginsRelativeArrangement = true
            column.layoutMargins = UIEdgeInsets(top: 11, left: 0, bottom: 0, right: 0)

            let icon = UIImageView()
            icon.contentMode = .scaleAspectFit
            icon.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }
            icon.image = index < currentStep
                ? Self.completedImage()
                : Self.numberImage(index + 1, active: index == currentStep)
            iconViews.append(icon)

            let label = UILabel()
            label.text = names[index]
            label.font = .systemFont(ofSize: 10, weight: .semibold)
            label.textColor = index <= currentStep ? AppTheme.textPrimary : AppTheme.textQuaternary

            column.addArrangedSubview(icon)
            column.addArrangedSubview(label)
            stack.addArrangedSubview(column)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        for (index, connector) in connectorViews.enumerated() {
            guard index + 1 < iconViews.count else { continue }
            let startIcon = iconViews[index]
            let endIcon = iconViews[index + 1]
            let startCenter = startIcon.convert(CGPoint(x: startIcon.bounds.midX, y: startIcon.bounds.midY), to: self)
            let endCenter = endIcon.convert(CGPoint(x: endIcon.bounds.midX, y: endIcon.bounds.midY), to: self)
            let gap = startIcon.bounds.width / 2 + 18
            let startX = startCenter.x + gap
            let endX = endCenter.x - gap
            connector.frame = CGRect(x: startX, y: startCenter.y - 0.5, width: max(0, endX - startX), height: 1)
        }
    }

    private static func numberImage(_ number: Int, active: Bool) -> UIImage? {
        UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28)).image { context in
            let color = active ? AppTheme.textPrimary : UIColor.white
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 26, height: 26))
            if !active {
                AppTheme.authFieldBorderColor.setStroke()
                context.cgContext.strokeEllipse(in: CGRect(x: 1.5, y: 1.5, width: 25, height: 25))
            }
            let text = "\(number)" as NSString
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .bold),
                .foregroundColor: active ? UIColor.white : AppTheme.textTertiary
            ]
            let size = text.size(withAttributes: attributes)
            text.draw(at: CGPoint(x: (28 - size.width) / 2, y: (28 - size.height) / 2), withAttributes: attributes)
        }
    }

    private static func completedImage() -> UIImage? {
        UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28)).image { context in
            AppTheme.primaryColor.setFill()
            context.cgContext.fillEllipse(in: CGRect(x: 1, y: 1, width: 26, height: 26))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 8, y: 14))
            path.addLine(to: CGPoint(x: 12, y: 18))
            path.addLine(to: CGPoint(x: 20, y: 10))
            path.lineWidth = 2
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            AppTheme.textPrimary.setStroke()
            path.stroke()
        }
    }
}

final class PostMediaSourceSheetViewController: UIViewController {
    enum Action { case library, photo, video }
    var onAction: ((Action) -> Void)?
    private let sheet = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 24
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sheet)
        sheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(300)
        }

        let title = UILabel()
        title.text = "Add media"
        title.font = AppFont.h3(.bold)
        title.textAlignment = .center
        sheet.addSubview(title)
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }

        let buttons = [
            actionButton("Choose from Library", 0),
            actionButton("Take Photo", 1),
            actionButton("Record Video", 2),
            actionButton("Cancel", 3)
        ]
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        sheet.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); sheet.transform = CGAffineTransform(translationX: 0, y: sheet.bounds.height); UIView.animate(withDuration: 0.25) { self.sheet.transform = .identity } }
    private func actionButton(_ title: String, _ tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.backgroundColor = .white
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.titleLabel?.font = AppFont.body(.semibold)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        return button
    }

    @objc private func tapped(_ sender: UIButton) {
        let callback = onAction
        guard sender.tag < 3 else {
            dismiss(animated: false)
            return
        }
        let action: Action = sender.tag == 0 ? .library : sender.tag == 1 ? .photo : .video
        dismiss(animated: false) { callback?(action) }
    }
}
