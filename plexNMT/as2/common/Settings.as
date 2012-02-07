
import com.syabas.as2.common.Util;

import mx.utils.Delegate;
import mx.xpath.XPathAPI;

class plexNMT.as2.common.Settings {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.Settings;
	private static var settings:SharedObject = null;
	
	// Public Properties:
	public var plexURL:String = null;
	public var xWall:Number = null;
	public var yWall:Number = null;
		
	// Private Properties:
	private var plexServers:Array = null;

	// Destroy all global variables.
	public function destroy():Void
	{
		this.plexURL = null;
		this.xWall = null;
		this.yWall = null;
		this.plexServer = null;
		this.plexPort = null;
	}
	// Initialization:
	public function Settings() 
	{
		this.loadSettings();
	}
    // first entry function
    public static function start()
    {
        // set reading SharedObject callback function.
        // Not sure why, the callback function must be static when running on
        // the box, or else it will not get called.
        // You have to use callback function, because reading SharedObject may not
        // be instantaneous on embedded system.
        SharedObject.addListener("plexNMT", this.onSoRead);

        SharedObject.getLocal("plexNMT"); // start reading.
    }

    // this callback function will be called when the box finished reading the SharedObject.
    private static function onSoRead(so:SharedObject)
    {
        new loadSettings(so);
    }

    private function loadSettings(so:SharedObject)
    {
        settings = so;

        this.plexIP = settings.data.plexServers[0].plexIP;
		this.plexPort = settings.data.plexServers[0].plexPort;
		this.plexURL = "http://" + this.plexIP + ":" + this.plexPort;
	}
	
	private function saveSettings()
	{
		//settings.data.plexIP = "192.168.0.3";
		//settings.data.plexPort = "34200";
		
        Settings.so.flush();
	}
	
	public function addServer(ip:String, port:String)
	{
		plexSevers.push({plexIP:ip, plexPort:port});
	}
	
	
}