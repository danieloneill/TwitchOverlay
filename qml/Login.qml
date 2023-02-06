import QtQuick 2.15

import com.oneill.AuthWindow 1.0

AuthWindow {
    id: syncWindow

    Component.onCompleted: {
        resize(400, 600);
        setTitle(qsTr("Twitch Authentication"));
    }

    function spawn()
    {
        show();
        url = 'https://id.twitch.tv/oauth2/authorize?client_id='+settings.clientid+'&redirect_uri='+overlayRect.api.m_authurl+'&response_type=code&scope=chat:read';
    }

    function loadUrl(url)
    {
        syncWindow.url = url;
    }

    onLoadingChanged: function (loadRequest) {
        console.log("Webview: "+loadRequest.status+" for URL: "+loadRequest.url);
        const url = ''+loadRequest.url;
        if( url.substr(0,overlayRect.api.m_authurl.length) === overlayRect.api.m_authurl )
        {
            // This is for a valid HTTP OAuth2 "reflector" (twitchoverlay.php running somewhere):
            if( loadRequest.status === true )
            {
                // Got it:
                runJavaScript("document.body.innerHTML", function(result) {
                    console.log("Contents: "+result);
                    const json = JSON.parse( ""+result );
                    settings.authkey = json['access_token'];

                    const expSecs = parseInt(''+json['expires_in']) - 120; // This will make us refresh 2 mins before it expires.
                    const expiry = new Date(Date.now() + (1000 * expSecs));
                    settings.expires = expiry;
                    settings.refreshtoken = json['refresh_token'];

                    overlayRect.linked();
                    syncWindow.hide();
                });
            }
            else if( loadRequest.status === false )
            {
                // We'll do it ourselves:
                const querystr = url.substr(overlayRect.api.m_authurl.length + 1);
                const pairs = querystr.split('&');
                let codeset = {};
                for( var x=0; x < pairs.length; x++ )
                {
                    const keypair = pairs[x].split('=');
                    const k = decodeURIComponent( keypair[0] );
                    const v = decodeURIComponent( keypair[1] );
                    codeset[k] = v;
                }

                const nurl = 'https://id.twitch.tv/oauth2/token';
                const params = 'client_id='+encodeURIComponent(settings.clientid)
                            +'&client_secret='+encodeURIComponent(settings.clientsecret)
                            +'&code='+encodeURIComponent(codeset['code'])
                            +'&grant_type=authorization_code&redirect_uri='
                            +encodeURIComponent(overlayRect.api.m_authurl);

                console.log("Posting: "+nurl+" => "+params);
                overlayRect.api.httpPostRequester(nurl, function(contents) {
                    console.log("Got these contents in response: "+contents);

                    const json = JSON.parse( ""+contents );
                    settings.authkey = json['access_token'];

                    const expSecs = parseInt(''+json['expires_in']) - 120; // This will make us refresh 2 mins before it expires.
                    const expiry = new Date(Date.now() + (1000 * expSecs));
                    settings.expires = expiry.getTime();
                    settings.refreshtoken = json['refresh_token'];

                    overlayRect.linked();
                    syncWindow.hide();
                }, false, params);
            }
        }
    }
}
