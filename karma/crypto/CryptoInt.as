package karma.crypto {
	import com.adobe.crypto.MD5;
	import mochi.as3.MochiDigits;
	
	public class CryptoInt {
		private var _value:int;
		private var __value:String;
		private var ___value:String;
		private var ____value:MochiDigits;
		
		public function CryptoInt(def:int = 0) {
			____value = new MochiDigits(def);
			value = def;
		}
		
		public function get value():int {
			if(MD5.hash(""+(_value + 745)) == __value && MD5.hash(""+(_value - 392) + __value) == ___value && _value == ____value.value) {
				return ____value.value;
			} else {
				return 0;
			}
		}
		public function set value(v:int):void {
			_value = v;
			__value = MD5.hash(""+(_value + 745));
			___value = MD5.hash(""+(_value - 392) + __value);
			____value.value = v;
		}
		
		public function get hacked():Boolean {
			return !(MD5.hash(""+(_value + 745)) == __value && MD5.hash(""+(_value - 392) + __value) == ___value && _value == ____value.value);
		}
		
		public function get code():String {
			if(!hacked) {
				return "CInt:" + (_value + 1582) + ":" + __value + ":" + ___value + "";
			} else {
				value = 0;
				return code;
			}
		}
		public function set code(v:String):void {
			if (v == "" || v == null) return;
			var ss:Array = v.split(":");
			if (ss[0] == "CInt" && MD5.hash("" + (int(ss[1]) - 1582 + 745)) == ss[2] && MD5.hash(""+(int(ss[1]) - 1582 - 392) + ss[2]) == ss[3]) {
				value = int(ss[1]) - 1582;
			} else {
				value = 0;
			}
		}
	}
}