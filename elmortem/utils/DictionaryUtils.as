package elmortem.utils {
	import flash.utils.Dictionary;
	
	public class DictionaryUtils {
		
		static public function length(dict:Dictionary):int {
			var res:int = 0;
			for (var key:* in dict) {
				++res;
			}
			return res;
		}
		
		static public function keys(dict:Dictionary):Array {
			var arr:Array = new Array();
			for (var key:* in dict) {
				arr.push(key);
			}
			return arr;
		}
	}
}