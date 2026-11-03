// ============================================================
// Locket Remote Config – Force US Region & Storefront (REQUEST)
// Endpoint: firebaseremoteconfig.googleapis.com/.../firebase:fetch
// Tác giả: @tduc (https://www.facebook.com/tduck.2007/)
// ============================================================

if ($request.method === "POST") {
    var headers = $request.headers || {};

    // Ép dấu vân tay vùng miền về US
    headers["Accept-Language"] = "en-US,en;q=0.9";
    headers["X-Firebase-Locale"] = "en_US";
    headers["X-Ios-Locale"] = "en_US";
    headers["X-Apple-Store-Front"] = "143441-1,29"; // US App Store Storefront ID

    if ($request.body) {
        try {
            var body = typeof $request.body === "string" ? JSON.parse($request.body) : $request.body;
            if (body && typeof body === "object") {
                body.country_code = "us";
                body.countryCode = "US";
                body.time_zone = "America/New_York";
                body.language_code = "en_US";
                body.locale = "en_US";
                $done({ body: JSON.stringify(body), headers: headers });
            } else {
                $done({ headers: headers });
            }
        } catch (e) {
            $done({ headers: headers });
        }
    } else {
        $done({ headers: headers });
    }
} else {
    $done({});
}
