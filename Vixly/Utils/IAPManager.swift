import StoreKit

class IAPManager: NSObject {
    static let shared = IAPManager()
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    private var productsRequest: SKProductsRequest?
    private var products: [SKProduct] = []
    private var isLoading = false
    private var purchaseCompletion: ((Result<Bool, Error>) -> Void)?
    private var productsCompletion: (([SKProduct]) -> Void)?
    
    private let testProductIds: Set<String> = [
        "lvbsvhxcgcrvesor",
        "dxismgcwewhrtezo",
        "khtxlcejaxmqcsra",
        "yadwwvxspgxwlndb",
        "qnrcuelbtiuflyky",
        "ymohxnvpkqxutvab"
    ]
    
    var isTestEnvironment: Bool = true
    
    var productCount: Int {
        return products.count
    }
    
    func loadProducts(completion: @escaping ([SKProduct]) -> Void) {
        guard !isLoading else { return }
        
        productsCompletion = completion
        isLoading = true
        
        let productIds = testProductIds
        
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()
        productsRequest = request
    }
    
    func getProduct(at index: Int) -> SKProduct? {
        guard index < products.count else { return nil }
        return products[index]
    }
    
    func getProducts() -> [SKProduct] {
        return products
    }
    
    func purchaseProduct(at index: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard index < products.count else {
            completion(.failure(NSError(domain: "IAPError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid product"])))
            return
        }
        
        guard SKPaymentQueue.canMakePayments() else {
            completion(.failure(NSError(domain: "IAPError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Payments are disabled"])))
            return
        }
        
        purchaseCompletion = completion
        let product = products[index]
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func formatPrice(_ product: SKProduct) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: product.price) ?? "$0.99"
    }
    
    func getCoinAmount(for product: SKProduct) -> Int {
        let priceInCents = Int((product.price.doubleValue * 100).rounded())
        let coinAmountsByPrice: [Int: Int] = [
            99: 400,
            199: 800,
            499: 2_450,
            999: 5_150,
            1_299: 6_400,
            1_999: 10_800,
            2_499: 14_900,
            4_999: 29_400,
            7_999: 39_500,
            9_999: 63_700
        ]
        return coinAmountsByPrice[priceInCents] ?? 0
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.products = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
            self.productsCompletion?(self.products)
            self.productsCompletion = nil
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            self.productsCompletion?([])
            self.productsCompletion = nil
        }
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction: transaction)
            case .failed:
                handleFailed(transaction: transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func handlePurchased(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        
        let productId = transaction.payment.productIdentifier
        if let product = products.first(where: { $0.productIdentifier == productId }) {
            let coins = getCoinAmount(for: product)
            DataRepository.shared.addCoins(amount: coins)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.purchaseCompletion?(.success(true))
            self?.purchaseCompletion = nil
        }
    }
    
    private func handleFailed(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        
        let error = transaction.error ?? NSError(domain: "IAPError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Purchase failed"])
        
        DispatchQueue.main.async { [weak self] in
            self?.purchaseCompletion?(.failure(error))
            self?.purchaseCompletion = nil
        }
    }
}
