/***************************************************
* Copyright (c) 2011 Syabas Technology Inc.
* All Rights Reserved.
*
* The information contained herein is confidential property of Syabas Technology Inc.
* The use of such information is restricted to Syabas Technology Inc. platform and
* devices only.
*
* THIS SOURCE CODE IS PROVIDED ON AN "AS-IS" BASIS WITHOUT WARRANTY OF ANY KIND AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL Syabas Technology Sdn. Bhd. BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS UPDATE, EVEN IF Syabas Technology Sdn. Bhd.
* HAS BEEN ADVISED BY USER OF THE POSSIBILITY OF SUCH POTENTIAL LOSS OR DAMAGE.
* USER AGREES TO HOLD Syabas Technology Sdn. Bhd. HARMLESS FROM AND AGAINST ANY AND
* ALL CLAIMS, LOSSES, LIABILITIES AND EXPENSES.
*
* Version: 1.0.2
*
* Developer: Syabas Technology Inc.
*
* Class Description: Sequential Image Loader.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.IMGLoader
{
	private static var ACTUAL_SIZE:Number = 1;
	private static var FIT_TO_SCREEN:Number = 2;
	private static var FULL_SCREEN:Number = 3;

	private var imgs:Array = null;		// array of imageLoader MovieClipLoader objects pool.
	private var q:Array = null;			// queue containing the data that will be used to load the Image.
	private var idItems:Object = null;	// stored the item object of the specific id.
	private var maxLoad:Number = -1;	// how many Image will be loading at one time. Default is 1. Maximum 6 Image will be loading.
	private var onloads:Array = null;	// containing the parentMC current in loading.

	/*
	* Destroy all global variables.
	*/
	public function destroy():Void
	{
		delete this.onloads;
		this.onloads = null;
		delete this.imgs;
		this.imgs = null;
		delete this.q;
		this.q = null;
		delete this.idItems;
		this.idItems = null;
	}

	/*
	* Contructor.
	*
	* maxLoad: how many Image will be loading at one time. Default is 1. Maximum 6.
	*/
	public function IMGLoader(maxLoad:Number)
	{
		this.q = new Array();
		this.idItems = new Object();

		if (maxLoad == undefined || maxLoad == null)
			maxLoad = 1;

		if(maxLoad > 6)
			maxLoad = 6;

		this.maxLoad = maxLoad;
		this.onloads = new Array();
		this.imgs = new Array();
		this.initLoader(maxLoad)
	}

	/*
	* Initialize MovieClipLoader instance.
	*/
	private function initLoader(maxLoad:Number):Void
	{
		var imgLoader:MovieClipLoader = null;
		var img:Object = null;
		var fn:Object = {
			loadImg:Delegate.create(this, this.loadImg),
			onLoaded:Delegate.create(this, this.onLoaded)
		};

		for (var i:Number=0; i<maxLoad; i++)
		{
			img = new Object();
			imgLoader = new MovieClipLoader();
			img.imgLoader = imgLoader;
			img.fn = fn;
			img.i = i;

			imgLoader.addListener(img);

			img.onLoadInit = Delegate.create(img, function(targetMC:MovieClip):Void
			{
				var width:Number = this.item.o.scaleProps.width;
				var height:Number = this.item.o.scaleProps.height;
				if(width == undefined || width == null)
					width = 1280;
				if(height == undefined || height == null)
					height = 720;
				
				var scaleMode:Number = this.item.o.scaleMode;
				if(scaleMode == undefined || scaleMode == null)
					scaleMode = 1;

				switch(scaleMode)
				{
					case IMGLoader.FIT_TO_SCREEN:
						IMGLoader.scaleImage(targetMC, width, height);
					break;
					case IMGLoader.FULL_SCREEN:
						IMGLoader.stretchImage(targetMC, width, height);
					break;
					case IMGLoader.ACTUAL_SIZE:
					default://do ntg
						if (targetMC._width > width || targetMC._height > height)
						{
							var op:Number = this.item.o.scaleProps.actualSizeOption;
							if(op == undefined || op == null)
								op = 1;
							switch(op)
							{
								default:
								case 1://fit to screen
									IMGLoader.scaleImage(targetMC, width, height);
								break;
								case 2://full screen
									IMGLoader.stretchImage(targetMC, width, height);
								break;
								case 3://actual size, do ntg.
								break;
							}
						}
					break;
				}
				if(this.item.o.scaleProps.center == true)
				{
					targetMC._x = (width - targetMC._width) / 2;
					targetMC._y = (height - targetMC._height) / 2;
				}

				var mcProps:Object = this.item.o.mcProps;
				for (var prop:String in mcProps)
					targetMC[prop] = mcProps[prop];

				var lmcId:String = this.item.o.lmcId;
				if (lmcId != undefined && lmcId != null && !this.item.skip)
					this.item.loadingMC.removeMovieClip();
				this.fn.onLoaded(true, this);
			});

			// errorCode: URLNotFound or LoadNeverCompleted
			img.onLoadError = Delegate.create(img, function(targetMC:MovieClip, errorCode:String, httpStatus:Number):Void
			{
				var lmcId:String = this.item.o.lmcId;
				if (lmcId != undefined && lmcId != null && !this.item.skip)
					this.item.loadingMC.removeMovieClip();

				if (this.item.o.retry > 0)
				{
					this.item.o.retry--;
					this.imgLoader.loadClip(this.item.url, this.item.imgMC);
				}
				else
					this.fn.onLoaded(false, this);
			});

			this.imgs.push(img);
		}
	}

	/*
	* Clear all the data.
	*/
	public function clear()
	{
		delete this.onloads;
		this.onloads = null;
		this.onloads = new Array();
		delete this.imgs;
		this.imgs = null;
		this.imgs = new Array();
		this.initLoader(this.maxLoad);
		this.q.splice(0);
		delete this.idItems;
		this.idItems = new Object();
	}

	/*
	* Load Image from a specific URL.
	*
	* id: loading Image with same ID will skip all the previous Image with same ID.
	* url: the image URL.
	* parentMC: parent movieClip to attach the new image movieClip.
	* o: extra arguments Object with properties:
	*   1. mcProps:Object      - properties of the image movieClip.
	*   2. lmcId:String        - id of the loading animation movieClip.
	*   3. lmcProps:Object     - properties of the loading movieClip.
	*   4. retry:Number        - retry how many time when failed.
	*   5. addToFirst:Boolean  - add this new URL as first item on the queue.
	*   6. scaleMode:Number    - mode to scale after image loaded. 1=Actual Size, 2=Fit To Screen, 3=Full Screen. Default is 1.
	*   7. scaleProps:object   - properties of the scaling process.
	*      a. center:Boolean   - keep image at center of parent movieclip.
	*      b. width:Number     - width of the image to scale. Default is 1280.
	*      c. height:Number    - height of the image to scale. Default is 720.
	*      d. actualSizeOption:Number - use when loaded image more then width or height and scaleMode is 1. 1=Fit to Screen, 2=Full Screen, 3=no change. Default is 1.
	*   8. doneCB:Function     - callback function when image is loaded or failed. Arguments:
	*       a. success:Boolean.
	*       b. o:Object        - extra object to pass back.
	*			i. id:String   - same as the id pass to this load function.
	*			ii. url:String - same as the url pass to this load function.
	*			iii. o:Object  - same as the "o" Object pass to this load function.
	*
	* parentMC
	*   |-- loadingMC
	*   |-- <il_holder>
	*         |-- imgMC_<random number>
	*
	*/
	public function load(id:String, url:String, parentMC:MovieClip, o:Object):Void
	{
		if (id == undefined)
			id = null;
		var retry:Number = o.retry;
		if (retry == undefined || retry == null || retry == "" || isNaN(retry) || typeof(retry) != "number" || retry < 1)
			o.retry = 0;

		var l:Number = -1;
		for (var item:String in parentMC["il_holder"])
		{
			l = this.onloads.length;
			for (var i:Number = 0;  i < l; i++)
			{
				if (this.onloads[i] == parentMC) // check current movieclip onloading.
				{
					this.onloads.splice(i, 1);
					this.initLoader(1);
					break;
				}
			}
			parentMC["il_holder"][item].removeMovieClip();
		}

		parentMC["il_holder"].removeMovieClip();
		var imgHolderMC:MovieClip = parentMC.createEmptyMovieClip("il_holder", parentMC.getNextHighestDepth());
		var d:Date = new Date();
		var mcName:String = "imgMC_"+d.getTime()
		var imgMC:MovieClip = imgHolderMC.createEmptyMovieClip(mcName , imgHolderMC.getNextHighestDepth());

		var loadingMC:MovieClip = null;
		if (o.lmcId != undefined && o.lmcId != null)
		{
			loadingMC = parentMC[o.lmcId];
			if(loadingMC == undefined || loadingMC == null)
				loadingMC = parentMC.attachMovie(o.lmcId, o.lmcId, parentMC.getNextHighestDepth());

			var lmcProps:Object = o.lmcProps;
			for (var prop:String in lmcProps)
				parentMC[o.lmcId][prop] = lmcProps[prop];
		}

		var item:Object = {id:id, url:url, parentMC:parentMC, o:o, skip:false, loadingMC:loadingMC, imgMC:imgMC, mcName:mcName};

		if (id != null)
		{
			var idItem:Object = this.idItems[id];
			if (idItem != undefined || idItem != null) // set previous item with same id to skip.
				idItem.skip = true;
			this.idItems[id] = item;
		}

		if (this.imgs.length > 0)
		{
			var img:Object = this.imgs.pop();
			img.fn.loadImg(img, item);
		}
		else if (o.addToFirst == true)
			this.q.unshift(item);
		else
			this.q.push(item);
	}

	private function loadImg(img:Object, item:Object):Void
	{
		this.onloads.push(item.parentMC)
		img.item = item;
		img.imgLoader.loadClip(item.url, item.imgMC);
	}

	private function onLoaded(success:Boolean, img:Object):Void
	{
		var item:Object = img.item;
		var l:Number = this.onloads.length;

		for (var i:Number = 0;  i < l; i++)
		{
			if(this.onloads[i] == item.parentMC)
			{
				this.onloads.splice(i, 1);
				break;
			}
		}

		var doneCB:Function = item.o.doneCB;
		if (!item.skip && doneCB != undefined && doneCB != null)
			doneCB(success, {id:item.id, url:item.url, o:item.o}); // callback.

		IMGLoader.clearItem(item);

		if (this.q.length > 0) // load the next URL
		{
			item = this.q.shift();
			while (item != null && item.skip) // skipping all previous id items.
			{
				IMGLoader.clearItem(item);
				item = this.q.shift();
			}

			if (item != null)
				img.fn.loadImg(img, item);
		}
		else
			this.imgs.push(img);
	}

	private static function clearItem(item:Object):Void
	{
		item.mcName = null;
		item.loadingMC = null;
		item.imgMC = null;
		item.id = null;
		item.url = null;
		item.parentMC = null;
		item.skip = true;
	}

	/*
	* Unload image and clear created movieclip.
	*
	* id       - unload Image with same ID.
	* parentMC - parent movieClip to attach the new image movieClip.
	* lmcId    - id of the loading animation movieClip.
	*/
	public function unload(id:String, parentMC:MovieClip, lmcId:String):Void
	{
		var l:Number = -1;
		for(var item:String in parentMC["il_holder"])
		{
			l = this.onloads.length;
			for (var i:Number = 0;  i < l; i++)
			{
				if(this.onloads[i] == parentMC) //check current movieclip onloading.
				{
					this.onloads.splice(i, 1);
					this.initLoader(1);
					break;
				}
			}
			parentMC["il_holder"][item].removeMovieClip();
		}

		parentMC[lmcId].removeMovieClip();
		if (id != null)
		{
			var idItem:Object = this.idItems[id];
			if (idItem != undefined || idItem != null) // set previous item with same id not to load and show.
				idItem.skip = true;
		}
	}

	private static function scaleImage(mc:MovieClip, width:Number, height:Number):Void
	{
		var mcWidth:Number = mc._width;
		var mcHeight:Number = mc._height;
		
		if ((width * mcHeight) > (height * mcWidth)) // (width / height) > (mcWidth / mcHeight)
		{
			mc._height = height;
			mc._width = (height / mcHeight) * mcWidth;
		}
		else
		{
			mc._width = width;
			mc._height = (width / mcWidth) * mcHeight;
		}
	}

	private static function stretchImage(mc:MovieClip, width:Number, height:Number):Void
	{
		mc._width = width;
		mc._height = height;
	}
}