package elmortem.ui.skins {
	import flash.display.Graphics;
	
	public class UiRoundRectSkin extends UiSkin {
		private var color:uint;
		
		public function UiRoundRectSkin(attrIn:Object = null) {
			super(attrIn);
			
			color = (attr.color != null)?attr.color:0xff0000;
		}
		
		override public function render(width:Number, height:Number):void {
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle();
			g.beginFill(color);
			g.drawRoundRect(0, 0, width, height, 10, 10);
			g.endFill();
		}
	}
}