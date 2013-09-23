package elmortem.utils {
	import flash.display.Stage;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;

	public class UrlUtils {
		static private var E101:int = 101;
		static private var ENONE:String = "";
		static public var stage:Stage;
		
		static public function init(stage:Stage):void {
			UrlUtils.stage = stage;
		}
		
		static public function getDomain(stage:Stage, sub:Boolean = true):String {
			if (stage == null) stage = UrlUtils.stage;
			if (stage == null) return null;
			
			var url:String = stage["loa"+"d"+String.fromCharCode(E101)+"rIn"+ENONE+"fo"]["l"+"oad"+String.fromCharCode(E101)+"rU"+"RL"];
			var urlStart:Number = url.indexOf("://")+3;
			var urlEnd:Number = url.indexOf("/", urlStart);
			var domain:String = url.substring(urlStart, urlEnd);
			if (domain == "") domain = "local";
			if (sub) return domain;
			var LastDot:Number = domain.lastIndexOf(".")-1;
			var domEnd:Number = domain.lastIndexOf(".", LastDot)+1;
			domain = domain.substring(domEnd, domain.length);
			return domain;
		}
		
		static public function isUrl(urls:/*String*/Array, stage:Stage = null, sub:Boolean = false):Boolean {
			if (stage == null) stage = UrlUtils.stage;
			if (stage == null) return false;
			var domain:String = getDomain(stage, sub);
			if (domain == null) return false;
			
			var i:int;
			if (sub) {
				for (i = 0; i < urls.length; i++) {
					if (domain.indexOf(urls[i]) >= 0) {
						return true;
					}
				}
			} else {
				for (i = 0; i < urls.length; i++) {
					if (urls[i].indexOf(domain) >= 0) {
						return true;
					}
				}
			}
			
			/*for (i = 0; i < urls.length; i++) {
				//if (domain.indexOf(urls[i]) >= 0) {
				if (domain == urls[i]) {
					return true;
				}
			}*/
			return false;
		}
		static public function open(url:String, target:String = "_blank"):Boolean {
			var req:URLRequest = new flash.net.URLRequest(url);
			try {
				if(target == null)
					navigateToURL(req);
				else
					navigateToURL(req, target);
			} catch (err:String) {
				trace(err);
				return false;
			}
			return true;
		}
	}
}