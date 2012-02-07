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
* Class Description: GridLite component.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.GridLite
{
	// **WARNING: variables below are READ ONLY for public, they should not be changed outside of this class.
	//			It is for performance tuning. Accessing variable directly is faster than going through getter function.
	public var _hl:Number = -1;
	public var _len:Number = -1;
	public var _cSize:Number = -1;
	public var _rSize:Number = -1;
	public var _size:Number = -1;

	// **WARNING: variables below are to be set ONE TIME ONLY, they should not be changed after set.
	//			It is for performance tuning. Accessing variable directly is faster than going through getter function.
	public var xMCArray:Array = null;
	public var xHoriz:Boolean = false;
	public var xWrap:Boolean = true;
	public var xWrapLine:Boolean = true;
	public var xHLStopTime:Number = 0;

	public var up:Function = null;		// function to move up.
	public var down:Function = null;	// function to move down.
	public var left:Function = null;	// function to move left.
	public var right:Function = null;	// function to move right.

	// data to be displayed on the Grid. Default is null.
	public var data:Array = null;

	/*
	*   1.  onItemUpdateCB:Function - callback function to Update the data on the movieClip. Default is null.
	*                                 Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   2.  onItemClearCB:Function - callback function to Clear the movieClip. Default is null.
	*                                Arguments: {mc:MovieClip}
	*   3.  hlCB:Function - callback function to highlight the movieClip. Default is null.
	*                       Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   4.  unhlCB:Function - callback function to remove highlight from the movieClip. Default is null.
	*                         Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   5.  overTopCB:Function - callback function to be called when highlight go above the top most data row. Default is null.
	*                            Return: true to remain in the grid, else will unhighlight.
	*   6.  overBottomCB:Function - callback function to be called when highlight go below the bottom most data row. Default is null.
	*                               Return: true to remain in the grid, else will unhighlight.
	*   7.  overLeftCB:Function - callback function to be called when highlight go to the left over left most data column. Default is null.
	*                             Return: true to remain in the grid, else will unhighlight.
	*   8.  overRightCB:Function - callback function to be called when highlight go to the right over right most data column. Default is null.
	*                              Return: true to remain in the grid, else will unhighlight.
	*   9.  onEnterCB:Function - callback function to be called when enter key is pressed. Default is null.
	*                            Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   10. onKeyDownCB:Function - callback function to be called when key other than up/down/left/right/enter is called. Default is null.
	*                              Arguments: o:Object {keyCode:Number, asciiCode:Number}
	*   11. onHLStopCB:Function - callback function to be called when highlight stop for hlStopTime milliseconds. Default is null.
	*                             Arguments: {mc:MovieClip, data:Object, dataIndex:Number}
	*   12. singleSelectCB:Function - callback function to be called when item is selected/unselected. Default is null.
	*                                 Arguments: {mc:MovieClip, data:Object, dataIndex:Number, selected:Boolean}
	*                                 Return: true to reset current selected item.
	*/
	public var onItemUpdateCB:Function = null;
	public var onItemClearCB:Function = null;
	public var hlCB:Function = null;
	public var unhlCB:Function = null;
	public var onHLStopCB:Function = null;
	public var overTopCB:Function = null;
	public var overBottomCB:Function = null;
	public var overLeftCB:Function = null;
	public var overRightCB:Function = null;
	public var onEnterCB:Function = null;
	public var onKeyDownCB:Function = null;
	public var singleSelectCB:Function = null;

	private var fn:Object = null;
	private var keyListener:Object = null;
	private var keyDown:Function = null;
	private var klTimeout:Number = 0;
	private var hlStopTimeoutId:Number = 0;

	public var top:Number = -1;
	private var c:Number = -1;
	private var r:Number = -1;
	private var lastTop:Number = -1;	// last page 1st item data index.
	private var lastC:Number = -1;		// last item column.
	private var lastR:Number = -1;		// last item row.

	private var ssIndex:Number = -1;	//index for single select. Default is -1;

	public function GridLite()
	{
		this.fn = {
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
	* Destroy all global variables.
	*/
	public function destroy():Void
	{
		this.clear();
		this.keyListener.onKeyDown = null;
		Key.removeListener(this.keyListener);

		this._cSize = -1;
		this._rSize = -1;
		this._size = -1;
		this.xWrap = true;
		this.xWrapLine = true;
		this.xHoriz = false;

		this.xMCArray = null;
		this.data = null;

		this.fn = null;
		this.keyListener = null;
		this.keyDown = null;
		this.klTimeout = 0;

		this._hl = -1;
		this.hlStopTimeoutId = 0;
		this.xHLStopTime = 0;
		this._len = -1;
		this.top = -1;
		this.c = -1;
		this.r = -1;
		this.lastTop = -1;
		this.lastC = -1;
		this.lastR = -1;

		this.up = null;
		this.down = null;
		this.left = null;
		this.right = null;
	}

	/*
	* Clear data in all MC.
	*/
	public function clear():Void
	{
		this._hl = -1;
		this.top = -1;
		var onItemClearCB:Function = this.onItemClearCB;
		if (onItemClearCB == null)
			return;
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var mcArray:Array = this.xMCArray;

		for (var i:Number=0; i<rSize; i++)
			for (var j:Number=0; j<cSize; j++)
				onItemClearCB({mc:mcArray[i][j]});
	}

	/*
	* Create UI. Will clear all MC before create.
	* hl:Number - If hl(data index) equals undefined or null then will load data from index 0.
	*/
	public function createUI(hl:Number):Void
	{
		if (this.xMCArray == undefined || this.xMCArray == null || this.xMCArray.length < 1)
			return;
		this.clear();
		trace("createUI, Setting _rSize to " + this.xMCArray.length);
		this._rSize = this.xMCArray.length;
		var temp:Number = this.xMCArray[0].length;
		this._cSize = (temp != undefined && temp != null ? temp : 1);
		this.up = this.verticalUp;
		this.down = this.verticalDown;
		this.left = this.verticalLeft;
		this.right = this.verticalRight;
		if(this.xHoriz == true)
			this.configHoriz();
		this._size = this._rSize * this._cSize;
		this.setLength(data.length);

		this.setHL(hl, false);
	}

	/*
	* Get data. If dataIndex equals undefined or null then will return current highlighted data.
	*/
	public function getData(dataIndex:Number):Object
	{
		if (dataIndex == undefined || dataIndex == null)
			dataIndex = this._hl;
		if (dataIndex < 0)
			return null;

		var data:Array = this.data;
		if (data == undefined || data == null)
			return null;

		if (dataIndex < data.length)
			data = data[dataIndex];
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
			return (this.xHoriz ? this.r : this.c);
		if(dataIndex < this.top || dataIndex >= this.top+this._size)
			return null;

		var cSize:Number = this._cSize;
		var mcHL:Number = (dataIndex - this.top);
		var c:Number = mcHL % cSize;
		var r:Number = Math.floor((mcHL / cSize));
		return (this.xHoriz ? r : c);
	}

	/*
	* Get row value. If dataIndex equals undefined or null then will return current highlighted row value.
	*/
	public function getR(dataIndex:Number):Number
	{
		if (dataIndex == undefined || dataIndex == null)
			return (this.xHoriz ? this.c : this.r);
		if(dataIndex < this.top || dataIndex >= this.top+this._size)
			return null;

		var cSize:Number = this._cSize;
		var mcHL:Number = (dataIndex - this.top);
		var c:Number = mcHL % cSize;
		var r:Number = Math.floor((mcHL / cSize));
		return (this.xHoriz ? c : r);
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
		return this.xMCArray[row][column];
	}

	/*
	* Get current page number. Start from 1.
	*/
	public function getPage():Number
	{
		if (this.top < 0)
			return -1;
		return Math.floor((this._hl / this._size)) + 1;
	}

	/*
	* Highlight with the hl(data index) specified and enable the keyListener.
	*/
	public function highlight(hl:Number):Void
	{
		this.setHL(hl, true);
	}

	/*
	* Disable the keyListener and remove the highlight.
	*/
	public function unhighlight():Void
	{
		this.disableKeyListener();
		this.removeHighlight();
	}

	/*
	* Select/unselect single item. If dataIndex equals undefined or null then will select/unselect current highlighted item.
	*/
	public function singleSelect(dataIndex:Number):Void
	{
		if (isNaN (new Number (dataIndex)) == true)
			dataIndex = this._hl;
		if (dataIndex < 0)
			return;
		var index:Number = this.ssIndex;
		var r:Number = 0;
		var c:Number = 0;
		var reset:Boolean = false;
		if (index >= 0)
		{
			if (index >= this.top && index < this.top + this._size) // check prev selected item is in current grid
			{
				r = (this.xHoriz? this.getC(index) : this.getR(index))
				c = (this.xHoriz? this.getR(index) : this.getC(index))
				reset = this.singleSelectCB( { mc:this.xMCArray[r][c], data:this.getData(index), dataIndex:index, selected:false } );// return unselected data
			}
		}
		if(dataIndex == index && reset == true)
			this.ssIndex = -1;
		else
		{
			this.ssIndex = dataIndex;
			r = (this.xHoriz? this.getC(dataIndex) : this.getR(dataIndex))
			c = (this.xHoriz? this.getR(dataIndex) : this.getC(dataIndex))
			this.singleSelectCB({mc:this.xMCArray[r][c], data:this.getData(dataIndex), dataIndex:dataIndex, selected:true});// return selected data
		}
	}

	/*
	* Configure grid for horizontal layout.
	*/
	private function configHoriz():Void
	{
		var tempT:Function = this.overTopCB;
		var tempB:Function = this.overBottomCB;
		var tempL:Function = this.overLeftCB;
		var tempR:Function = this.overRightCB;
		this.overTopCB = tempL;
		this.overBottomCB = tempR;
		this.overLeftCB = tempT;
		this.overRightCB = tempB;

		var tempRs:Number = this._rSize;
		var tempCs:Number = this._cSize;
		var tempArr:Array = new Array();

		this._cSize = tempRs;
		trace("configHoriz, Setting _rSize to " + tempCs);
		this._rSize = tempCs;
		this.up = this.verticalLeft;
		this.down = this.verticalRight;
		this.left = this.verticalUp;
		this.right = this.verticalDown;

		for (var j:Number=0; j<this._rSize; j++)
		{
			tempArr.push(new Array());
			for (var i:Number=0; i<this._cSize; i++)
				tempArr[j].push(this.xMCArray[i][j]);
		}
		this.xMCArray = tempArr;
	}

	private function removeHighlight():Void
	{
		if (this.unhlCB == null || this.top < 0)
			return;
		_global.clearTimeout(this.hlStopTimeoutId);
		this.unhlCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
	}

	private function setHL(hl:Number, showHighlight:Boolean):Void
	{
		var prevHL:Number = this._hl;
		if (isNaN (new Number (hl)) == true) // if hl is not a number.
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

		var len:Number = this._len;
		if (hl < 0)
			hl = 0;
		else if (hl >= len)
			hl = len - 1;
		this._hl = hl;

		var cSize:Number = this._cSize;
		var size:Number = this._size;
		var top:Number = 0;

		if (this._hl > this.top && this._hl < this.top + size && this.top >= 0)
			top = this.top;
		else
		{
			if (hl >= size)
				top = ((Math.floor((hl / cSize)) - this._rSize + 1) * cSize);
		}

		var mcHL:Number = (hl - top);
		this.c = mcHL % cSize;
		this.r = Math.floor((mcHL / cSize));

		this.setTop(top, showHighlight);
	}

	private function setTop(top:Number, showHighlight:Boolean):Void
	{
		var prevTop:Number = this.top;
		//trace("setTop.prevTop: " + prevTop);
		if (top != prevTop)
		{
			this.top = top;
			if (top < 0)
				return;

			var onLoadData:Function = this.fn.updateAllMC;
			if (prevTop > -1) // not the first entry.
			{
				trace("Doing setTop.prevTop...");
				if (top == (prevTop - this._cSize)) // go to previous line.
					onLoadData = this.fn.verticalMCArrayDown;
				else if (top == (prevTop + this._cSize)) // go to next line.
					onLoadData = this.fn.verticalMCArrayUp;
			}

			onLoadData();
		}

		this.showHighlight(showHighlight);
	}

	private function showHighlight(showHighlight:Boolean):Void
	{
		if (showHighlight == false)
			return;

		if (this.hlCB != null && this.top >= 0)
		{
			var obj:Object = this.getData(this._hl);
			var stop:Boolean = true;

			this.hlCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});

			if (this.onHLStopCB != null && this.xHLStopTime > 0)
			{
				_global.clearTimeout(this.hlStopTimeoutId);
				this.hlStopTimeoutId = _global.setTimeout(this.fn.onHLStop, this.xHLStopTime);
			}
		}

		this.enableKeyListener();
	}

	private function onHLStop():Void
	{
		_global.clearTimeout(this.hlStopTimeoutId);
		this.onHLStopCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
	}

	private function enableKeyListener():Void
	{
		if (this.keyListener.onKeyDown != null)
			return;
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.klTimeout = _global.setTimeout(this.fn.onEnableKeyListener, 100); // delay abit to prevent getting the previously press key.
	}

	private function onEnableKeyListener():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = this.keyDown;
	}

	private function disableKeyListener():Void
	{
		_global.clearTimeout(this.klTimeout);
		this.klTimeout = null;
		this.keyListener.onKeyDown = null;
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
				if(this.singleSelectCB != null)
					this.singleSelect();
				else
				{
					if (this.onEnterCB != null)
						this.onEnterCB({mc:this.xMCArray[this.r][this.c], data:this.getData(), dataIndex:this._hl});
				}
				break;
			default:
				if (this.onKeyDownCB != null)
					this.onKeyDownCB({keyCode:keyCode,asciiCode:Key.getAscii()});
				break;
		}
	}

	private function verticalUp():Void // or left for horizontal.
	{
		trace("Doing verticalUp...");
		if (this.r == 0) // first row.
		{	
			trace("Doing verticalUp First Row...");
			if (this.top == 0) // first page.
			{
				if (this.overTopCB != null)
				{
					var b:Boolean = this.overTopCB();
					if (!b || b == null || b == undefined)
					{
						this.removeHighlight();
						this.disableKeyListener();
						return;
					}
				}

				if (this.xWrap)
				{
					// go to last page.
					this.removeHighlight();
					this.c = Math.min(this.c, this.lastC);
					this.r = this.lastR;
					this._hl = this.lastTop + (this.r * this._cSize) + this.c;
					this.setTop(this.lastTop, true);
					return;
				}
				else
					return;
			}
			else // page 2 or line 2 onwards.
			{	
				trace("Doing verticalUp 2nd Row+...");
				this.removeHighlight();
				this._hl = this._hl - this._cSize;
				this.setTop((this.top - this._cSize), true);
				return;
			}
		}
		else // not first row.
		{
			trace("Doing verticalUp Not 1st Row...");
			this.removeHighlight();
			this.r--; // highlight up one row.
			this._hl = this._hl - this._cSize;
		}

		this.showHighlight();
	}

	private function verticalDown():Void // or right for horizontal.
	{
		trace("Doing verticalDown...");
		trace("this.top: " + this.top);
		trace("this.lastTop: " + this.lastTop);
		trace("this.r: " + this.r);
		trace("this.lastR: " + this.lastR);
		trace("this._rSize: " + this._rSize);
		if (this.top == this.lastTop && this.r == this.lastR) // last data row.
		{
			trace("Doing verticalDown Last Row...");
			if (this.overBottomCB != null)
			{
				var b:Boolean = this.overBottomCB();
				if (!b || b == null || b == undefined)
				{
					this.removeHighlight();
					this.disableKeyListener();
					return;
				}
			}

			if (this.xWrap)
			{
				this.removeHighlight();
				// go to first page.
				this.r = 0;
				this._hl = this.c;
				this.setTop(0, true);
				return;
			}
			else
				return;
		}
		else if (this.r == this._rSize - 1) // last ui row.
		{	
			trace("Doing verticalDown Last UI Row...");
			this.removeHighlight();
			this._hl = this._hl + this._cSize;// down one row.
			if(this._hl >  this._len - 1)
			{
				this._hl = this._len - 1; // highlight last data.
				this.c = this.lastC;
			}
			this.setTop((this.top + this._cSize), true);
			return;
		}
		else // not last row.
		{
			trace("Doing verticalDown Not Last Row...");
			this.removeHighlight();
			// highlight down one row.
			this.r++;
			this._hl = this._hl + this._cSize;
		}

		if (this.top == this.lastTop && this.r == this.lastR && this.c > this.lastC) // check column is not over last data column.
		{
			this._hl = this._len - 1; // highlight last data.
			this.c = this.lastC;
		}

		this.showHighlight();
	}

	private function verticalLeft():Void // or up for horizontal.
	{
		trace("Doing verticalLeft...");
		if (this.c == 0) // first column.
		{
			if (this.overLeftCB != null)
			{
				var b:Boolean = this.overLeftCB();
				if (!b || b == null || b == undefined)
				{
					this.removeHighlight();
					this.disableKeyListener();
					return;
				}
			}

			if (this.xWrapLine) // highlight previous row last column.
			{
				this.removeHighlight();
				this.c = this._cSize - 1;
				this._hl = this._hl + this.c; // move highlight to last column before moving up.
				this.verticalUp();
				return;
			}
			else if (this._cSize > 1 && this.xWrap)
			{
				this.removeHighlight();
				if (this.top == this.lastTop && this.r == this.lastR) // if it is last data row.
				{
					this.c = this.lastC;
					this._hl = this._len - 1; // highlight last data.
				}
				else
				{
					this.c = this._cSize - 1;
					this._hl = this._hl + this.c; // move highlight to last column.
				}
			}
			else
				return;
		}
		else // not first column.
		{
			this.removeHighlight();
			this.c--;
			this._hl--;
		}

		this.showHighlight();
	}

	private function verticalRight():Void // or down for horizontal.
	{
		trace("Doing verticalRight...");
		if ((this.c == this._cSize - 1) // last column.
			|| (this.top == this.lastTop && this.r == this.lastR && this.c == this.lastC))
		{
			if (this.overRightCB != null)
			{
				var b:Boolean = this.overRightCB();
				if (!b || b == null || b == undefined)
				{
					this.removeHighlight();
					this.disableKeyListener();
					return;
				}
			}

			if (this.xWrapLine) // highlight next row first column.
			{
				this.removeHighlight();
				this._hl = this._hl - this.c; // move highlight to first column before moving down.
				this.c = 0;
				this.verticalDown();
				return;
			}
			else if (this._cSize > 1 && this.xWrap)
			{
				this.removeHighlight();
				this._hl = this._hl - this.c; // move highlight to first column.
				this.c = 0;
			}
			else
				return;
		}
		else // not last column.
		{
			this.removeHighlight();
			this.c++;
			this._hl++;
		}

		this.showHighlight();
	}

	/*
	* Move all the movieClips one line up.  And move the first movieClip to the last.
	*/
	private function verticalMCArrayUp():Void // or move left for horizontal.
	{
		trace("Doing verticalMCArrayUp...");
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var mcArray:Array = this.xMCArray;
		var mcBelow:MovieClip = null;
		var mcAbove:MovieClip = null;
		var last:Object = null;
		var lastRow:Number = this.top + ((rSize-1)*cSize);

		for (var i:Number=0; i<cSize; i++) // do for every column.
		{
			mcBelow = mcArray[rSize-1][i];
			last = {x:mcBelow._x, y:mcBelow._y}; // keep the last mc properties so the 1st mc can move to last.

			for (var j:Number=rSize-2; j>=0; j--) // move from last mc up until 1st mc.
			{
				mcAbove = mcArray[j][i];
				mcBelow._x = mcAbove._x;
				mcBelow._y = mcAbove._y;
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
		trace("Doing verticalMCArrayDown...");
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var mcArray:Array = this.xMCArray;
		var mcAbove:MovieClip = null;
		var mcBelow:MovieClip = null;
		var first:Object = null;
		var top:Number = this.top;

		for (var i:Number=0; i<cSize; i++) // do for every column.
		{
			mcAbove = mcArray[0][i];
			first = {x:mcAbove._x, y:mcAbove._y}; // keep the 1st mc properties so the last mc can move to 1st.

			for (var j:Number=1; j<rSize; j++) // move from 1st mc down until last mc.
			{
				mcBelow = mcArray[j][i];
				mcAbove._x = mcBelow._x;
				mcAbove._y = mcBelow._y;
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

	/*
	* Set length of the data and calculate needed value.
	*/
	private function setLength(len:Number):Void
	{
		if (len == undefined || len == null)
			len = 0;
		this._len = len;

		// calculate lastTop, lastR, lastC.
		this.lastTop = -1;
		this.lastR = -1;
		this.lastC = -1;
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;

		var lastDataRow:Number = Math.floor(((len - 1) / cSize));
		var lastC:Number = (len - 1) % cSize;
		var lastR:Number = lastDataRow;
		if (lastR > (rSize - 1))
			lastR = rSize - 1;

		this.lastTop = (lastDataRow - lastR) * cSize;
		this.lastC = lastC;
		this.lastR = lastR;
	}

	/*
	* Update all the MC.
	*/
	private function updateAllMC():Void
	{
		var mcArray:Array = this.xMCArray;
		var cSize:Number = this._cSize;
		var rSize:Number = this._rSize;
		var top:Number = this.top;

		for (var i:Number=0; i<rSize; i++)
			for (var j:Number=0; j<cSize; j++)
				this.updateMC(mcArray[i][j], (i * cSize) + top + j);
	}

	/*
	* Update the MC.
	*/
	private function updateMC(mc:MovieClip, dataIndex:Number):Void
	{
		if (dataIndex < 0)
			return;

		if (dataIndex >= this._len) // clear if index is over the data length.
		{
			if (this.onItemClearCB != null)
				this.onItemClearCB({mc:mc});
		}
		else if (this.onItemUpdateCB != null)
			this.onItemUpdateCB({mc:mc, data:this.getData(dataIndex), dataIndex:dataIndex});
	}
}