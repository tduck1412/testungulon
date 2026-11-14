/***********************************************
> Locket AI Filter Modifier, Unblur & Community Gold VIP
> Phân phối: Nightmarketserver
> Tác giả: MinhHiep08 (@minhhiep07)
> Hỗ trợ: Shadowrocket, Loon, Surge, Quantumult X
> Tính năng:
  - Chiều Request: Giả lập US, xóa sạch cache 304, tùy biến Prompt AI.
  - Chiều Response:
    1. Tự động nhận diện tài khoản chủ máy (Self): Cấp Gold, vương miện & viền vàng, tự động đăng ký P2P lên Worker.
    2. Nhận diện bạn bè trong mạng lưới VIP cộng đồng (kích hoạt qua Web hoặc Module): Cấp viền vàng & tim vàng (💛) chuẩn Locket.
    3. Hỗ trợ argument "all_friends=true" nếu muốn hiện Gold cho toàn bộ bạn bè.
    4. Gỡ bỏ hoàn toàn mã lỗi (402, 403), gỡ che mờ ảnh (unblur) và cờ khóa đòi Gold trên filter/moment.
***********************************************/

const WORKER_HOST = "https://locket-vip.mhiep20077.workers.dev";
const VIP_STORE_KEY = "LOCKET_VIP_COMMUNITY";
const SELF_UID_KEY = "LOCKET_SELF_UID";
const SELF_USERNAME_KEY = "LOCKET_SELF_USERNAME";

// Danh sách hạt giống VIP tích hợp sẵn (Bao gồm cả Username lẫn UID đã kích hoạt trong mạng lưới)
const BASE_VIP_USERS = ["mhhiep","2c7dlquxuqulknrwgpcqsqlw0sk2","th_quang08","th_quang","nln9pozfecsccxhuqpiwvkhfwsi2","mhhuyz","7tulqjjxb0srwqbbp3euildiqfe3","nguyentuankietne","blgpf4fdvbbnlmfllziy4hnbjjn1","d4vy8lqpxevoi7yw0etjagd8ihm1","duuxx","nin1qotyjmnywtrmudubinmywwt1","kienvin","ovqinfsvsud70wk1zzamju8cxrf1","nightmarketserver","qudekzvkzif2oaox79fnh1fodxf3","nightmarket","j5n7ioiufeymskpmcohjjjswrxa2","7ghwealmlhxvkdvhp11vwwwciie2","hjmbhnrxstco62kjojgojtc8ddn2","dualato","g8mrjoobvcfgo6pomplyvmqfet92","12tsoagygjyx6xdmvqj7d5phsv93","6fbwotlsq5ojnd7azlrcuousv5k2","v6nunol4iiacnmfnrxsfoko5dxn2","khoia","zhuudjqjnatlsn350x4w0wnnnwn1","ak24","b09lwjxdn3ublwbgtjaqwwnvxcs1","ak2703","t5fvkfp994fywhgwfkwsikscleg1","duyvinh09","729ckhper7p0lnynwp0fsrtktng2","4a5e1hpej5zgxeaii5z2kdbmolf2","mpqza6lcmoxwtnwqn7jz2yi7vi22","ghfpj4icughbjhtrqt8hvfqiwmg2","zg1dvwmntaq2jmdvuwqel8fxhei2","tzxpq8rmhrsq70zyr0wwytnk5t33","enil4j1rdjfwzvkz4y5bxvcnv4k2","jfv4gmq9gie6g2capflgnozrwhg2","leanhminh2104","utjvlg8fbfx12lz0qp2c3n5qgay1","talaquaivat","eufsqtikwsre05wdktcibpcxvhi3","sarhlywj6doce6yybr0z3vx23ef1","tduc","znoppo16aanvdi2g9dswximmhrl2","8acssqcce7gwhfzxtkgdczgmjte2","daokinnn","4njw4uo7tusl1huh39dy03sl6xf1","tr.duck","2u96nqywrdeopjwhn4tvtivpeyh2","nguyenhoangtulinh","wphe1l0fp9g1wuifi0xrdv3zeqv1","6mvzl2stbafos0v8wwuujalumel1","gzbnnaurnib6no8ow5yz9cvtwct2","ann203","hkcgcbmndwve1uvnlcceu9gbscw1","q5yk3p7jd5qqqwth6aqaohcjvvl1","wvkrbhbs58zn9xp1oalb732uh922","nlidzrbg3sylny3hursjov5co8t2","effh2jtjanha5uhmx9mkhbw2kgw2","1zkaxildwlc54iqvpfvc0xshch93","nviitxuxhmypiq9crffclxbzj7v2","hunglaoshi","om2esk68dfxqfzryveblf1znoxx1","miubaby","mzuspertjfsfbfxhllmvrhzifx62","khaido1117","obu5ilvrknwrrtu1vyefp8odol43","1fcncwgripguvtx8hpjw10bsrzh3","pvaheohbr4v01cfg9hai1iwxdkt2","duonganhky","8kiu9dwtuicniutzojhr6kf0qyp1","o9ac9wcvwqgfxaw2hmdkbyluqkb2","ptan.01","vlrlnbb1esmdut8ch4bepfckkdk2","tloc0088","hso9tm4a6cpkcpgxjohxiqu6dhi1","yi9tybjdfzg0kbonhqjb516sbzw2","baoconcu","rhm8b6rlv1d3snxdfj1jxg1qcrc2","ho_ann","e11r1kxh4ezehcbglv0zun6dndn2","bichna14","w733f9quh4gceczqhipvtvmkqpk2","taikhoantest1","supfr8xxdkdph6rkcftz0lgsu6q1","ccc","onwh7iehjvgylmnsyu9ljuwp4a82","ntnmedia","gvneomp84yuw8znzpyyqhwwasiy2","6bsfuqrk1zw8yvqanhnvwndvqql1","nguyentankietne","oeg7utzfdff5kppub7vcfiqmlli2","phw_naw","grtrogz4xcdhznd8kzdrkdl66md2","bn_sii","f7ugzfhyc7xrikjvee8wbrcmt0k1","oahn2309","fuokhow1rxuvugyb0bz7xl3wcku2","mhhieuz","igxfmpws63dt7zpaqp0irtruyj72","canh.quang","t9inecetx2dje9n36vvyb9xomxy2","kienviet"];

// Hàm gán toàn bộ cờ Gold & Huy hiệu tim vàng vào đối tượng
function applyGoldBadge(target) {
    if (!target || typeof target !== "object") return;
    target.badge = "locket_gold";
    target.badge_tier = "gold";
    target.show_badge = true;
    target.is_gold = true;
    target.has_gold = true;
    target.gold = true;
    target.gold_subscription = true;
    target.has_gold_subscription = true;
    target.tier = "gold";
    target.subscription_status = "active";
    if (target.user && typeof target.user === "object" && target.user !== target) {
        applyGoldBadge(target.user);
    }
    if (target.friend && typeof target.friend === "object" && target.friend !== target) {
        applyGoldBadge(target.friend);
    }
    if (target.profile && typeof target.profile === "object" && target.profile !== target) {
        applyGoldBadge(target.profile);
    }
}

// Hàm kiểm tra đa chiều xem node có thuộc danh sách VIP hay không
function isNodeVip(target, vSet) {
    if (!target || typeof target !== "object") return false;

    // Kiểm tra trực tiếp các trường UID / ID phổ biến nhất
    const uid = String(target.uid || target.user_id || target.id || target.friend_uid || target.friend_id || target.friendId || target.userId || "").toLowerCase().trim();
    if (uid && vSet.has(uid)) return true;

    // Kiểm tra trực tiếp Username
    const uname = String(target.username || target.friend_username || "").toLowerCase().trim();
    if (uname && vSet.has(uname)) return true;

    // Kiểm tra trong object con target.user
    if (target.user && typeof target.user === "object") {
        const uUid = String(target.user.uid || target.user.id || target.user.user_id || "").toLowerCase().trim();
        if (uUid && vSet.has(uUid)) return true;
        const uUname = String(target.user.username || target.user.friend_username || "").toLowerCase().trim();
        if (uUname && vSet.has(uUname)) return true;
    }

    // Kiểm tra trong object con target.friend
    if (target.friend && typeof target.friend === "object") {
        const fUid = String(target.friend.uid || target.friend.id || "").toLowerCase().trim();
        if (fUid && vSet.has(fUid)) return true;
        const fUname = String(target.friend.username || "").toLowerCase().trim();
        if (fUname && vSet.has(fUname)) return true;
    }

    // Kiểm tra display_name hoặc name
    const dName = String(target.display_name || target.first_name || target.name || (target.user && (target.user.display_name || target.user.first_name)) || "").toLowerCase().trim();
    if (dName && vSet.has(dName)) return true;

    return false;
}

// =========================================================================
// 1. CHIỀU REQUEST: Xóa cache 304 & Phản hồi changeProfileInfo thành công
// =========================================================================
if (typeof $response === "undefined") {
    const reqUrl = (typeof $request !== "undefined" && $request.url) ? $request.url : "";
    if (reqUrl.includes("changeProfileInfo")) {
        $done({
            response: {
                status: 200,
                headers: {
                    "Content-Type": "application/json; charset=utf-8",
                    "Access-Control-Allow-Origin": "*"
                },
                body: JSON.stringify({
                    data: { badge: "locket_gold", badge_tier: "gold", is_gold: true, success: true },
                    result: { badge: "locket_gold", badge_tier: "gold", is_gold: true, success: true }
                })
            }
        });
        return;
    }

    let headers = Object.assign({}, ($request && $request.headers) || {});

    // Xóa triệt để header cache gây lỗi 304 Not Modified
    for (let k of Object.keys(headers)) {
        if (['if-none-match', 'if-modified-since', 'x-revenuecat-etag'].includes(k.toLowerCase())) {
            delete headers[k];
        }
    }

    $done({ headers: headers });
}

// =========================================================================
// 2. CHIỀU RESPONSE: Mở khóa kết quả ảnh, gỡ mờ (unblur) & cấp quyền VIP
// =========================================================================
else {
    const reqUrl = (typeof $request !== "undefined" && $request.url) ? $request.url : "";
    if (reqUrl.includes("generateFilteredImage")) {
        $done({});
        return;
    }

    let body = $response.body;
    let status = $response.status || $response.statusCode || 200;

    // Kiểm tra cấu hình argument (VD: all_friends=true để mở huy hiệu vàng cho tất cả bạn bè)
    const customArg = (typeof $argument === "string" && $argument.trim()) ? $argument.trim().toLowerCase() : "";
    const unlockAllFriends = customArg.includes("all_friends=true") || customArg.includes("gold_all=true");

    // Khởi tạo tập hợp VIP từ hạt giống có sẵn
    let vipSet = new Set(BASE_VIP_USERS.map(u => String(u).toLowerCase().trim()));

    // Hàm giải mã an toàn UID của chủ tài khoản từ Firebase JWT Authorization Header
    function extractSelfUidFromHeaders(headers) {
        if (!headers || typeof headers !== "object") return null;
        const auth = headers["authorization"] || headers["Authorization"] || headers["AUTHORIZATION"] || "";
        if (!auth || typeof auth !== "string") return null;
        const token = auth.replace(/^Bearer\s+/i, "").trim();
        const parts = token.split(".");
        if (parts.length >= 2) {
            try {
                let base64Url = parts[1].replace(/-/g, "+").replace(/_/g, "/");
                while (base64Url.length % 4) base64Url += "=";
                let output = "";
                let str = String(base64Url).replace(/=+$/, "");
                const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
                for (let bc = 0, bs, buffer, idx = 0; buffer = str.charAt(idx++); ~buffer && (bs = bc % 4 ? bs * 64 + buffer : buffer, bc++ % 4) ? output += String.fromCharCode(255 & bs >> (-2 * bc & 6)) : 0) {
                    buffer = chars.indexOf(buffer);
                }
                if (output) {
                    const payload = JSON.parse(output);
                    return payload.user_id || payload.sub || payload.uid || null;
                }
            } catch (e) {}
        }
        return null;
    }

    // Nhận diện chính xác UID của chủ máy từ JWT Header hoặc bộ nhớ đã lưu
    const reqHeaders = (typeof $request !== "undefined" && $request && $request.headers) ? $request.headers : {};
    const jwtSelfUid = extractSelfUidFromHeaders(reqHeaders);
    let myUid = (typeof $persistentStore !== "undefined") ? $persistentStore.read(SELF_UID_KEY) : null;
    if (jwtSelfUid) {
        myUid = jwtSelfUid;
        if (typeof $persistentStore !== "undefined") {
            $persistentStore.write(myUid, SELF_UID_KEY);
        }
    }
    if (myUid) vipSet.add(String(myUid).toLowerCase().trim());
    const myUname = (typeof $persistentStore !== "undefined") ? $persistentStore.read(SELF_USERNAME_KEY) : null;
    if (myUname) vipSet.add(String(myUname).toLowerCase().trim());

    // Nạp thêm danh sách VIP từ bộ nhớ thiết bị ($persistentStore)
    if (typeof $persistentStore !== "undefined") {
        try {
            const rawVip = $persistentStore.read(VIP_STORE_KEY);
            if (rawVip) {
                const list = JSON.parse(rawVip);
                if (Array.isArray(list)) {
                    for (let id of list) {
                        if (id) vipSet.add(String(id).toLowerCase().trim());
                    }
                }
            }
        } catch (e) {}
    }

    if (body && typeof body === "string") {
        try {
            let obj = JSON.parse(body);
            const isFriendsOrFeed = /getFriends|getUsers|fetchFriends|getRecipients|recipients|moments|fetchMoments|getMoments|contacts/i.test(reqUrl);

            // Chỉ gỡ lỗi 402/403 cho tính năng Filter, TUYỆT ĐỐI không ghi đè làm mất dữ liệu bạn bè hay moments
            if (!isFriendsOrFeed && (status === 402 || status === 403 || status === 400)) {
                status = 200;
                if (obj && obj.error && reqUrl.includes("generateFilteredImage")) {
                    obj = {
                        result: {
                            status: 200,
                            is_gold: true,
                            is_locked: false,
                            requires_gold: false,
                            unlocked: true,
                            data: obj.error.details || {}
                        }
                    };
                }
            }

            function unlockSelfUser(userNode) {
                if (!userNode || typeof userNode !== "object") return;
                applyGoldBadge(userNode);
                userNode.can_use_filters = true;
                userNode.can_use_gold_features = true;
                userNode.can_generate_filtered_image = true;
                userNode.can_create_filtered_image = true;
                userNode.has_ai_access = true;
                userNode.filter_access = true;

                const actual = (userNode.user && typeof userNode.user === "object") ? userNode.user : userNode;
                const uid = String(actual.uid || actual.user_id || actual.id || userNode.uid || userNode.user_id || userNode.id || myUid || "").toLowerCase().trim();
                const username = String(actual.username || userNode.username || "").toLowerCase().trim();

                if (typeof $persistentStore !== "undefined") {
                    if (uid) $persistentStore.write(uid, SELF_UID_KEY);
                    if (username) $persistentStore.write(username, SELF_USERNAME_KEY);
                }
                if (uid) vipSet.add(uid);
                if (username) vipSet.add(username);

                // Tự động đồng bộ tài khoản chủ máy lên Worker để người dùng module khác thấy Gold
                if ((uid || username) && typeof $httpClient !== "undefined") {
                    try {
                        $httpClient.get(`${WORKER_HOST}/api/register-vip?uid=${encodeURIComponent(uid)}&username=${encodeURIComponent(username)}`, function() {});
                    } catch (e) {}
                }

                // Tự động kích hoạt huy hiệu locket_gold trực tiếp lên máy chủ chính chủ api.locketcamera.com
                const authHeader = reqHeaders["authorization"] || reqHeaders["Authorization"];
                if (authHeader && typeof $httpClient !== "undefined") {
                    const lastSyncTime = (typeof $persistentStore !== "undefined") ? $persistentStore.read("LOCKET_PROFILE_BADGE_SYNCED") : null;
                    const now = Date.now();
                    if (!lastSyncTime || (now - Number(lastSyncTime)) > 3600000) {
                        if (typeof $persistentStore !== "undefined") {
                            $persistentStore.write(String(now), "LOCKET_PROFILE_BADGE_SYNCED");
                        }
                        try {
                            $httpClient.post({
                                url: "https://api.locketcamera.com/changeProfileInfo",
                                headers: {
                                    "Authorization": authHeader,
                                    "Content-Type": "application/json"
                                },
                                body: JSON.stringify({
                                    data: {
                                        badge: "locket_gold"
                                    }
                                })
                            }, function() {});
                        } catch (e) {}
                    }
                }
            }

            // 1. Chỉ mở khóa Self nếu payload là hồ sơ của chính chủ máy (khớp myUid hoặc có email tài khoản)
            const isSingleUserProfile = Boolean(
                !isFriendsOrFeed &&
                ((obj && obj.data && typeof obj.data === "object" && !Array.isArray(obj.data) && (obj.data.email || (myUid && obj.data.uid === myUid))) ||
                 (obj && obj.result && typeof obj.result === "object" && !Array.isArray(obj.result) && (obj.result.email || (myUid && obj.result.uid === myUid))) ||
                 (obj && obj.user && typeof obj.user === "object" && !Array.isArray(obj.user) && (obj.user.email || (myUid && obj.user.uid === myUid))))
            );

            if (isSingleUserProfile) {
                applyGoldBadge(obj);
                unlockSelfUser(obj.data || obj.result || obj.user || obj);
            }

            // 2. Duyệt phân biệt chính xác Bạn bè và Chủ máy (Bảo toàn 100% streak và danh sách bạn bè)
            function transformNode(node) {
                if (!node || typeof node !== "object") return;

                if (Array.isArray(node)) {
                    for (let i = 0; i < node.length; i++) {
                        transformNode(node[i]);
                    }
                    return;
                }

                const actualUser = (node.user && typeof node.user === "object") ? node.user : node;
                const nodeUid = String(actualUser.uid || actualUser.user_id || actualUser.id || node.uid || node.user_id || node.id || "").toLowerCase().trim();

                // Chỉ nhận là Self nếu trùng khớp chính xác UID chủ máy hoặc chứa email cá nhân / push_token riêng tư
                // (Bạn bè trong Locket không bao giờ có email hoặc push_token, nhưng CÓ THỂ có phone_number từ danh bạ)
                const isSelf = Boolean(
                    (myUid && nodeUid && nodeUid === myUid.toLowerCase()) ||
                    ("email" in node && node.email && typeof node.email === "string" && node.email.includes("@")) ||
                    ("push_token" in node && node.push_token) ||
                    ("fcm_token" in node && node.fcm_token)
                );

                if (isSelf) {
                    unlockSelfUser(node);
                } else {
                    // Đây là Bạn bè (Friend): Bảo toàn 100% streak, locket_count, thông tin tài khoản
                    const isVipFriend = unlockAllFriends || isNodeVip(node, vipSet);

                    if (isVipFriend) {
                        applyGoldBadge(node);
                        if (node.user && typeof node.user === "object") {
                            applyGoldBadge(node.user);
                        }
                        if (node.friend && typeof node.friend === "object") {
                            applyGoldBadge(node.friend);
                        }
                    }
                }

                // Gỡ bỏ các cờ che mờ & đòi tiền trên ảnh/filter
                const falseFlags = [
                    "is_locked", "locked", "requires_gold", "require_gold",
                    "gold_only", "is_gold_only", "paywall", "show_paywall",
                    "show_upsell", "upsell", "blurred", "is_blurred", "needs_gold"
                ];
                for (let f of falseFlags) {
                    if (f in node) node[f] = false;
                }

                const trueFlags = [
                    "can_view", "unlocked", "is_unlocked", "is_free", "free",
                    "can_use_filter", "allowed", "can_use_filters"
                ];
                for (let t of trueFlags) {
                    if (t in node) node[t] = true;
                }

                // Đổi link ảnh mờ thành link ảnh rõ nét thành phẩm
                const clearUrl = node.unblurred_url || node.unlocked_url || node.result_url || node.image_url || node.transformed_image_url || node.url;
                if (clearUrl && typeof clearUrl === "string" && clearUrl.startsWith("http")) {
                    if ("blurred_url" in node) node.blurred_url = clearUrl;
                    if ("blurred_image_url" in node) node.blurred_image_url = clearUrl;
                    if ("preview_url" in node && node.is_blurred) node.preview_url = clearUrl;
                }

                // Duyệt sâu các trường con mà không làm hỏng cấu trúc
                for (let k of Object.keys(node)) {
                    if (k !== "badge" && k !== "is_gold" && k !== "has_gold" && k !== "tier" && k !== "gold") {
                        if (vipSet.has(k.toLowerCase().trim()) && node[k] && typeof node[k] === "object") {
                            applyGoldBadge(node[k]);
                        }
                        transformNode(node[k]);
                    }
                }
            }

            transformNode(obj);
            body = JSON.stringify(obj);
        } catch (e) {}
    }

    // Tự động tải ngầm danh sách VIP mới nhất từ Worker vào bộ nhớ thiết bị
    if (typeof $httpClient !== "undefined") {
        try {
            $httpClient.get(`${WORKER_HOST}/api/vip-users`, function(err, resp, data) {
                if (!err && data) {
                    try {
                        const resData = JSON.parse(data);
                        if (resData && Array.isArray(resData.identifiers) && typeof $persistentStore !== "undefined") {
                            $persistentStore.write(JSON.stringify(resData.identifiers), VIP_STORE_KEY);
                        }
                    } catch (e) {}
                }
            });
        } catch (e) {}
    }

    let respHeaders = Object.assign({}, ($response && $response.headers) || {});
    delete respHeaders["Content-Encoding"];
    delete respHeaders["content-encoding"];
    delete respHeaders["Content-Length"];
    delete respHeaders["content-length"];
    delete respHeaders["Transfer-Encoding"];
    delete respHeaders["transfer-encoding"];
    respHeaders["content-type"] = "application/json; charset=utf-8";

    $done({
        status: status,
        headers: respHeaders,
        body: body
    });
}