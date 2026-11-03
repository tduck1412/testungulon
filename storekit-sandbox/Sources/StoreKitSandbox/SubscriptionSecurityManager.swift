import Foundation
import StoreKit

/// Quản lý xác thực bản quyền mật mã qua Apple StoreKit 2
/// Tuân thủ nguyên lý Zero-Trust: Chỉ cấp quyền khi chữ ký JWS của Apple được xác thực hợp lệ.
@MainActor
public final class SubscriptionSecurityManager: ObservableObject {

    public static let shared = SubscriptionSecurityManager()

    // Danh sách định danh sản phẩm chuẩn
    public enum ProductID {
        public static let goldYearly = "locket_1600_1y"
        public static let goldMonthly = "locket_gold_monthly"
        public static let filterPack10 = "com.locket.Locket.FilterPack_10Photos_400"
        public static let filterPack20 = "com.locket.Locket.FilterPack_20Photos_500"
    }

    // Trạng thái quyền hạn đã được xác thực mã hóa
    @Published public private(set) var hasGoldAccess: Bool = false
    @Published public private(set) var hasEffectPackAccess: Bool = false
    @Published public private(set) var remainingEffectPhotos: Int = 0
    @Published public private(set) var purchasedProductIDs: Set<String> = []

    // Task theo dõi giao dịch thời gian thực từ StoreKit
    private var updateListenerTask: Task<Void, Never>?

    private init() {
        self.updateListenerTask = listenForTransactionUpdates()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // =========================================================================
    // 1. LẮNG NGHE GIAO DỊCH REAL-TIME TỪ APPLE (Transaction.updates)
    // =========================================================================
    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.verifyTransactionSignature(result)
                    await self.handleVerifiedTransaction(transaction)
                    await transaction.finish()
                } catch {
                    print("[StoreKit2 Security] Phát hiện chữ ký không hợp lệ trong Transaction.updates: \(error.localizedDescription)")
                }
            }
        }
    }

    // =========================================================================
    // 2. XÁC THỰC MẬT MÃ CHỮ KÝ SỐ JWS (Cryptographic Verification)
    // =========================================================================
    /// Xác thực chữ ký số JWS được ký bởi Apple Root Certificate.
    /// Nếu gói tin bị MITM sửa đổi hoặc sai lệch khóa bí mật, hàm sẽ ném ra VerificationResult.unverified.
    public func verifyTransactionSignature<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safeObject):
            // Chữ ký JWS hoàn toàn nguyên bản từ Apple, không bị giả mạo
            return safeObject
        case .unverified(let unverifiedObject, let verificationError):
            // DỮ LIỆU BỊ SỬA ĐỔI HOẶC CHỮ KÝ SAI LỆCH
            throw SecurityError.invalidJWSSignature(
                error: verificationError,
                details: "Giao dịch không vượt qua kiểm tra mật mã của Apple StoreKit."
            )
        }
    }

    // =========================================================================
    // 3. ĐỒNG BỘ TOÀN BỘ QUYỀN HẠN CỤC BỘ (Transaction.currentEntitlements)
    // =========================================================================
    /// Quét toàn bộ quyền hạn đang hoạt động trên thiết bị.
    /// Tự động thu hồi nếu người dùng hết hạn hoặc đã hoàn tiền (Refund).
    public func refreshEntitlements() async {
        var activeGold = false
        var activeEffect = false
        var activeIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try verifyTransactionSignature(result)

                // Kiểm tra xem giao dịch có bị Apple thu hồi (Revoke/Refund) hay không
                guard transaction.revocationDate == nil else {
                    print("[StoreKit2 Security] Giao dịch \(transaction.productID) đã bị thu hồi/hoàn tiền.")
                    continue
                }

                // Kiểm tra thời hạn hết hạn đối với gói thuê bao tự động gia hạn
                if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                    print("[StoreKit2 Security] Thuê bao \(transaction.productID) đã hết hạn vào \(expirationDate).")
                    continue
                }

                activeIDs.insert(transaction.productID)

                if transaction.productID == ProductID.goldYearly || transaction.productID == ProductID.goldMonthly {
                    activeGold = true
                }

                if transaction.productID == ProductID.filterPack10 || transaction.productID == ProductID.filterPack20 {
                    activeEffect = true
                }
            } catch {
                print("[StoreKit2 Security] Từ chối cấp quyền: Chữ ký số JWS không hợp lệ.")
            }
        }

        self.hasGoldAccess = activeGold
        self.hasEffectPackAccess = activeEffect
        self.purchasedProductIDs = activeIDs
    }

    // =========================================================================
    // 4. KIỂM SOÁT HÀNH VI CHỤP ẢNH KÈM FILTER (Post-Capture Authorization Gating)
    // =========================================================================
    /// Kiểm tra quyền trước khi giải phóng ảnh hoặc gửi Moment có gắn Filter
    public func canSendMomentWithFilter() -> Bool {
        // Nguyên tắc cấp phép: Có gói Gold HOẶC còn lượt trong gói Effect Pack
        if hasGoldAccess {
            return true
        }

        if hasEffectPackAccess && remainingEffectPhotos > 0 {
            return true
        }

        return false
    }

    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        await refreshEntitlements()
    }

    public enum SecurityError: LocalizedError {
        case invalidJWSSignature(error: VerificationResult<Transaction>.VerificationError, details: String)

        public var errorDescription: String? {
            switch self {
            case .invalidJWSSignature(_, let details):
                return details
            }
        }
    }
}
