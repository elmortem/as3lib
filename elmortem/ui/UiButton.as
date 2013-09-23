package elmortem.ui {
	import elmortem.ui.events.UiEvent;
	import elmortem.ui.events.UiMouseEvent;
	import elmortem.ui.skins.UiSkin;
	
	public class UiButton extends UiComponent {
		private var skinNormal:UiSkin;
		private var skinOver:UiSkin;
		private var skinDown:UiSkin;
		private var is_over:Boolean;
		private var is_down:Boolean;
		private var state:int;
		
		public function UiButton(attrIn:Object = null):void {
			super(attrIn);
			
			is_over = false;
			is_down = false;
			state = 0;
			
			addChild(skinNormal = attr.skinNormal);
			addChild(skinOver = attr.skinOver);
			addChild(skinDown = attr.skinDown);
			cacheAsBitmap = true;
			
			UiManager._addListener(null, UiMouseEvent.DOWN, onDown);
			UiManager._addListener(null, UiMouseEvent.UP, onUp);
			UiManager._addListener(null, UiMouseEvent.OVER, onOver);
			UiManager._addListener(null, UiMouseEvent.OUT, onOut);
		}
		
		override public function render():void {
			if (isLock) return;
			
			trace("Button render: " + state);
			
			if (state == 0) {
				skinNormal.visible = true;
				skinOver.visible = false;
				skinDown.visible = false;
				skinNormal.render(width, height);
			} else if (state == 1) {
				skinNormal.visible = false;
				skinOver.visible = true;
				skinDown.visible = false;
				skinOver.render(width, height);
			} else if (state == 2) {
				skinNormal.visible = false;
				skinOver.visible = false;
				skinDown.visible = true;
				skinDown.render(width, height);
			}
		}
		
		private function onDown(e:UiMouseEvent):void {
			is_down = true;
			state = 2;
			render();
		}
		private function onUp(e:UiMouseEvent):void {
			is_down = false;
			if (is_over) state = 1;
			else state = 0;
			render();
		}
		private function onOver(e:UiMouseEvent):void {
			is_over = true;
			if (is_down) state = 2;
			else state = 1;
			render();
		}
		private function onOut(e:UiMouseEvent):void {
			is_over = false;
			state = 0;
			render();
		}
	}
}