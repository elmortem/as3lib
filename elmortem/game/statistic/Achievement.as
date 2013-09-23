package elmortem.game.statistic {
	import elmortem.core.Config;
	import flash.events.EventDispatcher;
	
	public class Achievement extends EventDispatcher {
		public static const LESS:int = 0;
		public static const MORE:int = 1;
		public static const EQUAL:int = 2;
		public static const LESSEQUAL:int = 3;
		public static const MOREEQUAL:int = 4;
		
		private var achieves:Array = [];
		
		public function Achievement() {
		}
		
		public function add(varName:String, value:int, type:int, id:*, is_auto_success:Boolean = true):Boolean {
			achieves.push( { name:varName, value:value, type:type, id:id, is_success:(is_auto_success && Config.getVar("elmortem__achievement__" + id, false)) } );
			return true;
		}
		public function find(id:*):Object {
			for (var i:int = 0; i < achieves.length; i++) {
				if (achieves[i].id == id) return achieves[i];
			}
			return null;
		}
		public function isSuccess(id:*):Boolean {
			var o:Object = find(id);
			if (o != null) return o.is_success;
			return false;
		}
		public function setSuccess(id:*, val:Boolean = true):void {
			var o:Object = find(id);
			if(o != null) o.is_success = val;
		}
		public function getList():Array {
			return achieves;
		}
		public function get count():int {
			return achieves.length;
		}
		public function get countSuccess():int {
			var res:int = 0;
			for (var i:int = 0; i < achieves.length; i++) {
				if (achieves[i].is_success) res++;
			}
			return res;
		}
		
		public function reset():void {
			for (var i:int = 0; i < achieves.length; i++) {
				achieves[i].is_success = Config.getVar("elmortem__achievement__" + achieves[i].id, false);
			}
		}
		
		public function onVarChange(e:StatisticEvent):void {
			//trace("change " + e.name + " = " + e.value);
			for(var i:int = 0; i < achieves.length; i++) {
				if (achieves[i].name != e.name) continue;
				//trace(e.name + ", test value " + e.value);
				if (achieves[i].is_success) continue;
				if((achieves[i].type == LESS && achieves[i].value > e.value) || 
					(achieves[i].type == MORE && achieves[i].value < e.value) ||
					(achieves[i].type == EQUAL && achieves[i].value == e.value) ||
					(achieves[i].type == LESSEQUAL && achieves[i].value >= e.value) ||
					(achieves[i].type == MOREEQUAL && achieves[i].value <= e.value)) {
					//trace("! "+achieves[i].value);
					Config.setVar("elmortem__achievement__" + achieves[i].id, true);
					achieves[i].is_success = true;
					dispatchEvent(new AchievementEvent(achieves[i].id, AchievementEvent.UNLOCK));
				}
			}
		}
	}
}