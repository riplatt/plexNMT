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

// THIS CLASS IS OUR MEDIA PLAYING INTERFACE.  IT IS THE DEVICE INDEPENDED MIDDLEMAN
import ev.Common;
import api.dataYAMJ;

import com.dentedboxes.as2.Popapi;
import com.dentedboxes.as2.Duneapi;
import com.dentedboxes.as2.StringUtil;
import com.dentedboxes.as2.Preloader;

import com.syabas.as2.common.PlayerMain;

import mx.xpath.XPathAPI;
import mx.utils.Delegate;

class com.dentedboxes.as2.Mediaplayer {
	// nav
	public static var Callback:Function=null;

	// stuff
	public static var parentMC:MovieClip = null;
	public static var mainMC:MovieClip = null;
	public static var playerObj:Object = null;
	public static var playerMC:MovieClip = null;
	public static var playerMain:PlayerMain = null;

	// player things
	public static var playqueue:Array = null;  // the queue!
	public static var mountqueue:Array = null; // reprocess queue
	public static var isPlaying:Boolean=null;  // if the player is active
	public static var current:Object=null;     // the currently playing media
	public static var queueerr:String=null;
	public static var usenative:Boolean=null;
	public static var useflv:Boolean=null;
	public static var useyoutube:Boolean=null;
	public static var tryingmount:Boolean=null;
	public static var errorstate:Number=null;
	public static var playstate:Number=null;
	public static var playlist:Boolean=null;
	public static var singlestop:Boolean=null;
	public static var sdkpath:String=null;
	public static var sdkpathchecked:Boolean=null;
	public static var sdkpathsize:Number=null;

	// data
	public static var datasource=null;
	public static var drivesupdated:Boolean=null;
	public static var sharesupdated:Boolean=null;
	public static var remotemoved:Boolean=null;

// ************************* QUEUE/PLAY FUNCTIONS ********************************

	public static function resetQueue():Void {
		trace("MP: RESET QUEUE RECIEVED");

		delete Mediaplayer.playqueue;
		Mediaplayer.playqueue = new Array();
		Mediaplayer.playerMain.destroy();

		delete Mediaplayer.mountqueue;
		Mediaplayer.mountqueue = new Array();

		delete Mediaplayer.current;
		Mediaplayer.current=new Object();

		Mediaplayer.datasource.cleanup();
		Mediaplayer.datasource = null;
		Mediaplayer.datasource = new dataYAMJ();

		Mediaplayer.isPlaying=false;
		Mediaplayer.queueerr=null;
		Mediaplayer.usenative=false;
		Mediaplayer.useflv=false;
		Mediaplayer.useyoutube=false;
		Mediaplayer.tryingmount=false;

		Mediaplayer.drivesupdated=false;
		Mediaplayer.sharesupdated=false;
		Mediaplayer.playlist=false;
		Mediaplayer.remotemoved=false;
		Mediaplayer.singlestop=false;

		Mediaplayer.errorstate=null;
		Mediaplayer.playstate=0;

		Mediaplayer.sdkpathsize=244728;

		delete Mediaplayer.playerObj;
		Mediaplayer.playerObj = new Object();
		Mediaplayer.playerObj.enableTrickMode = true;  											// ff rw
		Mediaplayer.playerObj.playMode = 3; 													// native playback.
		Mediaplayer.playerObj.completePlaybackCB = Mediaplayer.playFinished;
		Mediaplayer.playerObj.userActionStopPlaybackCB = Mediaplayer.playerFinished;
		Mediaplayer.playerObj.enableSeek = true;
		//Mediaplayer.playerObj.disableAutoSkip = true;
		Mediaplayer.playerObj.configDisplayTxt={skipTo:Common.evPrompts.skipto,
												goTo:Common.evPrompts.goto,
												playlist:Common.evPrompts.playlist,
												couldNotPlay:Common.evPrompts.couldnotplay,
												infoPanel:Common.evPrompts.infopanel,
												downloadSpeed:Common.evPrompts.dlspeed,
												videoQuality:Common.evPrompts.videoquality,
												connectionStatus:Common.evPrompts.connstatus,
												bufferingStatus:Common.evPrompts.buffstatus,
												ttInfo:Common.evPrompts.infopanel,
												ttPlaylist:Common.evPrompts.ttpl,
												ttseek:Common.evPrompts.ttseek
												};
	}

	public static function playrom(parentMC, callback) {
		// make sure we're ready to go
		if(Mediaplayer.playqueue.length == null) {
			Mediaplayer.resetQueue();
		}

		Mediaplayer.parentMC = parentMC;
		Mediaplayer.playerObj.parentPath = Mediaplayer.parentMC._url;
		Mediaplayer.Callback = callback;

		Preloader.update(Common.evPrompts.preprom);
		Popapi.get("file_operation?arg0=list_user_storage_file&arg1=CDROM&arg2=0&arg3=1&arg4=true&arg5=true&arg6=true&arg7=", Mediaplayer.playoptical);
	}

	public static function playfile(parentMC, callback, rawdata) {
		// make sure we're ready to go
		Mediaplayer.resetQueue();

		Mediaplayer.parentMC = parentMC;
		Mediaplayer.playerObj.parentPath = Mediaplayer.parentMC._url;
		Mediaplayer.Callback = callback;

		trace("ready to queue up " + rawdata.title + " url " + rawdata.file);

		if(rawdata.file==undefined || rawdata.file==null) {
			callback("ERROR", Common.evPrompts.enovideo);
			return;
		}

		Mediaplayer.mountqueue.push({file:rawdata.file, name:rawdata.title, realstart:true});
		Mediaplayer.delayedqueuecheck();
	}

	public static function addEP(epdata, start:Number, ending:Number, callback:Function, parentMC:MovieClip) {
		if(epdata==null||epdata==undefined) {
			callback("ERROR", Common.evPrompts.enovideo);
			return;
		}

		// make sure we're ready to go
		Mediaplayer.resetQueue();

		Mediaplayer.parentMC = parentMC;
		Mediaplayer.playerObj.parentPath = Mediaplayer.parentMC._url;
		Mediaplayer.Callback = callback;

		// make sure we really have numbers
		start = int(start);
		ending = int(ending);
		var epstart = start;

		if(ending==0) {
			trace("adjusting for play rest");
			start = 0;
			ending = 9999;
		}

		trace("MP: adding episodes start:"+start+" end:"+ending);
		var first:Boolean = false;
		for(var e = 0;e<epdata.length;e++) {
			trace("..testing "+epdata[e].playnum);
			if(epdata[e].playnum >= start && epdata[e].playnum <= ending) {
				trace(".... inrange");

				// if not first, check for skip
				if(first == true && epdata[e].newpart != true) {
					trace(".... aborting, multi-file and not first part");
					continue;
				}

				// playfrom here where to start from
				if(epdata[e].playnum>=epstart) var realstart = true;
				   else var realstart = false;

				if(!Mediaplayer.insert_queue(epdata[e].playname,epdata[e].url,epdata[e].zcd,realstart)) return;

				first = true;
			} else trace(".... skipped: not in range");
		}

		if(Mediaplayer.mountqueue.length!=0) {
			trace("delayed queue processing started");
			Mediaplayer.delayedqueuecheck();
		} else {
			// we're good to go now
			Mediaplayer.startPlaying();
		}
	}

	public static function addFromXML(xml:XMLNode, start:Number, ending:Number, callback:Function, parentMC:MovieClip) {
		if(xml==null||xml==undefined) {
			callback("ERROR", Common.evPrompts.enovideo);
			return;
		}

		// make sure we're ready to go
		Mediaplayer.resetQueue();

		Mediaplayer.parentMC = parentMC;
		Mediaplayer.playerObj.parentPath = Mediaplayer.parentMC._url;
		Mediaplayer.Callback = callback;

		// make sure we really have numbers
		start = int(start);
		ending = int(ending);
		var epstart = start;

		if(ending == 0) {
			trace("adjusting for play rest");
			start = 0;
			ending = 9999;
		}

		trace("MP: adding xml start:" + start + " end:" + ending);
		var season = Mediaplayer.datasource.process_data("season", xml);
		var title = Mediaplayer.datasource.process_data("title", xml); // tv show title name

		// extract fileparts
		var xmlNodeList:Array = XPathAPI.selectNodeList(xml, "/movie/files/file");
		var xmlDataLen:Number = xmlNodeList.length;
		trace(xmlDataLen+" records");

		// loop the records
		for(var i = 0;i<xmlDataLen;i++) {
			// pull out the first and last
			var firstpart = int(XPathAPI.selectSingleNode(xmlNodeList[i], "/file").attributes.firstPart.toString());
			var lastpart = int(XPathAPI.selectSingleNode(xmlNodeList[i], "/file").attributes.lastPart.toString());

			trace(". start/end range: fp:"+firstpart+" lp:"+lastpart+"  start: "+start+" ending:"+ending);
			if((firstpart >= start && firstpart <=ending) || (lastpart >= start && lastpart <=ending)) {
				trace(".. record is inrange");

				// prepare name
				if(season=="-1") {  // movie naming
					if(Common.evSettings.intromovie!=undefined && Common.evSettings.intromovie!=null && Common.evSettings.intromovie!="" && Mediaplayer.mountqueue.length <1 && Mediaplayer.playqueue.length <1) {
						trace("..intro movie being added");
						Mediaplayer.insert_queue(Common.evSettings.introname,Common.evSettings.intromovie,undefined,true);
					}

					if(xmlDataLen != 1) {  	// multipart movie
						var name = title + " " + Common.evPrompts.part + " " + firstpart;
					} else {					// single file movie
						var name = title;
					}
				} else {   			// tv naming
					// common to both prep
					if(season.length<2) season = "0" + season;
					var showpart = firstpart.toString();
					if(showpart.length<2) showpart = "0" + showpart;

					if(firstpart!=lastpart) {  // multiple-episode video
						var showlastpart = lastpart.toString();
						if(showlastpart.length<2) showlastpart = "0"+showlastpart;
						var name = title + " " + Common.evPrompts.seasonshort + season + Common.evPrompts.episodeshort + showpart + " - " + Common.evPrompts.episodeshort + showlastpart;
					} else {					// single episode video with epname
						var epname = XPathAPI.selectSingleNode(xmlNodeList[i], "/file").attributes.title.toString();
						var name = title+" "+Common.evPrompts.seasonshort+season+Common.evPrompts.episodeshort+showpart+": "+epname;
					}
				}

				// prep file and zcd
				var file = XPathAPI.selectSingleNode(xmlNodeList[i], "/file/fileURL").firstChild.nodeValue.toString();
				var zcd = XPathAPI.selectSingleNode(xmlNodeList[i], "/file").attributes.zcd.toString();

				if(firstpart>=epstart) var realstart = true;
				   else var realstart = false;

				if(!Mediaplayer.insert_queue(name, file, zcd, realstart)) return;
			}
		}

		if(Mediaplayer.mountqueue.length!=0) {
			trace("delayed queue processing started");
			Mediaplayer.delayedqueuecheck();
		} else {
			// we're good to go now
			Mediaplayer.startPlaying();
		}
	}

	public static function insert_queue(name, file, zcd, realstart) {
		trace("name " + name + ", file " + file + ", zcd " + zcd + ", realstart " + realstart);

		// windows path error check
		if(file.indexOf("\\") != -1 || file.charAt(1) == ":" || StringUtil.beginsWith(file,"\\\\")) {
			Mediaplayer.Callback("ERROR", Common.evPrompts.ewinpath);
			return;
		}

		if(Common.overSight || Common.jbmissing) {
			var cleancheck:String = unescape(file);
			if(!StringUtil.beginsWith(cleancheck,"file:///opt") && StringUtil.beginsWith(cleancheck,"file://") && !StringUtil.beginsWith(cleancheck,"file:///")) {
				trace("adjusting path for oversight");
				var newfile:String = cleancheck.slice(7);
				file = "file:///opt/sybhttpd/localhost.drives/NETWORK_SHARE/" + newfile;
				file = StringUtil.replace(file, "&", "%26");
				file = StringUtil.replace(file, "?", "%3F");
				file = StringUtil.replace(file, "+", "%2B");
				trace(".. new path: "+file);
			}
		}



		// see if we're delaying or immediately queuing.
		var delayed:Boolean = true;
		if(Mediaplayer.mountqueue.length != 0 || StringUtil.beginsWith(file,"//") || StringUtil.beginsWith(file,"smb://") || StringUtil.beginsWith(file,"nfs") || StringUtil.beginsWith(file,"ev-usb") || file.indexOf("NETWORK_SHARE") != -1) {
			trace("possible delayed queue");

			if(file.indexOf("NETWORK_SHARE") != -1) {
				if(Common.evSettings.playercheckmounts == "true") {
					trace(".. native path network share enabled, delayed queue");
				} else {
					delayed=false;
				}
			} else {
				trace(".. delayed queue");
			}
		} else delayed=false;

		// only immediately queue if we're not already delayed
		if(Mediaplayer.mountqueue.length == 0 && delayed == false) {
			trace("immediate queue");

			var isNative:Boolean = Mediaplayer.addQueue(file, name, zcd, realstart);
			if(isNative == true) Mediaplayer.usenative = true;
		} else {
			trace(".. delayed queue");
			trace("... file: " + file);
			trace("... zcd: " + zcd);
			Mediaplayer.mountqueue.push({file:file, zcd:zcd, name:name, realstart:realstart});
		}

		// queue error
		if(Mediaplayer.queueerr != null) {
			Mediaplayer.Callback("ERROR", Mediaplayer.queueerr);
			Mediaplayer.resetQueue();
			return(false);
		}
		return(true);
	}

	public static function startPlaying() {
		// check queue has media
		if(Mediaplayer.playqueue.length<1) {
			Mediaplayer.Callback("ERROR", Common.evPrompts.enovideo);
			return;
		}

		// play it
		if(Mediaplayer.useyoutube == true) {
			// error out if dune
			if(noDunePlayer()) return;

			trace(".. player will be youtube");

			// disable others
			Mediaplayer.usenative = false;
			Mediaplayer.useflv = false;

			// switch sdk defaults
			Mediaplayer.playerObj.playMode = 5;
			Mediaplayer.playerObj.showPlaybackStatus=false;
			if(Common.evSettings.youtubequality!="auto") Mediaplayer.playerObj.videoQuality=Common.evSettings.youtubequality;

			// start playing
			Mediaplayer.startYAMJPlayer();
		} else if(Mediaplayer.useflv == true) {
			// error out if dune
			if(noDunePlayer()) return;

			trace(".. player will be flv");
			// disable native
			Mediaplayer.usenative=false;

			// switch sdk defaults
			Mediaplayer.playerObj.playMode = 1;
			Mediaplayer.playerObj.showPlaybackStatus=false;

			// start playing
			Mediaplayer.startYAMJPlayer();
		} else if(Mediaplayer.startDune()) {       		// dune
			trace("dune enabled playback");
		} else if(Mediaplayer.usenative == true) {   	// syabas native
			trace('.. player will be native');
			Mediaplayer.nativeplayerStart();
		} else {								   		// syabas sdk
			trace('.. player will be SDK');
			Mediaplayer.startYAMJPlayer();
		}
	}

	// adds a single file to the queue and returns true if native player should be used
	public static function addQueue(file:String, title:String, zcd:Number, realstart:Boolean):Boolean {
		if(file==null||file==undefined) {
			trace("MP queue, no file, skipped");
			return;
		}

		// simple relative path support
		if(StringUtil.beginsWith(file,"../")) {
			trace("relative path detected "+file);
			trace("path "+Mediaplayer.parentMC._url);
			var tpath:String=Mediaplayer.parentMC._url;
			var path:String=tpath.substring(0, Mediaplayer.parentMC._url.lastIndexOf("/"));
			file=path.substring(0, path.lastIndexOf("/"))+file.slice(2);
			trace("new file "+file);
		}

		// yahoo redirect
		if(file.indexOf("playlist.yahoo") != -1) {
			trace("yahoo trailer detected, using netstream");
			Mediaplayer.useflv = true;
		}

		// flash detect
		if(StringUtil.endsWith(file.toUpperCase(), ".FLV") == true || StringUtil.beginsWith(file.toLowerCase(), "rtmp://") == true) {
			trace("flv detected");
			if(Common.evSettings.playerflv == "NATIVE") {
				trace(".. user picked native");
			} else {
				trace(".. user picked SDK");
				Mediaplayer.useflv=true;
			}
		}

		// youtube detect
		if(file.indexOf("youtu") != -1) {
			trace("youtube detected, youtube player forced");
			//file=StringUtil.replace(file,"/watch?v=","/embed/");

			if(file.indexOf("?v=") != -1) {
				file=file.slice(file.indexOf("?v=")+3);
			} else if(file.indexOf("/embed/") != -1) {
				file=file.slice(file.indexOf("/embed/")+7);
			}

			if(file.indexOf("&feature") != -1) file=file.substring(0, file.indexOf("&feature"));
			if(file.indexOf("&amp;feature") != -1) file=file.substring(0, file.indexOf("&amp;feature"));

			trace("youtube url "+file);

			Mediaplayer.useyoutube=true;
		}

		var usenative:Boolean=false;
		// figure out the needed player
		if(zcd=="2" || StringUtil.endsWith(file.toUpperCase(), "VIDEO_TS.IFO") == true) {  // DISC RIP
			// figure out the type of disc rip
			// file ends in iso
			if(StringUtil.endsWith(file.toUpperCase(), ".ISO") == true || StringUtil.endsWith(file.toUpperCase(), ".IMG") == true || StringUtil.endsWith(file.toUpperCase(), ".DAT") == true || StringUtil.endsWith(file.toUpperCase(), ".BIN") == true ||StringUtil.endsWith(file.toUpperCase(), ".CUE") == true) {
				trace(".. iso file.. player setting is " + Common.evSettings.playeriso);
				if(Common.evSettings.playeriso == "NATIVE") {
					usenative=true;
				}
			} else if(StringUtil.endsWith(file.toUpperCase(), "VIDEO_TS") == true) {
				trace(".. video_ts file.. player setting is " + Common.evSettings.playervideots);
				if(Common.evSettings.playervideots == "NATIVE") {
					usenative=true;
				}
				// remove video_ts from the path
				file=file.substr(0,file.length-9);
			} else if(StringUtil.endsWith(file.toUpperCase(), "VIDEO_TS.IFO") == true) {
				trace(".. video_ts/video_ts.ifo file.. player setting is " + Common.evSettings.playervideots);
				if(Common.evSettings.playervideots == "NATIVE") {
					usenative=true;
				}
				// remove video_ts from the path
				file=file.substr(0,file.length-22);
			} else {
				trace(".. bdmv file.. player setting is " + Common.evSettings.playerbdmv);
				if(Common.evSettings.playerbdmv == "NATIVE") {
					usenative=true;
				}
			}
			// fix the url for pch player
			// chop off file://
			if(StringUtil.beginsWith(file.toUpperCase(), "FILE://") == true) {
				trace(".. fixing play url");
				file=file.substr(7);
			}

			if(Common.evSettings.playersingleiso == "true") {
				trace("isostop enabled, skipping rest");
				Mediaplayer.singlestop = true;
			} else trace("isostop disabled, continuing");
		} else {  // SINGLE FILE
			trace(".. single file.. player setting is " + Common.evSettings.playersingle);
			if(Common.evSettings.playersingle == "NATIVE") {
				usenative = true;
			}
		}
		trace("added " + title + " file: " + file + " realstart " + realstart);

		file=unescape(file);

		if(StringUtil.beginsWith(file, "http")) {
			file = StringUtil.replace(file, "&", "%26");
			file = StringUtil.replace(file, "+", "%2B");
			//file=escape(file);
		}

		Mediaplayer.playqueue.push({url:file, title:title, realstart:realstart});

		return(usenative);
	}


// ***************************** DELAYED QUEUE **************************************
	public static function delayedqueuecheck() {
		if(Mediaplayer.mountqueue.length!=0) {
			var queuenow=false;

			// dune support
			if(Duneapi.disabled==false) {
				queuenow=true;
			} else if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"smb://") || StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs://") || StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs-tcp://")) { // if zero mount
				// if nfs-tcp and converted enabled
				if(Common.evSettings.mountnfstcpasnfs==true && StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs-tcp://")) {
					trace("swapping nfs-tcp to nfs");
					Mediaplayer.mountqueue[0].file=StringUtil.replace(Mediaplayer.mountqueue[0].file, "nfs-tcp://", "nfs://");
				} else trace("nfs-tcp url but user choose to not convert");

				// full mount skip
				if((Common.evRun.hardware.fullmounts==false && Common.evRun.hardware.cfgmounts!='false') || Common.evRun.hardware.cfgmounts=='true') {
					trace("full mounts not needed, direct queue");
					queuenow=false;
				} else {
					Preloader.update( Common.evPrompts.prepnet);
					trace("Mount for: "+Mediaplayer.mountqueue[0].file);
					Popapi.get("file_operation?arg0=list_user_storage_file&arg1="+Mediaplayer.mountqueue[0].file+"&arg2=0&arg3=1&arg4=true&arg5=true&arg6=false&arg7=", Mediaplayer.afterMount);
				}
			} else if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"ev-usb://")) { // ev-usb:// paths
				// convert to usb_drive only, file check comes later

				// If we haven't updated this queue run, get the drive list now..
				if(Mediaplayer.drivesupdated==false) {
					Mediaplayer.drivesupdated=true;
					Preloader.update(Common.evPrompts.prepdrives);
					Popapi.drives(Mediaplayer.delayedqueuecheck);
					return;
				}
				Preloader.update("Preparing usb drive");

				trace("ev-usb path detected "+Mediaplayer.mountqueue[0].file);
				var chopends=Mediaplayer.mountqueue[0].file.indexOf("/",9);
				var usbname:String=Mediaplayer.mountqueue[0].file.slice(9,chopends).toLowerCase();
				trace(".. usb drive name: "+usbname);
				var numdrives=Common.evRun.drives.length;
				trace(".. drives to check: "+numdrives);
				for(var i=0;i<numdrives;i++) {
					if(Common.evRun.drives[i].type=="usb" && Common.evRun.drives[i].name==usbname) {
						trace("... found: "+Common.evRun.drives[i].path);
						Mediaplayer.mountqueue[0].file="file:///opt/sybhttpd/localhost.drives/"+Common.evRun.drives[i].path+Mediaplayer.mountqueue[0].file.slice(chopends);
						break;
					} else trace("... skipped: "+Common.evRun.drives[i].name);
				}

				if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"ev-usb://")) {
					// CHANGE: usb drive not connected message
					Mediaplayer.Callback("ERROR", Common.evPrompts.usbdrive+" "+usbname+" "+Common.evPrompts.enotfound.toLowerCase());
					return;
				}
				trace(".. new file "+Mediaplayer.mountqueue[0].file);
				Mediaplayer.delayedqueuecheck();
			} else if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"//")) { // internal drive by name support
				// If we haven't updated this queue run, get the drive list now..
				if(Mediaplayer.drivesupdated==false) {
					Mediaplayer.drivesupdated=true;
					Preloader.update(Common.evPrompts.prepdrives);
					Popapi.drives(Mediaplayer.delayedqueuecheck);
					return;
				}
				Preloader.update(Common.evPrompts.prepintdrive);

				trace("// internal path detected "+Mediaplayer.mountqueue[0].file);
				var chopends=Mediaplayer.mountqueue[0].file.indexOf("/",2);
				var drivename:String=Mediaplayer.mountqueue[0].file.slice(2,chopends).toLowerCase();
				trace(".. internal: "+drivename);
				var numdrives=Common.evRun.drives.length;
				trace(".. drives to check: "+numdrives);
				for(var i=0;i<numdrives;i++) {
					if(Common.evRun.drives[i].type=="harddisk" && Common.evRun.drives[i].name==drivename) {
						trace("... found: "+Common.evRun.drives[i].path);
						Mediaplayer.mountqueue[0].file="file:///opt/sybhttpd/localhost.drives/"+Common.evRun.drives[i].path+Mediaplayer.mountqueue[0].file.slice(chopends);
						break;
					} else trace("... skipped: "+Common.evRun.drives[i].name);
				}
				if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"//")) {
					Mediaplayer.Callback("ERROR", Common.evPrompts.intdrive+" "+drivename+" "+Common.evPrompts.enotfound.toLowerCase());
					return;
				}
				trace(".. new file "+Mediaplayer.mountqueue[0].file);
				Mediaplayer.delayedqueuecheck();
			} else if(Mediaplayer.mountqueue[0].file.indexOf("NETWORK_SHARE") != -1) { // NETWORK_SHARE
				// If we haven't updated this queue run, get the share list now..
				if(Mediaplayer.sharesupdated==false) {
					Mediaplayer.sharesupdated=true;
					Preloader.update(Common.evPrompts.updateshare);
					Popapi.shares(Mediaplayer.delayedqueuecheck);
					return;
				}

				Preloader.update(Common.evPrompts.prepnet);
				Mediaplayer.nativeNetCheck();
			} else {
				queuenow=true;
			}

			if(queuenow) {
				// no preloader change for this one.
				trace("delayed non-mount: "+Mediaplayer.mountqueue[0].file);
				var isNative:Boolean=Mediaplayer.addQueue(Mediaplayer.mountqueue[0].file, Mediaplayer.mountqueue[0].name, Mediaplayer.mountqueue[0].zcd, Mediaplayer.mountqueue[0].realstart);
				if(isNative==true) Mediaplayer.usenative=true;
				// remove from mount queue
				Mediaplayer.mountqueue.shift(); // remove the working element
				Mediaplayer.delayedqueuecheck();
			}
		} else {
			Mediaplayer.startPlaying();
		}
	}

    public static function mount_error(share:String) {
		if(Common.evRun.shares.length>0) {
			for(var tt=0;tt<Common.evRun.shares.length;tt++) {
				if(StringUtil.beginsWith(share, Common.evRun.shares[tt].url)) {
					Mediaplayer.Callback("ERROR", Common.evPrompts.enomount+" "+Common.evRun.shares[tt].share);
					return;
				}
			}
		}
		Mediaplayer.Callback("ERROR", Common.evPrompts.enomountzero+" "+share);
	}

// ************************** NATIVE NET PATH STUFF ***********************************
	public static function nativeNetCheck() {
		trace("native net check for "+Mediaplayer.mountqueue[0].file);

		var start=Mediaplayer.mountqueue[0].file.indexOf("NETWORK_SHARE/")+14;
		var end=Mediaplayer.mountqueue[0].file.indexOf("/",start)-start;
		var testshare:String=Mediaplayer.mountqueue[0].file.substr(start,end);
		trace("test share "+testshare);

		if(Common.evRun.shares.length<1) {
			Mediaplayer.Callback("ERROR", Common.evPrompts.enoshare+" "+testshare);
			return;
		}

		var share=unescape(testshare.toLowerCase());

		for(var tt=0;tt<Common.evRun.shares.length;tt++) {
			trace("testing "+Common.evRun.shares[tt].share);
			if(Common.evRun.shares[tt].share.toLowerCase()==share) {
				trace("found share");
				Mediaplayer.mountqueue[0].file=Common.evRun.shares[tt].url+Mediaplayer.mountqueue[0].file.substr(Mediaplayer.mountqueue[0].file.indexOf("/",start));
				trace("new path "+Mediaplayer.mountqueue[0].file);
				Mediaplayer.delayedqueuecheck();
				return;
			}
		}

		Mediaplayer.Callback("ERROR", Common.evPrompts.enoshare+" "+testshare);
	}

// ****************************** MOUNT STUFF ****************************************

	public static function mountCheck() {
		if(Mediaplayer.mountqueue.length!=0) {
			if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"smb://") || StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs://") || StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs-tcp://")) {
				trace("Mount for: "+Mediaplayer.mountqueue[0].file);
				Popapi.get("file_operation?arg0=list_user_storage_file&arg1="+Mediaplayer.mountqueue[0].file+"&arg2=0&arg3=1&arg4=true&arg5=true&arg6=false&arg7=", Mediaplayer.afterMount);
			} else {
				trace("delayed non-mount: "+Mediaplayer.mountqueue[0].file);
				var isNative:Boolean=Mediaplayer.addQueue(Mediaplayer.mountqueue[0].file, Mediaplayer.mountqueue[0].name, Mediaplayer.mountqueue[0].zcd);
				if(isNative==true) Mediaplayer.usenative=true;
				// remove from mount queue
				Mediaplayer.mountqueue.shift(); // remove the working element
				// NEXT!
				Mediaplayer.delayedqueuecheck();
			}
		} else {
			Mediaplayer.startPlaying();
		}
	}

	public static function afterMount(success:Boolean, xml:XML) {
		if(success) {
			trace("mount returned worked");
			var pathtemp = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/fileList/file/name").firstChild.nodeValue.toString();
			if(StringUtil.beginsWith(pathtemp,"/opt")) {
				pathtemp="file://"+pathtemp;
				trace("new path: "+pathtemp);
				// real queue it
				var isNative:Boolean=Mediaplayer.addQueue(pathtemp, Mediaplayer.mountqueue[0].name, Mediaplayer.mountqueue[0].zcd, Mediaplayer.mountqueue[0].realstart);
				if(isNative==true) Mediaplayer.usenative=true;
				// remove from mount queue
				Mediaplayer.mountqueue.shift(); // remove the working element
				// NEXT!
				Mediaplayer.delayedqueuecheck();
			} else {
				var pcheck=pathtemp.toUpperCase();
				var fcheck = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/fileList/file/isFolder").firstChild.nodeValue.toString();
				if(fcheck=="no") pcheck="BDMV";

				switch(pcheck) {
					case 'VIDEO_TS':
					case 'VIDEO_TS.VOB':
					case 'BDMV':
					case 'BDAV':
						var isNative:Boolean=Mediaplayer.addQueue(Mediaplayer.mountqueue[0].file, Mediaplayer.mountqueue[0].name, Mediaplayer.mountqueue[0].zcd);
						if(isNative==true) Mediaplayer.usenative=true;
						// remove from mount queue
						Mediaplayer.mountqueue.shift(); // remove the working element
						// NEXT!
						Mediaplayer.delayedqueuecheck();
						break;
					default:
						if(fcheck=="yes") {  // last resort
							Mediaplayer.mountqueue[0].file=Mediaplayer.mountqueue[0].file.slice(0,Mediaplayer.mountqueue[0].file.lastIndexOf("/"));
							var isNative:Boolean=Mediaplayer.addQueue(Mediaplayer.mountqueue[0].file, Mediaplayer.mountqueue[0].name, Mediaplayer.mountqueue[0].zcd, Mediaplayer.mountqueue[0].realstart);
							if(isNative==true) Mediaplayer.usenative=true;
							// remove from mount queue
							Mediaplayer.mountqueue.shift(); // remove the working element
							// NEXT!
							Mediaplayer.delayedqueuecheck();
						} else {
							Mediaplayer.Callback("ERROR", Common.evPrompts.enomountzero+" "+pathtemp);
						}
						break;
				}
			}
		} else {
			if(StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs://") || StringUtil.beginsWith(Mediaplayer.mountqueue[0].file,"nfs-tcp://")) {
				trace("nfs not mounted, trying to find root");
				// chop off the last bit
				var path:String=Mediaplayer.mountqueue[0].file.substring(0, Mediaplayer.mountqueue[0].file.lastIndexOf("/"));
				// try again
				Popapi.get("file_operation?arg0=list_user_storage_file&arg1="+path+"&arg2=0&arg3=1&arg4=true&arg5=true&arg6=true&arg7=", Mediaplayer.nfsrootMount);
			} else {
				if(Mediaplayer.tryingmount==false) {
					// attempt a non-encrypted password mount
					var username="";
					var password="";
					var newmount:String=Mediaplayer.mountqueue[0].file;

					// strip login from mount url
					var start=newmount.indexOf("[");
					var end=newmount.indexOf("]");
					var typeend=newmount.slice(0,newmount.indexOf(":"));

					//trace("end "+end);
					if(end != undefined && end > 1 && end != null) {
						trace("mount is "+newmount);
						trace("user/password to strip");
						var templogin=newmount.slice(start,end+1);
						newmount=typeend+"://"+Mediaplayer.mountqueue[0].file.slice(end+1);
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
					// strip the non-share part off
					start=newmount.indexOf("/",newmount.indexOf("/",7)+1);
					newmount=newmount.slice(0,start);
					trace("ready to mount "+newmount);
					Mediaplayer.tryingmount=true;
					Popapi.get("network_browse?arg0=list_network_content&arg1="+newmount+"&arg2=&arg3="+username+"&arg4="+password+"&arg5=0&arg6=1&arg7=true&arg8=true&arg9=false&arg10=",Mediaplayer.smbpwmount);
				} else {
					Mediaplayer.tryingmount=false;
					Mediaplayer.mount_error(Mediaplayer.mountqueue[0].file);
				}
			}
		}
	}

	public static function smbpwmount(success:Boolean, xml:XML) {
		if(success) {
			trace("smb non-encrypt mount worked");

			// now try to queue it!
			Mediaplayer.mountCheck();
		} else {
			Mediaplayer.mount_error(Mediaplayer.mountqueue[0].file);
		}
	}

	public static function nfsrootMount(success:Boolean, xml:XML) {
		if(success) {
			trace("mount returned worked");
			// now try to queue it!
			Mediaplayer.mountCheck();
		} else {
			trace("nfs still not mounted");
			// get the last try
			var lastry = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/request/arg1").firstChild.nodeValue.toString();
			var path:String=lastry.substring(0, lastry.lastIndexOf("/"));
			//Mediaplayer.Callback("ERROR", "last "+lastry+path);
			//return;
			if(path != "nfs:/" && path != "nfs-tcp:/" && path != undefined && path != null) {
				Popapi.get("file_operation?arg0=list_user_storage_file&arg1="+path+"&arg2=0&arg3=1&arg4=true&arg5=true&arg6=true&arg7=", Mediaplayer.nfsrootMount);
			} else {
				Mediaplayer.mount_error(Mediaplayer.mountqueue[0].file);
			}
		}
	}

// ****************************** PCH PLAYER STUFF ****************************************
	public static function nativeplayerStart() {
		Preloader.clear();

		// make sure the player isn't already going
		if(Mediaplayer.isPlaying!=false) {
			trace("MP: player is already running video");
			return;
		}

		// is this a playlist
		if(Mediaplayer.playqueue.length > 1) Mediaplayer.playlist=true;

		// play from here start adjust
		if(Mediaplayer.playqueue[0].realstart==false) {
			trace("play start is not 0");
			var loopend=Mediaplayer.playqueue.length;
			for(var i=0;i<loopend;i++) {
				if(Mediaplayer.playqueue[0].realstart!=true) {
					if(Common.evSettings.playlistreorder == true) {
						trace(".. "+i+" shifted to end");
						var temp=Mediaplayer.playqueue.shift();
						Mediaplayer.playqueue.push(temp);
					} else {
						trace(".. "+i+" discarded per playlistreorder setting");
						Mediaplayer.playqueue.shift();
					}
				} else {
					trace("play start is now "+i);
					break;
				}
			}
		}

		// add the next video
		Mediaplayer.nativeplayerNext();
	}

	public static function nativeplayerNext() {
		// get the next item in queue
		delete Mediaplayer.current;
		Mediaplayer.current=null;
		Mediaplayer.current=Mediaplayer.playqueue.shift();

		// was thing anything in the queue?
		if(Mediaplayer.current.url==undefined) {
			trace("queue empty");
			if(Mediaplayer.isPlaying==false) {
				trace("nothing to play, aborting");
				Popapi.send("playback?arg0=stop_vod", Mediaplayer.nativeplayerFinished);
				Mediaplayer.Callback("ERROR", Common.evPrompts.enovideo);
				return;
			} else {
				delete Mediaplayer.current;
				Mediaplayer.current=null;
				////Mediaplayer.nativeplayerFinished();
				//_global["setTimeout"](Mediaplayer.nativeplaymonitor, 1000);
				//Mediaplayer.Callback("PLAY");
				Mediaplayer.remotemoved=false;
				Mediaplayer.waitforplaystart();
				return;
			}
		} else {
		    // bookmark support
			var bookmark:String="";
			trace("bookmark property "+Common.evRun.hardware.settingcode+"nativebm set to "+Common.evSettings[Common.evRun.hardware.settingcode+"nativebm"]);
			if(Common.evSettings[Common.evRun.hardware.settingcode+"nativebm"]=="false") bookmark="0";

			trace("bookmark is: "+bookmark);

			if(Mediaplayer.isPlaying==false) {
				// start the player
				trace("START: "+Mediaplayer.current.title+" "+Mediaplayer.current.url);
				Popapi.send("playback?arg0=start_vod&arg1="+escape(Mediaplayer.current.title)+"&arg2="+escape(Mediaplayer.current.url)+"&arg3=show&arg4="+bookmark, Mediaplayer.nativePlayerAdded);
			} else {
				// add to the queue
				trace("QUEUE: "+Mediaplayer.current.title+" "+Mediaplayer.current.url);
				Popapi.send("playback?arg0=insert_vod_queue&arg1="+escape(Mediaplayer.current.title)+"&arg2="+escape(Mediaplayer.current.url)+"&arg3=&arg4="+bookmark, Mediaplayer.nativePlayerAdded);
			}
		}
	}

	public static function waitforplaystart(success:Boolean, xml:XML, errorcode) {
		if(success) {
			trace("play started!");
			Mediaplayer.Callback("PLAY");
			_global["setTimeout"](Mediaplayer.nativeplaymonitor, 1000);
		} else {
			trace("play didn't start yet");
			// remote check
			if(Mediaplayer.remotemoved==true && Mediaplayer.playerMain == null) {
				trace("remote moved, play failed stopping wait");
				//Mediaplayer.Callback("ERROR", Common.evPrompts.couldnotplay);
				Mediaplayer.isPlaying=false;
				Mediaplayer.resetQueue();
				Mediaplayer.Callback("DONE");
			} else if(Mediaplayer.isPlaying==true) {
				trace("still playing, waiting for start");
				_global["setTimeout"](Mediaplayer.checkplaystatus, Common.evSettings.playermonitorstart);
			}
		}
	}

	public static function checkplaystatus() {
		trace("checking play status");
		Popapi.send("playback?arg0=get_current_vod_info", Mediaplayer.waitforplaystart);
	}

	// called by loadxml after it sends over the video
	public static function nativePlayerAdded(success:Boolean, xml:XML) {
		trace("back from player send");
		if(success) {
			if(Mediaplayer.singlestop==true && Mediaplayer.isPlaying!=true) {
				trace("rip stop active, skipping rest of playlist");
				Mediaplayer.isPlaying=true;
			} else {
				// queue the next file
				Mediaplayer.isPlaying=true;
				Mediaplayer.nativeplayerNext();
			}

		} else {
			trace("failed");
			// just in case, get the player stopped and head back to skin
			Popapi.send("playback?arg0=stop_vod", Mediaplayer.nativeplayerFinished);
			_global["setTimeout"](Mediaplayer.delayederror, 1000);
		}
	}

	public static function delayederror() {
		Mediaplayer.Callback("ERROR", Common.evPrompts.enativeresp);
	}

	// called when done or user pressed stop
	public static function nativeplayerFinished() {
		trace("MP: all done");
		Mediaplayer.isPlaying=false;
		Mediaplayer.resetQueue();
		Mediaplayer.Callback("DONE");
	}

	public static function nativeplaymonitor() {
		if(Common.evSettings.playermonitor!="true") {
			trace("play monitor disabled");
			if(Mediaplayer.playerMain == null) Mediaplayer.nativeplayerFinished();
			return;
		}

		if(Mediaplayer.isPlaying==true) {
			if(Mediaplayer.remotemoved==true && Mediaplayer.playerMain == null) {
				trace("remote moved, video must be over");
				// we're done!
				Popapi.send("playback?arg0=stop_vod");
				Popapi.send("system?arg0=suspend_screensaver&arg1=0");
				if(Mediaplayer.playerMain != null) {
					Mediaplayer.playerMain.destroy();
					Mediaplayer.playFinished();
				} else {
					Mediaplayer.nativeplayerFinished();
				}
			} else {
				Popapi.send("playback?arg0=get_current_vod_info", Mediaplayer.nativeplaycheck);
			}
		} else {
			trace("media not playing, aborting monittor");
		}
	}

	public static function nativeplaycheck(success,xml,errorcode) {
		if(success) {
			// queue the next check
			trace("still playing");
			Mediaplayer.playstate=0;
			_global["setTimeout"](Mediaplayer.nativeplaymonitor, Common.evSettings.playermonitorinterval);
		} else {
			if(Mediaplayer.playstate>=Common.evSettings.playerforceexit || Mediaplayer.playlist==false) {
				// we're done!
				Popapi.send("playback?arg0=stop_vod");
				Popapi.send("system?arg0=suspend_screensaver&arg1=0");
				if(Mediaplayer.playerMain != null) {
					Mediaplayer.playerMain.destroy();
					Mediaplayer.playFinished();
				} else {
					Mediaplayer.nativeplayerFinished();
				}
			} else {
				// check the queue to make sure we're really stopped
				Popapi.send("playback?arg0=get_current_vod_info", Mediaplayer.nativeplayqueuecheck);
			}
		}
	}

	public static function nativeplayqueuecheck(success,xml,errorcode) {
		if(success) {
			trace("queue has a video, we're not done playing");
			Mediaplayer.playstate=0;
		} else {
			// queue up the next
			trace("play failed try#"+Mediaplayer.playstate);
			Mediaplayer.playstate++;
		}

		_global["setTimeout"](Mediaplayer.nativeplaymonitor, Common.evSettings.playermonitorinterval);
	}

// ****************************** ROM STUFF ***************************************
	public static function playoptical(success) {
		if(success) {
			trace("DISC FOUND!!!");
			Mediaplayer.playqueue.push({url:"file:///cdrom", title:"DISC PLAY", realstart:true});
			Mediaplayer.nativeplayerStart();
		} else {
			if(Mediaplayer.drivesupdated == false) {
				Mediaplayer.drivesupdated = true;
				Preloader.update("Updating drive status");
				Popapi.drives(Mediaplayer.romdrivecheck);
				return;
			}

			trace("no movie disc to play");
			Mediaplayer.Callback("ERROR", Common.evPrompts.enodisc);
		}
	}

	public static function romdrivecheck() {
		if(Common.evRun.drives.length==0) {
			Mediaplayer.Callback("ERROR", Common.evPrompts.enocdrom);
			return;
		}

		for(var i=0;i<Common.evRun.drives.length;i++) {
			if(Common.evRun.drives[i].type=="rom") {
				trace("drive found, no movie to play");
				Mediaplayer.Callback("ERROR", Common.evPrompts.enodisc);
				return;
			}
		}

		Mediaplayer.Callback("ERROR", Common.evPrompts.enocdrom);
	}

// ****************************** SDK PLAYER STUFF ***************************************

	// start playing using yamj player (sdk player for now)
	public static function startYAMJPlayer() {
		// make sure the player isn't already going
		if(Mediaplayer.isPlaying!=false) {
			trace("MP: player is already running video");
			return;
		}

		// check to see if we should look for an updated player
		if(Mediaplayer.sdkpathchecked != true && Common.evSettings.findsdkupdate == "true") {
			Mediaplayer.findsdkupdate();
			Mediaplayer.sdkpathchecked = true;

			// MAKE SURE WE STOP HERE WHILE LOOKING
			return;
		}

		//public static var sdkpath:String=null;
		//public static var sdkpathchecked:Boolean=null;

		// disable screensaver
		Popapi.send("system?arg0=suspend_screensaver&arg1=1");
		Preloader.clear();

		// is this a playlist
		if(Mediaplayer.playqueue.length > 1) Mediaplayer.playlist = true;

	    Mediaplayer.playerMC = Mediaplayer.parentMC.createEmptyMovieClip("playerMC", Mediaplayer.parentMC.getNextHighestDepth());

		Mediaplayer.playerObj.mediaObj = Mediaplayer.playqueue;
		//trace("MP: ready to start "+Mediaplayer.current.name+" "+Mediaplayer.current.file);

		// play from here start adjust
		if(Mediaplayer.playqueue[0].realstart == false) {
			trace("play start is not 0");
			var loopend=Mediaplayer.playqueue.length;
			for(var i=0;i<loopend;i++) {
				if(Mediaplayer.playqueue[i].realstart == true) {
					trace("play start is now "+i);
					Mediaplayer.playerObj.startIndex = i;
					break;
				}
			}
		}

		Mediaplayer.isPlaying = true;
		Mediaplayer.playerMain = new PlayerMain();
		Mediaplayer.playerMain.startPlayback(Mediaplayer.playerMC, Mediaplayer.playerObj, Mediaplayer.sdkpath);
		Mediaplayer.Callback("PLAY");
		if(Mediaplayer.useflv!=true && Mediaplayer.useyoutube != true) Mediaplayer.waitforplaystart();
		//_global["setTimeout"](Mediaplayer.nativeplaymonitor, 37000);			// old if part
	}

	// called by the player when its done
	public static function playFinished() {
		trace("player sent over finished");

		Mediaplayer.playerFinished();
	}

	// called when done or user pressed stop
	public static function playerFinished() {
		trace("MP: all done");
		Popapi.send("playback?arg0=stop_vod");
		Popapi.send("system?arg0=suspend_screensaver&arg1=0");
		Preloader.clear();

		Mediaplayer.isPlaying=false;
		Mediaplayer.parentMC.playerMC.removeMovieClip();

		/*
		if(Mediaplayer.errorstate>0) [
			trace("mediaplayer in error state");
			var errormsg="Unknown Hardware Player error";
			switch(Mediaplayer.errorstate) {
				case 1:
					errormsg="Invalid file";
					break;
				case 2:
					errormsg="Unable to open file";
					break;
				case 3:
					errormsg="Unable to read from file";
					break;
				case 4:
					errormsg="Connection error";
					break;
				case 12:
					errormsg="Unsupported video file";
					break;
				default:
			}
			Mediaplayer.Callback("ERROR", errormsg);
		} else */

		Mediaplayer.Callback("DONE");
	}

	public static function findsdkupdate() {
		trace("**** searching for newer sdk player");
		Preloader.update(Common.evPrompts.presdkupdate);

		// find current filesize (best we can do)

		var checkpath:String=Common.evRun.storagerootpath;
		if(Common.evSettings.wintesting=="1" && Common.evSettings.sdkrootpath!=undefined) {
			trace(".. windows debugging, using sdk root path");
			checkpath=Common.evSettings.sdkrootpath;
		}
		trace(".. getting info on "+checkpath+"/eversion/player.swf");

		Popapi.get("file_operation?arg0=get_user_storage_file_info&arg1="+checkpath+"/eversion/player.swf", Mediaplayer.findsdkexisting);
	}

	public static function findsdkexisting(success:Boolean, xml:XML) {
		if(success) {
			trace("got existing info");

			var sizetemp = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/fileSize").firstChild.nodeValue.toString();
			trace(".. size: "+sizetemp);
			Mediaplayer.sdkpathsize=Number(sizetemp);
		} else {
			trace("got error, using "+Mediaplayer.sdkpathsize);
		}

		Popapi.get("file_operation?arg0=get_user_storage_file_info&arg1=../../../opt/syb/usr/popApps/1006/player.swf", Mediaplayer.findsdkyoutube);
	}

	public static function findsdkyoutube(success:Boolean, xml:XML) {
		if(success) {
			trace("got existing info");

			var sizetemp = XPathAPI.selectSingleNode(xml.firstChild, "/theDavidBox/response/fileSize").firstChild.nodeValue.toString();
			trace(".. youtube player.swf size: "+sizetemp);
			var checksize:Number=number(sizetemp);
			if(checksize>Mediaplayer.sdkpathsize) {
				trace(".. LARGER!  using this version instead!");
				Mediaplayer.sdkpath="file:///opt/syb/usr/popApps/1006/";
			}
		} else {
			trace("error loading size, using default sdk player");
		}

		trace("restarting player");
		Preloader.clear();
		Mediaplayer.startYAMJPlayer();
	}

// ****************************** DUNE PLAYER *********************************************
	public static function startDune() {
		if(Duneapi.disabled==false) {
			trace("dune playback");

			// find first
			var loopend=Mediaplayer.playqueue.length;
			for(var i=0;i<loopend;i++) {
				if(Mediaplayer.playqueue[0].realstart==true) {
					Duneapi.playvid(Mediaplayer.playqueue[0].url);
					return(true);
				} else Mediaplayer.playqueue.shift();
			}

			// if we made it here, there was nothing to play
			return(false);
		} else {
			return(false);
		}
	}

	public static function noDunePlayer() {
		if(Duneapi.disabled == false) {
			trace("no support in dune");
			Mediaplayer.Callback("ERROR", "Dune hardware does not support this video");
			return(true);
		} else {
			return(false);
		}
	}
}
/*  SDK error messages

1 invalid file
2 open file error
3 read file error
4 connection error
5 detection error
8 system error
9 queue error
10 network error
12 format not supported
13 unknown error

*/