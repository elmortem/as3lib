package elmortem.utils {

	public class AngleUtils {
		public static const PI2:Number = Math.PI * 2;
		public static const RAD_TO_DEG:Number = 180 / Math.PI; // 57.29577951;
		public static const DEG_TO_RAD:Number = Math.PI / 180;
		
		static public function approach(val:Number, a:Number, a_to:Number):Number { // a=5, a_to=355, tmp=-350(350)
			var tmp:Number = a - a_to;
			if(tmp > 0) {
				if (tmp < 180) {
					if (tmp <= val) return normal(a_to);
					return normal(a - val);
				} else {
					if (360 - tmp <= val) return normal(a_to);
					return normal(a + val);
				}
			} else if(tmp < 0) {
				tmp = -tmp;
				if (tmp < 180) {
					if (tmp <= val) return normal(a_to);
					return normal(a + val);
				} else {
					if (360 - tmp <= val) return normal(a_to);
					return normal(a - val);
				}
			} else
				return normal(a_to);
		}
		static public function approachRad(val:Number, a:Number, a_to:Number):Number {
			var tmp:Number = a - a_to;
			if(tmp > 0) {
				if (tmp < Math.PI) {
					if (tmp <= val) return normalRad(a_to);
					return normalRad(a - val);
				} else {
					if (PI2 - tmp <= val) return normalRad(a_to);
					return normalRad(a + val);
				}
			} else if (tmp < 0) {
				tmp = -tmp;
				if (tmp < Math.PI) {
					if (tmp <= val) return normalRad(a_to);
					return normalRad(a + val);
				} else {
					if (PI2 - tmp <= val) return normalRad(a_to);
					return normalRad(a - val);
				}
			} else
				return normal(a_to);
		}
		static public function normal(a:Number):Number {
			if(a >= 360) return a - 360;
			else if(a < 0) return a + 360;
			return a;
		}
		static public function normalRad(a:Number):Number {
			if (a >= PI2) return a - PI2;
			else if (a < 0) return a + PI2;
			return a;
		}
		static public function delta(a1:Number, a2:Number, abs:Boolean = false):Number {
			var tmp:Number = normal(a2) - normal(a1);
			if (tmp > 0) {
				if(tmp > 180)
					tmp = 360 - tmp;
			} else if (tmp < 0) {
				if(tmp < -180)
					tmp = 360 + tmp;
			} else
				tmp = 0;
				
			if (abs && tmp < 0) tmp = -tmp;
			return tmp;
		}
		/*static public function diff(a1:Number, a2:Number):Number {
			var a:Number = normal(a2) - normal(a1);
			if (a < 0) a = -a;
			return 360 - a;
		}*/
		static public function toRad(deg:Number):Number {
			if (isNaN(deg)) return 0;
			return DEG_TO_RAD * deg;
		}
		static public function toDeg(rad:Number):Number {
			if (isNaN(rad)) return 0;
			return rad * RAD_TO_DEG;
		}
		
		static public function sin(x:Number):Number {
			var sin:Number;
			if (x < -3.14159265)
				x += 6.28318531;
			else if (x >  3.14159265)
				x -= 6.28318531;
			if (x < 0) {
				sin = 1.27323954 * x + .405284735 * x * x;

				if (sin < 0)
					sin = 0.225 * (sin *-sin - sin) + sin;
				else
					sin = 0.225 * (sin * sin - sin) + sin;
			} else {
				sin = 1.27323954 * x - 0.405284735 * x * x;

				if (sin < 0)
					sin = 0.225 * (sin *-sin - sin) + sin;
				else
					sin = 0.225 * (sin * sin - sin) + sin;
			}
			return sin;
		}
		static public function cos(x:Number):Number {
			var cos:Number;
			x += 1.57079632;
			if (x >  3.14159265)
				x -= 6.28318531;

			if (x < 0) {
				cos = 1.27323954 * x + 0.405284735 * x * x;

				if (cos < 0)
					cos = 0.225 * (cos *-cos - cos) + cos;
				else
					cos = 0.225 * (cos * cos - cos) + cos;
			} else {
				cos = 1.27323954 * x - 0.405284735 * x * x;

			if (cos < 0)
				cos = 0.225 * (cos *-cos - cos) + cos;
			else
				cos = 0.225 * (cos * cos - cos) + cos;
			}
			return x;
		}
	}
}