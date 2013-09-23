package elmortem.api.mochi {
	import elmortem.api.BaseAPI;
	import flash.events.Event;
	import mochi.as3.MochiScores;
	import mochi.as3.MochiServices;
	
	public class MochiAPI2 extends BaseAPI {
		
		public function MochiAPI2() {
			super();
		}
		override public function sendScore(Score:int, Mode:String = null):void {
			MochiScores.showLeaderboard({boardID:Mode, score:Score, onDisplay:onLeaderboardDisplay, onClose:onLeaderboardClose});
		}
		override public function showLeaderboard(Mode:String = null):void {
			MochiScores.showLeaderboard({boardID:Mode, onDisplay:onLeaderboardDisplay, onClose:onLeaderboardClose});
		}
		
		private function onLeaderboardDisplay():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_SHOW));
		}
		private function onLeaderboardClose():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_HIDE));
		}
	}
}