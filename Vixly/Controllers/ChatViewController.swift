import UIKit
import SnapKit
import PhotosUI
import UniformTypeIdentifiers
import AVFoundation

class ChatViewController: BaseViewController {
    
    private let userId: String
    private var messages: [Message] = []
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var isRecording = false
    private var recordPermissionGranted = false
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var inputBarBottomConstraint: Constraint?

    private let chatHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let chatHeaderSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.authFieldBorderColor
        return view
    }()
    
    private let messagesStackView = UIStackView()
    
    private let inputBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let imageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = AppTheme.textSecondary
        return button
    }()
    
    private let voiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic"), for: .normal)
        button.tintColor = AppTheme.textSecondary
        return button
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Message"
        tf.font = AppFont.caption()
        tf.textColor = AppTheme.textPrimary
        tf.backgroundColor = AppTheme.backgroundColor
        tf.layer.cornerRadius = 21
        tf.layer.borderWidth = 1
        tf.layer.borderColor = AppTheme.authFieldBorderColor.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.backgroundColor = AppTheme.primaryColor
        button.layer.cornerRadius = 25
        button.isEnabled = false
        return button
    }()
    
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        loadData()
        addObservers()
        recordPermissionGranted = AVAudioSession.sharedInstance().recordPermission == .granted
        
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(voiceTouchDown), for: .touchDown)
        voiceButton.addTarget(self, action: #selector(voiceTouchUp), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(voiceTouchUp), for: .touchUpOutside)
        voiceButton.addTarget(self, action: #selector(voiceTouchUp), for: .touchCancel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigationBar() {
        guard let user = DataRepository.shared.getUser(byId: userId) else { return }

        navigationController?.setNavigationBarHidden(true, animated: false)
        let isFirstSetup = chatHeaderView.superview == nil
        chatHeaderView.subviews
            .filter { $0 !== chatHeaderSeparator }
            .forEach { $0.removeFromSuperview() }
        if chatHeaderView.superview == nil {
            view.addSubview(chatHeaderView)
            chatHeaderView.addSubview(chatHeaderSeparator)
        }

        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.textPrimary
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        chatHeaderView.addSubview(backButton)

        let avatarView = UIImageView()
        avatarView.backgroundColor = AppTheme.secondaryColor
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        avatarView.image = DataRepository.shared.avatarImage(for: user) ?? UIImage(named: user.avatar)
        chatHeaderView.addSubview(avatarView)

        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.spacing = 1
        let nameLabel = UILabel()
        nameLabel.text = "@" + user.name.lowercased().replacingOccurrences(of: " ", with: ".")
        nameLabel.font = AppFont.subtitle(.bold)
        nameLabel.textColor = AppTheme.textPrimary
        titleStack.addArrangedSubview(nameLabel)
        chatHeaderView.addSubview(titleStack)

        let voiceCallButton = headerButton(image: UIImage(named: "phone") ?? UIImage(systemName: "phone"), action: #selector(voiceCallTapped))
        let videoCallButton = headerButton(image: UIImage(named: "video") ?? UIImage(systemName: "video"), action: #selector(videoCallTapped))
        let moreButton = headerButton(image: UIImage(systemName: "ellipsis"), action: #selector(moreTapped))
        [voiceCallButton, videoCallButton, moreButton].forEach(chatHeaderView.addSubview)

        if isFirstSetup {
            chatHeaderView.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(88)
            }
            chatHeaderSeparator.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(1)
            }
        }
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(64)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        titleStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(voiceCallButton.snp.leading).offset(-12)
        }
        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        videoCallButton.snp.makeConstraints { make in
            make.trailing.equalTo(moreButton.snp.leading).offset(-17)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        voiceCallButton.snp.makeConstraints { make in
            make.trailing.equalTo(videoCallButton.snp.leading).offset(-17)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
    }

    private func headerButton(image: UIImage?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = AppTheme.textPrimary
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        scrollView.backgroundColor = AppTheme.backgroundColor
        contentView.backgroundColor = AppTheme.backgroundColor
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(messagesStackView)
        
        view.addSubview(inputBar)
        inputBar.addSubview(imageButton)
        inputBar.addSubview(voiceButton)
        inputBar.addSubview(textField)
        inputBar.addSubview(sendButton)
        
        messagesStackView.axis = .vertical
        messagesStackView.spacing = 12
        messagesStackView.alignment = .fill
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(chatHeaderView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar.snp.top)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        messagesStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            self.inputBarBottomConstraint = make.bottom.equalToSuperview().constraint
            make.height.equalTo(76)
        }
        
        imageButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview().offset(-5)
            make.width.height.equalTo(28)
        }
        
        voiceButton.snp.makeConstraints { make in
            make.left.equalTo(imageButton.snp.right).offset(22)
            make.centerY.equalToSuperview().offset(-5)
            make.width.height.equalTo(28)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(voiceButton.snp.right).offset(13)
            make.centerY.equalToSuperview().offset(-5)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.height.equalTo(42)
        }
        
        sendButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-9)
            make.centerY.equalToSuperview().offset(-5)
            make.width.height.equalTo(50)
        }
        let separator = UIView()
        separator.backgroundColor = AppTheme.authFieldBorderColor
        inputBar.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }

        if #available(iOS 15.0, *) {
            inputBarBottomConstraint?.deactivate()
            inputBar.snp.makeConstraints { make in
                make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            }
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadData(scrollToLatest: Bool = false) {
        messages = DataRepository.shared.getMessages(for: "conv_\(userId)").reversed()
        reloadMessages(scrollToLatest: scrollToLatest)
    }
    
    private func reloadMessages(scrollToLatest: Bool = false) {
        for subview in messagesStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for message in messages {
            let bubble = ChatMessageBubble(message: message)
            let isFromMe = message.senderId == DataRepository.shared.currentUser?.id
            
            let container = UIView()
            container.addSubview(bubble)
            
            if isFromMe {
                bubble.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.right.equalToSuperview()
                    make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
                }
            } else {
                bubble.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.left.equalToSuperview()
                    make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
                }
            }

            messagesStackView.addArrangedSubview(container)
        }

        guard scrollToLatest else { return }
        // The stack view's content size is updated during the next layout pass.
        // Scroll after that pass so the newly sent message is actually visible.
        DispatchQueue.main.async { [weak self] in
            self?.scrollToLatest(animated: true)
        }
    }

    private func scrollToLatest(animated: Bool) {
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()
        let bottomOffset = max(
            -scrollView.adjustedContentInset.top,
            scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
        )
        scrollView.setContentOffset(CGPoint(x: 0, y: bottomOffset), animated: animated)
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(messageSent), name: .messageSent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdated), name: .userProfileUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func messageSent() {
        loadData(scrollToLatest: true)
    }

    @objc private func profileUpdated() {
        setupNavigationBar()
    }

    @objc private func keyboardWillChange(_ notification: Notification) {
        if #available(iOS 15.0, *) { return }
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let frameInView = view.convert(keyboardFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - frameInView.minY)
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveValue = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue ?? 7
        let options = UIView.AnimationOptions(rawValue: UInt(curveValue << 16))
        inputBarBottomConstraint?.update(offset: -overlap)
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, options]) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func textChanged() {
        sendButton.isEnabled = !(textField.text?.isEmpty ?? true)
    }
    
    @objc private func sendTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        guard DataRepository.shared.isLoggedIn else { return }
        DataRepository.shared.sendMessage(to: userId, content: text)
        textField.text = ""
        sendButton.isEnabled = false
    }

    @objc private func imageTapped() {
        let sheet = ChatMediaSourceSheetViewController()
        sheet.onChoice = { [weak self] choice in
            if choice == .camera { self?.presentImagePicker(source: .camera) }
            else { self?.presentPhotoLibrary() }
        }
        sheet.modalPresentationStyle = .overFullScreen
        present(sheet, animated: false)
    }

    private func presentPhotoLibrary() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images; config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config); picker.delegate = self; present(picker, animated: true)
    }

    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }
        let picker = UIImagePickerController(); picker.sourceType = source; picker.mediaTypes = [UTType.image.identifier]; picker.delegate = self; present(picker, animated: true)
    }

    @objc private func voiceTouchDown() {
        guard recordPermissionGranted, !isRecording else { return }
        startRecording()
    }

    @objc private func voiceTouchUp() {
        if isRecording {
            stopRecording()
            return
        }
        guard !recordPermissionGranted else { return }
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.recordPermissionGranted = granted
                if !granted { self?.voiceButton.tintColor = AppTheme.textSecondary }
            }
        }
    }

    private func startRecording() {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("voice_\(UUID().uuidString).m4a")
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .default)
        try? session.setActive(true)
        guard let recorder = try? AVAudioRecorder(url: url, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1]) else { return }
        guard recorder.record() else { return }
        audioRecorder = recorder
        recordingURL = url
        isRecording = true
        voiceButton.tintColor = AppTheme.textDanger
    }

    private func stopRecording() {
        guard let recorder = audioRecorder else { return }
        // Read the elapsed time before stopping; AVAudioRecorder may reset its
        // currentTime after stop() has completed.
        let recordedDuration = recorder.currentTime
        recorder.stop()
        audioRecorder = nil
        isRecording = false
        voiceButton.tintColor = AppTheme.textSecondary
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        guard let url = recordingURL else { return }
        guard let path = PostMediaStorage.saveAudio(from: url) else { return }
        let fileDuration = (try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path)))?.duration ?? 0
        let duration = fileDuration > 0 ? fileDuration : recordedDuration
        DataRepository.shared.sendMessage(to: userId, content: path, type: .voice, duration: duration)
    }
    
    @objc private func voiceCallTapped() {
        let voiceCallVC = VoiceCallViewController(userId: userId, isIncoming: false)
        voiceCallVC.modalPresentationStyle = .fullScreen
        present(voiceCallVC, animated: true)
    }
    
    @objc private func videoCallTapped() {
        let videoCallVC = VideoCallViewController(userId: userId, isIncoming: false)
        videoCallVC.modalPresentationStyle = .fullScreen
        present(videoCallVC, animated: true)
    }
    
    // MARK: - O-05 More Options
    @objc private func moreTapped() {
        let sheet = ReportBlockSheetViewController()
        sheet.onAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .report:
                let reportVC = ReportViewController(targetUserId: self.userId, postId: nil, source: "Chat")
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
}

extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage, let path = PostMediaStorage.saveImage(image) else { return }
            DispatchQueue.main.async { self?.sendImage(path: path) }
        }
    }
    private func sendImage(path: String) { DataRepository.shared.sendMessage(to: userId, content: path, type: .image) }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) { if let image = info[.originalImage] as? UIImage, let path = PostMediaStorage.saveImage(image) { sendImage(path: path) }; picker.dismiss(animated: true) }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
}

final class ChatMediaSourceSheetViewController: UIViewController {
    enum Choice { case library, camera }
    var onChoice: ((Choice) -> Void)?
    private let sheet = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        sheet.backgroundColor = .white
        sheet.layer.cornerRadius = 24
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(sheet)
        sheet.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(260)
        }

        let title = UILabel()
        title.text = "Send photo"
        title.font = AppFont.h3(.bold)
        title.textAlignment = .center
        sheet.addSubview(title)
        title.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(28)
        }

        let buttons = [
            button("Choose from Library", 0),
            button("Take Photo", 1),
            button("Cancel", 2)
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
    private func button(_ title: String, _ tag: Int) -> UIButton {
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
        let callback = onChoice
        guard sender.tag < 2 else {
            dismiss(animated: false)
            return
        }
        let choice: Choice = sender.tag == 1 ? .camera : .library
        dismiss(animated: false) { callback?(choice) }
    }
}

final class ChatMessageBubble: UIView {
    private let message: Message
    private let timeLabel = UILabel()
    private let textLabel = UILabel()
    private let mediaImageView = UIImageView()
    private let playButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let durationLabel = UILabel()
    private var player: AVAudioPlayer?
    private var timer: Timer?
    init(message: Message) {
        self.message = message; super.init(frame: .zero)
        let isFromMe = message.senderId == DataRepository.shared.currentUser?.id
        backgroundColor = isFromMe ? AppTheme.secondaryColor : .white; layer.cornerRadius = 16
        timeLabel.font = .systemFont(ofSize: 9, weight: .regular); timeLabel.textColor = AppTheme.textTertiary; let formatter = DateFormatter(); formatter.dateFormat = "HH:mm"; timeLabel.text = formatter.string(from: message.createdAt); addSubview(timeLabel)
        switch message.type {
        case .text:
            textLabel.font = .systemFont(ofSize: 13, weight: .regular); textLabel.numberOfLines = 0; textLabel.text = message.content; addSubview(textLabel); textLabel.snp.makeConstraints { $0.top.leading.trailing.equalToSuperview().inset(14); $0.bottom.equalTo(timeLabel.snp.top).offset(-4) }
        case .image:
            let image = UIImage(contentsOfFile: message.content)
            mediaImageView.image = image
            mediaImageView.contentMode = .scaleAspectFit
            mediaImageView.clipsToBounds = true
            mediaImageView.layer.cornerRadius = 12
            addSubview(mediaImageView)
            let imageWidth: CGFloat = 210
            let imageRatio = image.map { $0.size.height / max($0.size.width, 1) } ?? 0.75
            mediaImageView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview().inset(8)
                $0.width.equalTo(imageWidth)
                $0.height.equalTo(imageWidth * imageRatio)
                $0.bottom.equalTo(timeLabel.snp.top).offset(-6)
            }
        case .voice:
            layer.cornerRadius = 8
            // Reserve enough horizontal space for a usable progress track
            // between the play control and the total-duration label.
            snp.makeConstraints { $0.width.equalTo(160) }
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal); playButton.tintColor = .white; playButton.backgroundColor = AppTheme.textPrimary; playButton.layer.cornerRadius = 16; playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside); addSubview(playButton); addSubview(progressView); progressView.progressTintColor = AppTheme.textPrimary; progressView.trackTintColor = UIColor.white.withAlphaComponent(0.65); playButton.snp.makeConstraints { $0.leading.equalToSuperview().offset(12); $0.top.equalToSuperview().offset(12); $0.width.height.equalTo(32); $0.bottom.equalTo(timeLabel.snp.top).offset(-8) }; progressView.snp.makeConstraints { $0.leading.equalTo(playButton.snp.trailing).offset(10); $0.trailing.equalToSuperview().offset(-12); $0.centerY.equalTo(playButton); $0.height.equalTo(3) }
            durationLabel.text = formattedDuration(totalAudioDuration())
            durationLabel.font = .systemFont(ofSize: 10, weight: .regular)
            durationLabel.textColor = AppTheme.textPrimary
            durationLabel.textAlignment = .right
            addSubview(durationLabel)
            durationLabel.snp.makeConstraints {
                $0.trailing.equalToSuperview().offset(-12)
                $0.centerY.equalTo(playButton)
                $0.width.equalTo(34)
            }
            progressView.snp.remakeConstraints {
                $0.leading.equalTo(playButton.snp.trailing).offset(10)
                $0.trailing.equalTo(durationLabel.snp.leading).offset(-10)
                $0.centerY.equalTo(playButton)
                $0.height.equalTo(3)
            }
        default: break
        }
        timeLabel.snp.makeConstraints { $0.trailing.equalToSuperview().offset(-12); $0.bottom.equalToSuperview().offset(-8) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func playTapped() {
        if player?.isPlaying == true {
            player?.pause(); timer?.invalidate(); playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return
        }
        if let player {
            player.play()
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startProgressTimer()
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        guard let audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: message.content)) else { return }
        player = audioPlayer
        audioPlayer.delegate = self
        progressView.progress = 0
        audioPlayer.play()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        startProgressTimer()
    }

    private func startProgressTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let player = self.player else { return }
            self.progressView.progress = Float(player.currentTime / max(player.duration, 0.01))
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private func totalAudioDuration() -> TimeInterval {
        if let duration = message.duration, duration > 0 {
            return duration
        }
        return (try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: message.content)))?.duration ?? 0
    }
}

extension ChatMessageBubble: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) { timer?.invalidate(); progressView.progress = 1; playButton.setImage(UIImage(systemName: "play.fill"), for: .normal) }
}
