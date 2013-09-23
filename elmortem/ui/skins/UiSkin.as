package elmortem.ui.skins {
	import flash.display.Sprite;
	
	public class UiSkin extends Sprite {
		public var attr:Object;
		
		public function UiSkin(attrIn:Object = null) {
			attr = attrIn;
			mouseEnabled = false;
			mouseChildren = false;
		}
		public function render(width:Number, height:Number):void {
		}
	}
}