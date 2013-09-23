package elmortem.preloaders {
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class PreloaderBar extends Sprite {
		private var gfx:DisplayObject;
		private var msk:Sprite;
		
		
		public function PreloaderBar() {
			gfx = null;
			msk = null;
		}
		public function initWidthGfx(Gfx:DisplayObject):void {
			gfx = Gfx;
			addChild(gfx);
			gfx.x = 0;
			gfx.y = 0;
			msk = new Sprite();
			addChild(msk);
			msk.graphics.lineStyle();
			msk.graphics.beginFill(0x00);
			msk.graphics.drawRect(0, 0, gfx.width, gfx.height);
			msk.graphics.endFill();
			cacheAsBitmap = true;
			mask = msk;
			msk.cacheAsBitmap = true;
			msk.scaleX = 0.001;
		}
		public function init(Color:uint, Width:int, Height:int):void {
			addChild(gfx = new Sprite());
			var g:Graphics = (gfx as Sprite).graphics;
			g.lineStyle();
			g.beginFill(Color, 1);
			g.drawRect(0, 0, Width, Height);
			g.endFill();
			gfx.scaleX = 0.001;
		}
		
		public function set progress(value:Number):void {
			value = Math.max(0.001, Math.min(1, value));
			if (msk != null) {
				msk.scaleX = value;
			} else if(gfx != null) {
				gfx.scaleX = value;
			}
			if(parent != null) parent.setChildIndex(this, parent.numChildren - 1);
		}
		public function get progress():Number {
			return (msk != null)?msk.scaleX:gfx.scaleX;
		}
	}
}