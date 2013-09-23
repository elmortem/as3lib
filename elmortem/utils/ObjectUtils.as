package elmortem.utils {
	
	public class ObjectUtils {
		
		static public function print(o:Object):void {
			trace(_trace(o, 0));
		}
		static private function _trace(o:Object, wave:int):void {
			var s:String = "";
			var i:int = 0;
			for (var key:String in o) {
				if (i > 0) s += "\n";
				for (var i:int = 0; i < wave; i++) {
					s += "\t";
				}
				s+key+" = "o[key];
			}
			return s;
		}
	}
}