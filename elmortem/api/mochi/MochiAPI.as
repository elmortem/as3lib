package elmortem.api.mochi {
	import elmortem.api.BaseAPI;
	import flash.events.Event;
	import mochi.as3.MochiScores;
	import mochi.as3.MochiServices;
	
	public class MochiAPI extends BaseAPI {
		private var boardID:String;
		
		public function MochiAPI(BoardID:String) {
			super();
			boardID = BoardID;
		}
		override public function sendScore(Score:int, Mode:String = null):void {
			//MochiScores.submit(score, null);
			MochiScores.showLeaderboard({boardID:boardID, score:Score, onDisplay:onLeaderboardDisplay, onClose:onLeaderboardClose});
		}
		override public function showLeaderboard(Mode:String = null):void {
			MochiScores.showLeaderboard({boardID:boardID, onDisplay:onLeaderboardDisplay, onClose:onLeaderboardClose});
		}
		
		private function onLeaderboardDisplay():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_SHOW));
		}
		private function onLeaderboardClose():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_HIDE));
		}
	}
}