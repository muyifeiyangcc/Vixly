import UIKit
import SnapKit
import AudioToolbox

class VideoCallViewController: UIViewController {
    
    private let userId: String
    private let isIncoming: Bool
    private var isCalling = true
    private var isMuted = false
    private var isCameraOn = true
    private var isFrontCamera = true
    private var callTimer: Timer?
    private var callDuration: TimeInterval = 0
    private var ringingTimer: Timer?
    
    private let remoteVideoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    private let remoteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let localVideoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    private let youLiveLabel: UILabel = {
        let label = UILabel()
        label.text = "YOU LIVE"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Impact", size: 42) ?? .systemFont(ofSize: 42, weight: .black)
        label.textColor = .white
        return label
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = .white
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption(.bold)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        return label
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private let muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic.slash"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "video.slash"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let flipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 28
        return button
    }()
    
    private let endButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "red_call") ?? UIImage(systemName: "phone.down.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel video call", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
    
    init(userId: String, isIncoming: Bool) {
        self.userId = userId
        self.isIncoming = isIncoming
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        configureWithUser()
        
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        flipButton.addTarget(self, action: #selector(flipTapped), for: .touchUpInside)
        endButton.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRingingTone()
    }
    
    private func setupUI() {
        view.addSubview(remoteVideoView)
        remoteVideoView.addSubview(remoteImageView)
        view.addSubview(localVideoView)
        localVideoView.addSubview(youLiveLabel)
        
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(durationLabel)
        view.addSubview(statusLabel)
        view.addSubview(buttonsStack)
        
        buttonsStack.addArrangedSubview(endButton)
        buttonsStack.addArrangedSubview(cancelButton)
        
        remoteVideoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        remoteImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        localVideoView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(150)
        }
        
        youLiveLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-184)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(usernameLabel.snp.bottom).offset(16)
        }

        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(statusLabel.snp.bottom).offset(4)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(14)
        }
        
        endButton.snp.makeConstraints { make in
            make.width.height.equalTo(127)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(22)
        }
    }
    
    private func configureWithUser() {
        if let user = DataRepository.shared.getUser(byId: userId) {
            nameLabel.text = user.name.uppercased()
            usernameLabel.text = "@\(user.name.lowercased().replacingOccurrences(of: " ", with: "."))"
            if let image = DataRepository.shared.avatarImage(for: user) {
                remoteImageView.image = image
            }
        }
        
        if isIncoming {
            statusLabel.text = "Video calling..."
            cancelButton.isHidden = true
            buttonsStack.isHidden = true
        } else {
            statusLabel.text = "Video calling..."
            durationLabel.text = "Video call · Mutual follow"
            cancelButton.isHidden = false
            buttonsStack.isHidden = false
            localVideoView.isHidden = true
            muteButton.isHidden = true
            cameraButton.isHidden = true
            flipButton.isHidden = true
        }
    }
    
    private func startRingingTone() {
        ringingTimer?.invalidate()
        AudioServicesPlaySystemSound(1007)
        ringingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in AudioServicesPlaySystemSound(1007) }
    }
    
    private func connectCall() {
        isCalling = false
        statusLabel.isHidden = true
        durationLabel.isHidden = false
        cancelButton.isHidden = true
        buttonsStack.isHidden = false
        
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.callDuration += 1
            self.updateDurationLabel()
        }
    }
    
    private func updateDurationLabel() {
        let minutes = Int(callDuration) / 60
        let seconds = Int(callDuration) % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc private func muteTapped() {
        isMuted.toggle()
        if isMuted {
            muteButton.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
            muteButton.backgroundColor = .white
            muteButton.tintColor = AppTheme.textPrimary
        } else {
            muteButton.setImage(UIImage(systemName: "mic.slash"), for: .normal)
            muteButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            muteButton.tintColor = .white
        }
    }
    
    @objc private func cameraTapped() {
        isCameraOn.toggle()
        localVideoView.isHidden = !isCameraOn
        
        if isCameraOn {
            cameraButton.setImage(UIImage(systemName: "video.slash"), for: .normal)
            cameraButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            cameraButton.tintColor = .white
        } else {
            cameraButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
            cameraButton.backgroundColor = .white
            cameraButton.tintColor = AppTheme.textPrimary
        }
    }
    
    @objc private func flipTapped() {
        isFrontCamera.toggle()
    }
    
    @objc private func endTapped() {
        callTimer?.invalidate()
        callTimer = nil
        ringingTimer?.invalidate()
        ringingTimer = nil
        dismiss(animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        callTimer?.invalidate()
        ringingTimer?.invalidate()
        ringingTimer = nil
    }
}
