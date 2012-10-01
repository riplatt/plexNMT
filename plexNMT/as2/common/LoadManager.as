import mx.events.EventDispatcher;

class plexNMT.as2.common.LoadManager {
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.common.LoadManager;
	
	// Public Properties:
	public var dispatchEvent:Function;
    public var addEventListener:Function;
    public var removeEventListener:Function;
    
	// Private Properties:
	private var _loader:MovieClipLoader;
    private var _loaded:Boolean;
    private var _listener:Object;
    private var _progressBar:MovieClip;
    private var _target:MovieClip;
    private var _url:String;
    private var _scale:Number;
    private var _percent:Number;

	// Initialization:
	public function LoadManager(url:String, target:MovieClip) {
        _loader = new MovieClipLoader();
        _listener = new Object();
        _url = url;
        _scale = 1;
        _percent = 0;
        _target = target;
        EventDispatcher.initialize(this);
	}

	// Public Methods:
	public function destroy():Void
	{
		_loader.unloadClip();
		_loader.removeListener(this);
		_loader = null;
		
		_progressBar.removeMovieClip();
		delete _progressBar;
		
		_listener = null;
	}
	
	public function beginLoad()
	{
        if (_percent == 0) {
            _percent = 0.001;
            _loader.addListener(this);
            _loader.loadClip(_url, _target);
        }
    }
	
	public function get progressBar():MovieClip { return(_progressBar); }
    public function set progressBar(mc:MovieClip) { _progressBar = mc; }

    public function get mc():MovieClip { return(_target); }
    //public function set mc(mc:MovieClip) { _target = mc; }

    public function get scale():Number { return(_scale); }
    public function set scale(val:Number) { _scale = val; }

    public function get percent():Number { return(_percent); }
    public function set percent(val:Number) { _percent = val; }

    public function get loaded():Boolean { return(_loaded); }
    public function set loaded(val:Boolean) { _loaded = val; }

    public function get alpha():Number { return(_progressBar._alpha); }
    public function set alpha(val:Number) { _progressBar._alpha = val; }
	
	// Private Methods:
	private function onLoadStart(mc:MovieClip) {
        // code here for declaring functions on the new loaded movie...
    }
    
    private function onLoadError(mc:MovieClip, errorCode:String, httpStatus:Number) {
        trace("LoadManager - " + mc + " error: " + errorCode + " (" + httpStatus + ")");
    } 
    
    private function onLoadProgress(mc:MovieClip, bytesLoaded:Number, bytesTotal:Number) {
        _percent = (bytesLoaded / bytesTotal) * 100;
        _progressBar._xscale = (_scale * _percent);// * .98;
    }
    
    private function onLoadComplete(target_mc:MovieClip, httpStatus:Number) {
        //if (httpStatus != 0) trace("LoadManager - Status: (" + target_mc + ") " + httpStatus);
		dispatchEvent ({type:"onLoadComplete"});
    }
    
    private function onLoadInit(mc:MovieClip) {
        _loaded = true;
        dispatchEvent ({type:"complete", movie:mc, loader:this});
    }
}