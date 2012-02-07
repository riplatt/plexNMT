import mx.xpath.XPathAPI;

class plexNMT.as2.api.PopAPI
{
	var hardware:Array = [
						  {isPCH:false,
						  remoteCodes:"",
						  sharesFrom:"",
						  loadPage:false,
						  pchEject:false,
						  sharePwStrip:false,
						  frimware:"",
						  modelName:"",
						  settingCode:""
						  }];
	var enviroment:Array = [{
							playerFirmware:"",
							hyperDraw:0
							}];
    function PopAPI()
    {
    } // End of the function
    public function model(callback)
    {
        trace ("popapi: getting player model");
        PopAPI.get("system?arg0=get_firmware_version", PopAPI.onDetectPlayer, callback);
    } // End of the function
    private function onDetectPlayer(success, xml, errorcode, callback)
    {
        if (success)
        {
            hardware["isPCH"] = true;
            hardware["remoteCodes"] = "SYABAS";
            hardware["sharesFrom"] = "pch";
            hardware["loadPage"] = true;
            hardware["pchEject"] = true;
            hardware["sharePwStrip"] = true;
            var _loc1 = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/firmwareVersion").firstChild.nodeValue.toString();
            enviroment.playerFirmware = _loc1;
            hardware["firmware"] = _loc1;
            var _loc4 = _loc1.indexOf("-POP-") + 5;
            var _loc3 = _loc1.lastIndexOf("-");
            var _loc2 = _loc1.substring(_loc4, _loc3);
            trace ("tmodel " + _loc2);
            switch (_loc2)
            {
                case "412":
                case "413":
                {
                    hardware["modelName"] = "POPBOX 3D";
                    hardware["loadPage"] = false;
                    hardware["pchEject"] = false;
                    hardware["settingCode"] = "pb";
                    hardware["sharesFrom"] = "api";
                    hardware["sharePwStrip"] = false;
                    enviroment.hyperdraw = int(ev.Common.evSettings.pbhyperdraw);
                    break;
                } 
                case "415":
                {
                     hardware["modelName"] = "AsiaBox";
                    hardware["settingCode"] = "ab";
                    enviroment.hyperdraw = int(ev.Common.evSettings.abhyperdraw);
                    break;
                } 
                default:
                {
                     hardware["modelName"] = "Popcorn Hour 200 Series";
                    hardware["settingCode"] = "pch";
                    enviroment.hyperdraw = int(ev.Common.evSettings.pchhyperdraw);
                    break;
                } 
            } // End of switch
            if (enviroment.hyperdraw < 0 || enviroment.hyperdraw > 10)
            {
                enviroment.hyperdraw = 0;
            } // end if
            callback(true);
        }
        else
        {
            trace ("error talking to api, errorcode " + errorcode);
            callback(false, errorcode);
        } // end else if
    } // End of the function
	
    static function uniqueid(callback)
    {
        trace ("popapi: getting mac address");
        PopAPI.get("system?arg0=get_mac_address", PopAPI.onMacLoaded, callback);
    } // End of the function
    static function onMacLoaded(success, xml, errorcode, callback)
    {
        if (success)
        {
            var _loc1 = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/macAddress").firstChild.nodeValue.toString();
            enviroment.hardware.id = _loc1.split(":").join("");
            enviromentmacAddress = enviroment.hardware.id;
            trace ("mac address of player: " + enviromentmacAddress);
            callback(true);
        }
        else
        {
            trace ("error talking to api, errorcode " + errorcode);
            callback(false, errorcode);
        } // end else if
    } // End of the function
    static function drives(callback)
    {
        PopAPI.get("system?arg0=list_devices", PopAPI.onDrivesLoaded, callback);
    } // End of the function
    static function onDrivesLoaded(success, xml, errorcode, callback)
    {
        if (success)
        {
            trace ("ondrivesloaded");
            var _loc8 = XPathAPI.selectNodeList(xml.firstChild, "/theDavidBox/response/device");
            var _loc7 = _loc8.length;
            if (_loc7 > 0)
            {
                trace ("found " + _loc7 + " drives");
                enviromentdrives = new Array();
                for (var _loc2 = 0; _loc2 < _loc7; ++_loc2)
                {
                    var _loc1 = _loc8[_loc2];
                    var _loc3 = XPathAPI.selectSingleNode(_loc1, "/device/type").firstChild.nodeValue.toString();
                    var _loc4 = XPathAPI.selectSingleNode(_loc1, "/device/name").firstChild.nodeValue.toString().toLowerCase();
                    var _loc5 = XPathAPI.selectSingleNode(_loc1, "/device/accessPath").firstChild.nodeValue.toString();
                    trace ("...type " + _loc3 + " name " + _loc4 + " path " + _loc5);
                    enviromentdrives.push({type: _loc3, name: _loc4, path: _loc5});
                } // end of for
            }
            else
            {
                trace (".. no attached drives");
            } // end else if
            callback(true);
        }
        else
        {
            trace ("error talking to api, errorcode " + errorcode);
            callback(false, errorcode);
        } // end else if
    } // End of the function
    static function shares(callback)
    {
        switch (enviroment.hardware.sharesfrom)
        {
            case "api":
            {
                PopAPI.get("setting?arg0=list_network_shared_folder", PopAPI.onAPIShares, callback);
                break;
            } 
            default:
            {
                if (PopAPI.apiurl == "127.0.0.1:8008/")
                {
                    PopAPI.fileget("/tmp/setting.txt", PopAPI.onPCHShares, callback);
                }
                else
                {
                    PopAPI.fileget("../../tmp/setting.txt", PopAPI.onPCHShares, callback);
                } // end else if
                break;
            } 
        } // End of switch
    } // End of the function
    static function onAPIShares(success, xml, errorcode, callback)
    {
        if (success)
        {
            var _loc16 = XPathAPI.selectNodeList(xml.firstChild, "/theDavidBox/response/networkShare");
            var _loc17 = _loc16.length;
            enviromentshares = new Array();
            for (var _loc4 = 0; _loc4 < _loc17; ++_loc4)
            {
                var _loc6 = _loc16[_loc4];
                var _loc5 = XPathAPI.selectSingleNode(_loc6, "/networkShare/shareName").firstChild.nodeValue.toString();
                var _loc12 = XPathAPI.selectSingleNode(_loc6, "/networkShare/url").firstChild.nodeValue.toString().slice(4);
                if (tools.StringUtil.beginsWith(_loc12, "nfs"))
                {
                    var _loc14 = _loc12.indexOf("[");
                    var _loc3 = _loc12.indexOf("]");
                    var _loc8 = _loc12.slice(0, _loc14);
                    _loc12 = _loc8 + _loc12.slice(_loc3 + 1);
                    var _loc9 = _loc12;
                    var _loc7 = "";
                    var _loc11 = "";
                }
                else
                {
                    _loc7 = "";
                    _loc11 = "";
                    var _loc1 = _loc12;
                    if (enviroment.hardware.sharepwstrip)
                    {
                        _loc14 = _loc1.indexOf("[");
                        _loc3 = _loc1.indexOf("]");
                        var _loc13 = _loc1.slice(0, _loc1.indexOf(":"));
                        if (_loc3 != undefined && _loc3 > 1 && _loc3 != null)
                        {
                            var _loc10 = _loc1.slice(_loc14, _loc3 + 1);
                            _loc1 = _loc13 + "://" + _loc12.slice(_loc3 + 1);
                            var _loc2 = new Array();
                            _loc2 = _loc10.split("=");
                            _loc7 = _loc2[0].slice(1);
                            if (_loc2[1].length > 1)
                            {
                                _loc11 = _loc2[1].slice(0, _loc2[1].length - 1);
                            } // end if
                        } // end if
                    } // end if
                    _loc9 = _loc1;
                } // end else if
                enviromentshares.push({share: _loc5, url: _loc12, mounturl: _loc9, username: _loc7, password: _loc11});
                trace (".. name: " + _loc5 + " url: " + _loc12 + " user: " + _loc7 + " pw: " + _loc11 + " mounturl: " + _loc9);
            } // end of for
            callback(true);
        }
        else
        {
            callback(false, "10005");
        } // end else if
    } // End of the function
    static function onPCHShares(success, data, callback)
    {
        if (success)
        {
            var _loc5 = new Array();
            for (var _loc6 = 0; _loc6 < data.length; ++_loc6)
            {
                if (tools.StringUtil.beginsWith(data[_loc6], "servname") || tools.StringUtil.beginsWith(data[_loc6], "servlink"))
                {
                    var _loc1 = data[_loc6].split("=");
                    if (_loc1[1] != "" && _loc1[1] != null && _loc1[1] != undefined)
                    {
                        var _loc3 = int(_loc1[0].slice(8));
                        --_loc3;
                        _loc1.shift();
                        _loc1 = _loc1.join("=");
                        if (_loc5[_loc3].kind == undefined)
                        {
                            _loc5[_loc3] = new Array();
                            _loc5[_loc3].kind = "share";
                        } // end if
                        if (tools.StringUtil.beginsWith(data[_loc6], "servlink"))
                        {
                            if (tools.StringUtil.beginsWith(_loc1, "nfs"))
                            {
                                var _loc2 = tools.StringUtil.replace(_loc1, "&smb.user=&smb.passwd=", "");
                                _loc1 = _loc2.slice(_loc2.indexOf(":") + 3);
                                _loc1 = tools.StringUtil.replace(_loc1, ":/", "");
                                _loc2 = _loc2.slice(0, _loc2.indexOf(":") + 3) + _loc1;
                                var _loc9 = "";
                                var _loc11 = "";
                                var _loc12 = _loc2;
                            }
                            else
                            {
                                _loc2 = tools.StringUtil.replace(_loc1, "&smb.user=", "[");
                                _loc2 = tools.StringUtil.replace(_loc2, "&smb.passwd=", "=") + "]";
                                _loc2 = _loc2.slice(6);
                                _loc1 = _loc2.split("[");
                                _loc2 = "smb://[" + _loc1[1] + _loc1[0];
                                _loc9 = "";
                                _loc11 = "";
                                var _loc4 = _loc2;
                                var _loc15 = _loc4.indexOf("[");
                                var _loc8 = _loc4.indexOf("]");
                                var _loc14 = _loc4.slice(0, _loc4.indexOf(":"));
                                if (_loc8 != undefined && _loc8 > 1 && _loc8 != null)
                                {
                                    var _loc13 = _loc4.slice(_loc15, _loc8 + 1);
                                    _loc4 = _loc14 + "://" + _loc2.slice(_loc8 + 1);
                                    var _loc7 = new Array();
                                    _loc7 = _loc13.split("=");
                                    _loc9 = _loc7[0].slice(1);
                                    if (_loc7[1].length > 1)
                                    {
                                        _loc11 = _loc7[1].slice(0, _loc7[1].length - 1);
                                    } // end if
                                } // end if
                                _loc12 = _loc4;
                            } // end else if
                            trace ("... url: " + _loc2 + " mounturl: " + _loc12 + " user: " + _loc9 + " pw: " + _loc11);
                            _loc5[_loc3].url = _loc2;
                            _loc5[_loc3].mounturl = _loc12;
                            _loc5[_loc3].username = _loc9;
                            _loc5[_loc3].password = _loc11;
                            continue;
                        } // end if
                        _loc5[_loc3].share = _loc1.toLowerCase();
                    } // end if
                } // end if
            } // end of for
            enviromentshares = new Array();
            if (_loc5.length != 0)
            {
                enviromentshares = _loc5;
            } // end if
            callback(true);
        }
        else
        {
            callback(false, "10004");
        } // end else if
    } // End of the function
    static function playvideo(callback)
    {
    } // End of the function
    static function systemled(toggle)
    {
        trace ("switching system led to " + toggle);
        switch (toggle)
        {
            case "off":
            {
                PopAPI.send("system?arg0=set_system_led&arg1=off");
                break;
            } 
            case "blink":
            {
                PopAPI.send("system?arg0=set_system_led&arg1=blink");
                break;
            } 
            default:
            {
                PopAPI.send("system?arg0=set_system_led&arg1=on");
                break;
            } 
        } // End of switch
    } // End of the function
    static function send(command, callback, origcallback)
    {
        trace ("popapi send command: " + command);
        var _loc1 = "http://" + PopAPI.apiurl + command;
        PopAPI.loadSEND(_loc1, callback, origcallback);
    } // End of the function
    static function get(command, callback, origcallback)
    {
        trace ("popapi get command: " + command);
        var _loc1 = "http://" + PopAPI.apiurl + command;
        PopAPI.loadSEND(_loc1, callback, origcallback);
    } // End of the function
    static function fileget(command, onLoad, callback)
    {
        PopAPI.loadfileGET(command, onLoad, callback);
    } // End of the function
    static function loadSEND(url, onLoad, callback)
    {
        var xml = new XML();
        xml.ignoreWhite = true;
        xml.onLoad = function (success)
        {
            if (xml.status == 0 && success == true)
            {
                var _loc1 = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/returnValue").firstChild.nodeValue.toString();
                if (_loc1 == "0")
                {
                    trace ("popapi send successful");
                    onLoad(true, xml, null, callback);
                }
                else
                {
                    trace ("popapi send unsuccessful, pch error");
                    onLoad(false, xml, int(_loc1), callback);
                } // end else if
            }
            else
            {
                onLoad(false, null, null, callback);
            } // end else if
            delete xml.idMap;
            xml = null;
        };
        xml.load(url);
    } // End of the function
    static function loadfileGET(url, onLoad, callback)
    {
        var my_lv = new LoadVars();
        my_lv.onData = function (src)
        {
            if (src != undefined)
            {
                var _loc1 = src.split("\n");
                onLoad(true, _loc1, callback);
            }
            else
            {
                onLoad(false, null, callback);
            } // end else if
            my_lv = null;
        };
        my_lv.load(url);
    } // End of the function
    static var apiurl = "127.0.0.1:8008/";
} // End of Class
