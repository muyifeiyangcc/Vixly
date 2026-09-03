import UIKit
import SnapKit
import WebKit

class WebViewController: BaseViewController {
    
    private let url: String
    private let pageTitle: String
    
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(url: String, pageTitle: String) {
        self.url = url
        self.pageTitle = pageTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = pageTitle
        setupBackButton()
        setupUI()
        loadURL()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Web content is pushed from both auth and signed-in flows. Ensure
        // the system navigation bar is visible for the page title and back
        // affordance even when the previous screen uses a custom header.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        
        webView.navigationDelegate = self
        
        webView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func loadURL() {
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        activityIndicator.startAnimating()
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
