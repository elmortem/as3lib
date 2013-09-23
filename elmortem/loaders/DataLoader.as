package elmortem.loaders {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.LoaderContext;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author Osokin <elmortem> Makar
	 */
	public class DataLoader {
		static private var log:Function = null;
		
		static public function set logCallback(value:Function):void {
			log = value;
		}
		static public function loadImage(url:String, on_load:Function = null, on_progress:Function = null, on_error:Function = null):Loader {
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			
			var r:URLRequest = new URLRequest(url);
			
			try {
			Security.allowDomain(r.url);
			Security.allowDomain("*");
			Security.allowInsecureDomain(r.url);
			Security.allowInsecureDomain("*");
			} catch (err:Error) {
			}
			
			var loader:Loader = new Loader();
			if (on_load != null) loader.contentLoaderInfo.addEventListener(Event.COMPLETE, on_load);
			if (on_progress != null) loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, on_progress);
			if(on_error != null) loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, on_error);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			//loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			
			loader.load(r, context);
			return loader;
		}
		
		static public function loadData(url:String, params:Object, on_load:Function = null, on_progress:Function = null, on_error:Function = null, method:String = "POST"):URLLoader {
			var vars:URLVariables = new URLVariables();
			if (params) {
				for (var key:String in params) vars[key] = params[key];
			}
			vars.random = Math.floor(Math.random() * int.MAX_VALUE);
			
			var r:URLRequest = new URLRequest(url);
			try {
				Security.allowDomain(r.url);
			} catch (err:Error) {
				trace(err);
			}
			try {
				Security.allowDomain("*");
			} catch (err:Error) {
				trace(err);
			}
			try {
			Security.allowInsecureDomain(r.url);
			Security.allowInsecureDomain("*");
			} catch(err:Error) {}
			r.data = vars;
			r.method = method;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			if (on_load != null) loader.addEventListener(Event.COMPLETE, on_load, false, 0, true);
			if (on_progress != null) loader.addEventListener(ProgressEvent.PROGRESS, on_progress, false, 0, true);
			//loader.addEventListener(Event.COMPLETE, onXmlLoad);
			if (on_error != null) loader.addEventListener(IOErrorEvent.IO_ERROR, on_error, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIoError, false, 0, true);
			//loader.addEventListener(Event.COMPLETE, onLoad);
			//loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			
			loader.load(r);
			return loader;
		}
		/*static private function onLoad(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, onLoad);
			is_sending = false;
		}*/
		static private function onIoError(e:IOErrorEvent):void {
			/*Log.add("DataLoader - IO error.");
			Log.add(e.toString());
			try {
				//var ldr:Loader = e.target as Loader;
				Log.add("(loaderURL) "+(e.target.loaderInfo as LoaderInfo).loaderURL + " not loaded...");
			} catch (err:Error) {
				Log.add("a: "+err.message);
			}
			try {
				//var ldr:Loader = e.target as Loader;
				Log.add("(loaderURL) "+(e.target as LoaderInfo).loaderURL + " not loaded...");
				Log.add("(url) " + (e.target as LoaderInfo).url + " not loaded...");
				Log.add("(content_loaderURL) "+(e.target as LoaderInfo).loader.contentLoaderInfo.loaderURL + " not loaded...");
				Log.add("(content_url) " + (e.target as LoaderInfo).loader.contentLoaderInfo.url + " not loaded...");
			} catch (err:Error) {
				Log.add("b: "+err.message);
			}
			Log.add(e.text);*/
			trace(e.toString());
			if (log != null) log(e.toString());
		}
		static private function onHttpStatus(e:HTTPStatusEvent):void {
			try {
				e.currentTarget.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			} catch (err:Error) { }
			try {
				e.target.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatus);
			} catch(err:Error) {}
			if(e.status != 200) {
				//Log.add("HTTP Status: " + e.status, Log.CUSTOM);
				trace(e.toString());
				if (log != null) log(e.toString());
			}
		}
	}
}