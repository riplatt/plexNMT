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
* Version: 1.1.2
*
* Developer: Syabas Technology Inc.
*
* Class Description: Utilities functions.
*
***************************************************/

class com.syabas.as2.common.Util
{
	/*
	* Return true if the String is null or undefined or empty string.
	*/
	public static function isEmpty(s:String):Boolean
	{
		return (s == null || s == "null" || s == undefined || s == "undefined" || s == "");
	}

	/*
	* Whitespace:
	* U+0009-U+000D (control characters, containing Tab, CR and LF)
	* U+0020 SPACE
	* U+0085 NEL (control character next line)
	* U+00A0 NBSP (NO-BREAK SPACE)
	* U+1680 OGHAM SPACE MARK
	* U+180E MONGOLIAN VOWEL SEPARATOR
	* U+2000-U+200A (different sorts of spaces)
	* U+2028 LS (LINE SEPARATOR)
	* U+2029 PS (PARAGRAPH SEPARATOR)
	* U+202F NNBSP (NARROW NO-BREAK SPACE)
	* U+205F MMSP (MEDIUM MATHEMATICAL SPACE)
	* U+3000 IDEOGRAPHIC SPACE
	*/
	private static var WHITESPACE:Object = {c133:true, c160:true, c5760:true, c6158:true,
		c8232:true, c8233:true, c8239:true, c8287:true, c12288:true};

	/*
	* Return true if the String is null or undefined or empty string or blank.
	*/
	public static function isBlank(s:String):Boolean
	{
		if (Util.isEmpty(s))
			return true;

		s = s.toString();
		var whitespace:Object = Util.WHITESPACE;
		var i:Number = s.length-1;
		if (i >= 0)
		{
			var c:Number = s.charCodeAt(i);
			while (i >= 0 && (c <= 32 || (whitespace["c" + c] == true) || (8192 <= c && c <= 8202)))
			{
				i--;
				c = s.charCodeAt(i);
			}
		}

		return (i < 0);
	}

	/*
	* Return true if the String is Alphabet (A-Z or a-z).
	*/
	public static function isAlpha(s:String):Boolean
	{
		if (Util.isBlank(s))
			return false;

		var len:Number = s.length;
		var code:Number = null;
		for (var i:Number=0; i<len; i++)
		{
			code = s.charCodeAt(i);
			if (!((65 <= code && code <= 90) || (97 <= code && code <= 122)))
				return false;
		}
		return true;
	}

	/*
	* Return true if the String is Numeric (0-9).
	*/
	public static function isNum(s:String):Boolean
	{
		if(isNaN(new Number(s)))
			return false;
		return true;
	}

	/*
	* Return true if the String is Alphabet and Numeric (A-Z, a-z or 0-9).
	*/
	public static function isAlphanum(s:String):Boolean
	{
		if (Util.isBlank(s))
			return false;

		var len:Number = s.length;
		var code:Number = null;
		for (var i:Number=0; i<len; i++)
		{
			code = s.charCodeAt(i);
			if (!((65 <= code && code <= 90) || (97 <= code && code <= 122) || (48 <= code && code <= 57)))
				return false;
		}
		return true;
	}

	/*
	* Return true if the String is Hexadecimal (A-F, a-f or 0-9).
	*/
	public static function isHex(s:String):Boolean
	{
		if (Util.isBlank(s))
			return false;

		var len:Number = s.length;
		var code:Number = null;
		for (var i:Number=0; i<len; i++)
		{
			code = s.charCodeAt(i);
			if (!((48 <= code && code <= 57) || (65 <= code && code <= 70) || (97 <= code && code <= 102)))
				return false;
		}
		return true;
	}

	/*
	* Return true if the String is Identifier ($, _, A-Z, a-z or 0-9).
	*/
	public static function isIdentifier(s:String):Boolean
	{
		if (Util.isBlank(s))
			return false;

		var len:Number = s.length;
		var code:Number = null;
		for (var i:Number=0; i<len; i++)
		{
			code = s.charCodeAt(i);
			if (!((65 <= code && code <= 90) || (97 <= code && code <= 122)
				|| (48 <= code && code <= 57) || (code == 36) || (code == 95)))
			{
				return false;
			}
		}
		return true;
	}

	/*
	* Return true if the String is Email.
	*/
	public static function isEmail(s:String):Boolean
	{
		if (Util.isBlank(s) || (s.indexOf("..") != -1))
			return false;

		s = Util.trim(s);
		s = s.toLowerCase();
		var a:Array = s.split("@");
		if (a.length != 2)
			return false;

		var username:String = a[0];
		var domain:String = a[1];
		if (Util.isBlank(username) || Util.isBlank(domain)
			|| domain.indexOf('.') == -1 || username.charAt(0) == '.' || domain.charAt(0) == '.'
			|| username.charAt((username.length - 1)) == '.' || domain.charAt((domain.length - 1)) == '.'
			|| !Util.isEmailString(username) || !Util.isEmailString(domain))
		{
			return false;
		}
		return true;
	}

	private static var NOT_EMAIL_CHAR:Array = null;

	/*
	* Email Char: a-z, A-Z, 0-9, ! # $ % & ' * + - / = ? ^ _ ` { | } ~
	*/
	private static function isEmailString(s:String):Boolean
	{
		if (Util.isBlank(s))
			return false;

		var notEmailChar:Array = Util.NOT_EMAIL_CHAR;
		if (notEmailChar == null)
		{
			notEmailChar = new Array();
			for (var i:Number=0; i<127; i++)
				notEmailChar[i] = false;
			var indices:Array = [34, 40, 41, 44, 58, 59, 60, 62, 91, 92, 93];
			for (var i:Number=0; i<11; i++)
				notEmailChar[indices[i]] = true;
		}

		var len:Number = s.length;
		var code:Number = null;
		for (var i:Number=0; i<len; i++)
		{
			code = s.charCodeAt(i);
			if (code < 33 || 126 < code || notEmailChar[code])
				return false;
		}
		return true;
	}

	/*
	* Return default value if the Object is null or undefined.
	*/
	public static function value(o:Object, defaultValue:Object):Object
	{
		return (o == null || o == undefined ? defaultValue : o);
	}

	/*
	* Replace all 'from' String 'to' to String within String 's'.
	*/
	public static function replaceAll(s:String, from:String, to:String):String
	{
		if (Util.isEmpty(s))
			return s;
		return s.toString().split(from).join(to);
	}

	/*
	* Remove all the blank character from the right and left of the String.
	*/
	public static function trim(s:String):String
	{
		if (Util.isEmpty(s))
			return "";

		s = s.toString();
		var whitespace:Object = Util.WHITESPACE;
		var sLen:Number = s.length;
		var i:Number = 0;
		var c:Number = s.charCodeAt(i);
		while (i < sLen && (c <= 32 || (whitespace["c" + c] == true) || (8192 <= c && c <= 8202)))
		{
			i++;
			c = s.charCodeAt(i);
		}

		var j:Number = sLen-1;
		c = s.charCodeAt(j);
		while (j > i && (c <= 32 || (whitespace["c" + c] == true) || (8192 <= c && c <= 8202)))
		{
			j--;
			c = s.charCodeAt(j);
		}
		return s.substring(i, j+1);
	}

	/*
	* Get data from the URL.
	*
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
	*/
	public static function loadURL(url:String, onLoadCB:Function, o:Object):Void
	{
		if (o == undefined || o == null)
			o = new Object();

		if (url == undefined || url == null)
		{
			o.status = -98;
			onLoadCB(false, null, o);
			return;
		}

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

		if (o.method == "GET")
			o.response = o.request;
		else
		{
			if (o.request.__proto__ == XML.prototype)
			{
				o.response = new XML();
				o.response.ignoreWhite = true;
			}
			else
				o.response = new LoadVars();
		}

		if (o.timeout == undefined || o.timeout == "" || isNaN(o.timeout) || typeof(o.timeout) != "number" || o.timeout < 0)
			o.timeout = 0;

		Util.doLoadURL(url, onLoadCB, o);
	}

	private static function doLoadURL(url:String, onLoadCB:Function, o:Object):Void
	{
		_global.clearTimeout(o.luTimeout);

		var httpStatus:Number = null;

		o.response.onHTTPStatus = function(stt:Number):Void
		{
			httpStatus = stt;
		}

		o.response.onData = function(data:String):Void
		{
			_global.clearTimeout(o.luTimeout);

			if (onLoadCB != undefined && onLoadCB != null)
			{
				if (o.target == "string")
				{
					this.loaded = true;
					onLoadCB((data != undefined), data, {url:url, o:o, httpStatus:httpStatus, status:o.response.status});
				}
				else if (o.target == "xml")
				{
					var xmlParser:XML = new XML();
					xmlParser.ignoreWhite = true;
					xmlParser.parseXML(data);
					this.loaded = true;
					onLoadCB((data != undefined), xmlParser, {url:url, o:o, httpStatus:httpStatus, status:xmlParser.status});
					delete xmlParser.idMap;
					xmlParser = null;
				}
				else if (o.target == "loadvars")
				{
					var lvDecoder:LoadVars = new LoadVars();
					lvDecoder.decode(data);
					this.loaded = true;
					onLoadCB((data != undefined), lvDecoder, {url:url, o:o, httpStatus:httpStatus, status:0});
				}
			}
			onLoadCB = null;

			if (o.response.__proto__ == XML.prototype)
				delete o.response.idMap;
			o.response = null;
			if (o.request.__proto__ == XML.prototype)
				delete o.request.idMap;
			o.request = null;
		}

		if (o.method == "GET")
			o.request.load(url);
		else
			o.request.sendAndLoad(url, o.response);

		if (o.timeout > 0)
		{
			o.luTimeout = _global.setTimeout(function():Void
			{
				_global.clearTimeout(o.luTimeout);

				o.response.onData = null;
				o.response.onLoad = null;
				o.response.loaded = true;
				if (onLoadCB != undefined && onLoadCB != null)
					onLoadCB(false, null, {url:url, o:o, httpStatus:0, status:-99});
				onLoadCB = null;

				if (o.response.__proto__ == XML.prototype)
					delete o.response.idMap;
				o.response = null;
				if (o.request.__proto__ == XML.prototype)
					delete o.request.idMap;
				o.request = null;
			}, o.timeout);
		}
	}

	private static var HTML_ESC:Array = [["&amp;", "&"], ["&gt;", ">"], ["&lt;", "<"], ["&quot;", '"'], ["&apos;", "'"]];

	/*
	* Escape HTML characters.
	*
	* @param str str to convert.
	*/
	public static function escapeHTML(s:String):String
	{
		var s2:String = s;
		var esc:Array = Util.HTML_ESC;
		var esc2:Array = null;
		var len:Number = esc.length;

		for (var i = 0; i < len; i++)
		{
			esc2 = esc[i];
			s2 = s2.split(esc2[0]).join(esc2[1]);
		}

		return s2;
	}
}