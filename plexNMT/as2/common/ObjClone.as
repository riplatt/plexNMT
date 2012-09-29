class plexNMT.as2.common.ObjClone{
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.ObjClone;
	
	// Public Properties:
	// Private Properties:

	// Initialization:
	public function ObjClone(_obj:Object) {
		var i:String;
		
		for(i in _obj)
		{
			this[i] = new Object(_obj[i]);
			ObjClone(_obj[i]);
		}
	}
}