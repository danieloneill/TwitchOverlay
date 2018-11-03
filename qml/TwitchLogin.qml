import QtQuick 2.7
import QtQuick.Window 2.3
import QtWebView 1.1

import 'twitch.js' as Twitch

Window {
    id: syncWindow
    title: 'Link Twitch account'
    width: 400
    height: 600

    function spawn()
    {
        show();
        webview.url = 'https://id.twitch.tv/oauth2/authorize?client_id=c6ssxu5079nah0rrwqcdfpg1qy8bwq&redirect_uri=http://dawnnest.com/twitchoverlay.php&response_type=code&scope=chat:read&force_verify=true';
    }

    WebView {
        id: webview
        anchors.fill: parent
        onLoadingChanged: {
            console.log("Webview: "+loadRequest.status+" for URL: "+loadRequest.url);
            var url = ''+loadRequest.url;
            if( loadRequest.status == 2 && url.substr(0,37) == "http://dawnnest.com/twitchoverlay.php" )
            {
                // Got it:
                runJavaScript("document.body.innerHTML", function(result) {
                    console.log("Contents: "+result);
                    var json = JSON.parse( ""+result );
                    Overlay.setAuthkey(json['access_token']);

                    var expSecs = parseInt(''+json['expires_in']);
                    var expiry = new Date(Date.now() + (1000 * expSecs));
                    Overlay.setExpires(expiry);
                    Overlay.setRefreshtoken(json['refresh_token']);

                    Twitch.api.getUsername();
                    syncWindow.hide();
                });
            }
        }
    }
}
