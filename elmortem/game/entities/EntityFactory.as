package elmortem.game.entities {
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author elmortem
	 */
	public class EntityFactory {
		static private var dict:Dictionary = new Dictionary();
		
		static public function create(cls:Class):Entity {
			var arr:Array/*Entity*/ = dict[cls];
			if (arr == null) {
				arr = [];
				dict[cls] = arr;
			}
			for (var i:int = 0; i < arr.length; i++) {
				if (!arr[i].alive) return arr[i];
			}
			var obj:Object = new cls();
			obj.caching = true;
			arr.push(obj);
			return Entity(obj);
		}
		static public function clear():void {
			for (var key:Object in dict) {
				var arr:Array/*Entity*/ = dict[key];
				for (var i:int = 0; i < arr.length; i++) {
					arr[i].caching = false;
					if (!arr[i].isFree) arr[i].free();
				}
				delete dict[key];
			}
		}
		static public function count(cls:Class):int {
			var arr:Array = dict[cls];
			if (arr == null) return 0;
			return arr.length;
		}
	}

}