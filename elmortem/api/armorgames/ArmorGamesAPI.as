package elmortem.api.armorgames {
	import elmortem.api.BaseAPI;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;


	public class ArmorGamesAPI extends BaseAPI {
		
		// Kongregate API reference
		private var clip:Sprite;
		private	var agi:Object = null;
		private var onReady:Function = null;
		private var devKey:String;
		private var gameKey:String;
		
		public function ArmorGamesAPI(clip:Sprite, devKey:String, gameKey:String, onReady:Function = null) {
			this.onReady = onReady;
			this.devKey = devKey;
			this.gameKey = gameKey;
			this.clip = clip;
			
			// URL to the AGI swf.
			var agi_url:String = "http://agi.armorgames.com/assets/agi/AGI.swf";
			Security.allowDomain(agi_url);

			// Load the AGI
			var urlRequest:URLRequest = new URLRequest(agi_url);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
			loader.load( urlRequest );
		}
		
		// This function is called when loading is complete
		private function loadComplete(e:Event):void {
			agi = e.currentTarget.content;
 
			// Add the AGI as a child to your document class or lowest level display object (required)
			clip.addChild(agi as DisplayObject);

			// Initialize the AGI with your developer key and game key
			agi.init(devKey, gameKey, onError, CONFIG::debug);
			agi.initAGUI({onClose:_hideLB});
			
			if (onReady != null) onReady(true);
		}
		private function onError(s:String):void {
			trace(s);
		}
		
		override public function getNickname():String {
			if (agi == null) {
				return "anonymous";
			} else {
				return agi.getUserName();
			}
		}
		override public function sendScore(Score:int, Mode:String = "Scores"):void {
			if (agi == null) return;
			agi.showScoreboardSubmit(Score, getNickname());
			_showLB();
		}
		override public function showLeaderboard(Mode:String = null):void {
			agi.showScoreboardList();
			_showLB();
		}
		private function _showLB():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_SHOW));
			//addEventListener(Event.ENTER_FRAME, onLBVisible);
		}
		private function _hideLB():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_HIDE));
		}
		/*private function onLBVisible():void {
			if (!agi.isAGUIVisible()) {
				clip.stage.focus = clip.stage;
				dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_HIDE));
				removeEventListener(Event.ENTER_FRAME, onLBVisible);
			}
		}*/
	}
}