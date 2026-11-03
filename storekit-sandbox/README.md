# Môi Trường Nghiên Cứu Mật Mã Giao Dịch StoreKit 2 Sandbox

Dự án này triển khai kiến trúc bảo mật xác thực bản quyền giao dịch trên iOS bằng **Apple StoreKit 2** và kiểm thử tự động với **StoreKitTest (`SKTestSession`)**.

---

## 1. Cấu Trúc Thành Phần

```text
storekit-sandbox/
├── Package.swift                    # Cấu hình Swift Package
├── Products.storekit                # Tệp cấu hình giả lập sản phẩm StoreKit của Xcode
├── Sources/
│   └── StoreKitSandbox/
│       └── SubscriptionSecurityManager.swift  # Xử lý xác thực chữ ký JWS & Quản lý quyền
└── Tests/
    └── StoreKitSandboxTests/
        └── SubscriptionSecurityTests.swift    # Bộ 5 bài kiểm thử tự động với SKTestSession
```

---

## 2. Nguyên Lý Bảo Mật Triển Khai (Zero-Trust Entitlement Verification)

1. **Xác thực chữ ký JWS (JSON Web Signature):**
   * Sử dụng enum `VerificationResult<Transaction>` từ Apple:
     * `.verified(let transaction)`: Được ký số bởi Apple Root CA, dữ liệu nguyên bản.
     * `.unverified(_, let error)`: Phát hiện dữ liệu bị can thiệp trên mạng (MITM) hoặc sai lệch chữ ký $\rightarrow$ Ném lỗi `invalidJWSSignature`.
2. **Quét quyền hạn thời gian thực:**
   * Sử dụng `Transaction.currentEntitlements` để đọc trực tiếp trạng thái được mã hóa.
   * Lắng nghe `Transaction.updates` để cập nhật trạng thái khi người dùng gia hạn hoặc đổi gói.
3. **Phân định rõ ràng hai lớp quyền:**
   * `hasGoldAccess`: Quyền thành viên toàn cục (`locket_1600_1y` hoặc `locket_gold_monthly`).
   * `hasEffectPackAccess`: Quyền sử dụng bộ lọc AR ngày lễ (`FilterPack_10Photos_400`, `FilterPack_20Photos_500`).
4. **Kiểm soát xuất Moment (`canSendMomentWithFilter()`):**
   * Cho phép gửi ảnh khi người dùng sở hữu `Gold` HOẶC còn lượt trong `Effect Pack`.

---

## 3. Cách Mở & Chạy Kiểm Thử Trong Xcode

1. **Mở dự án:**
   * Kéo thả thư mục `storekit-sandbox` vào Xcode hoặc mở tệp `Package.swift`.
2. **Kích hoạt StoreKit Configuration:**
   * Chọn Scheme: `Product` $\rightarrow$ `Scheme` $\rightarrow$ `Edit Scheme...`
   * Chọn thẻ `Run` hoặc `Test` $\rightarrow$ `Options`.
   * Tại mục **StoreKit Configuration**, chọn tệp `Products.storekit`.
3. **Chạy bộ kiểm thử tự động:**
   * Nhấn tổ hợp phím **`Cmd + U`** để thực thi bộ 5 bài test trong `SubscriptionSecurityTests.swift`:
     * ✅ `test01_initialState_shouldBeDenied`: Kiểm tra trạng thái ban đầu khi chưa mua.
     * ✅ `test02_purchaseGoldYearly_shouldVerifyJWSAndGrantAccess`: Kiểm tra mua gói năm, xác thực JWS và cấp quyền.
     * ✅ `test03_purchaseEffectPack_shouldGrantEffectAccess`: Kiểm tra mua lẻ gói hiệu ứng ngày lễ.
     * ✅ `test04_subscriptionExpiration_shouldRevokeGoldAccess`: Kiểm tra tự động thu hồi quyền khi hết hạn.
     * ✅ `test05_refundTransaction_shouldInvalidateEntitlementImmediately`: Kiểm tra thu hồi ngay khi bị hoàn tiền.
