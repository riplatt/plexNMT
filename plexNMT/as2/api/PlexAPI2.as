import plexNMT.as2.common.PlexData;
import plexNMT.as2.common.Utils;
import plexNMT.as2.common.ObjClone;

import com.gskinner.net.XML2;

import it.sephiroth.XMLObject;

import mx.utils.Delegate;
import mx.events.EventDispatcher;

class plexNMT.as2.api.PlexAPI2 {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.api.PlexAPI2;
	
	// Public Properties:
	public var dispatchEvent:Function;
    public var addEventListener:Function;
    public var removeEventListener:Function;
	// Private Properties:
	private var _listener:Object;

	// Initialization:
	public function PlexAPI2() {
       
		_listener = new Object();
		EventDispatcher.initialize(this);
	}

	// Public Methods:
	public function lazyLoad(strObj:String, key:String, iStart:Number, iSize:Number)
	{
		trace("PlexAPI - Doing Lazy Load...");
		
		if (PlexData[strObj].MediaContainer != undefined)
		{
			trace("PlexAPI - "+strObj+" Initialized...");
			if (iSize > PlexData[strObj].intLength)
			{
				trace("PlexAPI - iSize is bigger then range, Setting to range size...")
				iSize = PlexData[strObj].intLength;
			}
			var iBegin:Number = PlexData.getRotation(strObj, iStart);
			trace("PlexAPI - "+(iBegin+iSize)+" > "+PlexData[strObj].intLength);
			if (iBegin+iSize>PlexData[strObj].intLength)
			{
				trace("PlexAPI - Request is out of range, Doing 2 Calls...");
				var iEnd:Number = iBegin+iSize-PlexData.oWallData.intLength;
				
				var url1:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start="+iBegin+"&X-Plex-Container-Size="+iSize;
				var url2:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start=0&X-Plex-Container-Size="+iEnd;
				
				getData(strObj, url1, PlexData.oSettings.timeout, {iStart:iBegin, iEnd:PlexData[strObj].intLength+1, action:"wait"});
				getData(strObj, url2, PlexData.oSettings.timeout, {iStart:0, iEnd:iEnd, action:"dispatch"});
			} else {
				trace("PlexAPI - Request is in range, Doing 1 Call...");
				var url:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start="+iStart+"&X-Plex-Container-Size="+iSize;
				
				getData(strObj, url, PlexData.oSettings.timeout, {iStart:iStart, iSize:iSize, action:"dispatch"});
			}
		} else {
			trace("PlexAPI - No Data Yet! Initializing "+strObj+"...");
			var url:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start=0&X-Plex-Container-Size=1";

			getData(strObj, url, PlexData.oSettings.timeout, {key:key, iStart:iStart, iSize:iSize, action:"init"});
		}
	}
	// Private Methods:
	private function getData(strObj:String, url:String, timeout:Number, obj:Object):Void
	{
		trace("PlexAPI - Doing getData...");
		//Utils.traceVar(obj);
		var myXML:XML2 = new XML2();
		var _obj:Object = new ObjClone(obj);
		myXML.addEventListener("complete", Delegate.create(this, onXMLLoad));
		myXML.addEventListener("httpStatus", Delegate.create(this, httpStatus));
		myXML.connectionTimeout = 3000;
		myXML.timeout = PlexData.oSettings.timeout;
		myXML.obj = {strObj:strObj, obj:_obj};
		trace("PlexAPI - Calling XML2.load with: " + url);	
		myXML.load(url);
	}
	
	private function onXMLLoad(evtObj:Object):Void
	{
		trace("PlexAPI - Doing onXMLLoad...");
		//Utils.traceVar(evtObj.obj);
		var XMLObj:XML = evtObj.target;
		var obj:Object = new ObjClone(evtObj.obj.obj);
		var strObj:String = evtObj.obj.strObj;
		trace("PlexAPI - obj.action:"+obj.action+" || strObj:"+strObj);
		if (obj.action == "init") {
			trace("PlexAPI - Initializing " + evtObj.obj.strObj);
			//var strObj:String = evtObj.obj.strObj;
			PlexData[strObj] = new XMLObject().parseXML(XMLObj, true);
			trace("PlexAPI - "+strObj.substr(1, strObj.length -1));
			PlexData["set" + strObj.substr(1, strObj.length -1)]();
			obj.action = "lasyload";
		} else {
			trace("PlexAPI - Adding objects to " + evtObj.obj.strObj);
			var j:Number = 0;
			var i:Number = 0;
			var child:String = "";
			var _obj:Object = new XMLObject().parseXML(XMLObj, true);
			if (_obj.MediaContainer[0].Directory != undefined)
			{
				child = "Directory";
			} else {
				child = "Video";
			}
			trace("PlexAPI - Adding objects to " + evtObj.obj.strObj + " from " + obj.iStart + " to " + obj.iEnd);
			for (j=obj.iStart; j<obj.iEnd; j++)
			{
				trace("PlexAPI - Adding " + _obj.MediaContainer[0][child][i].attributes.title + " to MediaContainer[0]["+child+"]["+j+"]");
				PlexData.oWallData.MediaContainer[0][child][j] = _obj.MediaContainer[0][child][i];
				trace("PlexAPI - Added " + PlexData.oWallData.MediaContainer[0][child][j].attributes.title);
				i++;
			}
		}
		
		delete XMLObj.idMap;
		XMLObj = null;

		trace("PlexAPI - Calling onDataLoad...");
		this.onDataLoad(strObj, obj);
	}

	// function to handle the httpStatus event:
	private function httpStatus(evtObj:Object):Void {
		trace("PlexAPI - http status: "+evtObj.httpStatus);
	}
	
	private function onDataLoad(strObj:String, obj:Object):Void
	{
		trace("PlexAPI - Doing onDataLoad...");
		Utils.traceVar(obj);
		var action:String = obj.action.toString();
		if (action == undefined)
		{
			trace("PlexAPI - Dispatching evtError event...");
			dispatchEvent ({type:"evtError", msg:"PlexAPI.onDataLoad call without action..."});
		} else {
			trace("PlexAPI - obj.action:"+action+" typeOf:"+typeof(action));
			switch (action)
			{
				case "lasyload":
					//PlexData["set" + strObj.substr(1, strObj.length -1)]();
					lazyLoad(strObj, obj.key, obj.iStart, obj.iSize);
				break;
				case "dispatch":
					trace("PlexAPI - Dispatching onDataLoaded event...");
					dispatchEvent ({type:"onDataLoaded"});
				break;
				case "wait":
					trace("PlexAPI - Been asked to wait...");
				break;
			}
		}
	}
}