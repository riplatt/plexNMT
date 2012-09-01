
class plexNMT.as2.common.Utils
{
	public static function varDump(_obj:Object, indent:String) 
	{
		if (indent == undefined){
			indent = " ";
		}
		
		var indentPlus:String = substring(indent,0,1);
		
		for (var i in _obj) {
			trace(indent + i + " : " + _obj[i]);
			if (typeof (_obj[i]) == "object" || typeof (_obj[i]) == "movieclip") {
				varDump(_obj[i], indent + indentPlus);
			}
		}
	}
	
	public static function clone(obj:Object):Object
	{
		var i;
		var o;
		
		o = new Object()
		
		for(i in obj)
		{
			if(typeof(obj[i]) == "object")
			{
				o[i] = clone(obj[i]);
			} else {
				o[i] = obj[i];
			}
		}
		return(o);
	}
	
	public static function getObjectLength(obj:Object):Number
	{
		var len:Number = 0;
		for(var item in obj)
		{
			len++;
		}
		return len;
	}
	
	public static function formatTime(ms:Number):String
	{
		var hr:Number = int(ms/(1000 * 60 * 60));
		var min:Number = int(ms/(1000 *60)) - (hr * 60);
		
		return(hr + "hr " + min + "min");
	}
}