import UIKit

class AppRouter {
    static let shared = AppRouter()
    
    private init() {}
    
    var window: UIWindow?
    
    func setupRootViewController(in window: UIWindow) {
        self.window = window
        
        if !UserDefaults.standard.bool(forKey: "EULA_AGREED") {
            if DataRepository.shared.isLoggedIn {
                showMainTabBar()
            } else {
                showOnboarding()
            }
            showEULA()
        } else if DataRepository.shared.isLoggedIn {
            showMainTabBar()
        } else {
            showOnboarding()
        }
    }
    
    func showEULA() {
        let eulaVC = EULAViewController()
        eulaVC.modalPresentationStyle = .overFullScreen
        guard let rootViewController = window?.rootViewController else {
            window?.rootViewController = eulaVC
            return
        }

        DispatchQueue.main.async {
            guard rootViewController.presentedViewController == nil else { return }
            rootViewController.present(eulaVC, animated: false)
        }
    }
    
    func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        let navigationController = UINavigationController(rootViewController: onboardingVC)
        navigationController.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = navigationController
    }
    
    func showMainTabBar(asGuest guest: Bool = false) {
        let tabBarVC = MainTabBarController(isGuest: guest)
        window?.rootViewController = tabBarVC
    }
    
    func showSignIn(from _: UIViewController) {
        // Guest-only sign-in prompts should return to the same landing page
        // shown after launch. The landing page then lets the user choose
        // email sign-in or sign-up after accepting the agreements.
        showOnboarding()
    }
    
    func handleLoginSuccess() {
        showMainTabBar()
    }
    
    func pushWebViewController(from viewController: UIViewController, url: String, title: String) {
        let webVC = WebViewController(url: url, pageTitle: title)
        webVC.hidesBottomBarWhenPushed = true
        viewController.navigationController?.pushViewController(webVC, animated: true)
    }
}
