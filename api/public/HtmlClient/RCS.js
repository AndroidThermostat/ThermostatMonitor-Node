function rcsUpdate(t) {
    var socket = Titanium.Network.createTCPSocket(t.ipAddress, 2000);
    socket.onRead(function(data) {

        if (data == '*HELLO*') {
            socket.write('\rA=1 R=1\r');
        } else if (data.indexOf(' T') > -1) {
            var parts = data.split(' ');
            for (i = 0; i < parts.length; i++) {
                var part = parts[i];
                if (part.substring(0, 1) == 'T') t.temperature = part.replace('T=', '');
            }
            socket.write('\rA=1 R=2\r');
        } else {
            var parts = data.split(' ');
            var fan = false;
            for (i = 0; i < parts.length; i++) {
                var part = parts[i];
                switch (part) {
                    case 'FA=1':
                        fan = true;
                        break;
                    case 'H1A=1':
                        t.state = 'Heat';
                        break;
                    case 'C1A=1':
                        t.state = 'Cool';
                        break;
                }
            }
            if (fan && t.state=='Off') t.state='Fan';
            t.lastUpdated = new Date();
            t.successfulUpdate = true;
            socket.close();
        }

    });
    t.successfulUpdate = false;
    t.state = 'Off';
    socket.connect();
    
    
}