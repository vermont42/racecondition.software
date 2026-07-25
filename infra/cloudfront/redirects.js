// CloudFront Function — viewer-request event on distribution E17XJYXCFIPEQI
// (racecondition.software). Deployed copy lives in AWS as the function
// "racecondition-redirects"; this file is the source of record. Update both.
//
// It runs before the cache lookup, so redirects are issued on every request
// regardless of what CloudFront has cached.

var APEX = 'racecondition.software';

function handler(event) {
    var request = event.request;
    var host = request.headers.host ? request.headers.host.value.toLowerCase() : '';
    var uri = request.uri;

    var target = uri;
    var redirect = false;

    // The /blog/ listing was retired in favour of /archive/, which lists the
    // same posts. Only the bare listing moves: post permalinks (/blog/:title/)
    // and the paginated pages (/blog/page/:n/) must pass through untouched.
    if (uri === '/blog' || uri === '/blog/' || uri === '/blog/index.html') {
        target = '/archive/';
        redirect = true;
    }

    // Both hosts served the whole site, so search engines saw two complete
    // copies with no signal about which one was authoritative.
    if (host === 'www.' + APEX) {
        redirect = true;
    }

    if (!redirect) {
        return request;
    }

    return {
        statusCode: 301,
        statusDescription: 'Moved Permanently',
        headers: {
            // A finite max-age keeps the redirect revisable; browsers cache a
            // bare 301 indefinitely.
            'cache-control': { value: 'max-age=3600' },
            'location': { value: 'https://' + APEX + target + queryString(request.querystring) }
        }
    };
}

// Reassembles request.querystring, whose values arrive already URL-encoded.
function queryString(querystring) {
    var parts = [];

    for (var key in querystring) {
        var param = querystring[key];

        if (param.multiValue) {
            for (var i = 0; i < param.multiValue.length; i++) {
                parts.push(pair(key, param.multiValue[i].value));
            }
        } else {
            parts.push(pair(key, param.value));
        }
    }

    return parts.length === 0 ? '' : '?' + parts.join('&');
}

function pair(key, value) {
    return value === '' || value === undefined ? key : key + '=' + value;
}
