// ============================================================
// Locket Gold & Filter Pack Unlock (RevenueCat Response Rewrite)
// Endpoint: api.revenuecat.com/.../(receipts|subscribers)
// Tác giả: @tduc (https://www.facebook.com/tduck.2007/)
// ============================================================

var obj = {};
try {
    obj = JSON.parse($response.body);
} catch (e) {
    obj = {};
}

obj.Attention = "Chúc mừng bạn! Vui lòng không bán hoặc chia sẻ cho người khác!";

var FAR_FUTURE = "9999-01-09T10:10:14Z";
var PAST = "2005-01-09T10:10:14Z";

function makeSub(productId, priceAmount, priceCurrency) {
    return {
        auto_resume_date: null,
        display_name: productId,
        is_sandbox: false,
        ownership_type: "PURCHASED",
        billing_issues_detected_at: null,
        management_url: "https://apps.apple.com/account/subscriptions",
        period_type: "normal",
        price: {
            amount: priceAmount,
            currency: priceCurrency
        },
        expires_date: FAR_FUTURE,
        grace_period_expires_date: null,
        refunded_at: null,
        unsubscribe_detected_at: null,
        original_purchase_date: PAST,
        purchase_date: PAST,
        store: "app_store",
        store_transaction_id: "2000001108724193"
    };
}

function makeEnt(productId) {
    return {
        grace_period_expires_date: null,
        purchase_date: PAST,
        product_identifier: productId,
        expires_date: FAR_FUTURE
    };
}

obj.subscriber = obj.subscriber || {};
obj.subscriber.subscriptions = obj.subscriber.subscriptions || {};
obj.subscriber.entitlements = obj.subscriber.entitlements || {};

// ========== 1. MỞ KHÓA LOCKET GOLD ==========
var goldProduct = "locket_1600_1y";
obj.subscriber.subscriptions[goldProduct] = makeSub(goldProduct, 399000.0, "VND");
obj.subscriber.entitlements["Gold"] = makeEnt(goldProduct);
obj.subscriber.entitlements["pro"] = makeEnt(goldProduct);

// ========== 2. MỞ KHÓA FILTER PACKS & HIỆU ỨNG NGÀY LỄ ==========
var pack10Product = "com.locket.Locket.FilterPack_10Photos_400";
obj.subscriber.subscriptions[pack10Product] = makeSub(pack10Product, 0.0, "USD");
obj.subscriber.entitlements["effect_pack_10"] = makeEnt(pack10Product);

var pack20Product = "com.locket.Locket.FilterPack_20Photos_500";
obj.subscriber.subscriptions[pack20Product] = makeSub(pack20Product, 0.0, "USD");
obj.subscriber.entitlements["effect_pack_20"] = makeEnt(pack20Product);

$done({
    body: JSON.stringify(obj)
});
