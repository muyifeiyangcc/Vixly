import UIKit
import SnapKit

class LaunchScreenViewController: UIViewController {
    
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "VIXLY"
        label.font = .systemFont(ofSize: 48, weight: .black)
        label.textColor = AppTheme.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private let sloganLabel: UILabel = {
        let label = UILabel()
        label.text = "OOTD, Style & Chat"
        label.font = AppFont.body()
        label.textColor = AppTheme.textSecondary
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.proceedToNextScreen()
        }
    }
    
    private func setupUI() {
        view.addSubview(logoLabel)
        view.addSubview(sloganLabel)
        
        logoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        sloganLabel.snp.makeConstraints { make in
            make.top.equalTo(logoLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    private func proceedToNextScreen() {
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            AppRouter.shared.setupRootViewController(in: sceneDelegate.window ?? UIWindow())
        }
    }
}
