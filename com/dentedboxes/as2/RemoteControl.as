
import ev.Common;
import api.Mediaplayer;

class api.RemoteControl {
	public static var masterkeyListener:Object=null;
	public static var remoteExit:Function=null;
	public static var remotemap:Object=null;
	public static var remotemapname:Object=null;
	public static var skinBusy=null;

	// handlers
	public static var keyListener:Object=null;

	// ***************************** REMOTE CONTROL **********************************
	public static function setupRemote(remoteexit:Function) {
		RemoteControl.stopFullRemote();

		trace("starting master remote");

		RemoteControl.remoteExit = remoteexit;

		RemoteControl.masterkeyListener = new Object();
		RemoteControl.keyListener = new Object();

		RemoteControl.keyListener.segment = null;
		RemoteControl.keyListener.minidex = null;
		RemoteControl.keyListener.screen = null;

		if(RemoteControl.remotemapname  ==  null) RemoteControl.mapremote("default");

		Key.addListener(RemoteControl.masterkeyListener);
		RemoteControl.masterkeyListener.onKeyDown = RemoteControl.masterKeyHit;
	}

	public static function stopFullRemote() {
		trace("stopping master remote");

		Key.removeListener(RemoteControl.masterkeyListener);

		delete RemoteControl.masterkeyListener;
		RemoteControl.masterkeyListener = null;

		delete RemoteControl.keyListener;
		RemoteControl.keyListener = null;

		RemoteControl.remoteExit = null;
	}

	public static function startRemote(who,keylistener) {
		trace("taking remote for "+who);
		if(keylistener  ==  undefined || keylistener  ==  null) {
			trace(".. aborted, function invalid");
		} else {
			RemoteControl.keyListener[who] = keylistener;
		}
	}

	public static function stopRemote(who) {
		trace("stopping remote for "+who);
		RemoteControl.keyListener[who] = null;
	}

	public static function stopAllRemote() {
		trace("stopping remote for All");

		RemoteControl.keyListener.segment = null;
		RemoteControl.keyListener.minidex = null;
		RemoteControl.keyListener.screen = null;
	}

	public static function masterKeyHit():Void {
		if(RemoteControl.skinBusy != true) {
			RemoteControl.skinBusy = true;
			Mediaplayer.remotemoved = true;

			var keyhit = Key.getCode();
			//trace("keyhit "+keyhit);

			if(keyhit == Key.VOLUME_DOWN || keyhit == "SOFT2" || keyhit == 90 || keyhit == 16777218) {  //soft2 doesn't work in cs5.5
				if(Common.evSettings.volupdown!='true') {
					RemoteControl.skinBusy=false;
					return;
				}
				keyhit = Key.PGDN;
			} else if(keyhit == Key.VOLUME_UP || keyhit == "SOFT1" || keyhit == 65 || keyhit == 16777217) { //soft1 doesn't work in cs5.5
				if(Common.evSettings.volupdown!='true') {
					RemoteControl.skinBusy=false;
					return;
				}
				keyhit = Key.PGUP;
			} else if(keyhit == Key.BACKSPACE) {
				keyhit = 0x01000016;
			}

			//trace("keyhit2 "+keyhit);

			// convert special keys
			if(RemoteControl.remotemap[keyhit]!=undefined) keyhit=RemoteControl.remotemapname[RemoteControl.remotemap[keyhit]];

			//trace("keyhit3 "+keyhit);

			switch(keyhit) {			   // MASTER
				case 0x1000040F:		   // syabas eject
				case 16777246:			   // dune top_menu
					trace("global eject hit");
					RemoteControl.remoteExit("EXIT", "Eject button pressed");
					break;
				default:                    // REST
					if(RemoteControl.keyListener.segment != null && RemoteControl.keyListener.segment(keyhit)  ==  true) break;  // segment
					if(RemoteControl.keyListener.minidex != null && RemoteControl.keyListener.minidex(keyhit)  ==  true) break;  // minidex
					if(RemoteControl.keyListener.screen != null && RemoteControl.keyListener.screen(keyhit)  ==  true) break;    // screen
					break;
			}
			RemoteControl.skinBusy = false;
		}
	}

	public static function mapremote(who) {
		trace("creating remote map for "+who);

		delete RemoteControl.remotemap;
		delete RemoteControl.remotemapname;
		RemoteControl.remotemap=new Object();
		RemoteControl.remotemapname=new Object();

		// default mappings
		RemoteControl.remotemapname['FILEMODE']=0x10000405;
		RemoteControl.remotemapname['TITLE']=0x10000406;
		RemoteControl.remotemapname['REPEAT']=0x10000407;
		RemoteControl.remotemapname['ANGLE']=0x10000408;
		RemoteControl.remotemapname['SLOW']=0x10000409;
		RemoteControl.remotemapname['TIMESEEK']=0x1000040A;
		RemoteControl.remotemapname['ZOOM']=0x1000040B;
		RemoteControl.remotemapname['TVMODE']=0x1000040C;
		RemoteControl.remotemapname['AUDIO']=0x01000017;
		RemoteControl.remotemapname['SOURCE']=0x1000040E;
		RemoteControl.remotemapname['EJECT']=0x1000040F;
		RemoteControl.remotemapname['MUTE']=0x01000003;
		RemoteControl.remotemapname['PLAY']=0x01000007;
		RemoteControl.remotemapname['PAUSE']=0x01000008;
		RemoteControl.remotemapname['STOP']=0x01000009;
		RemoteControl.remotemapname['FASTFORWARD']=0x0100000A;
		RemoteControl.remotemapname['FAST_FORWARD']=0x0100000A;
		RemoteControl.remotemapname['REWIND']=0x0100000B;
		RemoteControl.remotemapname['SKIPFORWARD']=0x0100000C;
		RemoteControl.remotemapname['SKIPBACK']=0x0100000D;
		RemoteControl.remotemapname['MENU']=0x01000012;
		RemoteControl.remotemapname['INFO']=0x01000013;
		RemoteControl.remotemapname['BACK']=0x01000016;
		RemoteControl.remotemapname['AUDIO']=0x01000017;
		RemoteControl.remotemapname['SUBTITLE']=0x01000018;
		RemoteControl.remotemapname['RED']=0x0100001F;
		RemoteControl.remotemapname['GREEN']=0x01000020;
		RemoteControl.remotemapname['YELLOW']=0x01000021;
		RemoteControl.remotemapname['BLUE']=0x01000022;
		RemoteControl.remotemapname['EQUAL']=187;
		RemoteControl.remotemapname['COMMA']=188;
		RemoteControl.remotemapname['SEMICOLON']=186;
		RemoteControl.remotemapname['NUM0']=48;
		RemoteControl.remotemapname['NUM1']=49;
		RemoteControl.remotemapname['NUM2']=50;
		RemoteControl.remotemapname['NUM3']=51;
		RemoteControl.remotemapname['NUM4']=52;
		RemoteControl.remotemapname['NUM5']=53;
		RemoteControl.remotemapname['NUM6']=54;
		RemoteControl.remotemapname['NUM7']=55;
		RemoteControl.remotemapname['NUM8']=56;
		RemoteControl.remotemapname['NUM9']=57;
		RemoteControl.remotemapname['ENTER']=Key.ENTER;
		RemoteControl.remotemapname['SELECT']=Key.ENTER;
		RemoteControl.remotemapname['PAGEUP']=Key.PGUP;
		RemoteControl.remotemapname['PAGEDOWN']=Key.PGDN;
		RemoteControl.remotemapname['SEARCH']=268436490;
		RemoteControl.remotemapname['SETUP']=0x0100001C;

		// hardware conversions
		switch(who) {
			case 'DUNE':
				RemoteControl.remotemap[Key.SHIFT]='ENTER';   // select button reverse map

				RemoteControl.remotemapname['RED']=16777247;
				RemoteControl.remotemapname['GREEN']=16777248;
				RemoteControl.remotemapname['YELLOW']=16777249;
				RemoteControl.remotemapname['BLUE']=16777250;
				RemoteControl.remotemapname['BACK']=16777238;	// return key
				RemoteControl.remotemapname['MENU']=16777234;	// popup menu
				RemoteControl.remotemapname['INFO']=16777235;
				RemoteControl.remotemapname['PAGEUP']=16777220;
				RemoteControl.remotemapname['PAGEDOWN']=16777221;
				RemoteControl.remotemapname['SEARCH']=268436490;
				RemoteControl.remotemapname['SETUP']=16777244;
				RemoteControl.remotemapname['FILEMODE']=0x10000405;
				RemoteControl.remotemapname['TITLE']=0x10000406;
				RemoteControl.remotemapname['REPEAT']=16777241;
				RemoteControl.remotemapname['ANGLE']=16777236;
				RemoteControl.remotemapname['SLOW']=16777228;
				RemoteControl.remotemapname['TIMESEEK']=0x1000040A;
				RemoteControl.remotemapname['ZOOM']=16777233;
				RemoteControl.remotemapname['TVMODE']=16777232;
				RemoteControl.remotemapname['SOURCE']=0x1000040E;
				RemoteControl.remotemapname['EJECT']=0x1000040F;
				RemoteControl.remotemapname['MUTE']=16777219;
				RemoteControl.remotemapname['PLAY']=16777223;
				RemoteControl.remotemapname['PAUSE']=16777224;
				RemoteControl.remotemapname['STOP']=0x01000009;
				RemoteControl.remotemapname['FASTFORWARD']=16777226;
				RemoteControl.remotemapname['FAST_FORWARD']=16777226;
				RemoteControl.remotemapname['REWIND']=16777227;
				RemoteControl.remotemapname['SKIPFORWARD']=16777230;
				RemoteControl.remotemapname['SKIPBACK']=16777231;
				RemoteControl.remotemapname['AUDIO']=16777239;
				RemoteControl.remotemapname['SUBTITLE']=16777240;
				break;
			default:    // syabas
				trace("using default codes");
				RemoteControl.remotemap[0x1000040D]="AUDIO";
		}
	}
}