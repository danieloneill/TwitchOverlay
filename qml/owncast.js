let api = {
    m_wsurl: false,
    m_owncastHost: '',
    m_accessToken: false,
    m_username: false,

    m_chatHooks: [],

    m_chatSocket: false,
    m_reconnectTimer: false,
    m_chatModel: false,

    valid: function() {
        return this.m_wsurl.length > 0 && this.m_accessToken.length > 0;
    },

    hookChat: function(callback) {
        if( this.m_chatHooks.indexOf(callback) !== -1 )
            return;
        this.m_chatHooks.push(callback);
    },

    extractUrls: function()
    {
        const owncastHost = settings.owncastHost;
        const accessToken = settings.owncastToken;

        let wsurl;
        if( owncastHost.substr(0,8) === 'https://' )
            wsurl = 'wss://' + owncastHost.substr(8) + '/ws';
        else
            wsurl = 'ws://' + owncastHost.substr(7) + '/ws';

        this.m_owncastHost = owncastHost;
        this.m_wsurl = wsurl;
        this.m_accessToken = accessToken;

        console.log("Owncast WS: Remote URL set to: "+wsurl);
        this.m_chatSocket.url = this.m_wsurl + '?accessToken=' + this.m_accessToken;
    },

    create: function(chatModel)
    {
        let self = this;
        this.m_chatModel = chatModel;

        this.m_chatSocket = Qt.createQmlObject('import QtWebSockets 1.1; WebSocket { id: socket }', chatModel, 'm_chatSocket');
        this.m_chatSocket.statusChanged.connect( function(status) {
            console.log("Owncast WebSocket status: "+status+" => "+self.m_chatSocket.errorString);
            if( status === 1 )
                self.socketConnected();
            else if( status === 3 )
                self.socketDisconnected();
        });
        this.m_chatSocket.textMessageReceived.connect( function(msg) {
            self.socketRead(msg);
        });

        this.m_reconnectTimer = Qt.createQmlObject('import QtQuick 2.0; Timer { id: timer }', chatModel, 'm_reconnectTimer');
        console.log(`Owncast ReconnectTimer: ${this.m_reconnectTimer}`);
        this.m_reconnectTimer.interval = 10000;
        this.m_reconnectTimer.repeat = false;
        this.m_reconnectTimer.triggered.connect( function() { self.open() } );
    },

    open: function()
    {
        this.extractUrls();
        this.m_chatSocket.active = false;
        if( !this.valid() )
            return;

        console.log("Owncast WS: Connecting...");
        this.m_chatSocket.active = true;
    },

    close: function()
    {
        console.log("Owncast WS: Disconnecting.");
        this.m_chatSocket.active = false;
    },

    socketConnected: function()
    {
        console.log("Owncast WS: Connected.");
        this.m_reconnectTimer.stop();
    },

    socketRead: function(message)
    {
        let self = this;
        let json;
        try {
            json = JSON.parse(message);
        } catch(err) {
            console.log("Parse error: "+message);
            return;
        }

        if( json['type'] === 'PING' )
        {
            const reply = JSON.stringify( { 'type':'PONG', 'body':json['body'] } );
            this.m_chatSocket.sendTextMessage(reply);
        }
        else if( json['type'] === 'NAME_CHANGE'
              || json['type'] === 'USER_JOINED'
              || json['type'] === 'CHAT_ACTION' )
            this.chatAction(json);
        else if( json['type'] === 'CHAT' )
            this.chatSingleMessage( json );
        else if( json['type'] === 'CONNECTED_USER_INFO' )
            this.m_username = json['user']['displayName'];
        else if( json['type'] !== 'VISIBILITY-UPDATE' )
        {
            this.chatAction( { 'type':'unknown', 'body':JSON.stringify(json,null,2) } );
        }
    },

    socketDisconnected: function()
    {
        console.log("Owncast WS: Disconnected.");
        try {
            this.m_reconnectTimer.start();
        } catch(e) {
            console.log("Owncast WS: Reconnect timer stopped: "+e);
        }
    },

    serverStats: function( cb )
    {
        return this.httpRequester( this.m_owncastHost+'/api/status', cb, [] );
    },

    chatAction: function(packet)
    {
        let colour = '#cabada';
        let msg = `Action: ${packet['type']} -> ${packet['body']}`;
        if( packet['type'] === 'NAME_CHANGE' )
        {
            colour = '#aa7788';
            const oldName = packet['oldName'];
            const username = packet['user']['displayName'];
            msg = `User '${oldName}' is now known as '${username}'.`;
        }
        else if( packet['type'] === 'USER_JOINED' )
        {
            colour = '#ff7799';
            const username = packet['user']['displayName'];
            msg = `User '${username}' has joined.`;
        }
        else if( packet['type'] === 'CHAT_ACTION' )
        {
            colour = '#ddaa88';
            msg = packet['body'];
        }
	
        let ts = new Date(packet['timestamp']);
        let shortTime = `${ts.getHours()}:${(''+ts.getMinutes()).padStart(2, '0')}`;
	
        let message = `<span style="font-weight: 700; color: ${colour}">${msg}</span>`;
        let ent = {
            'facility': 'owncast',
            'type': 'action',
            'username': 'action',
            'styledusername': 'action',
            'timestamp': shortTime,
            'message': message,
            'avatarUrl': ''
        }

        console.log("Owncast Message: "+JSON.stringify(ent,null,2));
        this.m_chatHooks.forEach( e => e(ent) );
    },

    chatSingleMessage: function(packet)
    {
        console.log(`Packet: ${JSON.stringify(packet,null,2)}`);
        let message = packet['body'];
        let username = packet['user']['displayName'];
        if( message.length === 0 ) return;

        message = message.replace('\r', '');

        let flair = '';
        if( packet['user']['scopes'] && packet['user']['scopes'].includes('MODERATOR') )
            flair += `<img width="${chatter.overlayscale * 13}" height="${chatter.overlayscale * 13}" src="${this.m_owncastHost}/img/moderator-nobackground.svg" /> `;

        const colour = packet['user']['displayColor'];
        let ts = new Date(packet['timestamp']);
        let shortTime = `${ts.getHours()}:${(''+ts.getMinutes()).padStart(2, '0')}`;
        let msg = {
            'facility': 'owncast',
            'type': 'chat',
            'username': username,
            'styledusername': `${flair}<span style="font-weight: 700; color: #${colour}">${username}</span>`,
            'timestamp': shortTime,
            'message': message,
            'avatarUrl': ''
        }

        console.log("Owncast Message: "+JSON.stringify(msg,null,2));
        this.m_chatHooks.forEach( e => e(msg) );
    },

    sendMessage: function(message) {
        const obj = { 'type':'CHAT', 'body':message };
        const txt = JSON.stringify(obj);
        console.log("Owncast Sending message: "+txt);
        this.m_chatSocket.sendTextMessage(txt);
    },

    httpRequester: function(url, callback, headers) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
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

    httpPostRequester: function(url, callback, headers, params) {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if( doc.readyState === XMLHttpRequest.DONE )
            {
                console.log("Owncast Response status: "+doc.status);
                var a = doc.responseText;
                callback(a);
            }
        }

        doc.open("POST", url, true);
        doc.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        if( headers )
        {
            for( var x=0; x < headers.length; x++ )
            {
                var h = headers[x];
                doc.setRequestHeader(h[0], h[1]);
            }
        }
        doc.send(params);
    }
};

function getApi() { return api; }
