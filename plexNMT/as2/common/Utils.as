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
}