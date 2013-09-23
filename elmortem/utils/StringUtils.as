package elmortem.utils {
	
	public class StringUtils {
		
		static public function replace(org:String, fnd:Object, rpl:Object):String {
			if(fnd is String) {
				return org.split(fnd).join(rpl);
			} else if (fnd is Array) {
				var s:String = org;
				for (var i:int = 0; i < fnd.length; i++) {
					if (rpl is Array) {
						s = replace(s, fnd[i], rpl[i % rpl.length]);
					} else {
						s = replace(s, fnd[i], rpl);
					}
				}
				return s;
			}
			
			return org;
		}
		static public function toBoolean(val:String, def:Boolean = false):Boolean {
			if (val == "true" || val == "1") return true;
			else if (val == "false" || val == "0") return false;
			return def;
		}
		static public function isBoolean(val:String):Boolean {
			if (val == "true" || val == "false") return true;
			return false;
		}
		
		static public function levenshtein(s1:String, s2:String):int {		
			if (s1.length == 0 || s2.length == 0) return 0;

			var m:uint = s1.length + 1;
			var n:uint = s2.length + 1;
			var i:uint, j:uint, cost:uint;
			var d:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();

			for (i = 0; i < m; i++) {
				d[i] = new Vector.<int>();
				for (j = 0; j < n; j++)
				d[i][j] = 0;
			}

			for (i = 0; i < m; d[i][0] = i++) {};
			for (j = 0; j < n; d[0][j] = j++) {};

			for (i = 1; i < m; i++) {
				for (j = 1; j < n; j++)
				{       
					cost = (s1.charAt(i - 1) == s2.charAt(j - 1)) ? 0 : 1;
					d[i][j] = Math.min(Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1), d[i - 1][j - 1] + cost);
				}
			}
			return d[m-1][n-1];
    }
		
		static public function comparison(s1:String, s2:String):Number {
			var val:Number = levenshtein(s1, s2);
			var len:Number = s1.length;
			val -= s2.length - len;
			if (val < 0) val = len;
			return (len - val) / len;
		}
		
		static public function trim(s:String):String {
			//return s.replace(/^([\s|\t|\n|\r]+)?(.*)([\s|\t|\n|\r]+)?$/gm, "$2");
			return s.replace(/^\s+|\s+$/g, "");
			//return s.replace(/^\t*|\s*|\t*|\s*$/g, "");
		}
		
		static public function formatMoney(m:int, chr:String = " ", cnt:int = 3):String {
			var s:String = "" + m;
			var ss:String = "";
			for (var i:int = s.length-1; i >= 0; i--) {
				ss = s.charAt(i) + ss;
				if (i > 0 && i < s.length - 1 && (s.length - i) % cnt == 0) {
					ss = chr + ss;
				}
			}
			return ss;
		}
		static public function formatTime(time:Number, sec:Boolean = false, min:Boolean = true, hour:Boolean = true, day:Boolean = false):String {
			if (time < 0) time = 0;
			var res:String = "";
			if (sec) {
				res = ""+NumberUtils.addZero(int(time) % 60, 2);
			}
			if (min) {
				if (sec) res = ":" + res;
				res = NumberUtils.addZero(int(time / 60) % 60, 2) + res;
			}
			if (hour) {
				if (min) res = ":" + res;
				else if (sec) res = " hour " + res + " sec";
				res = NumberUtils.addZero(int(time / 60 / 60 / 60) * 60, 2) + res;
			}
			if (day) {
				res = (int(time / 60 / 60 / 60 / 24) * 60) + " day " + res;
			}
			
			return res;
		}
	}
}