package elmortem.api.newgrounds {
	import com.greensock.TweenLite;
	import com.newgrounds.API;
	import com.newgrounds.APIEvent;
	import elmortem.api.BaseAPI;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class NewgroundsAPI2 extends BaseAPI {
		private var stage:Stage;
		private var _onLoad:Function;
		
		public function NewgroundsAPI2(stage:Stage, apiId:String, encryptionKey:String, movieVersion:String = "", OnLoad:Function = null) {
			super();
			this.stage = stage;
			_onLoad = OnLoad;
			API.connect(stage, apiId, encryptionKey, movieVersion);
			API.addEventListener(APIEvent.API_CONNECTED, onConnected);
		}
		
		private function onConnected(e:Event):void {
			if (_onLoad != null) _onLoad();
		}
		
		override public function unlockAchievement(Id:Object):void {
			if (!API.connected) {
				TweenLite.delayedCall(3, unlockAchievement, [Id]);
				return;
			}
			
			API.unlockMedal(Id as String);
		}
		override public function sendScore(Score:int, Mode:String = null):void {
			if (!API.connected) {
				TweenLite.delayedCall(3, sendScore, [Score, Mode]);
				return;
			}
			
			if (Mode == null) Mode = "Scores";
			
			API.postScore(Mode, Score);
		}
		override public function showLeaderboard(Mode:String = null):void {
			//...
		}
		
		private function onLeaderboardDisplay():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_SHOW));
		}
		private function onLeaderboardClose():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_HIDE));
		}
	}
}