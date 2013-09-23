package elmortem.game.statistic {
	import flash.events.*;
	
	public class AchievementEvent extends Event {
		public static const UNLOCK:String = "achievement.add";
		public static const ADD:String = UNLOCK;
		
		public var id:*;
		
		public function AchievementEvent(id:*, type:String) {
			super(type, false, false);
			this.id = id;
		}
	}
}