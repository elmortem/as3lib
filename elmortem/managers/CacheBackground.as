package elmortem.managers {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class CacheBackground extends Sprite {
		private var bmp:Bitmap;
		private var bmpData:BitmapData;
		
		public function CacheBackground(width:int, height:int, transparent:Boolean = false) {
			super();
			
			bmpData = new BitmapData(width, height, transparent, 0x00000000);
			//bmpData.fillRect(bmpData.rect, 0x00ffffff);
			bmp = new Bitmap(bmpData, PixelSnapping.ALWAYS, true);
			super.addChild(bmp);
		}
		
		public function add(clip:DisplayObject):void {
			bmpData.draw(clip, clip.transform.matrix, clip.transform.colorTransform, null, null, true);
		}
	}

}