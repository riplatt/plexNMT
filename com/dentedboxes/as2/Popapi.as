// Eversion, the flash interface for YAMJ on the Syabas Embedded Players
// Copyright (C) 2012  Bryan Socha, aka Accident

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import ev.Common;
import tools.Data;
import tools.StringUtil;
import mx.xpath.XPathAPI;
import ExtCommand;

class api.Popapi {
	public static var apiurl:String="127.0.0.1:8008/";
	//public static var apiurl:String="10.1.2.224:8008/";
	//public static var apiurl:String="10.1.2.210/relay.php?";
	public static var disabled:Boolean=null;

// ****************  CALLED ROUTINES ***************

// toggle screensaver
	public static function screensaver(onoff, callback) {
		trace("popapi: suspend_screensaver "+onoff);
		Popapi.get("system?arg0=suspend_screensaver&arg1="+onoff,callback, callback);
	}

// cancel playback
	public static function stopvideo(callback:Function) {
		trace("popapi: stop_vod");
		Popapi.get("playback?arg0=stop_vod",callback, callback);
	}

// launcher
	public static function launcher(callback:Function) {
		trace("popapi: launcher call");
		Popapi.get("system?arg0=load_launcher",callback, callback);
	}

// gaya eject button
	public static function presseject(callback:Function) {
		trace("popapi: pressing eject");
		Popapi.get("system?arg0=send_key&arg1=eject&arg2=flashlite",callback, callback);
	}

// gaya eject
	public static function htmlexit(page, show, callback:Function) {
		var exit = "system?arg0=load_page&arg1=" + escape(page);
		if(show) {
			exit = exit+"&arg2=switch"
		}
		trace("popapi: load_page: "+exit);
		Popapi.get(exit,callback, callback);
	}

// load phf
	public static function phfexit(page, show, callback:Function) {
		var exit = "system?arg0=load_phf&arg1=" + escape(page);
		trace("popapi: load_phf: " + exit);
		Popapi.get(exit, callback, callback);
	}


// update the player model name and functionality
	public static function model(callback:Function) {
		trace("popapi: getting player model");
		Popapi.get("system?arg0=get_firmware_version",Popapi.onDetectPlayer, callback);
	}

	public static function onDetectPlayer(success:Boolean, xml:XML,errorcode, callback:Function) {
		if(success) {
			// most likely commons
			Common.evRun.hardware.isPCH = true;
			Common.evRun.hardware.fullmounts = true;
			Common.evRun.hardware.remotecodes = "SYABAS";
			Common.evRun.hardware.sharesfrom = "pch";
			Common.evRun.hardware.loadpage = true;
			Common.evRun.hardware.pcheject = true;
			Common.evRun.hardware.sharepwstrip = true;
			Common.evRun.hardware.bghighres = false;						// assume highres backgrounds aren't working
			Common.evRun.hardware.bghighresplaylist = true;
			Common.evRun.hardware.bghighresplaylistskipnext = false;

			var fware = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/firmwareVersion").firstChild.nodeValue.toString();
			Common.evRun.playerfirmware = fware;
			Common.evRun.hardware.firmware = fware;

			var start = fware.indexOf("-POP-")+5;
			var end = fware.lastIndexOf("-");
			var tmodel = fware.substring(start, end);
			trace("tmodel "+tmodel);

			switch(tmodel) {
				case "412":
				case "413":
					Common.evRun.hardware.modelname = "POPBOX 3D";
					Common.evRun.hardware.loadpage = false;
					Common.evRun.hardware.pcheject = false;
					Common.evRun.hardware.settingcode = "pb";
					Common.evRun.hardware.sharesfrom = "api";
					Common.evRun.hardware.sharepwstrip = false;
					Common.evRun.hyperdraw = int(Common.evSettings["pbhyperdraw"]);
					break;
				case "415":
					Common.evRun.hardware.modelname = "AsiaBox";
					Common.evRun.hardware.settingcode = "ab";
					Common.evRun.hyperdraw = int(Common.evSettings["abhyperdraw"]);
					break;
				case "417":
					Common.evRun.hardware.modelname = "POPBOX V8";
					Common.evRun.hardware.loadpage = false;
					Common.evRun.hardware.pcheject = false;
					Common.evRun.hardware.settingcode = "v8";
					Common.evRun.hardware.sharesfrom = "api";
					Common.evRun.hardware.sharepwstrip = false;
					//Common.evSettings.hyperactivedraw = 16;
					Common.evRun.hyperdraw = int(Common.evSettings["v8hyperdraw"]);
					Common.evRun.hardware.bghighresplaylistskipnext = true;
					break;
				case "420":
					Common.evRun.hardware.modelname = "Popcorn Hour C300";
					Common.evRun.hardware.loadpage = false;
					Common.evRun.hardware.pcheject = false;
					Common.evRun.hardware.settingcode = "c3";
					Common.evRun.hardware.sharesfrom = "api";
					Common.evRun.hardware.sharepwstrip = false;
					//Common.evSettings.hyperactivedraw = 16;
					Common.evRun.hyperdraw = int(Common.evSettings["c3hyperdraw"]);
					Common.evRun.hardware.bghighresplaylistskipnext = true;
					break;
				case "421":
					Common.evRun.hardware.modelname = "Popcorn Hour A300";
					Common.evRun.hardware.loadpage = false;
					Common.evRun.hardware.pcheject = false;
					Common.evRun.hardware.settingcode = "a3";
					Common.evRun.hardware.sharesfrom = "api";
					Common.evRun.hardware.sharepwstrip = false;
					//Common.evSettings.hyperactivedraw = 16;
					Common.evRun.hyperdraw = int(Common.evSettings["a3hyperdraw"]);
					Common.evRun.hardware.bghighresplaylistskipnext = true;
					break;
				default:
					Common.evRun.hardware.modelname = "Popcorn Hour 200 Series";
					Common.evRun.hardware.settingcode = "pch";
					Common.evRun.hyperdraw = int(Common.evSettings["pchhyperdraw"]);
					break;
			}
			if(Common.evRun.hyperdraw < 0 || Common.evRun.hyperdraw > 10) Common.evRun.hyperdraw = 0;

			// check to see if newer firmware with better info
			Popapi.get("system?arg0=system_info", Popapi.onSystemInfo, callback);

			//callback(true);
		} else {
			trace("error talking to api, errorcode "+errorcode);
			callback(false,errorcode);
		}
	}

	public static function onSystemInfo(success:Boolean, xml:XML,errorcode, callback:Function) {
		if(success) {
			trace("newer firmware with system info support!");

			// name
			var temp:String = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/name").firstChild.nodeValue.toString();
			if(temp!=undefined && temp!= null) {
				Common.evRun.hardware.modelname = temp;
				trace("new name "+temp);
			}

			var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/theDavidBox/response/modules/module");
			var xmlDataLen:Number = xmlNodeList.length;

			if(xmlDataLen>0) {
				trace("found " + xmlDataLen + " modules");

				for (var i:Number = 0; i < xmlDataLen; i++) {
					var modulename = xmlNodeList[i].firstChild.nodeValue.toString()
					trace(".. module: "+modulename);
					switch(modulename) {
						case 'gaya':
							var foundgaya = true;
							Common.evRun.hardware.loadpage = true;
							Common.evRun.hardware.pcheject = true;
							Common.evRun.hardware.sharepwstrip = true;
							Common.evRun.hardware.bghighresplaylist = false;
							break;
						default:
							break;
					}
				}
			}

			// activate high res background support
			if(foundgaya==undefined && Common.evRun.hardware.settingcode=="pch") {
				trace("gaya not found and default pch profile in use, switched to limited pb with pch settingcode");

				Common.evRun.hardware.loadpage = false;
				Common.evRun.hardware.pcheject = false;
				Common.evRun.hardware.sharesfrom = "api";
				Common.evRun.hardware.settingcode = "nog";
				Common.evRun.hardware.sharepwstrip = false;
				Common.evRun.hardware.bghighresplaylist = true;
				Common.evRun.hardware.fullmounts = false;
			}

			trace("high res bg support availble");
			Common.evRun.hardware.bghighres = true;
			trace("bg playlist mode: "+Common.evRun.hardware.bghighresplaylist);
			callback(true);
		} else {
			trace("older firmware without system info, not erroring");
			callback(true);
		}
	}

// get the unique id of the player hardware.
	public static function uniqueid(callback:Function) {
		trace("popapi: getting mac address");
		Popapi.get("system?arg0=get_mac_address", Popapi.onMacLoaded, callback);
	}

	public static function onMacLoaded(success:Boolean, xml:XML, errorcode, callback:Function) {
		if(success) {
			var mactemp = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/macAddress").firstChild.nodeValue.toString();
			Common.evRun.hardware.id = mactemp.split(":").join("");
			Common.evRun.macAddress = Common.evRun.hardware.id;		// legacy for now

			trace("mac address of player: " + Common.evRun.macAddress);
			callback(true);
		} else {
			trace("error talking to api, errorcode " + errorcode);
			callback(false,errorcode);
		}
	}

// update the drive list
	public static function drives(callback:Function) {
		Popapi.get("system?arg0=list_devices", Popapi.onDrivesLoaded, callback);
	}

	public static function onDrivesLoaded(success:Boolean, xml:XML, errorcode, callback) {
		if(success) {
			trace("ondrivesloaded");
			// process drives
			var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/theDavidBox/response/device");
			var xmlDataLen:Number = xmlNodeList.length;

			if(xmlDataLen>0) {
				trace("found "+xmlDataLen+" drives");
				Common.evRun.drives = new Array();

				for (var i:Number = 0; i < xmlDataLen; i++) {
					var itemNode = xmlNodeList[i];
					var kind = XPathAPI.selectSingleNode(itemNode, "/device/type").firstChild.nodeValue.toString();
					var name = XPathAPI.selectSingleNode(itemNode, "/device/name").firstChild.nodeValue.toString().toLowerCase();;
					var path =  XPathAPI.selectSingleNode(itemNode, "/device/accessPath").firstChild.nodeValue.toString();
					trace("...type "+kind+" name "+name+" path "+path);
					Common.evRun.drives.push({type:kind,name:name,path:path});
				}
			} else trace(".. no attached drives");

			callback(true);
	    } else {
			trace("error talking to api, errorcode "+errorcode);
			callback(false,errorcode);
		}
	}

// update network share list
	public static function shares(callback:Function) {
		switch(Common.evRun.hardware.sharesfrom) {
			case 'api':
				Popapi.get("setting?arg0=list_network_shared_folder", Popapi.onAPIShares, callback);
				break;
			default:
				if(Popapi.apiurl=="127.0.0.1:8008/") {
					Popapi.fileget("/tmp/setting.txt", Popapi.onPCHShares, callback);
				} else {
					Popapi.fileget("../../tmp/setting.txt", Popapi.onPCHShares, callback);
				}
				break;
		}
	}

	public static function onAPIShares(success:Boolean, xml:XML, errorcode, callback) {
		if(success) {
			var xmlNodeList:Array = XPathAPI.selectNodeList(xml.firstChild, "/theDavidBox/response/networkShare");
			var xmlDataLen:Number = xmlNodeList.length;

			Common.evRun.shares = new Array();
			//trace(xmlDataLen+" items");
			for(var i = 0;i<xmlDataLen;i++) {
				var itemNode = xmlNodeList[i];
				var name = XPathAPI.selectSingleNode(itemNode, "/networkShare/shareName").firstChild.nodeValue.toString();
				var url = XPathAPI.selectSingleNode(itemNode, "/networkShare/url").firstChild.nodeValue.toString();
				if(!StringUtil.beginsWith(url,"nfs") && !StringUtil.beginsWith(url,"smb")) url = url.slice(4);
				if(StringUtil.beginsWith(url,"nfs")) {
					var start=url.indexOf("[");
					var end=url.indexOf("]");
					var newurl=url.slice(0,start);
					var endurl=url.slice(end+1);
					endurl=StringUtil.replace(endurl,":","");
					url=newurl+endurl;
					var mounturl:String=url;
					var username="";
					var password="";
				} else {  // smb username/password
					var username="";
					var password="";
				    var newmount:String=url;

					if(Common.evRun.hardware.sharepwstrip) {
						// strip login from mount url
						var start = newmount.indexOf("[");
						var end = newmount.indexOf("]");
						var typeend = newmount.slice(0,newmount.indexOf(":"));

						//trace("end "+end);
						if(end != undefined && end > 1 && end != null) {
							//trace("mount is "+newmount);
							//trace("user/password to strip");
							var templogin = newmount.slice(start,end+1);
							newmount = typeend + "://" + url.slice(end+1);
							//trace("temp login "+templogin+" new mount "+newmount);

							// extract login
							var tempcred:Array=new Array();
							tempcred=templogin.split("=");
							username=tempcred[0].slice(1);
							if(tempcred[1].length > 1) {
								password=tempcred[1].slice(0,tempcred[1].length-1);
							}
							//trace("username: "+username+" password "+password);
						}
					}
					var mounturl:String = newmount;
				}
				Common.evRun.shares.push({share:name, url:url, mounturl:mounturl, username:username, password:password});
				trace(".. name: " + name + " url: " + url + " user: " + username + " pw: " + password + " mounturl: " + mounturl);
			}
			callback(true);
		} else {
			callback(false, "10005");
		}
	}

	public static function onPCHShares(success:Boolean, data, callback) {
		if(success) {
			var shares:Array=new Array();
			for(var i=0;i<data.length;i++) {
				//trace("checking: "+data[i]);
				if(StringUtil.beginsWith(data[i],"servname") || StringUtil.beginsWith(data[i],"servlink") || StringUtil.beginsWith(data[i],"netfs_name") || StringUtil.beginsWith(data[i],"netfs_url")) {
					trace(".. found: " + data[i]);
					data[i]=data[i].split("\r").join("");
					var tempinfo = data[i].split("=");
					if(tempinfo[1] != "" && tempinfo[1] != null && tempinfo[1] != undefined) {
						//trace(".. found: "+data[i].slice(1));
						if(StringUtil.beginsWith(data[i],"serv")) {
							var which:Number=int(tempinfo[0].slice(8));
						} else if(StringUtil.beginsWith(data[i],"netfs_name")) {
							var which:Number=int(tempinfo[0].slice(10));
						} else {
							var which:Number=int(tempinfo[0].slice(9));
						}
						//trace("... which "+which);
						which--;
						tempinfo.shift();
						tempinfo = tempinfo.join("=");
						if(shares[which].kind == undefined) {
							shares[which] = new Array();
							shares[which].kind = "share";
						}
						if(StringUtil.beginsWith(data[i],"servlink") || StringUtil.beginsWith(data[i],"netfs_url")) {
							// url fixes
							if(StringUtil.beginsWith(tempinfo, "nfs")) {
								var url = tempinfo.slice(0, tempinfo.indexOf("&smb.user="));
								tempinfo = url.slice(url.indexOf(":")+3);
								tempinfo = StringUtil.replace(tempinfo, ":/", "/");
								url = url.slice(0,url.indexOf(":")+3)+tempinfo;
								var username="";
								var password="";
								var mounturl:String=url;
							} else {
								if(tempinfo.indexOf("&smb.user=") != -1) {
									var url=StringUtil.replace(tempinfo, "&smb.user=", "[");
									url=StringUtil.replace(url, "&smb.passwd=", "=")+"]";
									url=url.slice(6);
									tempinfo=url.split("[");
									url="smb://["+tempinfo[1]+tempinfo[0];
								} else var url=tempinfo;

								var username="";
								var password="";
								var newmount:String = url;

								// strip login from mount url
								var start=newmount.indexOf("[");
								var end=newmount.indexOf("]");
								var typeend=newmount.slice(0,newmount.indexOf(":"));

								//trace("end "+end);
								if(end != undefined && end > 1 && end != null) {
									trace("mount is "+newmount);
									trace("user/password to strip");
									var templogin=newmount.slice(start,end+1);
									newmount=typeend+"://"+url.slice(end+1);
									trace("temp login "+templogin+" new mount "+newmount);

									// extract login
									var tempcred:Array=new Array();
									tempcred=templogin.split("=");
									username=tempcred[0].slice(1);
									if(tempcred[1].length > 1) {
										password=tempcred[1].slice(0,tempcred[1].length-1);
									}
									trace("username: "+username+" password "+password);
								}
								var mounturl:String=newmount;
							}
							trace("... "+which+" url: "+url+" mounturl: "+mounturl+" user: "+username+" pw: "+password);
							shares[which].url=url;
							shares[which].mounturl=mounturl;
							shares[which].username=username;
							shares[which].password=password;
						} else {
							trace("... name "+which+": "+tempinfo);
							shares[which].share=tempinfo.toLowerCase();
						}
					}
				}
			}

			Common.evRun.shares=new Array();
			if(shares.length!=0) {
				//trace("adding shares to pathdata");
				Common.evRun.shares=shares;
			}
			callback(true);
		} else {
			callback(false, "10004");
		}
	}

// pod
	public static function load_pod_bg(url, callback) {
		trace("+++ starting pod " + url);

		callback(true, null, null);
		return;

		if(Common.evRun.bghighres! = true) callback(false, null, 0);

		if(Common.evSettings.wintesting) {
			url = StringUtil.replace(url, Common.evSettings.yamjdatapath, "");
			url = StringUtil.replace(url, Common.evSettings.eskinrootpath, "");
			url = Common.evSettings.podrootpath+url;
		} else {
			if(StringUtil.beginsWith(url, ".")) {
				url=Common.evRun.rootpath+"/"+url.slice(1);
			}
		}
		
		url = unescape(url);
		trace("load url "+url);
		Popapi.send("playback?arg0=start_pod&arg1=hrbg&arg2="+url+"&arg3=0&arg4=&arg5=bgrun", callback, callback);
	}

	public static function next_pod_bg(url, callback) {
		callback(true,null,null);
		return;

		trace("+++ next pod "+url);

		if(Common.evRun.bghighres!=true) callback(false, null, 0);

		if(Common.evSettings.wintesting) {
			url=StringUtil.replace(url,Common.evSettings.yamjdatapath,"");
			url=StringUtil.replace(url,Common.evSettings.eskinrootpath,"");
			url=Common.evSettings.podrootpath+url;
		} else {
			if(StringUtil.beginsWith(url, ".")) {
				url=Common.evRun.rootpath+"/"+url.slice(1);
			}
		}
		url=unescape(url);
		trace("load url "+url);

		if(Common.evRun.hardware.bghighresplaylist == true) {
			Popapi.send("playback?arg0=insert_pod_queue&arg1=hrbg&arg2="+escape(url)+"&arg3=0&arg4=&arg5=bgrun",Popapi.fwd_pod_bg, callback);
		} else {
			Popapi.send("playback?arg0=start_pod&arg1=hrbg&arg2="+escape(url)+"&arg3=0&arg4=&arg5=bgrun",callback,callback);
		}
	}

	public static function fwd_pod_bg(success:Boolean, data, errorcode, callback) {
		if(success) {
			//Popapi.send("playback?arg0=delete_pod_entry_queue&arg1=1",callback,callback);
			if(Common.evRun.hardware.bghighresplaylistskipnext!=true) {
				Popapi.send("playback?arg0=next_pod_in_queue",callback,callback);
			} else callback(true);
		} else {
			callback(false);
		}
	}

	public static function clear_pod_queue() {
		return;
		Popapi.send("playback?arg0=delete_pod_entry_queue&arg1=0",null,null);
		Popapi.send("playback?arg0=delete_pod_entry_queue&arg1=1",null,null);
		Popapi.send("playback?arg0=delete_pod_entry_queue&arg1=0",null,null);
	}

	public static function pause_pod_bg(callback) {
		callback(true,null,null);
		return;

		if(Common.evRun.bghighres!=true || Common.evRun.hardware.bghighresplaylist!=true) callback(true,null,null);

		trace("+++ pausing pod");

		Popapi.send("playback?arg0=pause_pod",callback,callback);
	}


	public static function clear_pod_bg(callback) {
		callback(true,null,null);
		return;

		if(Common.evRun.bghighres!=true || Common.evRun.hardware.bghighresplaylist!=true) callback(true,null,null);

		trace("+++ stopping pod");

		Popapi.send("playback?arg0=stop_pod",callback,callback);
	}

// start videos
	public static function playvideo(callback:Function) {

	}

	public static function systemled(toggle:String) {
		return;

		// NOT REALLY USEFUL, DISABLED
		trace("switching system led to "+toggle);

		switch(toggle) {
			case 'off':
				Popapi.send("system?arg0=set_system_led&arg1=off");
				break;
			case 'blink':
				Popapi.send("system?arg0=set_system_led&arg1=blink");
				break;
			default: // on
				Popapi.send("system?arg0=set_system_led&arg1=on");
				break;
		}
	}


// ******* commands to the pch ********

	// send relays the command to the pch and returns true/false on success
	public static function send(command:String, callback:Function, origcallback:Function) {
		if(Popapi.disabled) {
			trace("popapi disabled");
			origcallback(false,null,9999);
			return;
		}
		trace("popapi send command: "+command);

		var request:String="http://" + Popapi.apiurl + command;
		Popapi.loadSEND(request, callback, origcallback);
	}

	// get retrieves data from the api, checks for api success and returns the data
	public static function get(command:String, callback:Function, origcallback:Function) {
		if(Popapi.disabled) {
			trace("popapi disabled");
			origcallback(false,null,9999);
			return;
		}
		trace("popapi get command: "+command);

		var request:String="http://" + Popapi.apiurl + command;
		Popapi.loadSEND(request, callback, origcallback);
	}

	public static function fileget(command:String, onLoad, callback:Function) {
		if(Popapi.disabled) {
			trace("popapi disabled");
			callback(false,null,9999);
			return;
		}

		//trace("popapi fileget command: "+command);

		Popapi.loadfileGET(command, onLoad, callback);
	}


// ******** actual api communication ********

	// load xml routine for send
	public static function loadSEND(url:String, onLoad:Function, callback:Function):Void {
		// prep the call
		var xml:XML = new XML();
		xml.ignoreWhite = true;

		// our xml processed successful routine
		xml.onLoad = function(success:Boolean):Void {
			if(xml.status==0 && success==true) {  // we have good xml at the moment
				// check the api response to see if its successfull or not
				var good = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/returnValue").firstChild.nodeValue.toString();
				if(good=="0") {  // we got a valid response
					trace("popapi send successful");
					onLoad(true,xml,null,callback);

				} else {  // api returned error
					trace("popapi send unsuccessful, pch error");
					onLoad(false,xml,int(good),callback);
				}
			} else {  // just fail
				onLoad(false,null,null,callback);
			}

			// cleanup the xml call
			delete xml.idMap;
			xml = null;
		};

		// get the xml!
		xml.load(url);
	}

	// meant to load setting.txt on pch units
	public static function loadfileGET(url:String, onLoad:Function,callback):Void {
		// prep the call
		var my_lv:LoadVars = new LoadVars();

		my_lv.onData = function(src:String):Void {
			if(src != undefined) {  // we have good xml at the moment
				////trace(src);
				var data=src.split(chr(10));
				//trace(data.length+" lines");
				onLoad(true, data,callback);
			} else {  // just fail
				//trace("bad load");
				onLoad(false,null,callback);
			}

			// cleanup the xml call
			my_lv = null;
		};
		// get the xml!
		my_lv.load(url);
	}
}