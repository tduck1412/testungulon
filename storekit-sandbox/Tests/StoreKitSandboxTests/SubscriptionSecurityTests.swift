import XCTest
import StoreKit
import StoreKitTest
@testable import StoreKitSandbox

/// Bộ kiểm thử bảo mật StoreKit 2 Sandbox sử dụng SKTestSession
/// Mô phỏng đầy đủ các kịch bản: Mua thành công, Xác thực JWS, Hết hạn thuê bao, và Hoàn tiền.
final class SubscriptionSecurityTests: XCTestCase {

    var session: SKTestSession!
    var manager: SubscriptionSecurityManager!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()

        // 1. Khởi tạo phiên StoreKit Sandbox cục bộ từ tệp cấu hình Products.storekit
        session = try SKTestSession(configurationFileNamed: "Products")
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()

        // 2. Tăng tốc thời gian kiểm thử (1 năm tương đương vài giây)
        session.timeRate = .oneSecondIsOneDay

        manager = SubscriptionSecurityManager.shared
        await manager.refreshEntitlements()
    }

    override func tearDown() async throws {
        session.clearTransactions()
        session = nil
        manager = nil
        try await super.tearDown()
    }

    // =========================================================================
    // TEST 1: TRẠNG THÁI KHỞI ĐẦU (TÀI KHOẢN FREE / CHƯA MUA)
    // =========================================================================
    @MainActor
    func test01_initialState_shouldBeDenied() async {
        XCTAssertFalse(manager.hasGoldAccess, "Tài khoản mới không được phép có Gold")
        XCTAssertFalse(manager.hasEffectPackAccess, "Tài khoản mới không được phép có Effect Pack")
        XCTAssertFalse(manager.canSendMomentWithFilter(), "Người dùng chưa mua không được phép gửi ảnh kèm filter")
    }

    // =========================================================================
    // TEST 2: MUA GÓI LOCKET GOLD NĂM VÀ XÁC THỰC CHỮ KÝ JWS THÀNH CÔNG
    // =========================================================================
    @MainActor
    func test02_purchaseGoldYearly_shouldVerifyJWSAndGrantAccess() async throws {
        // Thực hiện giao dịch mua trên Sandbox
        try await session.buyProduct(productIdentifier: SubscriptionSecurityManager.ProductID.goldYearly)

        // Quét lại quyền qua Transaction.currentEntitlements
        await manager.refreshEntitlements()

        XCTAssertTrue(manager.hasGoldAccess, "Quyền Locket Gold phải được kích hoạt sau khi mua")
        XCTAssertTrue(manager.purchasedProductIDs.contains(SubscriptionSecurityManager.ProductID.goldYearly))
        XCTAssertTrue(manager.canSendMomentWithFilter(), "Người dùng sở hữu Gold phải được gửi ảnh kèm filter tự do")
    }

    // =========================================================================
    // TEST 3: MUA GÓI EFFECT PACK (MUA LẺ BỘ LỌC NGÀY LỄ)
    // =========================================================================
    @MainActor
    func test03_purchaseEffectPack_shouldGrantEffectAccess() async throws {
        try await session.buyProduct(productIdentifier: SubscriptionSecurityManager.ProductID.filterPack10)

        await manager.refreshEntitlements()

        XCTAssertTrue(manager.hasEffectPackAccess, "Quyền Effect Pack phải được kích hoạt")
        XCTAssertFalse(manager.hasGoldAccess, "Mua Effect Pack không được tự động cấp quyền Locket Gold toàn cục")
    }

    // =========================================================================
    // TEST 4: THU HỒI QUYỀN KHI THUÊ BAO HẾT HẠN (SUBSCRIPTION EXPIRATION)
    // =========================================================================
    @MainActor
    func test04_subscriptionExpiration_shouldRevokeGoldAccess() async throws {
        // Mua gói năm
        try await session.buyProduct(productIdentifier: SubscriptionSecurityManager.ProductID.goldYearly)
        await manager.refreshEntitlements()
        XCTAssertTrue(manager.hasGoldAccess)

        // Ép thuê bao hết hạn trên Sandbox
        try session.expireSubscription(productIdentifier: SubscriptionSecurityManager.ProductID.goldYearly)

        // Quét lại quyền hạn
        await manager.refreshEntitlements()

        XCTAssertFalse(manager.hasGoldAccess, "Khi thuê bao hết hạn, quyền Gold phải lập tức bị thu hồi")
        XCTAssertFalse(manager.canSendMomentWithFilter(), "Hết hạn thuê bao không còn quyền gửi ảnh kèm filter")
    }

    // =========================================================================
    // TEST 5: THU HỒI QUYỀN KHI GIAO DỊCH BỊ HOÀN TIỀN (REFUND / CHARGEBACK)
    // =========================================================================
    @MainActor
    func test05_refundTransaction_shouldInvalidateEntitlementImmediately() async throws {
        // Mua gói năm
        let transaction = try await session.buyProduct(productIdentifier: SubscriptionSecurityManager.ProductID.goldYearly)
        await manager.refreshEntitlements()
        XCTAssertTrue(manager.hasGoldAccess)

        // Mô phỏng người dùng yêu cầu Apple hoàn tiền (Refund)
        try session.refundTransaction(identifier: UInt(transaction.id))

        // Quét lại quyền
        await manager.refreshEntitlements()

        XCTAssertFalse(manager.hasGoldAccess, "Giao dịch đã hoàn tiền (revocationDate != nil) phải bị vô hiệu hóa ngay lập tức")
    }
}
