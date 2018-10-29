var api = {
    m_chatHooks: [],
    m_avatarHooks: [],
    m_users: [],

    // FIXME: This is to prevent duplicate messages.
//    m_hack_lastLine: '',

    m_credentials: {},

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

    create: function(chatModel)
    {
        var self = this;
        this.m_chatModel = chatModel;
        this.m_chatSocket = Qt.createQmlObject('import org.jemc.qml.Sockets 1.0; TCPSocket { id: socket }', chatModel, 'm_chatSocket');
        this.m_chatSocket.connected.connect( function() { self.socketConnected(); } );
        this.m_chatSocket.read.connect( function(message) { self.socketRead(message); } );
        this.m_chatSocket.disconnected.connect( function() { self.socketDisconnected(); } );

        this.m_chatSocket.host = 'irc.chat.twitch.tv';
        this.m_chatSocket.port = 6667;

        this.m_reconnectTimer = Qt.createQmlObject('import QtQuick 2.0; Timer { id: timer }', chatModel, 'm_reconnectTimer');
        this.m_reconnectTimer.interval = 10000;
        this.m_reconnectTimer.repeat = false;
        this.m_reconnectTimer.triggered.connect( function() { self.open() } );
    },

    open: function()
    {
        this.m_chatSocket.disconnect();
        this.m_chatSocket.connect();
        console.log("IRC: Connecting...");
    },

    close: function()
    {
        console.log("IRC: Disconnecting.");
        this.m_chatSocket.disconnect();
    },

    socketConnected: function()
    {
        console.log("IRC: Connected.");
        this.m_reconnectTimer.stop();
        this.m_chatSocket.write("USER "+this.m_credentials['username']+" "+this.m_credentials['username']+" "+this.m_credentials['username']+" "+this.m_credentials['username']+"\n");
        this.m_chatSocket.write("PASS "+this.m_credentials['authkey']+"\n");
        this.m_chatSocket.write("NICK "+this.m_credentials['username']+"\n");
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
            console.log("IRC: "+line);

            var parts = line.split(' ');
            if( parts[0] == 'PING' )
            {
                console.log("PING received ("+line+"), sending PONG...");
                this.m_chatSocket.write("PONG "+parts[1]+"\n");
            }
            else if( parts[1] == '376' )
            {
                console.log("Joining channel: #"+this.m_credentials['channel']);
                this.m_chatSocket.write("JOIN #"+this.m_credentials['channel']+"\n");
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
            var url = 'http://dawnnest.com/userinfo.php?login=' + username;

            // TODO: Use the twitch auth oauth bearer heyitsmeandallgood auth thing with the server auth thing stuff to say "authed".. or something:
            //var url = 'https://api.twitch.tv/helix/users?login=' + username;
            //var headers = [ ['Client-ID', this.m_credentials['clientid']], ['Authorization', 'Bearer '+this.m_credentials['clientsecret']] ];

            this.httpRequester(url, function(pkt){
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
//            }, headers);
              });
        }
        else if( callback )
            callback( username, this.m_users[username] );
    },

    chatSingleMessage: function(username, message)
    {
        if( message.length == 0 ) return;

        message = message.replace('\r', '');

        var roles = [];
        if( username == this.m_credentials['username'] )
            roles.push('Owner');

        var msg = {
            'username': username,
            'userid': username,
            'styledusername': '<b>'+username+'</b>', // TODO: roles based on IRC rank?
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
        this.m_chatSocket.write("PRIVMSG #"+this.m_credentials['channel']+" :"+msg+"\n");
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
