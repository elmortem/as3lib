package elmortem.utils {
	
	public class VectorUtils {
		
		static public function concatNoDublicatInt(v1:Vector.<int>, v2:Vector.<int>):Vector.<int> {
			var v:Vector.<int> = v1.concat(null); // !!!
			var i:int;
			var j:int;
			var len1:int = v1.length;
			var len2:int = v2.length;
			var inv:Boolean;
			for (j = 0; j < len2; ++j) {
				inv = false;
				for (i = 0; i < len1; ++i) {
					if (v1[i] == v2[j]) {
						inv = true;
						break;
					}
				}
				if (!inv) {
					v.push(v2[j]);
				}
			}
			return v;
		}
	}
}