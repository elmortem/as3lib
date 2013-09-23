package elmortem.utils {
	import flash.geom.ColorTransform;
	
	public class ColorUtils {
		
		static public function ARGB(rgb:uint, alpha:uint):uint{
			/*var argb:uint = 0;
			argb += (alpha << 24);
			argb += (rgb);*/
			return R(rgb) | G(rgb) << 8 | B(rgb) << 16 | alpha << 24;
		}
		static public function A(argb:uint):uint {
			return argb >> 24 & 0xFF;
		}
		static public function R(argb:uint):uint {
			return argb >> 16 & 0xFF;
		}
		static public function G(argb:uint):uint {
			return argb >> 8 & 0xFF;
		}
		static public function B(argb:uint):uint {
			return argb & 0xFF;
		}
		static public function RGBA(r:uint, g:uint, b:uint, a:uint = 0):uint {
			r = Math.min(255, r);
			g = Math.min(255, g);
			b = Math.min(255, b);
			a = Math.min(255, a);
			return r | g << 8 | b << 16 | a << 24; 
		}
		
		static public function interpolateColorTransform(start:ColorTransform, end:ColorTransform, t:Number):ColorTransform {
			var result:ColorTransform = new ColorTransform();
			result.redMultiplier = start.redMultiplier + (end.redMultiplier - start.redMultiplier) * t;
			result.greenMultiplier = start.greenMultiplier + (end.greenMultiplier - start.greenMultiplier) * t;
			result.blueMultiplier = start.blueMultiplier + (end.blueMultiplier - start.blueMultiplier) * t;
			result.alphaMultiplier = start.alphaMultiplier + (end.alphaMultiplier - start.alphaMultiplier) * t;
			result.redOffset = start.redOffset + (end.redOffset - start.redOffset) * t;
			result.greenOffset = start.greenOffset + (end.greenOffset - start.greenOffset) * t;
			result.blueOffset = start.blueOffset + (end.blueOffset - start.blueOffset) * t;
			result.alphaOffset = start.alphaOffset + (end.alphaOffset - start.alphaOffset) * t;
			return result;
		}
	}
}