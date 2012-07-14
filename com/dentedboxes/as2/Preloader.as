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
import api.Popapi;

class tools.Preloader {
	public static var parentMC:MovieClip;
	public static var message:String=null;

	public static function init(parentMC:MovieClip) {
		Preloader.parentMC=parentMC;
		Preloader.clear();

		trace("preloader inited");
	}

	// update and update the preloader/message
	public static function update(message:String,nowait:Boolean) {
		if(Common.esSettings.preloadx!=undefined || Common.esSettings.preloadx!=null) Common.evSettings.preloadx=Common.esSettings.preloadx;
		if(Common.esSettings.preloady!=undefined || Common.esSettings.preloady!=null) Common.evSettings.preloady=Common.esSettings.preloady;

		// change message
		if(message==undefined) {
			message=Common.evPrompts.loading.toUpperCase();
		} else {
			message=message.toUpperCase();
		}

		trace(":::: Preloader updated "+message);
		// add preloader if not on
		if(Preloader.parentMC.preload._visible == undefined && Preloader.message == null) {
			if(nowait == true) {
				Preloader.message=message;
				Preloader.show();
			} else {
				if(Common.evSettings.preloadstart == 0) {
					_global["setTimeout"](Preloader.show, 1);
				} else {
					_global["setTimeout"](Preloader.show, Common.evSettings.preloadstart);
				}
			}
		}
		Preloader.message=message;
		Preloader.parentMC.preload.preload_txt.text=message;
	}

	// update the preloader only if something else activated it already.
	public static function update_active(message:String) {
		if(message==undefined || message==null) {
			Preloader.clear();
			return;
		}

		if(Preloader.message != null) {
			Preloader.message=message;
			Preloader.parentMC.preload.preload_txt.text=message;
		}
	}

	// make the preloader appear
	public static function show() {
		if(Preloader.parentMC.preload._visible==undefined && (Preloader.message != null && Preloader.message != undefined)) {
			Preloader.parentMC.attachMovie("preloader", "preload", Preloader.parentMC.getNextHighestDepth(), {_x:Common.evSettings.preloadx, _y:Common.evSettings.preloady});
			trace("Preloader show at depth "+Preloader.parentMC.preload.getDepth());
			Preloader.parentMC.preload.preload_txt.text=message.toUpperCase();
			if(Common.evSettings.preloadanimate==0) {
				_global["setTimeout"](Preloader.animate, 1);
			} else {
				_global["setTimeout"](Preloader.animate, Common.evSettings.preloadanimate);
			}
		}
	}

	// start the preloading animation
	public static function animate() {
		if(Preloader.parentMC.preload._visible!=undefined && (Preloader.message != null && Preloader.message != undefined)) {
				if(Common.evSettings.preloadstart==0) {
					_global["setTimeout"](Preloader.show, 1);
				} else {
					_global["setTimeout"](Preloader.show, Common.evSettings.preloadstart);
				}
			trace("animating");
			Preloader.parentMC.preload.circle.gotoAndPlay(2);
			if(Common.evSettings.waitingled=="true") Popapi.systemled("blink");
		} else Preloader.clear();
	}

	// swap depths with another mc
	public static function swap(higherMC:MovieClip) {
		trace("Preloader Depth: "+Preloader.parentMC.preload.getDepth());
		trace("Current Screen Depth: "+higherMC.getDepth());
		if(Preloader.parentMC.preload._visible!=undefined) {
			Preloader.parentMC.preload.swapDepths(higherMC);
			trace(".. preloader depth swapped");
		} else trace(".. preloader depth NOT swapped");
	}

	// clear and close the preloader
	public static function clear() {
		trace(":::: Preloader cleared");
		Preloader.parentMC.preload._visible=false;
		Preloader.parentMC.preload.stop();
		Preloader.parentMC.preload.removeMovieClip();
		Preloader.message=null;
		Popapi.systemled("off");
	}
}