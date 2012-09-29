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
	
	/*public function ObjClone(_obj) {
		var i:String;
        var newObj;
     
        newObj = new Object();
        for(var i in _obj) {
            if(_obj[i] instanceof Array) {
                //Array Item
                trace("Found Array:"+i);
                newObj[i] = copyArray(_obj[i]);
            } else if(_obj[i] instanceof Object) {
                 
                trace("Found Sub Object:"+i);
                newObj[i] = ObjClone(_obj[i]);
                
            } else {
                //real data element (not a reference)
                trace("Found Real Data Element:"+i);
                newObj[i] = _obj[i];
            }
        }
        
        return(newObj);
        
    }
    
    
    public function copyArray(sArray) {
        var tArray = [];
        var numItems = sArray.length;
        for(var i=0;i<numItems;i++) {
            if(sArray[i] instanceof Array) {
                trace("Found an array in index:"+i)
                tArray[i] = copyArray[sArray[i]];
            } else if (sArray[i] instanceof Object) {
                trace("Found an object in index:"+i);
                tArray[i] = ObjClone(sArray[i]);
            } else {
                //real data element (not a reference)
                trace("Found real data element in index:"+i)
                tArray[i] = sArray[i];
            }
        }
        return tArray;
    }*/

	// Public Methods:
	// Private Methods:

}