
import com.syabas.as2.common.Util;
import com.syabas.as2.common.D;

import mx.utils.Delegate;
import mx.xpath.XPathAPI;

import plexNMT.as2.common.PlexData;

/* -- to infrom plex what/who we are
?X-Plex-Client-Capabilities => 
	protocols=
		http-live-streaming,
		http-mp4-streaming,
		http-streaming-video,
		http-streaming-video-720p,
		http-mp4-video,
		http-mp4-video-720p;
	videoDecoders=
		h264{
			profile:high
			&resolution:1080
			&level:51
			};
	audioDecoders=
		mp3,
		aac{
			bitrate:160000
			}
&X-Plex-Client-Platform => 
	iOS
&X-Plex-Product =>
	Plex/iOS
&X-Plex-Version =>
	2.4.0
	
   -- to tell plex how much we have seen of video
/progress?key => 
	14872
&identifier => 
	com.plexapp.plugins.library
&time =>
	22672
&state => 
	playing //playing, stopped
	
	
-- myPlex Headers

X-Plex-Platform (Platform name, eg iOS, MacOSX, Android, LG, etc)
X-Plex-Platform-Version (Operating system version, eg 4.3.1, 10.6.7, 3.2)
X-Plex-Provides (one or more of [player, controller, server])
X-Plex-Product (Plex application name, eg Laika, Plex Media Server, Media Link)
X-Plex-Version (Plex application version number)
X-Plex-Device (Device name and model number, eg iPhone3, 2, Motorola XOOM™, LG5200TV)
X-Plex-Client-Identifier (UUID, serial number, or other number unique per device)


*/

class plexNMT.as2.api.PlexAPI_2
{
	
	// Constants:
	public static var CLASS_REF = plexNMT.as2.api.PlexAPI_2;
	public var plexURL:String = null;
	public var init:Boolean = false;
	
	// Public Properties:
	// Private Properties:
	private static var menu:String = "";

	// Initialization:
	public function PlexAPI_2() {
		if (this.init != flase) {
			
		}
	}
}