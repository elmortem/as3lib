package elmortem.api {
	import flash.events.EventDispatcher;


	public class BaseAPI extends EventDispatcher {
		//static public const EVENT_READY:String = "ScoreAPI.Ready";
		static public const EVENT_LEADERBOARD_SHOW:String = "ScoreAPI.LeaderboardShow";
		static public const EVENT_LEADERBOARD_HIDE:String = "ScoreAPI.LeaderboardHide";
		
		static private var instance:BaseAPI = null;
		
		static public function getApi():BaseAPI {
			if (instance == null) instance = new BaseAPI();
			return instance;
		}
		
		public function BaseAPI() {
			instance = this;
		}
		public function init(attr:Object):void {
		}
		public function setNickname(Nickname:String):void {
		}
		public function getNickname():String {
			return "anonymous";
		}
		public function sendScore(Score:int, Mode:String = null):void {
		}
		public function unlockAchievement(Id:Object):void {
		}
		public function showLeaderboard(Mode:String = null):void {
		}
		public function loadStat(name:String):int {
			return 0;
		}
		public function getParam(name:String, on_value:Function = null):Object {
			return null;
		}
		public function submitStat(name:String, value:int):void {
		}
	}
}