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

// Modified for plexNMT 2012-07-13

import com.dentedboxes.as2.StringUtil;
import com.dentedboxes.as2.Popapi;
import plexNMT.as2.common.PlexData;

class com.dentedboxes.as2.Loadimage {

	public static var bgloading:Boolean=null;
	public static var bgnext:Object=null;
	public static var bgalt:Object=null;
	public static var bgvisible:Object=null;
	public static var lastsuccess=null;

	public static function load(loadImgMCId:String, parentMC:MovieClip, x:Number, y:Number, width:Number, height:Number, url:String, alt:String,keepaspect:Boolean,valigned,haligned,hl:Boolean):Void
	{
		if(url==undefined || url==null || url=="UNKNOWN" || url.length<5 || StringUtil.endsWith(url,"UNKNOWN")) return;
		if(height<3||width<3) return;

		if(parentMC[loadImgMCId]._visible == true) return;

		if(parentMC[loadImgMCId]._visible!=undefined) {  // figure out if we even need to reload
			trace(loadImgMCId+" LOAD my url "+url);

			for (var tt in parentMC[loadImgMCId]) {
				if (typeof (parentMC[loadImgMCId][tt]) == "movieclip") {
					trace("LOAD check url "+parentMC[loadImgMCId][tt]._url);
					if(StringUtil.endsWith(parentMC[loadImgMCId][tt]._url,url)) {
						trace("..skipping load, image loaded already");
						parentMC[loadImgMCId][tt]._visible=true;
						parentMC[loadImgMCId]._visible=true;
						return;
					}
				}
			}
		}
		parentMC[loadImgMCId].removeMovieClip();

		var loadImgBaseMC:MovieClip = parentMC.createEmptyMovieClip(loadImgMCId, parentMC.getNextHighestDepth());
		var loadImgMC:MovieClip = loadImgBaseMC.createEmptyMovieClip(loadImgMCId + "_img", loadImgBaseMC.getNextHighestDepth());
		var imgLoader:MovieClipLoader = new MovieClipLoader();
		var imgLoaderListener:Object = new Object();
		var loadingMC:MovieClip;

		loadImgBaseMC._x = x;
		loadImgBaseMC._y = y;

		imgLoader.addListener(imgLoaderListener);

		imgLoaderListener.onLoadInit = function(targetMC:MovieClip) {
			//trace("KEEPASPECT="+keepaspect);

			if(keepaspect == true) {
				Loadimage.resize_keepaspect(targetMC, width, height);
			} else {
				targetMC._width = width;
				targetMC._height = height;
			}
		};

		imgLoaderListener.onLoadComplete = function(targetMC:MovieClip, httpStatus:Number):Void {
			targetMC._parent._visible=hl;
			var mydepth=targetMC.getDepth();

			for (var i in targetMC._parent) {
				if (typeof (targetMC._parent[i]) == "movieclip") {
					if(targetMC._parent[i]._url != targetMC._url) {
						if(targetMC._parent[i].getDepth() < mydepth) {
							targetMC._parent[i].removeMovieClip();
						}
					}
				}
			}
		}

		imgLoaderListener.onLoadError = function(targetMC:MovieClip, errorCode:String, httpStatus:Number) {

			trace("load failed: " + errorCode + " httpstatus " + httpStatus);

			if(alt != undefined && alt!=null) {
				trace('alternate image available, trying ' + alt);

				targetMC._parent.removeMovieClip();
				Loadimage.load(loadImgMCId, parentMC, x, y, width, height, alt, null, keepaspect, valigned, haligned, hl);
				return;
			}

			targetMC._parent.removeMovieClip();
			return;
		}

		imgLoader.loadClip(url, loadImgMC);
	}

	public static function bgload(loadMC:String, parentMC:MovieClip, depth:Number, url:String) {
		if(url==undefined || url==null || url=="UNKNOWN" || url.length<5 || StringUtil.endsWith(url,"UNKNOWN")) return;

		// see if we need this loaded
		if(Loadimage.bgvisible!=null) {
			trace("bg on screen");
			trace(".. on screen " + Loadimage.bgvisible.url);
			trace(".. about to load " + url);
			if(Loadimage.bgvisible.url == url) {  // url already up, stop the next and abort
				trace(".. and it's the same url, skipped");
				delete Loadimage.bgnext;
				Loadimage.bgnext = null;
				Loadimage.bgvisible.parentMC.evbg._visible = false;
				return;
			}
		}

		// see if we're loading a bg already
		if(Loadimage.bgloading == true) {
			trace("bg in process loading, queuing this next");
			//Popapi.pause_pod_bg(Loadimage.nextbg);
			Popapi.clear_pod_queue();

			if(Loadimage.bgnext == null) Loadimage.bgnext = new Object();

			trace(".. previous in queue: " + Loadimage.bgnext.url);

			Loadimage.bgnext.url = url;
			Loadimage.bgnext.depth = depth;
			Loadimage.bgnext.loadMC = loadMC;
			Loadimage.bgnext.parentMC = parentMC;
			trace(".. next in queue: " + url);
			//Loadimage.bgloading=false;
			//Loadimage.nextbg(true,null,null);
			return;
		}

		if(loadMC == "evbg") {
			trace("bg is bg, saving as alt in case needed");
			Loadimage.bgalt = new Object();
			Loadimage.bgalt.url = url;
			Loadimage.bgalt.depth = depth;
			Loadimage.bgalt.loadMC = loadMC;
			Loadimage.bgalt.parentMC = parentMC;
		}

		Loadimage.bgloading = true;
		if(Loadimage.bgvisible == null) Loadimage.bgvisible = new Object();
		Loadimage.bgvisible.url = url;
		Loadimage.bgvisible.depth = depth;
		Loadimage.bgvisible.loadMC = loadMC;
		Loadimage.bgvisible.parentMC = parentMC;

		trace("ready to load "+loadMC+": "+url);

		if(PlexData.oBackground.highres == true) {
			Popapi.next_pod_bg(url, Loadimage.delaynextbg);
		} else {
			if(PlexData.oSettings.overscanbg == "true" && PlexData.oSettings.overscan == "true") {
				var x:Number = 0 + PlexData.oSettings.overscanxshift;
				var y:Number = 0 + PlexData.oSettings.overscanyshift;
				var w:Number = 1280 * PlexData.oSettings.overscanx;
				var h:Number = 720 * PlexData.oSettings.overscany;
			} else {
				var x:Number = 0;
				var y:Number = 0;
				var w:Number = 1280;
				var h:Number = 720;
			}
			//trace("x "+x+" y "+y+" w "+w+" h "+h)
			Loadimage.uiload(loadMC, parentMC, x, y, w, h, depth, url, null, Loadimage.nextbgmc, true, false);
		}
	}

	public static function nextbgmc(who,depth,success) {
		trace("nextbgmc called");
		if(who!=null && depth!=null) return;

		Loadimage.nextbg(success, null, null);
	}

	public static function delaynextbg(success, xml, errorcode) {
		if(success) {
			trace("delaynextbg, image load successfull");
			if(Loadimage.bgvisible.loadMC == "evfn") {
				Loadimage.bgvisible.parentMC.evbg._visible = false;
				trace("delaynextbg, background mc hidden");
			} else {
				Loadimage.bgvisible.parentMC.evbg._visible = true;
				trace("delaynextbg, background mc visible");
			}
			Loadimage.lastsuccess = success;
			_global["setTimeout"](Loadimage.runnextbg, PlexData.oBackground.speed);
		} else {
			Loadimage.nextbg(success, xml, errorcode);
		}
	}

	public static function runnextbg() {
		if(Loadimage.bgvisible != null) {
			trace("bg still on screen, next step");
			Loadimage.nextbg(Loadimage.lastsuccess, null, null, true);
		} else {
			trace("nextbg step canceled, bg cleared");
		}
	}

	public static function nextbg(success, xml, errorcode, delayed) {
		trace("nextbg called");
		Loadimage.bgloading = false;

		if(success && delayed != true) {
			trace("nextbg, image load successfull");
			if(Loadimage.bgvisible.loadMC == "evfn") {
				Loadimage.bgvisible.parentMC.evbg._visible = false;
				if(PlexData.oBackground.highres != true) Loadimage.bgvisible.parentMC.evfn._visible = true;
				trace("nextbg, background mc hidden");
			} else {
				if(PlexData.oBackground.highres != true) Loadimage.bgvisible.parentMC.evbg._visible = true;
				Loadimage.bgvisible.parentMC.evfn._visible = false;
				trace("nextbg, background mc visible");
			}
		} else {
			trace("nextbg, image failed to load");
		}

		trace("nextbg, looking for next to load");

		if(Loadimage.bgnext!=null) {
			trace("BG: new image waiting to load");
			var tmp = Loadimage.bgnext;
			delete Loadimage.bgnext;
			Loadimage.bgnext = null;
			Loadimage.bgload(tmp.loadMC, tmp.parentMC, tmp.depth, tmp.url);
		} else if(!success && Loadimage.bgalt.url != undefined && Loadimage.bgvisible.loadMC != "evgb") {
			trace("nextbg, failed trying to bring up the alt background");
			Loadimage.bgload(Loadimage.bgalt.loadMC, Loadimage.bgalt.parentMC, Loadimage.bgalt.depth, Loadimage.bgalt.url);
		} else if(!success) {
			trace("nextbg, no replacement image to load");
			Loadimage.bgclear();
		}
	}

	public static function bgclear() {
		delete Loadimage.bgnext;
		Loadimage.bgnext=null;
		delete Loadimage.bgvisible;
		Loadimage.bgvisible=null;
		Loadimage.bgloading=false;
	}

	public static function bgclearpart() {
		delete Loadimage.bgnext;
		Loadimage.bgnext=null;
		delete Loadimage.bgalt;
		Loadimage.bgalt=null;
	}


	public static function bgclearall() {
		Loadimage.bgloading=false;
		delete Loadimage.bgalt;
		Loadimage.bgalt=null;
		delete Loadimage.bgnext;
		Loadimage.bgnext=null;
		delete Loadimage.bgvisible;
		Loadimage.bgvisible=null;
		Loadimage.bgloading=false;
	}

	public static function uiload(loadImgMCId:String, parentMC:MovieClip, x:Number, y:Number, width:Number, height:Number, depth:Number, url:String, alt:String, callback:Function, showit:Boolean, keepaspect:Boolean,valigned,haligned):Void
	{
		if(url==undefined || url==null || url=="UNKNOWN" || url.length<5 || StringUtil.endsWith(url,"UNKNOWN")) return;
		if(height<3||width<3) return;

		if(showit==undefined) showit=true;

		if(depth==undefined || depth==null) depth=parentMC.getNextHighestDepth();

		//trace("KEEPASPECT test="+keepaspect);
		var newdepth:Number = parentMC[loadImgMCId].getNextHighestDepth();

		if(parentMC[loadImgMCId]._visible != undefined) {  // figure out if we even need to reload
			trace(loadImgMCId + " my url " + url);

			for (var tt in parentMC[loadImgMCId]) {
				if (typeof (parentMC[loadImgMCId][tt]) == "movieclip") {
					trace("check url "+parentMC[loadImgMCId][tt]._url);
					if(StringUtil.endsWith(parentMC[loadImgMCId][tt]._url,url)) {
						trace("..skipping uiload, image loaded already");
						parentMC[loadImgMCId][tt]._visible=true;
						parentMC[loadImgMCId]._visible=showit;
						callback(null, null, true);
						return;
					}
				}
			}
		} else {
			// actual image loading needs to happen
			var loadImgBaseMC:MovieClip = parentMC.createEmptyMovieClip(loadImgMCId, depth);
			loadImgBaseMC._x = x;
			loadImgBaseMC._y = y;
			loadImgBaseMC._visible=showit;
		}

		var loadImgMC:MovieClip = parentMC[loadImgMCId].createEmptyMovieClip(newdepth, newdepth);
		loadImgMC._visible=false;

		var imgLoader:MovieClipLoader = new MovieClipLoader();
		var imgLoaderListener:Object = new Object();
		imgLoader.addListener(imgLoaderListener);

		imgLoaderListener.onLoadInit = function(targetMC:MovieClip) {
			//trace("KEEPASPECT="+keepaspect);

			if(keepaspect==true) {
				Loadimage.resize_keepaspect(targetMC, width, height,valigned,haligned);
			} else {
				targetMC._width = width;
				targetMC._height = height;
			}
		};

		imgLoaderListener.onLoadComplete = function(targetMC:MovieClip, httpStatus:Number):Void {
			var mydepth=targetMC.getDepth();
			targetMC._visible=true;
			//targetMC._parent._visible=showit;
			for (var i in targetMC._parent) {
				if (typeof (targetMC._parent[i]) == "movieclip") {
					if(targetMC._parent[i]._url != targetMC._url) {
						if(targetMC._parent[i].getDepth() < mydepth) {
							targetMC._parent[i].removeMovieClip();
						}
					}
				}
			}
			callback(null, null, true);
		}


		imgLoaderListener.onLoadError = function(targetMC:MovieClip, errorCode:String, httpStatus:Number) {
			trace("uiload failed: "+errorCode+" httpstatus "+httpStatus);
			targetMC._parent.removeMovieClip();
			callback(null, null, false);

			trace("uiload failed: "+errorCode+" httpstatus "+httpStatus);

			if(alt != undefined && alt!=null) {
				trace('alternate image available, trying '+alt);

				targetMC._parent.removeMovieClip();
				Loadimage.uiload(loadImgMCId, parentMC, x, y, width, height, depth, alt, null, callback, showit, keepaspect,valigned,haligned);
				return;
			}

			targetMC._parent.removeMovieClip();
			return;
		}

		imgLoader.loadClip(url, loadImgMC);
	}

	public static function resize_keepaspect(targetMC:MovieClip, neww, newh, valigned, haligned) {
		//trace(".. keeping aspect for "+targetMC._url);
		var aspect = targetMC._width/targetMC._height;
		var desiredaspect = neww/newh;
		var thisWidth = targetMC._width;
		var thisHeight = targetMC._height;
		//trace(".. current aspect "+aspect);
		//trace(".. default aspect "+neww/newh);
		if(aspect != desiredaspect) {
			//trace("++ need to proportion scale");
			if (thisWidth>neww) {
				//trace("+++ width fixing");
				thisWidth = neww;
				thisHeight = Math.round(thisWidth/aspect);
			}
			if (thisHeight>newh) {
				//trace("+++ height fixing");
				thisHeight = newh;
				thisWidth = Math.round(thisHeight*aspect);
			}
			targetMC._width = thisWidth;
			targetMC._height = thisHeight;
			//trace("+++ haligned: "+haligned);
			//trace("+++ valigned: "+valigned);
			switch(valigned) {
				case 'left':
				case 'top':
					targetMC._y=0;
					break;
				case 'right':
				case 'bottom':
					targetMC._y=newh-thisHeight;
					break;
				default: // center
					targetMC._y=(newh/2) - (thisHeight/2);
					break;
			}
			switch(haligned) {
				case 'left':
				case 'top':
					targetMC._x=0;
					break;
				case 'right':
				case 'bottom':
					targetMC._x=neww-thisWidth;
					break;
				default: // center
					targetMC._x=(neww/2) - (thisWidth/2);
					break;
			}

			//trace("+++ New Width: "+targetMC._width);
			//trace("+++ New Height: "+targetMC._height);
			//trace("+++ New x: "+targetMC._x);
			//trace("+++ New y: "+targetMC._y);
		} else {
			//trace("++ Aspect fine, just sizing");
			targetMC._width = neww;
			targetMC._height = newh;
		}
	}
}