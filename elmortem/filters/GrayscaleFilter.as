package elmortem.filters {
	import flash.filters.ColorMatrixFilter;
	
	
	public class GrayscaleFilter {
		
		static private var mtx:Array = null;
		
		static public function get matrix():Array {
			if (mtx == null) {
				var b:Number = 1 / 3;
				var c:Number = 1 - (b * 2);
				mtx = [
					c, b, b, 0, 0,
					b, c, b, 0, 0,
					b, b, c, 0, 0,
					0, 0, 0, 1, 0
				];
			}
			return mtx;
		}
		static public function getFilter():ColorMatrixFilter {
			return new ColorMatrixFilter(matrix);
		}
	}
}