package elmortem.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	public class SpriteUtils {
		
		static public function toFront(clip:DisplayObject):void {
			if (clip == null || clip.parent == null) return;
			clip.parent.setChildIndex(clip, clip.parent.numChildren - 1);
		}
		static public function toBack(clip:DisplayObject):void {
			if (clip == null || clip.parent == null) return;
			clip.parent.setChildIndex(clip, 0);
		}
		static public function resize(clip:DisplayObject, maxWidth:Number, maxHeight:Number, upScale:Boolean = false):void {
			if (clip == null) return;
			
			var k:Number = Math.min(maxHeight / clip.height, maxWidth / clip.width);
			if (k <= 1 || upScale)
			{
				clip.width *= k;
				clip.height *= k;
			}
		}
		static public function position(clip:DisplayObject, x:Number, y:Number, width:Number, height:Number):void {
			clip.x = x + (width - clip.width) * 0.5;
			clip.y = y + (height - clip.height) * 0.5;
		}
		static public function positionInRect(clip:DisplayObject, rect:Rectangle):void {
			position(clip, rect.x, rect.y, rect.width, rect.height);
		}
		static public function setInRect(clip:DisplayObject, rect:Rectangle, positionLeft:String = "left", positionTop:String = "top", upScale:Boolean = true):void {
			resize(clip, rect.width, rect.height, upScale);
			var r:Rectangle = clip.getBounds(clip);
			clip.x = rect.x - r.x * clip.scaleX;
			clip.y = rect.y - r.y * clip.scaleY;
			if (positionLeft == "right") {
				clip.x += rect.width - clip.width;
			} else if (positionLeft == "center") {
				clip.x += (rect.width - clip.width) * 0.5;
			}
			if (positionTop == "bottom") {
				clip.y += rect.height - clip.height;
			} else if (positionTop == "middle") {
				clip.y += (rect.height - clip.height) * 0.5;
			}
		}
		static public function stopAll(Clip:DisplayObjectContainer = null):void {
			if (Clip != null) {
				var mc:MovieClip = Clip as MovieClip;
				if (mc != null) {
					mc.stop();
				}
			}
			var contLength:int = Clip.numChildren;
			var Child:DisplayObjectContainer;
			for (var i : int = 0; i < contLength; i++) {
				Child = Clip.getChildAt(i) as DisplayObjectContainer;
				if (Child != null) {
					stopAll(Child);
				}
			}
		}
		static public function removeAllChilds(Clip:DisplayObjectContainer):void {
			if (Clip == null) return;
			var n:int = 0;
			while (Clip.numChildren > n) {
				try {
					Clip.removeChildAt(n);
				} catch (err:Error) {
					n++;
				}
			}
		}
		
		static public function cacheAsBitmap(Clip:DisplayObjectContainer):void {
			var bound:Rectangle = Clip.getBounds(Clip);
			var bd:BitmapData = new BitmapData(bound.width, bound.height, true, 0x00ffffff);
			var tx:Number = Clip.x;
			var ty:Number = Clip.y;
			var tr:Number = Clip.rotation;
			Clip.x = -bound.x;
			Clip.y = -bound.y;
			Clip.rotation = 0;
			bd.draw(Clip, Clip.transform.matrix);
			var bmp:Bitmap = new Bitmap(bd, "auto", true);
			bmp.x = bound.x;
			bmp.y = bound.y;
			//bmp.alpha = 0;
			removeAllChilds(Clip);
			Clip.addChild(bmp);
			Clip.x = tx;
			Clip.y = ty;
			Clip.rotation = tr;
		}
		
		static public function setBrightness(Clip:DisplayObject, Brightness:Number):void {
			if (Brightness > 1) Brightness = 1;
			if (Brightness < -1) Brightness = -1;
			var colorTrans:ColorTransform = Clip.transform.colorTransform;
			colorTrans.redMultiplier = colorTrans.greenMultiplier = colorTrans.blueMultiplier = 1 - Math.abs(Brightness);
			colorTrans.redOffset = colorTrans.greenOffset = colorTrans.blueOffset = (Brightness > 0) ? Brightness * 256 : 0;
			Clip.transform.colorTransform = colorTrans;
		}
	}
}