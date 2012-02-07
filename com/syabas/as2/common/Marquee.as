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
* Version: 2.0.3
*
* Developer: Syabas Technology Inc.
*
* Class Description:
* pixel(s) by pixel(s) horizontal marquee and Line by Line vertical marquee.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.Marquee
{
	private var txtField:TextField = null;
	private var oriText:String = null;
	private var prop:Object = null;
	private var marqueeTimeout:Number = 0;
	private var fmc:MovieClip = null;
	private var enterFrameFunc:Function = null;
	private var repeatPos:Number = null;
	private var frameCount:Number = 0;

	/*
	* Start the Marquee.
	*
	* txtField: the TextField.
	* prop: properties for the marquee
	*		1. delayInMillis:Number 	- delay how many milliseconds before start moving. Default is 0.
	*		2. stepPerMove:Number 		- total pixel(horizontal) or line(vertical) to move per move. Larger stepPerMove will move faster.Default is 1.
	*		3. endGap:Number 			- total space(horizontal) or newline(vertical) before the original text repeat itself. Default is 0.
	*		4. vertical:Boolean 		- true to move vertically. Default is false(horizontal).
	*		5. framePerMove:Number 		- number of frame to move 1 step. Default is 1.
	*/
	public function start(txtField:TextField, prop:Object):Void
	{
		if (txtField == null && txtField == undefined)
			return;
		if ((prop.vertical == true && txtField.maxscroll <= 1) || (prop.vertical !== true && txtField.maxhscroll <= 4))
			return;
		this.txtField = txtField;
		var oriTextFormat:TextFormat = txtField.getTextFormat();
		this.oriText = txtField.htmlText;
		this.prop = prop;
		if (this.prop == undefined || this.prop == null)
			this.prop = new Object ();
		if (isNaN (new Number (this.prop.delayInMillis)))
			this.prop.delayInMillis = 0;
		if (isNaN (new Number (this.prop.stepPerMove)))
			this.prop.stepPerMove = 1;
		if (isNaN (new Number (this.prop.endGap)))
			this.prop.endGap = 0;
		if (isNaN (new Number (this.prop.framePerMove)))
			this.prop.framePerMove = 1;

		var gap:String = "";
		if(this.prop.vertical == true)
		{
			for (var i:Number=0; i<this.prop.endGap; i++)
				gap += "\n";
			txtField.htmlText = this.oriText + gap;

			this.repeatPos = txtField.bottomScroll + txtField.maxscroll;
			txtField.htmlText = txtField.htmlText + this.oriText;

			this.enterFrameFunc = Delegate.create (this, this.vertical);
		}
		else
		{
			for (var i:Number=0; i<this.prop.endGap; i++)
				gap += " ";
			txtField.htmlText = this.oriText + gap;
			this.repeatPos = txtField.maxhscroll;
			txtField.htmlText += txtField.htmlText;
			this.repeatPos = txtField.maxhscroll - this.repeatPos;
			
			this.enterFrameFunc = Delegate.create (this, this.horizontal);
		}
		txtField.setTextFormat(oriTextFormat);
		this.initStart();
	}

	/*
	* Stop the Marquee.
	*/
	public function stop():Void
	{
		_global.clearTimeout (this.marqueeTimeout);
		delete this.fmc.onEnterFrame;
		delete this.fmc;
		this.fmc.removeMovieClip ();
		this.fmc = null;
		this.txtField.hscroll = 0;
		this.txtField.scroll = 1;
		var oriTextFormat:TextFormat = this.txtField.getTextFormat();
		this.txtField.htmlText = this.oriText;
		this.txtField.setTextFormat(oriTextFormat);

		this.txtField = null;
		this.oriText = null;
		this.prop = null;
		this.marqueeTimeout = 0;
		this.fmc = null;
		this.enterFrameFunc = null;
		this.repeatPos = null;
		this.frameCount = 0;
	}

	private function initStart ():Void
	{
		delete this.fmc.onEnterFrame;
		delete this.fmc;
		this.fmc.removeMovieClip ();
		this.fmc = null;
		this.marqueeTimeout = _global["setTimeout"] (Delegate.create (this, this.delayStart), this.prop.delayInMillis);
	}

	private function delayStart ()
	{
		_global.clearTimeout (this.marqueeTimeout);
		var randomDepth:Number = Math.floor (Math.random () * 999999);
		this.fmc = _root.createEmptyMovieClip ("marquee_fmc", 31338 + randomDepth);
		fmc.onEnterFrame = this.enterFrameFunc;
	}

	private function horizontal():Void
	{
		this.frameCount++;
		if(this.frameCount < this.prop.framePerMove)
			return;
		this.frameCount = 0;
		var txtField:TextField = this.txtField;
		txtField.hscroll = (txtField.hscroll + this.prop.stepPerMove) % this.repeatPos;
	}

	private function vertical():Void
	{
		this.frameCount++;
		if(this.frameCount < this.prop.framePerMove)
			return;
		this.frameCount = 0;
		if (this.txtField.scroll >= this.repeatPos)
			this.txtField.scroll = this.txtField.scroll - this.repeatPos;
		this.txtField.scroll += this.prop.stepPerMove;
	}
}