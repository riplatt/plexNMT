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
		trace("PlexAPI - key=>"+key);
		trace("PlexAPI - iStart=>"+iStart);
		trace("PlexAPI - size=>"+iSize);
		trace("PlexAPI - strObj=>"+strObj);
		if (PlexData[strObj].MediaContainer != undefined)
		{
			trace("PlexAPI - "+(iStart+iSize)+" > "+PlexData[strObj].intLength);
			if (iStart+iSize>PlexData[strObj].intLength)
			{
				var iEnd:Number = iStart+iSize-PlexData.oWallData.intLength;
				var url1:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start="+iStart+"&X-Plex-Container-Size="+iSize;
				var url2:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start=0&X-Plex-Container-Size="+iEnd;
				
				//Util.loadURL(url1, Delegate.create({onLoad:onLoad}, onLazyLoad), {target:"xml", timeout:timeout, intStart:iStart, iSize:PlexData.oWallData.intLength, _key:key, action:"wait"});
				//Util.loadURL(url2, Delegate.create({onLoad:onLoad}, onLazyLoad), {target:"xml", timeout:timeout, intStart:0, iSize:iEnd, _key:key, action:"dispatch"});
			} else {
				var url:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start="+iStart+"&X-Plex-Container-Size="+iSize;
				//Util.loadURL(url, Delegate.create({onLoad:onLoad}, onLazyLoad), {target:"xml", timeout:timeout, intStart:iStart, iSize:iStart+size, _key:key , action:"dispatch"});
			}
		} else {
			trace("PlexAPI - No Data Yet! Initializing "+strObj+"...");
			var url:String = PlexData.oSettings.url + key + "?X-Plex-Container-Start=0&X-Plex-Container-Size=1";

			getData(strObj, url, PlexData.oSettings.timeout, {key:key, iStart:iStart, iSize:iSize, action:"init"});
			trace("PlexAPI - this:");
			Utils.traceVar(this);
			this.addEventListener("onDataLoad", this);
			//this.addEventListener("onDataLoad", this);
			//getWallData(key, 0, 1, Delegate.create({onLoad:onLoad}, getLazyWallData), {key:key, iStart:iStart, size:size, onLoad:onLoad, timeout:timeout},PlexData.oSettings.timeout);
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
		Utils.traceVar(evtObj.obj);
		var XMLObj:XML = evtObj.target;
		var obj:Object = new ObjClone(evtObj.obj.obj);
		var strObj:String = evtObj.obj.strObj;
		trace("PlexAPI - obj.action:"+obj.action+" || strObj:"+strObj);
		if (obj.action == "init") {
			trace("PlexAPI - Initializing " + evtObj.obj.strObj);
			//var strObj:String = evtObj.obj.strObj;
			PlexData[strObj] = new XMLObject().parseXML(XMLObj, true);
			obj.action = "lasyload";
		} else {
			
		}
		
		/*trace("PlexAPI - Calling onDataLoad...");
		this.onDataLoad(strObj, obj);*/
		//Dispatch
		trace("PlexAPI - Sending Dispatch Event 'helloBob'...");
		dispatchEvent ({type:"helloBob", strObj:strObj, obj:obj});
		this.helloBob();
	}

	private function helloBob():Void{
		trace("PlexAPI - Hello Bob...");
	}
	// function to handle the httpStatus event:
	private function httpStatus(evtObj:Object):Void {
		trace("PlexAPI - http status: "+evtObj.httpStatus);
	}
	
	private function onDataLoad(strObj:String, obj:Object):Void
	{
		trace("PlexAPI - Doing onDataLoad...");
		if (obj.action == undefined)
		{
			dispatchEvent ({type:"onDataLoaded"});
		} else {
			switch (obj.action)
			{
				case "lasyload":
					PlexData["set" + strObj.substr(1, strObj.length -1)]();
				break;
				case "dispatch":
					
				break;
				case "wait":
					
				break;
			}
		}
	}
}