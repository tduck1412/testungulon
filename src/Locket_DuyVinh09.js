// ========= ID ========= //
const mapping = {
  'Locket': ['Gold']
};
// =========   Phần cố định  ========= // 
// =========  @duyvinh09 ========= // 
var ua = $request.headers["User-Agent"] || $request.headers["user-agent"],
  obj = JSON.parse($response.body);
obj.Attention = "Chúc mừng bạn! Vui lòng không bán hoặc chia sẻ cho người khác!";
var duyvinh09 = {
      auto_resume_date: null,
      display_name: "locket_1600_1y",
      is_sandbox: true,
      ownership_type: "PURCHASED",
      billing_issues_detected_at: null,
      management_url: "https://apps.apple.com/account/subscriptions",
      period_type: "normal",
      price: {
          "amount": 399000.0,
          "currency": "VND"
      },
      expires_date: "9999-01-09T10:10:14Z",
      grace_period_expires_date: null,
      refunded_at: null,
      unsubscribe_detected_at: null,
      original_purchase_date: "2005-01-09T10:10:15Z",
      purchase_date: "2005-01-09T10:10:14Z",
      store: "app_store",
      store_transaction_id: "2000001108724193",
  },
  locketGold = {
      grace_period_expires_date: null,
      purchase_date: "2005-01-09T10:10:14Z",
      product_identifier: "locket_1600_1y",
      expires_date: "9999-01-09T10:10:14Z"
  };
const match = Object.keys(mapping).find(e => ua.includes(e));
if (match) {
  let [e, s] = mapping[match];
  s ? (locketGold.product_identifier = s, obj.subscriber.subscriptions[s] = duyvinh09) : obj.subscriber.subscriptions["locket_1600_1y"] = duyvinh09, obj.subscriber.entitlements[e] = locketGold
} else obj.subscriber.subscriptions["locket_1600_1y"] = duyvinh09, obj.subscriber.entitlements.pro = locketGold;

// Mở khóa Filter Packs & Effects
const pack10 = "com.locket.Locket.FilterPack_10Photos_400";
const pack20 = "com.locket.Locket.FilterPack_20Photos_500";
obj.subscriber.subscriptions[pack10] = Object.assign({}, duyvinh09, { display_name: pack10 });
obj.subscriber.subscriptions[pack20] = Object.assign({}, duyvinh09, { display_name: pack20 });
obj.subscriber.entitlements["effect_pack_10"] = Object.assign({}, locketGold, { product_identifier: pack10 });
obj.subscriber.entitlements["effect_pack_20"] = Object.assign({}, locketGold, { product_identifier: pack20 });

$done({
  body: JSON.stringify(obj)
});
