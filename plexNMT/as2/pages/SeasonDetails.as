
import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.UI;

import plexNMT.as2.api.PlexAPI;
import plexNMT.as2.common.Remote;


class plexNMT.as2.pages.SeasonDetails extends MovieClip {
	
	// Constants:	
	public static var CLASS_REF = plexNMT.as2.pages.SeasonDetails;

	


	// Initialization:
	private function SeasonDetails() 
	{
		/*trace("Doing plexNMT.movieDetails...");
		
		plexRatingKey = _level0.plex.currentRatingKey;

		this.parentMC = parentMC;

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		
		this.preloadMC = this.parentMC.attachMovie("preload200", "preload200", parentMC.getNextHighestDepth(), {_x:640, _y:360});
		PlexAPI.loadSeasonDetails(plexURL+"library/metadata/" + plexRatingKey + "/children", Delegate.create(this, this.onDataLoad), 5000);*/
	}

	private function onDataLoad(data:Object):Void
	{
		/*trace("Doing SeDetails.parseXML.data: ");
		//var_dump(data);
		
		this.enableKeyListener();*/
			
	}
}