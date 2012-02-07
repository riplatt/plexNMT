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
* Version: 1.0.5
*
* Developer: Syabas Technology Inc.
*
* Class Description: Grid component.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.Grid
{
	public static var SCROLL_LINE:Number = 0; // scroll by line.
	public static var SCROLL_PAGE:Number = 1; // scroll by page.

	// config object properties default value.
	private static var DEFAULTS:Object = {
		mcArray:null, cSize:0, rSize:0, len:0,
		horiz:false, wrap:true, wrapLine:true, scroll:Grid.SCROLL_LINE,
		onDisplayCB:null, updateCB:null, clearCB:null, hlCB:null, unhlCB:null,
		overTopCB:null, overBottomCB:null, overLeftCB:null, overRightCB:null,
		onEnterCB:null, keyDownCB:null, hlStopCB:null, hlStopTime:0,
		loadDataCB:null, pagePerLoad:-1, maxLoads:1, singleSelectCB:null
	};

	// **WARNING: variables below are READ ONLY for public, they should not be changed outside of this class.
	//			It is for performance tuning. Accessing variable directly is faster than going through getter function.
	public var o:Object = null;			// config object.
	public var empty:Boolean = true;	// when data empty or no movieClip.
	public var size:Number = -1;		// cSize * rSize
	public var loadSize:Number = -1;	// size * pagePerLoad. (if fixed o.data is specified, loadSize will set to -1)
	public var hl:Number = -1;			// highlight data index.
	public var top:Number = -1;			// UI 1st item data index.
	private var prevAction:Number = 0;	// 0:no action, 1:up, 2:down, 3:left, 4:right

	private var o2:Object = null;		// to handle vert/horiz, storing cSize, rSize, over(Top/Bottom/Left/Right)CB, mcArray.
	private var showObj:Object = null;	// data to be used in the onShow function.
	private var keyDown:Function = null;
	private var keyListener:Object = null;
	private var c:Number = -1;			// highlight column. row if horizontal.
	private var r:Number = -1;			// highlight row. column if horizontal.
	private var lastTop:Number = -1;	// last page 1st item data index.
	private var lastC:Number = -1;		// last item column.
	private var lastR:Number = -1;		// last item row.
	private var hlStopIntervalId:Number = null; // hlStop intervalId.

	private var loads:Array = null;		// 2D array to store each load of data.
	private var loadDataObj:Object = null; // load data Object for retry purpose.

	public var selIndex:Number = -1;	// single selected index. Default is -1 (meaning no item selected).

	private var fn:Object = null;		// storing all Delegate.create functions for performance tuning.
	public var up:Function = null;		// function to move up.
	public var down:Function = null;	// function to move down.
	public var left:Function = null;	// function to move left.
	public var right:Function = null;	// function to move right.

	private var autoMove:Object = null;	// storing auto move to support disable, colspan and rowspan feature.
	private var klInterval:Number = 0;	// key listener interval id.

	/*
	* Destroy all global variables.
	*/
	public function destroy():Void
	{
		this.keyListener.onKeyDown = null;
		Key.removeListener(this.keyListener);

		delete this.o;
		this.o = null;
		this.empty = true;
		this.size = -1;
		this.loadSize = -1;
		this.hl = -1;
		this.top = -1;
		delete this.o2;
		this.o2 = null;
		delete this.keyDown;
		this.keyDown = null;
		delete this.keyListener;
		this.keyListener = null;
		this.c = -1;
		this.r = -1;
		this.lastTop = -1;
		this.lastC = -1;
		this.lastR = -1;
		this.selIndex = -1;
		this.hlStopIntervalId = null;
		delete this.loads;
		this.loads = null;
		this.clearLoadDataObj();
		this.clearShowObj();
		delete this.fn;
		this.fn = null;
	}

	/*
	* Constructor.
	*
	* o: config object, please refer to set(o:Object) function
	*/
	public function Grid(o:Object)
	{
		this.o = new Object();
		for (var prop:String in Grid.DEFAULTS)
			this.o[prop] = Grid.DEFAULTS[prop]; // set config object to all default values.

		this.set(o);

		this.fn = {
			onShow:Delegate.create(this, this.onShow),
			onEnableKeyListener:Delegate.create(this, this.onEnableKeyListener),
			onHLStop:Delegate.create(this, this.onHLStop),
			updateAllMC:Delegate.create(this, this.updateAllMC),
			verticalMCArrayUp:Delegate.create(this, this.verticalMCArrayUp),
			verticalMCArrayDown:Delegate.create(this, this.verticalMCArrayDown)
		};

		this.keyListener = new Object();
		Key.addListener(this.keyListener);
		this.keyDown = Delegate.create(this, this.onKeyDown);
	}

	/*
	* o: config object with properties below:
	*   1.  mcArray:Array       - 2 dimesional array of movieClip for the Grid. Default is null.
	*   2.  *parentMC:MovieClip - parent movieClip that house all the movieClips for the Grid. (required if mcArray is not specified)
	*   3.  cSize:Number        - number of column. Default is 0. (required if parentMC is specified)
	*   4.  rSize:Number        - number of row. Default is 0. (required if parentMC is specified)
	*   5.  *mcPrefix:String    - movieClip instanceId prefix for the Grid. Default is 'item'. (for case 'b' and 'c' below)
	*   6.  *mcName:String      - movieClip name used to create the grid. (required for case 'c' below)
	*   7.  *x:Number           - top left movieClip x position. Default is 0. (for case 'c' below)
	*   8.  *y:Number           - top left movieClip y position. Default is 0. (for case 'c' below)
	*   9.  *hgap:Number        - horizontal gap between movieClips. Default is 0. (for case 'c' below)
	*   10. *vgap:Number        - vertical gap between movieClips. Default is 0. (for case 'c' below)
	*
	*   There are 3 combinations of properties 1 to 7:
	*       a. mcArray only - cSize and rSize will be calculated based on this mcArray.
	*       b. parentMC, cSize, rSize, mcPrefix - all the movieClips for the Grid should already created
	*          on the parentMC. mcArray will be created.
	*       c. parentMC, cSize, rSize, mcName, hgap, vgap, x, y - all the movieClips for the Grid will be
	*          created on the parentMC. mcArray will be created.
	*
	*   11. horiz:Boolean         - true to scroll Horizontally. Default is false(Vertical).
	*   12. wrap:Boolean          - true to wrap from last to 1st, and 1st to last line. Default is true.
	*   13. wrapLine:Boolean      - true to wrap from line to line (e.g. For vertical, go right on last column will go to
	*                               next line, go left on 1st column will go to previous line). Default is true.
	*   14. scroll:Number         - Grid.SCROLL_PAGE = Scroll page by page, Grid.SCROLL_LINE = Scroll line by line. Default is Grid.SCROLL_LINE.
	*   15. onDisplayCB:Function  - callback function that will be called when displaying a data on movieClip (no Update on the data). Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   16. updateCB:Function     - callback function to Update the data on the movieClip. Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   17. clearCB:Function      - callback function to Clear the movieClip. Default is null.
	*                               Arguments: {mc:MovieClip}
	*   18. hlCB:Function         - callback function to highlight the movieClip. Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   19. unhlCB:Function       - callback function to remove highlight from the movieClip. Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   20. overTopCB:Function    - callback function that will be called when highlight go above the top most data row. Default is null.
	*                               Return: true to remain in the grid, else will disable key listener.
	*   21. overBottomCB:Function - callback function that will be called when highlight go below the bottom most data row. Default is null.
	*                               Return: true to remain in the grid, else will disable key listener.
	*   22. overLeftCB:Function   - callback function that will be called when highlight go to the left over left most data column. Default is null.
	*                               Return: true to remain in the grid, else will disable key listener.
	*   23. overRightCB:Function  - callback function that will be called when highlight go to the right over right most data column. Default is null.
	*                               Return: true to remain in the grid, else will disable key listener.
	*   24. onEnterCB:Function    - callback function that will be called when enter key is pressed. Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   25. keyDownCB:Function    - callback function that will be called when key other than up/down/left/right/enter is called. Default is null.
	*                               Arguments: o:Object {keyCode:Number, asciiCode:Number}
	*   26. hlStopCB:Function     - callback function that will be called when highlight stop for hlStopTime milliseconds. Default is null.
	*                               Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   27. singleSelectCB:Function - callback function that will be called when item is selected/unselected. Default is null.
	*                                 Arguments: {mc:MovieClip, data:Object, dataIndex:Number, selected:Boolean}
	*                                 Return: true to reset current selected item.
	*   28. hlStopTime:Number     - how many milliseconds the highlight navigation stop before calling to the hlStopCB callback function. Default is 0(disable).
	*   29. *data:Array	          - data to be displayed on the Grid. Default is null. If data is specified, loadDataCB will be set to null.
	*       a. support disable feature when gDis:Object property is set (not equal to null) in the data object.
	*          - available properties in this gDis:Object are:
	*            i.   init:String       - when this disabled data item is highlighted directly, where to auto navigate to?
	*            ii.  fromLeft:String   - when navigate from left to this disabled data item, where to auto navigate to?
	*            iii. fromRight:String  - when navigate from right to this disabled data item, where to auto navigate to?
	*            iv.  fromUp:String     - when navigate from up to this disabled data item, where to auto navigate to?
	*            v.   fromDown:String   - when navigate from down to this disabled data item, where to auto navigate to?
	*          - string that can set on the properties above are: "toLeft", "toRight", "toUp" or "toDown".
	*          - highlight will navigate in straight line if no direction is specified.
	*       b. support colspan or rowspan if properties rs:Number or cs:Number is set (not equal to null) in the data object.
	*          - NOTE: must set empty object (i.e. data:{}) for others columns/rows that related to the first colspan/rowspan data item.
	*   30. len:Number           - value is generated from data.length and should not be manually specify. Default is 0.
	*   31. loadDataCB:Function  - callback function to load new data. If this is specified, then scroll=Grid.SCROLL_PAGE. Arguments:
	*       a. startIndex:Number - index of the first data.
	*       b. loadSize:Number   - number of data to be loaded.
	*       onLoadDataCB() function should be called after data is loaded successfully.
	*   32. pagePerLoad:Number   - total number of page per load. Default is -1 (meaning loading all data at first load).
	*   33. maxLoads:Number      - maximum number of load to keep/cache.
	*
	*   (* property that will not be stored in the global config object.)
	*/
	public function set(o:Object)
	{
		// set mcArray, cSize, rSize.
		var temp:Object = o.mcArray;
		if (temp !== undefined) // mcArray:Array.
		{
			if (temp == null || temp.length < 1)
			{
				o.rSize = undefined;
				o.cSize = undefined;
			}
			else
			{
				o.rSize = temp.length;
				temp = temp[0].length;
				o.cSize = (temp != undefined && temp != null ? temp : 1);
			}
		}
		else
		{
			temp = o.parentMC;
			if (temp != undefined && temp != null) // parentMC:MovieClip, cSize:Number, rSize:Number, mcPrefix:String.
			{
				temp = o.mcPrefix;
				if (temp == undefined || temp == null)
					o.mcPrefix = "item";

				temp = o.rSize;
				if (temp == undefined && temp == null)
					o.rSize = 1;

				temp = o.cSize;
				if (temp == undefined || temp == null)
					o.cSize = 1;

				temp = o.mcName; // auto create movieClips on the parentMC.
				if (temp == undefined)
					o.mcName = null;
				else if (temp != null)
				{
					temp = o.x;
					if (temp == undefined || temp == null) o.x = 0;

					temp = o.y;
					if (temp == undefined || temp == null) o.y = 0;

					temp = o.hgap;
					if (temp == undefined || temp == null) o.hgap = 0;

					temp = o.vgap;
					if (temp == undefined || temp == null) o.vgap = 0;
				}

				var mc:MovieClip = null;
				var x:Number = o.x;
				var y:Number = o.y;

				o.mcArray = new Array();

				for (var i:Number=0; i<o.rSize; i++)
				{
					o.mcArray.push(new Array());
					for (var j:Number=0; j<o.cSize; j++)
					{
						if (o.mcName != null)
						{
							mc = o.parentMC.attachMovie(o.mcName, o.mcPrefix + "_" + i + "_" + j,
								o.parentMC.getNextHighestDepth(), {_x:x, _y:y});
							x = x + mc._width + o.hgap;
						}
						else
							mc = o.parentMC[o.mcPrefix + "_" + i + "_" + j];
						o.mcArray[i].push(mc);
					}
					x = o.x;
					y = y + mc._height + o.vgap;
				}
			}

			if (o.mcArray === undefined) // if mcArray still undefined.
			{
				o.cSize = undefined;
				o.rSize = undefined;
			}
		}

		// global config object.
		var gO:Object = this.o;

		// delete mcArray to store new values.
		if (o.mcArray !== undefined)
			delete gO.mcArray;

		// copying all the new values to the global config object.
		for (var prop:String in o)
		{
			temp = o[prop];
			if (temp === undefined || Grid.DEFAULTS[prop] === undefined)
				continue;
			gO[prop] = (temp == null ? Grid.DEFAULTS[prop] : temp);
		}

		if (this.o2 == null)
			this.o2 = new Object();
		var o2:Object = this.o2;

		// handling vertical and horizontal config values.
		if (gO.horiz)
		{
			o2.cSize = gO.rSize;
			o2.rSize = gO.cSize;
			o2.overTopCB = gO.overLeftCB;
			o2.overBottomCB = gO.overRightCB;
			o2.overLeftCB = gO.overTopCB;
			o2.overRightCB = gO.overBottomCB;
			this.up = this.verticalLeft;
			this.down = this.verticalRight;
			this.left = this.verticalUp;
			this.right = this.verticalDown;
		}
		else
		{
			o2.cSize = gO.cSize;
			o2.rSize = gO.rSize;
			o2.overTopCB = gO.overTopCB;
			o2.overBottomCB = gO.overBottomCB;
			o2.overLeftCB = gO.overLeftCB;
			o2.overRightCB = gO.overRightCB;
			this.up = this.verticalUp;
			this.down = this.verticalDown;
			this.left = this.verticalLeft;
			this.right = this.verticalRight;
		}

		this.autoMove = new Object();
		this.autoMove.toUp  = Delegate.create(this, this.up);
		this.autoMove.toDown  = Delegate.create(this, this.down);
		this.autoMove.toLeft  = Delegate.create(this, this.left);
		this.autoMove.toRight  = Delegate.create(this, this.right);

		if (o.mcArray !== undefined)
		{
			this.o2.mcArray.splice(0);
			delete this.o2.mcArray;
			o2.mcArray = new Array();

			if (gO.horiz)
			{
				 // reorder, so horizontal MC will be handle like vertical MC.
				for (var j:Number=0; j<o2.rSize; j++)
				{
					o2.mcArray.push(new Array());
					for (var i:Number=0; i<o2.cSize; i++)
						o2.mcArray[j].push(gO.mcArray[i][j]);
				}
			}
			else
			{
				for (var i:Number=0; i<o2.rSize; i++)
				{
					o2.mcArray.push(new Array());
					for (var j:Number=0; j<o2.cSize; j++)
						o2.mcArray[i].push(gO.mcArray[i][j]);
				}
			}
		}

		this.size = o2.rSize * o2.cSize; // calculate size.
		this.setLength(gO.len); // refresh other values just incase this.size had changed

		// if below properties new value is different from the old value.
		if (o.cSize != gO.cSize || o.rSize != gO.rSize || o.len != gO.len || o.data !== undefined
			|| o.scroll != gO.scroll)
		{
			gO.top = -1;
			gO.hl = -1;
			gO.c = -1;
			gO.r = -1;
		}

		// set a fixed data.
		temp = o.data;
		if (temp !== undefined) // if o.data is defined
		{
			if (temp != null && temp.length > 0)
			{
				gO.loadDataCB = null;
				gO.pagePerLoad = -1;
				gO.maxLoads = 1;
				this.loadSize = -1;
				this.clearLoadDataObj();
				this.loadDataObj = {startIndex:0, loadSize:-1, loadIndex:0, onLoadData:null, showHighlight:false};
				this.onLoadDataCB(o.data, temp.length);
			}
			else
				this.clear();
		}

		if (gO.loadDataCB != null && gO.pagePerLoad > 0) // dynamic data loading with multiple loads.
		{
			this.loadSize = this.size * gO.pagePerLoad; // total data to load in single load.
			gO.scroll = Grid.SCROLL_PAGE; // force scroll by page.
		}
	}

	/*
	* Populate the Grid now.
	*
	* showHighlight: true to show the highlight and enable keyListener. Default is true.
	* hl: data index to be highlighted.
	*/
	public function populateUI(showHighlight:Boolean, hl:Number):Void
	{
		showHighlight = (showHighlight != false);

		this.clearShowObj();
		this.showObj = {showHighlight:showHighlight, hl:hl};

		if (this.empty)
		{
			if (this.o.loadDataCB != null) // make the first data loading.
				this.loadData(0, this.loadSize, 0, this.fn.onShow, showHighlight);
			return;
		}

		this.onShow();
	}

	private function onShow():Void
	{
		var showObj:Object = this.showObj;
		if (showObj == null)
			return;

		this.setHL(showObj.hl, showObj.showHighlight);
		this.clearShowObj();
	}

	private function clearShowObj():Void
	{
		var showObj:Object = this.showObj;
		if (showObj == null)
			return;
		showObj.showHighlight = null;
		showObj.hl = null;
		delete this.showObj;
		this.showObj = null;
	}

	public function enableKeyListener():Void
	{
		if (this.keyListener.onKeyDown != null)
			return;
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.klInterval = _global["setInterval"](this.fn.onEnableKeyListener, 100); // delay abit to prevent getting the previously press key.
	}

	private function onEnableKeyListener():Void
	{
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.keyListener.onKeyDown = this.keyDown;
	}

	public function disableKeyListener():Void
	{
		clearInterval(this.klInterval);
		this.klInterval = null;
		this.keyListener.onKeyDown = null;
	}

	/*
	* Highlight with the hl(data index) specified and enable the keyListener.
	*/
	public function highlight(hl:Number):Void
	{
		this.setHL(hl, true);
		if (this.loadDataObj != null)
			this.loadDataObj.showHighlight = true;
	}

	/*
	* Disable the keyListener and remove the highlight.
	*/
	public function unhighlight():Void
	{
		this.prevAction = 0;
		this.disableKeyListener();
		this.removeHighlight();
		if (this.loadDataObj != null)
			this.loadDataObj.showHighlight = false;
	}

	/*
	* Get movieClip.
	*
	* If both column and row is undefined or null then will get current highlighted movieClip.
	* If column is undefined or null then column=0.
	* If row is undefined or null then row=0.
	* If column or row is less than 0 then will return null.
	*/
	public function getMC(column:Number, row:Number):MovieClip
	{
		if (column == undefined || column == null)
		{
			if (row == undefined || row == null)
			{
				if (this.top < 0)
					return null;

				column = this.c;
				row = this.r;
			}
			else
				column = 0;
		}
		else if (row == undefined || row == null)
			row = 0;

		if (column < 0 || row < 0)
			return null;
		return this.o2.mcArray[row][column];
	}

	/*
	* Get data. If dataIndex equals undefined or null then will return current highlighted data.
	*/
	public function getData(dataIndex:Number):Object
	{
		if (dataIndex == undefined || dataIndex == null)
			dataIndex = this.hl;
		if (dataIndex < 0)
			return null;
		if (this.loads == null)
			return null;

		var index:Number = (this.loadSize > 0 ? Math.floor((dataIndex / this.loadSize)) : 0); // find which loads contains the data.
		if (index >= this.loads.length)
			return null;

		var data:Array = this.loads[index];
		if (data == undefined || data == null)
			return null;

		index = (this.loadSize > 0 ? (dataIndex % this.loadSize) : dataIndex);
		if (index < data.length)
			data = data[index];
		else
			return null;
		if (data == undefined)
			return null;
		return data;
	}

	/*
	* Get column value. If dataIndex equals undefined or null then will return current highlighted column value.
	*/
	public function getC(dataIndex:Number):Number
	{
		if (dataIndex == undefined || dataIndex == null)
			return (this.o.horiz ? this.r : this.c);
		if(dataIndex < this.top || dataIndex >= this.top+this.size)
			return null;

		var cSize:Number = this.o2.cSize;
		var mcHL:Number = (dataIndex - this.top);
		var c:Number = mcHL % cSize;
		var r:Number = Math.floor((mcHL / cSize));
		return (this.o.horiz ? r : c);
	}

	/*
	* Get row value. If dataIndex equals undefined or null then will return current highlighted row value.
	*/
	public function getR(dataIndex:Number):Number
	{
		if (dataIndex == undefined || dataIndex == null)
			return (this.o.horiz ? this.c : this.r);
		if(dataIndex < this.top || dataIndex >= this.top+this.size)
			return null;

		var cSize:Number = this.o2.cSize;
		var mcHL:Number = (dataIndex - this.top);
		var c:Number = mcHL % cSize;
		var r:Number = Math.floor((mcHL / cSize));
		return (this.o.horiz ? c : r);
	}

	/*
	* Get current page number. Start from 1.
	*/
	public function getPage():Number
	{
		if (this.top < 0)
			return -1;
		return Math.floor((this.hl / size)) + 1;
	}

	/*
	* If the current data loading failed or no data is loaded
	* then program can call to retry() function to retry data loading again.
	*/
	public function isRetrying():Boolean
	{
		return (this.loadDataObj != null);
	}

	/*
	* Retry to load the data again if the previous data loading failed or no data is loaded.
	*/
	public function retry():Void
	{
		if (!this.isRetrying())
			return;

		var loadDataObj:Object = this.loadDataObj;
		this.loadData(loadDataObj.startIndex, loadDataObj.loadSize, loadDataObj.loadIndex,
			loadDataObj.onLoadData, loadDataObj.showHighlight);
	}

	/*
	* Refresh all the MC. This will disable the keyListener and enable back after upadted all MC.
	*/
	public function refresh():Void
	{
		if (this.isRetrying())
			return;

		this.disableKeyListener();
		this.updateAllMC();
		this.enableKeyListener();
	}

	/*
	* Clear all the data and MC.
	*/
	public function clear():Void
	{
		if (this.empty)
			return;

		this.removeHighlight();

		this.o.len = 0;
		this.empty = true;
		this.hl = -1;
		this.top = -1;
		this.c = -1;
		this.r = -1;
		this.lastTop = -1;
		this.lastR = -1;
		this.lastC = -1;
		this.selIndex = -1;
		delete this.loads;
		this.loads = null;
		this.clearLoadDataObj();

		var clearCB:Function = this.o.clearCB;
		if (clearCB == null)
			return;

		var o2:Object = this.o2;
		var cSize:Number = o2.cSize;
		var rSize:Number = o2.rSize;
		var mcArray:Array = o2.mcArray;

		for (var i:Number=0; i<rSize; i++)
			for (var j:Number=0; j<cSize; j++)
				clearCB({mc:mcArray[i][j]});
	}

	/*
	* Clear movieclip in grid. If dataIndex equals undefined or null then will clear all movieclip in grid.
	*/
	public function clearMC(dataIndex:Number):Void
	{
		if (dataIndex == undefined || dataIndex == null)
		{
			var clearCB:Function = this.o.clearCB;
			if (clearCB == null)
				return;
			var cSize:Number = o2.cSize;
			var rSize:Number = o2.rSize;
			var mcArray:Array = o2.mcArray;
			for (var i:Number=0; i<rSize; i++)
				for (var j:Number=0; j<cSize; j++)
					clearCB({mc:mcArray[i][j]});
		}
		else
		{
			if(dataIndex < this.top || dataIndex >= this.top+this.size)
				return;
			clearCB({mc:mcArray[this.getR(dataIndex)][this.getC(dataIndex)]});
		}
	}

	private function onKeyDown():Void
	{
		var keyCode:Number = Key.getCode();

		switch (keyCode)
		{
			case Key.LEFT:
				this.left();
				break;
			case Key.RIGHT:
				this.right();
				break;
			case Key.UP:
				this.up();
				break;
			case Key.DOWN:
				this.down();
				break;
			case Key.ENTER:
				this.onEnter();
				break;
			default:
				if (this.o.keyDownCB != null)
					this.o.keyDownCB({keyCode:keyCode, asciiCode:Key.getAscii()});
				break;
		}
	}

	private function onEnter():Void
	{
		if(this.o.singleSelectCB != null)
			this.singleSelect();
		else
		{
			if (this.o.onEnterCB != null)
				this.o.onEnterCB({mc:this.o2.mcArray[this.r][this.c], data:this.getData(), dataIndex:this.hl});
		}
	}

	/*
	* Get single selected value.
	*/
	public function getSingleSelect():Object
	{
		if (this.selIndex < 0)
			return null;
		return {data:this.getData(this.selIndex)};// return selected data
	}

	/*
	* Select/unselect single item. If dataIndex equals undefined or null then will select/unselect current highlighted item.
	*/
	public function singleSelect(dataIndex:Number)
	{
		if (dataIndex == undefined || dataIndex == null)
			dataIndex = this.hl;
		if (dataIndex < 0)
			return;
		if (this.loads == null)
			return;

		var i:Number = (this.loadSize > 0 ? Math.floor((dataIndex / this.loadSize)) : 0); // find which loads contains the data.
		if (i >= this.loads.length)
			return;

		var index:Number = this.selIndex;
		var r:Number = 0;
		var c:Number = 0;
		var reset:Boolean = false;
		if (index >= 0)
		{
			if (index >= this.top && index < this.top + this.size) // check prev selected item is in current grid
			{
				r = (this.o.horiz ? this.getC(index) : this.getR(index))
				c = (this.o.horiz ? this.getR(index) : this.getC(index))
				reset = this.o.singleSelectCB( { mc:this.o2.mcArray[r][c], data:this.getData(index), dataIndex:index, selected:false } ); // return unselected data
			}
		}
		if (dataIndex == index && reset)
			this.selIndex = -1;
		else
		{
			this.selIndex = dataIndex;
			r = (this.o.horiz ? this.getC(dataIndex) : this.getR(dataIndex))
			c = (this.o.horiz ? this.getR(dataIndex) : this.getC(dataIndex))
			this.o.singleSelectCB({mc:this.o2.mcArray[r][c], data:this.getData(dataIndex), dataIndex:dataIndex, selected:true}); // return selected data
		}
	}

	private function verticalUp():Void // or left for horizontal.
	{
		if (this.top < 0 || this.isRetrying())
		{
			if (this.o2.overTopCB != null)
				this.o2.overTopCB();
			return;
		}

		this.removeHighlight();
		if (this.prevAction == 0)
		{
			if (this.o.horiz)
				this.prevAction = 3;
			else
				this.prevAction = 1;
		}

		if (this.r == 0) // first row.
		{
			if (this.top == 0) // first page.
			{
				if (this.o2.overTopCB != null)
				{
					this.prevAction = 0;
					var b:Boolean = this.o2.overTopCB();
					if (!b || b == null || b == undefined)
					{
						this.disableKeyListener();
						return;
					}
				}

				if (this.o.wrap)
				{
					// go to last page.
					this.c = Math.min(this.c, this.lastC);
					this.r = this.lastR;
					this.hl = this.lastTop + (this.r * this.o2.cSize) + this.c;
					this.setTop(this.lastTop, true);
					return;
				}
				else
					this.prevAction = 0;
			}
			else // page 2 or line 2 onwards.
			{
				if (this.o.scroll == Grid.SCROLL_PAGE)
				{
					// go to previous page.
					this.r = this.o2.rSize - 1;
					this.hl = this.hl - this.o2.cSize; // highlight up one row.
					this.setTop((this.top - this.size), true);
					return;
				}
				else
				{
					// up one row.
					this.hl = this.hl - this.o2.cSize;
					this.setTop((this.top - this.o2.cSize), true);
					return;
				}
			}
		}
		else // not first row.
		{
			// highlight up one row.
			this.r--;
			this.hl = this.hl - this.o2.cSize;
		}

		this.showHighlight();
	}

	private function verticalDown():Void // or right for horizontal.
	{
		if (this.top < 0 || this.isRetrying())
		{
			if (this.o2.overBottomCB != null)
				this.o2.overBottomCB();
			return;
		}

		if (this.prevAction == 0)
		{
			if (this.o.horiz)
				this.prevAction = 4;
			else
				this.prevAction = 2;
		}
		this.removeHighlight();

		if (this.top == this.lastTop && this.r == this.lastR) // last data row.
		{
			if (this.o2.overBottomCB != null)
			{
				this.prevAction = 0;
				var b:Boolean = this.o2.overBottomCB();
				if (!b || b == null || b == undefined)
				{
					this.disableKeyListener();
					return;
				}
			}

			if (this.o.wrap)
			{
				// go to first page.
				this.r = 0;
				this.hl = this.c;
				this.setTop(0, true);
				return;
			}
			else
				this.prevAction = 0;
		}
		else if (this.r == this.o2.rSize - 1) // last ui row.
		{
			if (this.o.scroll == Grid.SCROLL_PAGE)
			{
				// go to next page.
				this.r = 0;
				this.hl = this.hl + this.o2.cSize; // highlight down one row.
				if(this.hl >  this.o.len - 1)
				{
					this.hl = this.o.len - 1; // highlight last data.
					this.c = this.lastC;
				}
				this.setTop((this.top + this.size), true);
				return;
			}
			else
			{
				// down one row.
				this.hl = this.hl + this.o2.cSize;
				if(this.hl >  this.o.len - 1)
				{
					this.hl = this.o.len - 1; // highlight last data.
					this.c = this.lastC;
				}
				this.setTop((this.top + this.o2.cSize), true);
				return;
			}
		}
		else // not last row.
		{
			// highlight down one row.
			this.r++;
			this.hl = this.hl + this.o2.cSize;
		}

		if (this.top == this.lastTop && this.r == this.lastR && this.c > this.lastC) // check column is not over last data column.
		{
			this.hl = this.o.len - 1; // highlight last data.
			this.c = this.lastC;
		}

		this.showHighlight();
	}

	private function verticalLeft():Void // or up for horizontal.
	{
		if (this.top < 0 || this.isRetrying())
		{
			if (this.o2.overLeftCB != null)
				this.o2.overLeftCB();
			return;
		}

		if (this.prevAction == 0)
		{
			if (this.o.horiz)
				this.prevAction = 1;
			else
				this.prevAction = 3;
		}
		this.removeHighlight();

		if (this.c == 0) // first column.
		{
			if (this.o2.overLeftCB != null)
			{
				this.prevAction = 0;
				var b:Boolean = this.o2.overLeftCB();
				if (!b || b == null || b == undefined)
				{
					this.disableKeyListener();
					return;
				}
			}

			if (this.o.wrapLine) // highlight previous row last column.
			{
				this.c = this.o2.cSize - 1;
				this.hl = this.hl + this.c; // move highlight to last column before moving up.
				this.verticalUp();
				return;
			}
			else if (this.o2.cSize > 1 && this.o.wrap)
			{
				if (this.top == this.lastTop && this.r == this.lastR) // if it is last data row.
				{
					this.c = this.lastC;
					this.hl = this.o.len - 1; // highlight last data.
				}
				else
				{
					this.c = this.o2.cSize - 1;
					this.hl = this.hl + this.c; // move highlight to last column.
				}
			}
			else
				this.prevAction = 0;
		}
		else // not first column.
		{
			this.c--;
			this.hl--;
		}

		this.showHighlight();
	}

	private function verticalRight():Void // or down for horizontal.
	{
		if (this.top < 0 || this.isRetrying())
		{
			if (this.o2.overRightCB != null)
				this.o2.overRightCB();
			return;
		}

		if (this.prevAction == 0)
		{
			if (this.o.horiz)
				this.prevAction = 2;
			else
				this.prevAction = 4;
		}
		this.removeHighlight();

		if ((this.c == this.o2.cSize - 1) // last column.
			|| (this.top == this.lastTop && this.r == this.lastR && this.c == this.lastC))
		{
			if (this.o2.overRightCB != null)
			{
				this.prevAction = 0;
				var b:Boolean = this.o2.overRightCB();
				if (!b || b == null || b == undefined)
				{
					this.disableKeyListener();
					return;
				}
			}

			if (this.o.wrapLine) // highlight next row first column.
			{
				this.hl = this.hl - this.c; // move highlight to first column before moving down.
				this.c = 0;
				this.verticalDown();
				return;
			}
			else if (this.o2.cSize > 1 && this.o.wrap)
			{
				this.hl = this.hl - this.c; // move highlight to first column.
				this.c = 0;
			}
			else
				this.prevAction = 0;
		}
		else // not last column.
		{
			this.c++;
			this.hl++;
		}

		this.showHighlight();
	}

	/*
	* For Colspan/Rowspan/Disabled/AutoMove
	*/
	private function moveCtrl(obj:Object,skip:Boolean):Boolean
	{
		var stop:Boolean = true;
		switch(this.prevAction)
		{
			case 0:
				if (obj.init != undefined && obj.init != null)
					this.autoMove[obj.init]();
				else
				{
					if(skip)
						this.right();
					else
						stop = false;
				}
			break;
			case 1:
				if (obj.fromDown != undefined && obj.fromDown != null)
					this.autoMove[obj.fromDown]();
				else
				{
					if(skip)
						this.up();
					else
						stop = false;
				}
			break;
			case 2:
				if (obj.fromUp != undefined && obj.fromUp != null)
					this.autoMove[obj.fromUp]();
				else
				{
					if(skip)
						this.down();
					else
						stop = false;
				}
			break;
			case 3:
				if (obj.fromRight != undefined && obj.fromRight != null)
					this.autoMove[obj.fromRight]();
				else
				{
					if(skip)
						this.left();
					else
						stop = false;
				}
			break;
			case 4:
				if (obj.fromLeft != undefined && obj.fromLeft != null)
					this.autoMove[obj.fromLeft]();
				else
				{
					if(skip)
						this.right();
					else
						stop = false;
				}
			break;
		}
		this.prevAction = 0;
		return stop;
	}

	private function showHighlight(showHighlight:Boolean):Void
	{
		if (showHighlight == false)
			return;

		if (this.o.hlCB != null && this.top >= 0 && !this.isRetrying()) // should not highlight when retrying
		{
			var obj:Object = this.getData(this.hl);
			var stop:Boolean = true;
			if (obj.gDis != undefined && obj.gDis != null)
			{
				stop = this.moveCtrl(obj.gDis, true);
				if(stop == true)
					return;
			}

			if (obj.gAutoMove != undefined && obj.gAutoMove != null)
			{
				stop = this.moveCtrl(obj.gAutoMove, false);
				if (stop == true)
					return;
			}

			this.prevAction = 0;
			this.o.hlCB({mc:this.o2.mcArray[this.r][this.c], data:this.getData(), dataIndex:this.hl});

			if (this.o.hlStopCB != null && this.o.hlStopTime > 0)
			{
				clearInterval(this.hlStopIntervalId);
				this.hlStopIntervalId = setInterval(this.fn.onHLStop, this.o.hlStopTime);
			}
		}

		this.enableKeyListener();
	}

	private function onHLStop():Void
	{
		clearInterval(this.hlStopIntervalId);
		this.o.hlStopCB({mc:this.o2.mcArray[this.r][this.c], data:this.getData(), dataIndex:this.hl});
	}

	private function removeHighlight():Void
	{
		if (this.o.unhlCB == null || this.top < 0 || this.isRetrying())
			return;
		clearInterval(this.hlStopIntervalId);
		this.o.unhlCB({mc:this.o2.mcArray[this.r][this.c], data:this.getData(), dataIndex:this.hl});
	}

	private function setHL(hl:Number, showHighlight:Boolean):Void
	{
		if (this.isRetrying())
		{
			if (showHighlight)
				this.enableKeyListener();
			return;
		}

		if (this.empty)
			return;

		var prevHL:Number = this.hl;
		if (hl == undefined || hl == null) // if hl is empty.
		{
			if (prevHL < 0) // if hl not set before.
				hl = 0;
			else // remain the previously set hl because new hl is empty.
			{
				this.showHighlight(showHighlight);
				return;
			}
		}
		else if (prevHL >= 0 && hl == prevHL) // new hl is same as previously set hl.
		{
			this.showHighlight(showHighlight);
			return;
		}

		var len:Number = this.o.len;
		if (hl < 0)
			hl = 0;
		else if (hl >= len)
			hl = len - 1;
		this.hl = hl;

		var cSize:Number = this.o2.cSize;
		var size:Number = this.size;
		var top:Number = 0;

		if (this.hl > this.top && this.hl < this.top + size && this.top >= 0)
			top = this.top;
		else
		{
			if (hl >= size) // 2nd page onwards.
			{
				if (this.o.scroll == Grid.SCROLL_PAGE)
					top = (Math.floor((hl / size)) * size);
				else
					top = ((Math.floor((hl / cSize)) - this.o2.rSize + 1) * cSize);
			}
		}

		var mcHL:Number = (hl - top);
		this.c = mcHL % cSize;
		this.r = Math.floor((mcHL / cSize));

		this.setTop(top, showHighlight);
	}

	private function setTop(top:Number, showHighlight:Boolean):Void
	{
		var prevTop:Number = this.top;
		if (top != prevTop)
		{
			this.top = top;
			if (top < 0)
				return;

			var onLoadData:Function = this.fn.updateAllMC;
			if (prevTop > -1) // not the first entry.
			{
				if (top == (prevTop - this.o2.cSize)) // go to previous line.
					onLoadData = this.fn.verticalMCArrayDown;
				else if (top == (prevTop + this.o2.cSize)) // go to next line.
					onLoadData = this.fn.verticalMCArrayUp;
			}

			if (this.o.loadDataCB != null) // for dynamic data loading.
			{
				var loadSize:Number = this.loadSize;
				var loadIndex:Number = (loadSize > 0 ? Math.floor((this.hl / loadSize)) : 0);
				var data:Array = null;

				if (this.loads != null && loadIndex < this.loads.length)
					data = this.loads[loadIndex];

				if (data == undefined || data == null) // if data not found in the loads array.
				{
					var startIndex:Number = 0;
					if (loadSize > 0)
					{
						startIndex = loadIndex * loadSize;
						var endIndex:Number = startIndex + loadSize - 1;
						if (endIndex >= this.o.len)
							loadSize = this.o.len - startIndex + 1;
					}

					// start dynamic data loading.
					this.loadData(startIndex, loadSize, loadIndex, onLoadData, showHighlight);
					return;
				}
			}

			onLoadData();
		}

		this.showHighlight(showHighlight);
	}

	private function loadData(startIndex:Number, loadSize:Number, loadIndex:Number,
		onLoadData:Function, showHighlight:Boolean):Void
	{
		if (this.o.loadDataCB == null)
			return;

		this.clearLoadDataObj();
		this.loadDataObj = {startIndex:startIndex, loadSize:loadSize, loadIndex:loadIndex,
			onLoadData:onLoadData, showHighlight:showHighlight};
		this.o.loadDataCB(startIndex, loadSize); // calling to load data callback function.
	}

	/*
	* Callback function that should be called after data loaded successfully.
	*
	* data - the new data.
	*        a. support disable feature when gDis:Object property is set (not equal to null) in the data object.
	*           - available properties in this gDis:Object are:
	*             i.   init:String       - when this disabled data item is highlighted directly, where to auto navigate to?
	*             ii.  fromLeft:String   - when navigate from left to this disabled data item, where to auto navigate to?
	*             iii. fromRight:String  - when navigate from right to this disabled data item, where to auto navigate to?
	*             iv.  fromUp:String     - when navigate from up to this disabled data item, where to auto navigate to?
	*             v.   fromDown:String   - when navigate from down to this disabled data item, where to auto navigate to?
	*           - string that can set on the properties above are: "toLeft", "toRight", "toUp" or "toDown".
	*           - highlight will navigate in straight line if no direction is specified.
	*        b. support colspan or rowspan if properties rs:Number or cs:Number is set (not equal to null) in the data object.
	*           - NOTE: must set empty object (i.e. data:{}) for others columns/rows that related to the first colspan/rowspan data item.
	* len - the new total number of data.
	*/
	public function onLoadDataCB(data:Array, len:Number):Void
	{
		if (data != undefined && data != null && data.length > 0) // if success and data is not empty.
		{
			var loadDataObj:Object = this.loadDataObj;
			this.loadDataObj = null;

			var loads:Array = this.loads;
			if (loads == null)
			{
				this.loads = new Array();
				loads = this.loads;
			}
			loads[loadDataObj.loadIndex] = data; // set data to the loads array.
			var loadsLen:Number = loads.length;
			var lastLoadIndex:Number = (loadSize > 0 ? Math.floor(((len-1) / loadSize)) : (len-1));
			var maxLoads:Number = this.o.maxLoads;

			if (loadsLen > maxLoads)
			{
				// trying to remove the front loaded data to maintain the maxLoads.
				var removeFrontIndex:Number = loadDataObj.loadIndex - maxLoads;
				var removeBackIndex:Number = loadDataObj.loadIndex + maxLoads;
				var removeIndex:Number = removeFrontIndex;

				if (this.o.wrap && removeIndex < 0) // less than first loaded data, try remove the last loaded data.
				{
					removeIndex = lastLoadIndex + removeIndex;
					removeIndex += 1;
					// cannot removed those loaded data that needed to be retained.
					if (removeIndex > removeFrontIndex && removeIndex < removeBackIndex)
						removeIndex = -1;
				}
				if (removeIndex >= 0 && removeIndex < loadsLen)
				{
					var load = loads[removeIndex];
					if (load != undefined && load != null)
					{
						delete this.loads[removeIndex];
						this.loads[removeIndex] = null;
					}
				}

				// trying to remove the back loaded data to maintain the maxLoads.
				removeIndex = removeBackIndex;
				if (this.o.wrap && removeIndex > lastLoadIndex) // over last loaded data, try remove first loaded data.
				{
					removeIndex = removeIndex - lastLoadIndex;
					removeIndex -= 1;
					// cannot removed those loaded data that needed to be retained.
					if (removeIndex > removeFrontIndex && removeIndex < removeBackIndex)
						removeIndex = loadsLen;
				}
				if (removeIndex >= 0 && removeIndex < loadsLen)
				{
					var load = loads[removeIndex];
					if (load != undefined && load != null)
					{
						delete this.loads[removeIndex];
						this.loads[removeIndex] = null;
					}
				}
			}

			if (len != undefined && len != null)
				this.setLength(len);

			if (loadDataObj.onLoadData != null)
				loadDataObj.onLoadData();

			this.processData();
			this.showHighlight(loadDataObj.showHighlight);

			this.clearLoadDataObj();
		}
	}

	/*
	* Process data that contain Colspan/Rowspan.
	*/
	private function processData():Void
	{
		var cSize:Number = this.o2.cSize;
		var rSize:Number = this.o2.rSize;
		var id:Number = 0;
		var d:Object = null;
		var cs:Number = 0;
		var rs:Number = 0;
		var index1:Number = 0;
		var index2:Number = 0;
		var data:Array = null;

		var mc:MovieClip = null;

		for (var r:Number = 0; r < rSize; r++)
		{
			for (var c:Number = 0; c < cSize; c++)
			{
				id = (r * cSize) + c;
				index1 = (this.loadSize > 0 ? Math.floor((id / this.loadSize)) : 0);
				if (index1 >= this.loads.length)
					continue;
				data = this.loads[index1];
				index2 = (this.loadSize > 0 ? (id % this.loadSize) : id);
				d = data[index2];
				cs = ((d.cs == null || d.cs == undefined) ? 1 : d.cs);
				rs = ((d.rs == null || d.rs == undefined) ? 1 : d.rs);

				if (cs == 1 && rs == 1)
					continue;

				mc = this.o2.mcArray[r][c];
				for (var i:Number = 0; i < rs; i++)
				{
					for (var j:Number = 0; j < cs; j++)
					{
						if(this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove == undefined || this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove == null)
							this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove = { };

						if (i == 0)
						{
							if (rs > 1)
								this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove.fromDown = "toUp";
						}
						else
						{
							if (i < (rs - 1))
								this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove.fromDown = "toUp";
							this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove.fromUp = "toDown";
						}

						if (j== 0)
						{
							if(cs > 1)
								this.loads[index1][index2 + (j * cSize)].gAutoMove.fromRight = "toLeft";
						}
						else
						{
							if (j < (cs + i - 1))
								this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove.fromRight = "toLeft";
							this.loads[index1][(index2 + j) + (i * cSize)].gAutoMove.fromLeft = "toRight";
						}
						this.o2.mcArray[r + i][c + j] = mc;
						for (var z:String in d)
						{
							if (!(z == "gAutoMove" || z == "cs" || z == "rs"))
								this.loads[index1][(index2 + j) + (i * cSize)][z] = d[z];
						}
					}
				}
			}
		}
	}

	public function clearLoadDataObj():Void
	{
		var loadDataObj:Object = this.loadDataObj;
		if (loadDataObj == null)
			return;
		loadDataObj.startIndex = null;
		loadDataObj.loadSize = null;
		loadDataObj.loadIndex = null;
		loadDataObj.onLoadData = null;
		loadDataObj.showHighlight = null;
		delete this.loadDataObj;
		this.loadDataObj = null;
	}

	private function setLength(len:Number):Void
	{
		if (len == undefined || len == null)
			len = 0;
		this.o.len = len;

		// check empty.
		this.empty = (len < 1 || this.size < 1);

		// calculate lastTop, lastR, lastC.
		this.lastTop = -1;
		this.lastR = -1;
		this.lastC = -1;
		if (!this.empty)
		{
			var cSize:Number = this.o2.cSize;
			var rSize:Number = this.o2.rSize;

			var lastDataRow:Number = Math.floor(((len - 1) / cSize));
			var lastC:Number = (len - 1) % cSize;
			var lastR:Number = lastDataRow;
			if (this.o.scroll == Grid.SCROLL_PAGE)
				lastR = lastR % rSize;
			else if (lastR > (rSize - 1))
				lastR = rSize - 1;

			this.lastTop = (lastDataRow - lastR) * cSize;
			this.lastC = lastC;
			this.lastR = lastR;
		}
	}

	/*
	* Update all the MC.
	*/
	private function updateAllMC():Void
	{
		var mcArray:Array = this.o2.mcArray;
		var cSize:Number = this.o2.cSize;
		var rSize:Number = this.o2.rSize;
		var top:Number = this.top;

		for (var i:Number=0; i<rSize; i++)
			for (var j:Number=0; j<cSize; j++)
				this.updateMC(mcArray[i][j], (i * cSize) + top + j);
	}

	/*
	* Move all the movieClips one line up.  And move the first movieClip to the last.
	*/
	private function verticalMCArrayUp():Void // or move left for horizontal.
	{
		if (this.empty)
			return;

		var cSize:Number = this.o2.cSize;
		var rSize:Number = this.o2.rSize;
		var mcArray:Array = this.o2.mcArray;
		var mcBelow:MovieClip = null;
		var mcAbove:MovieClip = null;
		var last:Object = null;
		var lastRow:Number = this.top + ((rSize-1)*cSize);
		var onDisplayCB:Function = this.o.onDisplayCB;

		for (var i:Number=0; i<cSize; i++) // do for every column.
		{
			mcBelow = mcArray[rSize-1][i];
			last = {x:mcBelow._x, y:mcBelow._y}; // keep the last mc properties so the 1st mc can move to last.

			for (var j:Number=rSize-2; j>=0; j--) // move from last mc up until 1st mc.
			{
				mcAbove = mcArray[j][i];
				mcBelow._x = mcAbove._x;
				mcBelow._y = mcAbove._y;
				if (onDisplayCB != null)
					onDisplayCB({mc:mcBelow, data:this.getData((this.top + (j * cSize) + i)), dataIndex:(this.top + (j * cSize) + i)});
				mcBelow = mcAbove; // mcAbove will be the next to move up.
			}

			// moving the 1st mc to last. (mcBelow already reached the 1st mc because of the loop j above)
			mcBelow._x = last.x;
			mcBelow._y = last.y;

			this.updateMC(mcBelow, lastRow + i); // update the last mc with new data.
		}

		// move 1st row to last row.
		var firstRow:Object = mcArray.shift();
		mcArray.push(firstRow);
	}

	/*
	* Move all the movieClips one line down.  And move the last movieClip to the first.
	*/
	private function verticalMCArrayDown():Void // or move right for horizontal.
	{
		if (this.empty)
			return;

		var cSize:Number = this.o2.cSize;
		var rSize:Number = this.o2.rSize;
		var mcArray:Array = this.o2.mcArray;
		var mcAbove:MovieClip = null;
		var mcBelow:MovieClip = null;
		var first:Object = null;
		var top:Number = this.top;
		var onDisplayCB:Function = this.o.onDisplayCB;

		for (var i:Number=0; i<cSize; i++) // do for every column.
		{
			mcAbove = mcArray[0][i];
			first = {x:mcAbove._x, y:mcAbove._y}; // keep the 1st mc properties so the last mc can move to 1st.

			for (var j:Number=1; j<rSize; j++) // move from 1st mc down until last mc.
			{
				mcBelow = mcArray[j][i];
				mcAbove._x = mcBelow._x;
				mcAbove._y = mcBelow._y;
				if (onDisplayCB != null)
					onDisplayCB({mc:mcAbove, data:this.getData((this.top + (j * cSize) + i)), dataIndex:(this.top + (j * cSize) + i)});
				mcAbove = mcBelow; // mcBelow will be the next to move down.
			}

			// moving the last mc to 1st. (mcAbove already reached the last mc because of the loop j above)
			mcAbove._x = first.x;
			mcAbove._y = first.y;

			this.updateMC(mcAbove, top + i); // update the 1st mc with new data.
		}

		// move last row to 1st row.
		var lastRow:Object = mcArray.pop();
		mcArray.unshift(lastRow);
	}

	private function updateMC(mc:MovieClip, dataIndex:Number):Void
	{
		if (dataIndex < 0)
			return;

		if (dataIndex >= this.o.len) // clear if index is over the data length.
		{
			if (this.o.clearCB != null)
				this.o.clearCB({mc:mc});
		}
		else if (this.o.updateCB != null)
			this.o.updateCB({mc:mc, data:this.getData(dataIndex), dataIndex:dataIndex});
	}

	public function toString():String
	{
		var o:Object = this.o;
		var o2:Object = this.o2;
		var showObj:Object = this.showObj;
		var loadDataObj:Object = this.loadDataObj;
		return "o=[cSize:" + o.cSize + ", rSize:" + o.rSize + ", len:" + o.len
		 	+ ", horiz:" + o.horiz + ", wrap:" + o.wrap + ", wrapLine:" + o.wrapLine + ", scroll:" + o.scroll
			+ ", CB:" + (o.onDisplayCB != null ? "onDisplay" : "")
			+ (o.updateCB != null ? ",update" : "") + (o.clearCB != null ? ",clear" : "")
			+ (o.hlCB != null ? ",hl" : "") + (o.unhlCB != null ? ",unhl" : "")
			+ (o.overTopCB != null ? ",oTop" : "") + (o.overBottomCB != null ? ",oBot" : "")
			+ (o.overLeftCB != null ? ",oLeft" : "") + (o.overRightCB != null ? ",oRight" : "")
			+ (o.onEnterCB != null ? ",enter" : "") + (o.keyDownCB != null ? ",keyDown" : "")
			+ (o.hlStopCB != null ? ",hlStop" : "") + ", hlStopTime:" + o.hlStopTime
			+ (o.loadDataCB != null ? ", loadDataCB=true" : "") + ", pagePerLoad:" + o.pagePerLoad + ", maxLoads:" + o.maxLoads
			+ "], o2=[cSize:" + o2.cSize + ", rSize:" + o2.rSize + ", CB:"
			+ (o2.overTopCB != null ? ",oTop" : "") + (o2.overBottomCB != null ? ",oBot" : "")
			+ (o2.overLeftCB != null ? ",oLeft" : "") + (o2.overRightCB != null ? ",oRight" : "")
			+ "], empty=" + this.empty + ", size=" + this.size + ", loadSize=" + this.loadSize + ", hl=" + this.hl + ", top=" + this.top
			+ ", c=" + this.c + ", r=" + this.r + ", lastTop=" + this.lastTop + ", lastC=" + this.lastC + ", lastR=" + this.lastR
			+ ", showObj=" + (showObj == null ? "null" : "[showHighlight=" + showObj.showHighlight + ", hl=" + showObj.hl + "]")
			+ ", loads" + (loads == null ? "=null" : ".length=" + loads.length)
			+ ", loadDataObj=" + (loadDataObj == null ? "null" : "[startIndex=" + loadDataObj.startIndex
				+ ", loadIndex=" + loadDataObj.startIndex + ", showHighlight=" + loadDataObj.showHighlight + "]")
			+ ", selIndex=" + selIndex;
	}
}