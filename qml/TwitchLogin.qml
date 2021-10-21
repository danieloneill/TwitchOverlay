import QtQuick 2.7
import QtQuick.Window 2.3
//import QtWebView 1.1 // Qt 5.x
import QtWebView       // Qt 6.x

import 'twitch.js' as Twitch

Window {
    id: syncWindow
    title: 'Link Twitch account'
    width: 400
    height: 600

    function spawn()
    {
        show();
        webview.url = 'https://id.twitch.tv/oauth2/authorize?client_id='+Overlay.clientid+'&redirect_uri='+Twitch.api.m_authurl+'&response_type=code&scope=chat:read';
    }

    function loadUrl(url)
    {
        webview.url = url;
    }

    WebView {
        id: webview
        anchors.fill: parent
        onLoadingChanged: function (loadRequest) {
            console.log("Webview: "+loadRequest.status+" for URL: "+loadRequest.url);
            var url = ''+loadRequest.url;
            if( url.substr(0,Twitch.api.m_authurl.length) == Twitch.api.m_authurl )
            {
                // This is for a valid HTTP OAuth2 "reflector" (twitchoverlay.php running somewhere):
                if( loadRequest.status == 2 )
                {
                    // Got it:
                    runJavaScript("document.body.innerHTML", function(result) {
                        console.log("Contents: "+result);
                        var json = JSON.parse( ""+result );
                        Overlay.setAuthkey(json['access_token']);

                        var expSecs = parseInt(''+json['expires_in']) - 120; // This will make us refresh 2 mins before it expires.
                        var expiry = new Date(Date.now() + (1000 * expSecs));
                        Overlay.setExpires(expiry);
                        Overlay.setRefreshtoken(json['refresh_token']);

                        // Reset the 'refresh' timer:
                        Twitch.api.updateRefresh(syncWindow);

                        Twitch.api.getUsername();
                        syncWindow.hide();
                    });
                }
                else if( loadRequest.status == 3 )
                {
                    // We'll do it ourselves:
                    var querystr = url.substr(Twitch.api.m_authurl.length + 1);
                    var pairs = querystr.split('&');
                    var codeset = {};
                    for( var x=0; x < pairs.length; x++ )
                    {
                        var keypair = pairs[x].split('=');
                        var k = decodeURIComponent( keypair[0] );
                        var v = decodeURIComponent( keypair[1] );
                        codeset[k] = v;
                    }

                    var nurl = 'https://id.twitch.tv/oauth2/token';
                    var params = 'client_id='+encodeURIComponent(Overlay.clientid)
                                +'&client_secret='+encodeURIComponent(Overlay.clientsecret)
                                +'&code='+encodeURIComponent(codeset['code'])
                                +'&grant_type=authorization_code&redirect_uri='
                                +encodeURIComponent(Twitch.api.m_authurl);

                    console.log("Posting: "+nurl+" => "+params);
                    Twitch.api.httpPostRequester(nurl, function(contents) {
                        console.log("Got these contents in response: "+contents);

                        var json = JSON.parse( ""+contents );
                        Overlay.setAuthkey(json['access_token']);

                        var expSecs = parseInt(''+json['expires_in']) - 120; // This will make us refresh 2 mins before it expires.
                        var expiry = new Date(Date.now() + (1000 * expSecs));
                        Overlay.setExpires(expiry);
                        Overlay.setRefreshtoken(json['refresh_token']);

                        // Reset the 'refresh' timer:
                        Twitch.api.updateRefresh(syncWindow);

                        Twitch.api.getUsername();
                        syncWindow.hide();
                    }, false, params);
                }
            }
        }
    }
}
