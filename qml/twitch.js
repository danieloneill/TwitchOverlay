var api = {
    m_clientid: 'c6ssxu5079nah0rrwqcdfpg1qy8bwq',
    m_authurl: 'http://dawnnest.com/twitchoverlay.php',

    m_chatHooks: [],
    m_avatarHooks: [],
    m_users: [],

    // FIXME: This is to prevent duplicate messages.
//    m_hack_lastLine: '',
    m_tryingToLogin: false,

    m_chatSocket: false,
    m_reconnectTimer: false,
    m_chatModel: false,

    joinChat: function(chatModel)
    {
        this.m_chatModel = this.create(chatModel);
        this.open();
    },

    hookChat: function(callback) {
        if( this.m_chatHooks.indexOf(callback) != -1 )
            return;
        this.m_chatHooks.push(callback);
    },

    hookAvatar: function(callback) {
        if( this.m_avatarHooks.indexOf(callback) != -1 )
            return;
        this.m_avatarHooks.push(callback);
    },

    getUsername: function()
    {
        console.log("Updating username...");
        var url = 'https://id.twitch.tv/oauth2/validate';
        var headers = [ ['Authorization', 'OAuth '+Overlay.authkey ] ];

        this.httpRequester(url, function(pkt) {
            var json = JSON.parse(pkt);

            Overlay.setUsername(json['login']);
            Overlay.setChannel(json['login']);

            Overlay.reload();
        }, headers);
    },

    refresh: function()
    {
        // We really shouldn't NEED to do this while we're connected, but it will ensure that we can reconnect next time before
        // it expires.
        var url = this.m_authurl + '?a=refresh&refresh=' + encodeURIComponent(Overlay.refreshtoken);

        this.httpRequester(url, function(pkt) {
            // TODO: Handle errors:
            console.log("Refresh result: "+pkt);
            var json = JSON.parse(pkt);

            Overlay.authkey = json['access_token'];
            Overlay.refreshtoken = json['refresh_token'];

            var expSecs = parseInt(''+json['expires_in']) - 120; // This will make us refresh 2 mins before it expires.
            var expiry = new Date(Date.now() + (1000 * expSecs));
            Overlay.setExpires(expiry);
        });
    },

    create: function(chatModel)
    {
        var self = this;
        this.m_chatModel = chatModel;

        this.m_chatSocket = Qt.createQmlObject('import QtWebSockets 1.1; WebSocket { id: socket }', chatModel, 'm_chatSocket');
        this.m_chatSocket.statusChanged.connect( function(status) {
            console.log("WebSocket status: "+status);
            if( status == 1 )
                self.socketConnected();
            else if( status == 3 )
                self.socketDisconnected();
        });
        this.m_chatSocket.textMessageReceived.connect( function(msg) {
            self.socketRead(msg);
        });
        this.m_chatSocket.url = 'ws://irc-ws.chat.twitch.tv:80';

        this.m_reconnectTimer = Qt.createQmlObject('import QtQuick 2.0; Timer { id: timer }', chatModel, 'm_reconnectTimer');
        this.m_reconnectTimer.interval = 10000;
        this.m_reconnectTimer.repeat = false;
        this.m_reconnectTimer.triggered.connect( function() { self.open() } );
    },

    write: function(msg)
    {
        this.m_chatSocket.sendTextMessage(msg);
    },

    open: function()
    {
        this.m_chatSocket.active = false;
        this.m_chatSocket.active = true;
        console.log("IRC: Connecting...");
    },

    close: function()
    {
        console.log("IRC: Disconnecting.");
        this.m_chatSocket.active = false;
    },

    socketConnected: function()
    {
        console.log("IRC: Connected.");
        this.m_reconnectTimer.stop();
        this.m_tryingToLogin = true;
        this.write("USER "+Overlay.username+" "+Overlay.username+" "+Overlay.username+" "+Overlay.username+"\n");
        this.write("PASS oauth:"+Overlay.authkey+"\n");
        this.write("NICK "+Overlay.username+"\n");
    },

    authFailed: function()
    {
        Overlay.showMessage(qsTr("Couldn't authenticate! Try re-linking your Twitch account in Configuration."));
        this.m_tryingToLogin = false;
        this.close();
        if( this.m_reconnectTimer )
            this.m_reconnectTimer.stop();
    },

    socketRead: function(message)
    {
        var self = this;
        /*
        if( message == this.m_hack_lastLine )
            return;

        this.m_hack_lastLine = message;
*/
        var lines = message.split("\n");
        for( var x=0; x < lines.length; x++ )
        {
            var line = lines[x];
            line = line.replace('\r', '');
            if( line.length == 0 )
                continue;

            console.log("IRC: "+line);

            var parts = line.split(' ');
            if( parts[0] == 'PING' )
            {
                console.log("PING received ("+line+"), sending PONG...");
                this.write("PONG "+parts[1]+"\n");
            }
            else if( parts[1] == 'NOTICE' && parts[3] == ':Login' && parts[4] == 'authentication' && parts[5] == 'failed')
            {
                console.log("Failed to authenticate. Token expired?");
                this.authFailed();
            }
            else if( parts[1] == '376' )
            {
                this.m_tryingToLogin = false;

                console.log("Enabling Twitch tags....");
                this.write("CAP REQ :twitch.tv/tags\n");

                console.log("Joining channel: #"+Overlay.channel);
                this.write("JOIN #"+Overlay.channel+"\n");
            }
            else if( parts[1] == '353' )
            {
                console.log("NAMES line...");
            }
            else if( parts[1] == 'PRIVMSG' )
            {
                var nickparts = parts[0].split('!');
                var text = line.substr( parts[0].length + parts[1].length + parts[2].length + 4 );
                var username = nickparts[0].substr(1);
                this.fetchAvatar( 0, username );
                this.chatSingleMessage( username, text );
            }
            else if( parts[0].substr(0,1) == '@' && parts[2] == 'PRIVMSG' )
            {
                // Twitch-tagged message.
                var tagpairs = parts[0].substr(1).split(';');

                // Create a hash:
                var tags = {};
                for( var y=0; y < tagpairs.length; y++ )
                {
                    var tagset = tagpairs[y].split('=');
                    var k = tagset[0];
                    var v = tagset[1];
                    if( k == 'emotes' && v.length > 0 )
                    {
                        var emotereps = [];

                        // Further parse these out:
                        var emotes = v.split('/');
                        for( var z=0; z < emotes.length; z++ )
                        {
                            var eline = emotes[z];
                            var idtoreps = eline.split(':');
                            var reps = idtoreps[1].split(',');
                            for( var a=0; a < reps.length; a++ )
                            {
                                var reppair = reps[a];
                                var sf = reppair.split('-');
                                emotereps.push( [ idtoreps[0], sf[0], sf[1] ] );
                            }
                        }
                        emotereps.sort( function(a,b) { return parseInt(a[1]) - parseInt(b[1]); } );
                        tags[k] = emotereps;
                    }
                    else
                        tags[k] = v;
                }

                console.log("TAGS: "+JSON.stringify(tags,null,2));

                var nickparts = parts[1].split('!');
                var text = line.substr( parts[0].length + parts[1].length + parts[2].length + parts[3].length + 5 );
                if( tags['emotes'] )
                {
                    // Parse emotes in:
                    var newtext = '';
                    var offset = 0;
                    for( var z=0; z < tags['emotes'].length; z++ )
                    {
                        var emote = tags['emotes'][z];
                        var id = emote[0];
                        var s = parseInt(emote[1]);
                        var e = parseInt(emote[2]);
                        var piece = text.substr(offset,s-offset).replace(/</g, '&lt;');
                        piece = piece.replace(/>/g, '&gt;');
                        newtext += piece;
                        newtext += '<img height=16 width=16 src="http://static-cdn.jtvnw.net/emoticons/v1/'+id+'/1.0" />';
                        offset = e+1;
                    }
                    if( offset < text.length )
                    {
                        var piece = text.substr(offset).replace('<', '&lt;');
                        piece = piece.replace('>', '&gt;');
                        newtext += piece;
                    }

                    text = newtext;
                }
                else
                {
                    text = text.replace(/</g, '&lt;');
                    text = text.replace(/>/g, '&gt;');
                }

                // Handle /me actions:
                var checkAction = /^\u0001ACTION (.*)\u0001/;
                var res = checkAction.exec(text);
                if( res && res.length > 1 )
                {
                    text = "<i>"+res[1]+"</i>";
                }

                // Let's grab the avatar:
                var username = nickparts[0].substr(1);
                this.fetchAvatar( 0, username );

                // Post the message:
                if( tags['display-name'] && tags['display-name'].length > 0 )
                    this.chatSingleMessage( username, text, tags['display-name'] );
                else
                    this.chatSingleMessage( username, text, username );
            }
        }
    },

    socketDisconnected: function()
    {
        console.log("IRC: Disconnected.");
        if( this.m_reconnectTimer )
            this.m_reconnectTimer.start();
    },

    addUser: function( username, data )
    {
        this.m_users[username] = data;
    },

    removeUser: function( username )
    {
        if( this.m_users[username] )
            delete this.m_users[username];
    },

    fetchAvatar: function( userid, username, callback )
    {
        var self = this;
        if( !this.m_users[username] )
        {
            // Grab their avatar:
            var headers = [ [ 'Client-ID', self.m_clientid ], [ 'Authorization', 'Bearer '+Overlay.authkey ] ];
            var url = 'https://api.twitch.tv/helix/users?login=' + username;

            this.httpRequester(url, function(pkt){
                console.log("Avatar response: "+pkt);
                var json = JSON.parse(pkt);
                var aurl = json['data'][0]['profile_image_url'];
                self.addUser( username, aurl );
                console.log("Avatar URL for '"+username+"' is '"+self.m_users[username]+"'");
                if( callback )
                    callback( username, aurl );

                for( var x=0; x < self.m_avatarHooks.length; x++ )
                {
                    self.m_avatarHooks[x]( username, aurl );
                }
            }, headers);
        }
        else if( callback )
            callback( username, this.m_users[username] );
    },

    chatSingleMessage: function(username, message, styledusername)
    {
        if( message.length == 0 ) return;

        message = message.replace('\r', '');

        var roles = [];
        if( username == Overlay.username )
            roles.push('Owner');

        var msg = {
            'username': username,
            'userid': username,
            'styledusername': '<b>'+styledusername+'</b>', // TODO: roles based on IRC rank?
            'roles': roles, // TODO: roles based on IRC rank?
            'timestamp': new Date(),
            'historic': false,
            'message': message,
            'avatarUrl': this.m_users[username] || ''
        }

        console.log(JSON.stringify(msg,null,2));
        for( var x=0; x < this.m_chatHooks.length; x++ )
        {
            this.m_chatHooks[x]( msg );
        }

        chatter.chat(msg);
    },

    sendMessage: function(msg) {
        console.log("Sending message: "+msg);
        this.write("PRIVMSG #"+Overlay.channel+" :"+msg+"\n");
    },

    httpRequester: function(url, callback, headers) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var a = doc.responseText;
                callback(a);
            }
        }

        doc.open("GET", url);
        if( headers )
        {
            for( var x=0; x < headers.length; x++ )
            {
                var h = headers[x];
                doc.setRequestHeader(h[0], h[1]);
            }
        }
        doc.send();
    },

    sendBulkMessage: function(msg) {
        return sendMessage(msg);
    },

    processBulkMessages: function() {
    }
};
