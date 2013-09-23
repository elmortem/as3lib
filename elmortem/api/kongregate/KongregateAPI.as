package elmortem.api.kongregate {
	import elmortem.api.BaseAPI;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;


	public class KongregateAPI extends BaseAPI {
		
		// Kongregate API reference
		private	var kongregate:Object = null;
		private var onReady:Function = null;
		
		public function KongregateAPI(clip:Sprite, onReady:Function = null) {
			this.onReady = onReady;
			// Pull the API path from the FlashVars
			var paramObj:Object = LoaderInfo(clip.root.loaderInfo).parameters;
			 
			// The API path. The "shadow" API will load if testing locally. 
			var apiPath:String = paramObj.kongregate_api_path || 
				"http://www.kongregate.com/flash/API_AS3_Local.swf";
			 
			// Allow the API access to this SWF
			Security.allowDomain(apiPath);
			 
			// Load the API
			var request:URLRequest = new URLRequest(apiPath);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load(request);
			clip.addChild(loader);
		}
		
		// This function is called when loading is complete
		private function loadComplete(event:Event):void {
			// Save Kongregate API reference
			kongregate = event.target.content;
	 
			// Connect to the back-end
			kongregate.services.connect();
	 
			// You can now access the API via:
			// kongregate.services
			// kongregate.user
			// kongregate.scores
			// kongregate.stats
			// etc...
			
			if (onReady != null) onReady(true);
		}
		
		override public function getNickname():String {
			if (kongregate == null || kongregate.services == null || kongregate.services.isGuest()) {
				return "anonymous";
			} else {
				return kongregate.services.getUsername();
			}
		}
		override public function unlockAchievement(Id:Object):void {
			if (kongregate == null || kongregate.stats == null) return;
			kongregate.stats.submit(Id as String, 1);
		}
		override public function sendScore(Score:int, Mode:String = "Scores"):void {
			if (kongregate == null || kongregate.stats == null) return;
			kongregate.stats.submit(Mode, Score);
		}
	}
}