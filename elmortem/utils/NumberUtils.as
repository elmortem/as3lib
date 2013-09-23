package elmortem.utils {
	
	public class NumberUtils {
		static public var lastApproach:Number = 0;
		
		public static function addZero(n:int, z:int):String {
			var c:int = z - Math.floor(n / 10) - 1;
			var s:String = "";
			for (var i:int = 0; i < c; i++) {
				s += "0";
			}
			return s + n;
		}
		public static function approach(val:Number, f1:Number, f2:Number):Number { // f1 - begin, f2 - end
			lastApproach = 0;
			var tmp:Number = f1 - f2;
			if(tmp > 0) {
				if (tmp < val) {
					lastApproach = val - tmp;
					return f2;
				} else
					return f1 - val;
			} else if(tmp < 0) {
				tmp = -tmp;
				if (tmp < val) {
					lastApproach = val - tmp;
					return f2;
				} else
					return f1 + val;
			} else
				return f2;
		}
		
		static public function equal(n1:Number, n2:Number, diff:Number = 0):Boolean {
			if(diff == 0) return n1 == n2;
			return Math.abs(n1 - n2) <= diff
		}
		
		static public function sign(x:Number):int {
			if (x >= 0) return 1;
			else return -1;
		}
		static public function signZero(x:Number):int {
			if (equal(x, 0, 0.001)) return 0; 
			if (x > 0) return 1;
			else return -1;
		}
	}
}