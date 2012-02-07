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
* Version: 1.0.0
*
* Developer: Syabas Technology Inc.
*
* Class Description:
* Sequential URL Loader. Add the URL to the Queue and load all the URLs in
* the Queue one by one in sequence.
*
***************************************************/

import mx.utils.Delegate;

class com.syabas.as2.common.URLLoader
{
	private var q:Array = null;			// queue containing the data that will be used to load the XML.
	private var idItems:Object = null;	// stored the item object of the specific id.
	private var fn:Object = null;		// stored all Delegate.create functions for performance tuning.
	private var maxLoad:Number = -1;	// maximum url load at one time.
	private var loads:Array = null;		// keep track available thread to load url.

	/*
	* Destroy all global variables.
	*/
	public function destroy():Void
	{
		this.emptyQueue();
		delete this.fn;
		this.fn = null;
		this.maxLoad = -1;
		delete this.loads;
		this.loads = null;
	}

	/*
	* Contructor.
	*
	* maxLoad: how many url will be loading at one time. Default is 1. Maximum 6.
	*/
	public function URLLoader(maxLoad:Number)
	{
		this.q = new Array();
		this.idItems = new Object();
		this.fn = {
			loadURL:Delegate.create(this, this.loadURL),
			onLoaded:Delegate.create(this, this.onLoaded)
		};

		if (maxLoad == undefined || maxLoad == null)
			maxLoad = 1;

		if (maxLoad > 6)
			maxLoad = 6;

		this.maxLoad = maxLoad;

		this.loads = new Array();
		for (var i:Number=0; i<maxLoad; i++)
			this.loads.push(11);
	}

	/*
	* Clear all item in queue.
	*/
	public function emptyQueue():Void
	{
		delete this.q;
		this.q = null;
		delete this.idItems;
		this.idItems = null;
	}

	/*
	* Skip item by id. The request without id is not supported.
	*/
	public function skip(id:String):Void
	{
		if (id == undefined || id == null)
			return;
		var idItem:Object = this.idItems[id];
		if (idItem != undefined && idItem != null) // set previous item with same id to skip.
		{
			idItem.skip = true;
			if (!(idItem.o.response == undefined || idItem.o.response == null))
			{
				idItem.o.response.onLoad = null;
				idItem.o.response.loaded = true;
				idItem.o.response.onData(undefined);
			}
		}
	}

	/*
	* Get data from the URL.
	*
	* id: loading XML with same ID will skip all the previous XML with same ID.
	* url:String - url to load the data.
	* onLoadCB:Function - callback function. Arguments:
	*   1. success:Boolean.
	*   2. loadVars:LoadVars or xml:XML.
	*   3. o:Object      - extra object to pass back.
	*      a. url:String - same as the url pass to this loadURL function.
	*      b. o:Object   - same as the "o" Object pass to this loadURL function.
	*      c. httpStatus:Number - The HTTP status code returned by the server.
	*      d. status:Number     - Indicates whether an XML document was successfully parsed into an XML object.
	*         0 No error; parse was completed successfully.
	*         -2 A CDATA section was not properly terminated.
	*         -3 The XML declaration was not properly terminated.
	*         -4 The DOCTYPE declaration was not properly terminated.
	*         -5 A comment was not properly terminated.
	*         -6 An XML element was malformed.
	*         -7 Out of memory.
	*         -8 An attribute value was not properly terminated.
	*         -9 A start-tag was not matched with an end-tag.
	*         -10 An end-tag was encountered without a matching start-tag.
	*         -98 Invalid request URL.
	*         -99 Request timeout.
	* o: extra arguments Object with properties:
	*   1. target:String        - [Optional] target type. Available value: string(Default), loadvars, xml
	*   2. method:String        - [Optional] GET(Default) or POST.
	*   3. request:Object       - [Optional] request object. LoadVars or XML. LoadVars will be created if null.
	*   4. textParsed:String    - [Optional] target must be "xml". Used when creating new XML object for request.
	*   5. timeout:Number       - [Optional] timeout in Milliseconds.
	*   6. addToFirst:Boolean   - add this new URL as first item on the queue.
	*/
	public function load(id:String, url:String, onLoadCB:Function, o:Object):Void
	{
		if (o == undefined || o == null)
			o = new Object();

		if (url == undefined || url == null)
		{
			o.status = -98;
			onLoadCB(false, null, o);
			return;
		}

		if (id == undefined)
			id = null;

		if (o.target == undefined || o.target == null || o.target == "")
			o.target = "string";

		if (o.method != "POST")
			o.method = "GET";

		if (o.request == undefined || o.request == null || o.request == "")
		{
			if (o.target == "xml")
			{
				o.request = new XML(o.textParsed);
				o.request.ignoreWhite = true;
			}
			else
				o.request = new LoadVars();
		}

		if (o.timeout == undefined || o.timeout == "" || isNaN(o.timeout) || typeof(o.timeout) != "number" || o.timeout < 0)
			o.timeout = 0;

		var item:Object = {id:id, url:url, onLoadCB:onLoadCB, o:o, skip:false};

		if (id != null)
		{
			var idItem:Object = this.idItems[id];
			if (idItem != undefined && idItem != null) // set previous item with same id to skip.
			{
				idItem.skip = true;
				if (!(idItem.o.response == undefined || idItem.o.response == null))
				{
					idItem.o.response.onLoad = null;
					idItem.o.response.loaded = true;
					idItem.o.response.onData(undefined);
				}
			}
			this.idItems[id] = item;
		}

		var hasLoad = this.loads.pop();
		if (hasLoad == 11)
			this.loadURL(item);
		else if (o.addToFirst == true)
			this.q.unshift(item);
		else
			this.q.push(item);
	}

	private function loadURL(item:Object):Void
	{
		if (item.skip == true)
			this.fn.onLoaded(false, item);
		else
		{
			if (item.o.method == "GET")
				item.o.response = item.o.request;
			else
			{
				if (item.o.request.__proto__ == XML.prototype)
				{
					item.o.response = new XML();
					item.o.response.ignoreWhite = true;
				}
				else
					item.o.response = new LoadVars();
			}
			item.fn = this.fn;

			item.o.response.onHTTPStatus = Delegate.create(item, function(stt:Number):Void
			{
				this.o.httpStatus = stt;
			});

			item.o.response.onData = Delegate.create(item, function(data:String):Void
			{
				_global.clearTimeout(this.o.ulTimeout);
				this.loaded = true;
				this.fn.onLoaded(data, this, 0);
			})

			if (item.o.method == "GET")
				item.o.request.load(item.url);
			else
				item.o.request.sendAndLoad(item.url, item.o.target);

			if (item.o.timeout > 0)
			{
				item.o.ulTimeout = _global.setTimeout(Delegate.create(item, function():Void
				{
					_global.clearTimeout(this.o.ulTimeout);
					this.o.response.onData = null;
					this.o.response.onLoad = null;
					this.o.response.loaded = true;
					this.fn.onLoaded(undefined, this, -99);
				}), item.o.timeout);
			}
		}
	}

	private function onLoaded(data:String, item:Object, status:Number):Void
	{
		if (item.skip == false && item.onLoadCB != null)
		{
			if (item.o.target == "string")
				item.onLoadCB((data != undefined), data, {id:item.id, url:item.url, o:item.o, httpStatus:item.o.httpStatus, status:status});
			else if (item.o.target == "xml")
			{
				if (status == 0)
				{
					var xmlParser:XML = new XML();
					xmlParser.ignoreWhite = true;
					xmlParser.parseXML(data);
					item.onLoadCB((data != undefined), xmlParser, {id:item.id, url:item.url, o:item.o, httpStatus:item.o.httpStatus, status:xmlParser.status});
					delete xmlParser.idMap;
					xmlParser = null;
				}
				else
					item.onLoadCB(false, null, {id:item.id, url:item.url, o:item.o, httpStatus:item.o.httpStatus, status:status});
			}
			else if (item.o.target == "loadvars")
			{
				if (status == 0)
				{
					var lvDecoder:LoadVars = new LoadVars();
					lvDecoder.decode(data);
					item.onLoadCB((data != undefined), lvDecoder, {id:item.id, url:item.url, o:item.o, httpStatus:item.o.httpStatus, status:0});
				}
				else
					item.onLoadCB(false, null, {id:item.id, url:item.url, o:item.o, httpStatus:item.o.httpStatus, status:status});
			}
		}

		URLLoader.clearItem(item);

		if (this.q.length > 0) // load the next URL.
		{
			var newItem = this.q.shift();
			while (newItem != null && newItem.skip) // skipping all previous id items.
			{
				URLLoader.clearItem(newItem);
				newItem = this.q.shift();
			}

			if (newItem != null)
				this.loadURL(newItem);
		}
		else
			this.loads.push(11);

		delete item.o.request.idMap;
		item.o.request.firstChild.removeNode();
		item.o.request = null;
		delete item.o.target.idMap;
		item.o.target.firstChild.removeNode();
		item.o.target = null;
	}

	private static function clearItem(item:Object):Void
	{
		delete item.o.request.idMap;
		item.o.request.xml = null;
		item.o.request.id = null;
		delete item.o.response.idMap;
		item.o.response.xml = null;
		item.o.method = null;
		item.url = null;
		item.onLoadCB = null;
		item.skip = true;
		item.fn = null;
	}
}