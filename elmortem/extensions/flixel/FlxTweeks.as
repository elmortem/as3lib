package elmortem.extensions.flixel  
{
	import org.flixel.FlxG;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	
	/**
	 * This is a utility class for enabling loading key/value pairs from a Google Spreadsheet into an Object.
	 */
	public final class FlxTweaks
	{
		
		public static function loadVars(obj:Object,spreadsheetURL:String,proxyURL:String,whenDoneFunc:Function=null,whenDoneFuncParams:Array=null):void
		{
			
			var ur:URLRequest = new URLRequest(proxyURL);
			ur.method = URLRequestMethod.POST;
			ur.data = new URLVariables();
			ur.data["_url"] = spreadsheetURL;
			
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, 
				function(e:Event):void 
				{
					FlxG.log("Tweak values received from Google spreadsheet!");
					
					var dataString:String = ((e.target as URLLoader).data) as String;
					
					var tweakXML:XML = new XML(dataString);
					
					// Extract the entries. It's namespaced, so deal with that.
					var xmlns:Namespace = new Namespace("xmlns", "http://www.w3.org/2005/Atom");
					tweakXML.addNamespace(xmlns);
					
					// Parse into our target object.
					for each(var entryXML:XML in tweakXML.xmlns::entry)
					{
						var key:String = entryXML.xmlns::title.toString();
						var value:String = entryXML.xmlns::content.toString();
						
						// This seems hacky! 
						// I have no idea why, but on my spreadsheet XML these characters appear 
						//	before every single value... rip them off!
						value = value.replace("_cokwr: ", "");
						
						obj[ key ] = value;
						
					}
					
					whenDoneFunc.apply(null, whenDoneFuncParams);
					
				}
			);
			
			var onLoadFail:Function =	function(e:Event):void
										{
											FlxG.log("Tweak values WERE NOT received from Google spreadsheet - using defaults! " + e);
											
											whenDoneFunc.apply(null, whenDoneFuncParams);
											
										};
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadFail);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadFail);
			
			loader.load(ur);
			
		}
		
		
	}

}