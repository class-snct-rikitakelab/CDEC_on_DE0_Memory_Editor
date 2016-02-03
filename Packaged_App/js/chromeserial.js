(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Serial = (function() {
    var connectionId;

    connectionId = null;

    function Serial(parms) {
      this.getData = __bind(this.getData, this);
      var name, value;
      for (name in parms) {
        value = parms[name];
        this[name] = value;
      }
      this.getPorts();
    }

    Serial.prototype.getPorts = function() {
      return chrome.serial.getDevices((function(_this) {
        return function(ports) {
          var i, port, value;
          for (i in ports) {
            value = ports[i];
            port = value.path;
            _this.select.appendChild(new Option(port, port));
          }
        };
      })(this));
    };

    Serial.prototype.startConnection = function() {
      var config, portName;
      portName = this.select.childNodes[this.select.selectedIndex].value;
      config = {
        bitrate: this.bitrate,
        dataBits: this.dataBits,
        parityBit: this.parityBit,
        stopBits: this.stopBits,
        receiveTimeout: this.receiveTimeout
      };
      chrome.serial.connect(portName, config, function(openInfo) {
        connectionId = openInfo.connectionId;
        console.log("connectionId = " + connectionId);
      });
    };

    Serial.prototype.endConnection = function() {
      return chrome.serial.disconnect(connectionId, function(result) {});
    };
    
    Serial.prototype.startWriteReplyReceive = function() {
      console.log("Receive start");
      return chrome.serial.onReceive.addListener(this.getWriteReplyReceiveData);
    };

    Serial.prototype.startReadReceive = function() {
      console.log("Receive start");
      return chrome.serial.onReceive.addListener(this.getReadReceiveData);
    };

    Serial.prototype.getWriteReplyReceiveData = function(replyInfo) {
      var data,str;
      data = new Uint8Array(replyInfo.data);
      str = String.fromCharCode.apply(null,data);
      return this.writeReplyReceiveCallback(str);
    };

    Serial.prototype.getReadReceiveData = function(readInfo) {
      var data;
      data = new Uint8Array(readInfo.data);
      str = String.fromCharCode.apply(null,data);
      return this.readReceiveCallback(str);
    };

    Serial.prototype.sendData = function(message) {
      var array, buffer, i, value, _i, _len;
      buffer = new ArrayBuffer(message.length);
      array = new Uint8Array(buffer);
      for (i = _i = 0, _len = message.length; _i < _len; i = ++_i) {
        value = message[i];
        array[i] = value;
      }
      return chrome.serial.send(connectionId, buffer, (function(_this) {
        return function(sendInfo) {
          return _this.sendCallback(sendInfo);
        };
      })(this));
    };

    return Serial;

  })();

}).call(this);
