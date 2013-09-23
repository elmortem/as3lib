package elmortem.utils {
	
	
	public class TimeUtils {
		
		static public function getHours(seconds:Number):int {
			return int(seconds / (60 * 60));
		}
		static public function getMinutes(seconds:Number):int {
			return int(seconds / 60);
		}
		static public function getSeconds(seconds:Number):int {
			return int(seconds);
		}
		static public function getMiliseconds(seconds:Number):int {
			return int(seconds * 1000);
		}
		static public function getTime(seconds:Number, ish:Boolean = false, ism:Boolean = false, isms:Boolean = false):String {
			var h:int = getHours(seconds);
			var m:int = getMinutes(seconds) - h * 60;
			var s:int = getSeconds(seconds) - m * 60 - h * 60 * 60;
			var ms:int = int(getMiliseconds(seconds - h * 60 * 60 - m * 60 - s) * 0.1);
			var r:String = "";
			if (h > 0 || ish) r += "" + NumberUtils.addZero(h, 2) + ":";
			if (m > 0 || ism) r += "" + NumberUtils.addZero(m, 2) + ":";
			r += "" + NumberUtils.addZero(s, 2);
			if(isms) r += ":" + NumberUtils.addZero(ms, 2);
			return r;
		}
	}
}