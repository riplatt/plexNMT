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
import ExtCommand;

class api.Duneapi {
	public static var disabled:Boolean=null;

	public static function macaddress() {
		var mac=ExtCommand.getSerialNumber();

		trace("duneapi: mac "+mac);
		return(mac);
	}

	public static function setup() {
		trace("setting up dune");

		Common.evRun.hardware.isDune=true;
		Common.evRun.hardware.remotecodes="DUNE";
		Common.evRun.hardware.modelname=ExtCommand.getProductId();

		Common.evRun.playerfirmware=ExtCommand.getFirmwareVersion();
		Common.evRun.hardware.firmware=ExtCommand.getFirmwareVersion();

		trace("model: "+Common.evRun.playerfirmware);
		trace("firm: "+Common.evRun.hardware.firmware);

		// not sure these are needed but just in case
		Common.evRun.hardware.bghighres=false;
		Common.evRun.hardware.settingcode="dune";
		Common.evRun.hyperdraw=int(Common.evSettings["dunehyperdraw"]);
		if(Common.evRun.hyperdraw < 0 || Common.evRun.hyperdraw > 10) Common.evRun.hyperdraw=0;
	}

	public static function exit() {
		if(Duneapi.disabled == false) {
			trace("duneapi: exit");
			ExtCommand.exitFlash();
		} else {
			trace("skipped dune exit, not a dune");
		}
	}

	public static function playvid(url:String) {
		if(Duneapi.disabled == false) {
			trace("duneapi: play "+unescape(url));
			ExtCommand.requestFilePlayerOnExitWithReturn(unescape(url));
			ExtCommand.exitFlash();
		} else {
			trace("skipped dune play, not a dune");
		}
	}
}