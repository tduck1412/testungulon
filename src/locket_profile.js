// ============================================================
// Locket Profile Info & Badge Injector
// Dùng cho: Shadowrocket / Loon / Surge / Quantumult X
// Tác giả: LAMDev / @duyvinh09
// ============================================================

const url = $request ? $request.url : "";

function injectBadge(node) {
    if (!node || typeof node !== "object") return;

    // Nếu đối tượng chứa các trường liên quan đến huy hiệu / hồ sơ
    if (
        "badge" in node ||
        "badge_name" in node ||
        "badge_number" in node ||
        "is_gold" in node ||
        "show_badge" in node
    ) {
        node.badge = "locket_gold";
        node.badge_tier = "gold";
        node.is_gold = true;
        node.show_badge = true;
    }

    // Duyệt đệ quy tất cả thuộc tính con trong cây JSON
    for (let key in node) {
        if (
            Object.prototype.hasOwnProperty.call(node, key) &&
            typeof node[key] === "object" &&
            node[key] !== null
        ) {
            injectBadge(node[key]);
        }
    }
}

// 1. Nếu gọi API đổi thông tin hồ sơ (changeProfileInfo): Mặc định trả về thành công có Gold Badge
if (url.includes("changeProfileInfo")) {
    $done({
        response: {
            status: 200,
            headers: {
                "Content-Type": "application/json; charset=utf-8",
                "Access-Control-Allow-Origin": "*"
            },
            body: JSON.stringify({
                data: {
                    badge: "locket_gold",
                    badge_tier: "gold",
                    is_gold: true,
                    success: true
                },
                result: {
                    badge: "locket_gold",
                    badge_tier: "gold",
                    is_gold: true,
                    success: true
                }
            })
        }
    });
} else {
    // Không can thiệp vào các API bạn bè / bảng tin khác để tránh biến cả danh sách bạn bè thành Gold
    $done({});
}

