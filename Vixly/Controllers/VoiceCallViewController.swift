import UIKit
import SnapKit
import AudioToolbox

class VoiceCallViewController: UIViewController {
    
    private let userId: String
    private let isIncoming: Bool
    private var isCalling = true
    private var isMuted = false
    private var isSpeakerOn = false
    private var callTimer: Timer?
    private var callDuration: TimeInterval = 0
    private var ringingTimer: Timer?
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = AppTheme.secondaryColor
        iv.layer.cornerRadius = 60
        iv.layer.borderWidth = 6
        iv.layer.borderColor = UIColor.white.cgColor
        iv.clipsToBounds = true
        return iv
    }()

    private let outerRing: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.textAccent.withAlphaComponent(0.28).cgColor
        view.layer.cornerRadius = 110
        return view
    }()

    private let middleRing: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = AppTheme.textAccent.withAlphaComponent(0.22).cgColor
        view.layer.cornerRadius = 82
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Impact", size: 42) ?? .systemFont(ofSize: 42, weight: .black)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.subtitle(.semibold)
        label.textColor = AppTheme.textSecondary
        label.textAlignment = .center
        return label
    }()

    private let callInfoLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.caption()
        label.textColor = AppTheme.textTertiary
        label.textAlignment = .center
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = AppFont.h3(.bold)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 32
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "mic.slash"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 32
        return button
    }()
    
    private let speakerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 32
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
        button.setTitle("Cancel call", for: .normal)
        button.titleLabel?.font = AppFont.authButton()
        button.setTitleColor(AppTheme.textPrimary, for: .normal)
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
        view.backgroundColor = AppTheme.secondaryColor
        setupUI()
        configureWithUser()
        
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        speakerButton.addTarget(self, action: #selector(speakerTapped), for: .touchUpInside)
        endButton.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRingingTone()
    }
    
    private func setupUI() {
        view.addSubview(outerRing)
        view.addSubview(middleRing)
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(statusLabel)
        view.addSubview(durationLabel)
        view.addSubview(callInfoLabel)
        view.addSubview(buttonsStack)
        
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 6
        buttonsStack.addArrangedSubview(endButton)
        buttonsStack.addArrangedSubview(cancelButton)
        
        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(72)
            make.width.height.equalTo(120)
        }

        outerRing.snp.makeConstraints { make in
            make.center.equalTo(avatarImageView)
            make.width.height.equalTo(220)
        }
        middleRing.snp.makeConstraints { make in
            make.center.equalTo(avatarImageView)
            make.width.height.equalTo(164)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(54)
            make.left.right.equalToSuperview().inset(24)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(24)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(24)
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(24)
        }

        callInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
        }
        
        buttonsStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        
        endButton.snp.makeConstraints { make in
            make.width.height.equalTo(127)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(22)
        }
    }
    
    private func configureWithUser() {
        if let user = DataRepository.shared.getUser(byId: userId) {
            nameLabel.text = user.name.uppercased()
            usernameLabel.text = "@\(user.name.lowercased().replacingOccurrences(of: " ", with: "."))"
            avatarImageView.image = DataRepository.shared.avatarImage(for: user)
        }
        
        if isIncoming {
            statusLabel.text = "Incoming call..."
            cancelButton.isHidden = true
        } else {
            let status = NSMutableAttributedString(string: "●  Calling...")
            status.addAttribute(.foregroundColor, value: AppTheme.textAccent, range: NSRange(location: 0, length: 1))
            statusLabel.attributedText = status
            callInfoLabel.text = "Voice call · Mutual follow"
            cancelButton.isHidden = false
            buttonsStack.isHidden = false
            muteButton.isHidden = true
            speakerButton.isHidden = true
        }
    }
    
    private func startRingingTone() {
        ringingTimer?.invalidate()
        AudioServicesPlaySystemSound(1007)
        ringingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in AudioServicesPlaySystemSound(1007) }
    }
    
    private func connectCall() {
        isCalling = false
        statusLabel.text = "Voice call · Mutual follow"
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
    
    @objc private func speakerTapped() {
        isSpeakerOn.toggle()
        if isSpeakerOn {
            speakerButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
            speakerButton.backgroundColor = .white
            speakerButton.tintColor = AppTheme.textPrimary
        } else {
            speakerButton.setImage(UIImage(systemName: "speaker.wave.2"), for: .normal)
            speakerButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            speakerButton.tintColor = .white
        }
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
        callTimer?.invalidate(); ringingTimer?.invalidate(); ringingTimer = nil
    }
}
