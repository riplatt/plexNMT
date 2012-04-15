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
* Version: 1.2.5
*
* Developer: Syabas Technology Inc.
*
* Class Description: Sample Menu.
*
***************************************************/

import com.syabas.as2.sample.Share;
import com.syabas.as2.common.GridLite;
import com.syabas.as2.common.Marquee;
import com.syabas.as2.common.Util;
import com.syabas.as2.common.UI;
import mx.utils.Delegate;
import caurina.transitions.Tweener;

class plexNMT.as2.pages.MainMenu
{
	private var parentMC:MovieClip = null;		// the parent movieClip to attach the menu movieClip.
	private var showHideInSec:Number = null;	// how many seconds to show and hide menu.

	private var menuMC:MovieClip = null;
	private var g:GridLite = null;				// Grid object used for the menu.
	private var itemMarquee:Marquee = null;		// Marquee for the menu item.
	private var fn:Object = null;				// storing all Delegate.create functions for performance tuning.

	private var totalItems:Number = 0;			// total menu items
	private var menuData:Array = null;

	/*
	* Destroy all global variables.
	*/
	public function destroy():Void
	{
		this.parentMC = null;
		this.showHideInSec = null;
		this.menuMC.removeMovieClip();
		delete this.menuMC;
		this.menuMC = null;
		this.g.destroy();
		delete this.g;
		this.g = null;
		this.itemMarquee.stop(false);
		delete this.itemMarquee;
		this.itemMarquee = null;
		delete this.fn;
		this.fn = null;
		this.totalItems = 0;
	}

	/*
	* Constructor.
	*
	* parentMC: the parent movieClip to attach the menu movieClip.
	* menuData: array of menu data object {title, link, thumbnail}.
	* onSelectCB: callback function that will be called when the menu item is selected.
	* onHideCB: callback function that will be called after menu is hide.
	* showHideInSec: how many seconds to show and hide menu.
	*/
	public function MainMenu(parentMC:MovieClip, menuData:Array, onSelectCB:Function, onHideCB:Function, showHideInSec:Number)
	{
		this.parentMC = parentMC;
		this.showHideInSec = showHideInSec;
		this.itemMarquee = new Marquee();
		this.menuData = menuData;

		// contructing the Grid.
		this.g = new GridLite();
		this.g.xWrapLine = false;
		this.g.xHLStopTime = 2000;
		this.g.data = this.menuData;
		this.g.onItemUpdateCB = Delegate.create(this, this.onItemUpdateCB);
		this.g.onItemClearCB = Delegate.create(this, this.onItemClearCB);
		this.g.hlCB = Delegate.create(this, this.hlCB);
		this.g.unhlCB = Delegate.create(this, this.unhlCB);
		this.g.onHLStopCB = Delegate.create(this, this.onHLStopCB);
		this.g.overRightCB = Delegate.create(this, this.overRightCB)
		this.g.onEnterCB = Delegate.create(this, this.onEnterCB);

		// storing all the callback functions.
		this.fn =
		{
			onSelectCB:onSelectCB,
			onHideCB:onHideCB,
			onHide:Delegate.create(this, this.onHide)
		};

		this.totalItems = menuData.length;
	}

	public function show():Void
	{
		this.g.unhighlight();
		if (this.menuMC == null)
		{
			this.menuMC = this.parentMC.attachMovie("menuMC", "menuMC", this.parentMC.getNextHighestDepth(), {_alpha:0, _x:-328, _y:83});
			var mcArray:Array = UI.attachMovieClip({
				parentMC:this.menuMC, cSize:1, rSize:9,
				mcPrefix:"item"
			});
			this.g.xMCArray = mcArray;

			this.g.createUI(0);
			this.menuMC.count._visible = (this.g._len > 9); // if more than 1 page, then show the item index and count.
		}
		this.g.highlight(0);
		this.menuMC._visible = true;
		Tweener.addTween(this.menuMC, {
			_alpha:100,
			time:Util.value(this.showHideInSec, 0),
			transition:"easeOutQuad",
			onComplete:null
		});
	}

	/*
	* Get selected menu item object. Return 0 if selected index is less than 0.
	*/
	public function getSelected():Object
	{
		var hl:Number = this.g._hl;
		if (hl < 0)
			hl = 0;
		return this.g.getData(hl);
	}

	/*
	* Return true if exit is selected.
	*/
	public function isExitSelected():Boolean
	{
		return (this.g._hl == this.totalItems-1);
	}

	private function hide():Void
	{
		this.itemMarquee.stop(true);
		this.g.unhighlight();
		Tweener.addTween(this.menuMC, {
			_alpha:0,
			time:Util.value(this.showHideInSec, 0),
			transition:"easeOutQuad",
			onComplete:this.fn.onHide
		});
	}

	private function onHide():Void
	{
		this.menuMC._visible = false;
	}

	/*
	* Update menu item. Will be called by the grid.
	*/
	private function onItemUpdateCB(o:Object):Void
	{
		o.mc.txt.htmlText = o.data.title; // setting the menu item title on the menu item movieClip.
	}

	/*
	* Clear menu item. Will be called by the grid.
	*/
	private function onItemClearCB(o:Object):Void
	{
		o.mc.txt.htmlText = ""; // clear menu item.
		o.mc.gotoAndStop("unhl"); // go to unhl frame. no highlight.
		this.itemMarquee.stop(false); // stop Marquee.
	}

	/*
	* Highlight menu item. Will be called by the grid.
	*/
	private function hlCB(o:Object):Void
	{
		o.mc.gotoAndStop("hl"); // show highlight.
		this.menuMC.count.text = (this.g._hl+1) + " / " + this.g._len; // show highlight item index.
	}

	/*
	* Highlight stop for hlStopTime milliseconds. Will be called by the grid.
	*/
	private function onHLStopCB(o:Object):Void
	{
		this.itemMarquee.start(o.mc.txt, {delayInMillis:1000, stepPerMove:2, endGap:5, vertical:false, framePerMove:1});// start Marquee.
	}

	/*
	* Remove menu item highlight. Will be called by the grid.
	*/
	private function unhlCB(o:Object):Void
	{
		o.mc.gotoAndStop("unhl");
		this.itemMarquee.stop(true); // stop Marquee.
	}

	/*
	* When navigate over the right of the menu. Will be called by the grid.
	*/
	private function overRightCB():Void
	{
		this.hide();
		this.fn.onHideCB();
	}

	/*
	* When menu item is selected. Will be called by the grid.
	*/
	private function onEnterCB():Void
	{
		this.hide();
		this.fn.onSelectCB();
	}
}