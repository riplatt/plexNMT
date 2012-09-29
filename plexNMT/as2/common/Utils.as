
class plexNMT.as2.common.Utils {
	public static function varDump(_obj:Object, indent:String):String {
		var strDump:String = "";
		if (indent == undefined) {
			indent = " ";
		}

		var indentPlus:String = substring(indent, 0, 1);

		for (var i in _obj) {
			strDump = strDump+indent+i+" : "+_obj[i]+" || "+typeof (_obj[i])+"\n";
			if (typeof (_obj[i]) == "object" || typeof (_obj[i]) == "movieclip") {
				strDump = strDump+varDump(_obj[i], indent+indentPlus);
			}
		}
		return strDump;
	}

	public static function traceVar(_obj:Object, indent:String):Void {
		var strDump:String = "";
		if (indent == undefined) {
			indent = " ";
		}

		var indentPlus:String = substring(indent, 0, 1);

		for (var i in _obj) {
			trace(indent+i+" : "+_obj[i]+" || "+typeof (_obj[i]));
			if (typeof (_obj[i]) == "object" || typeof (_obj[i]) == "movieclip") {
				traceVar(_obj[i],indent+indentPlus);
			}
		}
	}

	public static function cleanUp(_obj:Object):Void {
		for (var i in _obj) {
			//trace(i+" : "+_obj[i]+" || "+typeof (_obj[i]));
			switch (typeof (_obj[i])) {
				case "object" :
				case "movieclip" :
					cleanUp(_obj[i]);
					break;
				default :
					//trace("Removing: "+_obj[i]+" || "+typeof (_obj[i]));
					_obj[i] = null;
					delete _obj[i];
					break;
			}
			if (typeof (_obj[i]) == "movieclip") {
				//trace("Removing: "+_obj[i]+" || "+typeof (_obj[i]));
				_obj[i].removeMovieClip();
				delete _obj[i];
			}
		}
	}

	public static function clone(obj:Object):Object {
		var i;
		var o;

		o = new Object();
		for (i in obj) {
			if (typeof (obj[i]) == "object") {
				o[i] = clone(obj[i]);
			} else {
				o[i] = obj[i];
			}
		}
		return (o);
	}

	public static function getObjectLength(obj:Object):Number {
		var len:Number = 0;
		for (var item in obj) {
			len++;
		}
		return len;
	}

	public static function formatTime(ms:Number):String {
<<<<<<< HEAD
		var hr:Number = int(ms/(1000*60*60));
		var min:Number = int(ms/(1000*60))-(hr*60);

		return (hr+"hr "+min+"min");
=======
		
		
		var hr:Number = int(ms/(1000*60*60));
		var min:Number = int(ms/(1000*60))-(hr*60);
		var sec:Number = int((ms/1000)-(min*60)-(hr*60*60));
		
		switch (true)
		{
			case ms < 60000:
				return (sec+"s");
			break;
			case ms < 3600000:
				return (min+"min"+sec+"s");
			break;
			default:
				return (hr+"hr "+min+"min");
			break;
		}

		return ("0s");
>>>>>>> origin/dev
	}
}