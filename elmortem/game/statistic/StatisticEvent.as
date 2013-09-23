package elmortem.game.statistic {
	import flash.events.Event;
	
	public class StatisticEvent extends Event {
		public static const CHANGE:String = "statistic.change";
		
		public var name:String;
		public var value:int;
		
		public function StatisticEvent(name:String, value:int, type:String) {
			super(type, false, false);
			this.name = name;
			this.value = value;
		}
		override public function clone():Event {
			return new StatisticEvent(name, value, type);
		}
	}
}