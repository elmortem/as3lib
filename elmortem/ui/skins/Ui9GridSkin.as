package elmortem.ui.skins {
	import elmortem.core.Gfx;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	public class Ui9GridSkin extends UiSkin {
		
		public function Ui9GridSkin(attrIn:Object = null) {
			super(attrIn);
			
			attr.bitmap.cacheAsBitmap = true;
			addChild(attr.bitmap);
			scale9Grid = attr.rect;
			cacheAsBitmap = true;
		}
		
		override public function render(width:Number, height:Number):void {
			this.scaleX = this.width / width;
			this.scaleY = this.height / height;
			x = attr.offsetX;
			y = attr.offsetY;
			
			var g:Graphics = graphics;
			g.lineStyle();
			g.beginFill(0xff0000);
			//g.drawRoundRect(0, 0, 20, 20, 5, 5);
			g.drawRect(0, 0, 20, 20);
			g.endFill();
		}
	}
}