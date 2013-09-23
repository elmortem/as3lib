package elmortem.game.statistic {
	import elmortem.core.Config;
	import flash.events.EventDispatcher;
	
	public class Statistic extends EventDispatcher {
		static public const NONE:int = 0;
		static public const MORE:int = 1;
		
		protected var vars:Object;
		public var enabled:Boolean;
		
		private var event_change:StatisticEvent;
		
		public function Statistic():void {
			vars = { };
			enabled = true;
			event_change = new StatisticEvent("", 0, StatisticEvent.CHANGE);
		}
		public function free():void {
			vars = null;
		}
		public function clear():void {
			vars = { };
		}
		public function setVar(name:String, value:int, equal:int = NONE):void {
			if (!enabled) return;
			trace("set " + name + ": " + value);
			if(equal == NONE || (equal == MORE && vars[name] < value)) {
				vars[name] = value;
				event_change.name = name;
				event_change.value = value;
				dispatchEvent(event_change);
				//dispatchEvent(new StatisticEvent(name, value, StatisticEvent.CHANGE));
			}
		}
		public function addVar(name:String, value:int = 1):void {
			if (!enabled) return;
			setVar(name, int(vars[name]) + value);
		}
		public function getVar(name:String):int {
			return vars[name];
		}
		public function save():void {
			Config.setVar("elmortem__statistic", vars);
		}
		public function load():void {
			vars = Config.getVar("elmortem__statistic", {});
			if(vars == null) vars = { };
		}
	}
}