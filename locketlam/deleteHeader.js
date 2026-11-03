// ============================================================
// Delete Caching Headers for RevenueCat
// Dùng cho: Shadowrocket
// Tác giả: @tduc (https://www.facebook.com/tduck.2007/)
// ============================================================

var modifiedHeaders = $request && $request.headers ? Object.assign({}, $request.headers) : {};

function removeHeader(headers, name) {
    if (!headers) return;
    delete headers[name];
    delete headers[name.toLowerCase()];
    delete headers[name.toUpperCase()];
}

removeHeader(modifiedHeaders, "X-RevenueCat-ETag");
removeHeader(modifiedHeaders, "If-None-Match");
removeHeader(modifiedHeaders, "x-revenuecat-etag");
removeHeader(modifiedHeaders, "if-none-match");

$done({ headers: modifiedHeaders });
