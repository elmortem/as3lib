package elmortem.ui {
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author Osokin <elmortem> Makar
	 */
	public class ButtonManager2 {
		static private var list:/*MovieClip*/Array = [];
		static private var tabs:/*MovieClip*/Array = [];
		static private var select:MovieClip = null;
		static private var _playSound:Function = null;
		
		static public function init(eventer:IEventDispatcher, playSound:Function):void {
			eventer.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			_playSound = playSound;
		}
		
		public static function add(btn:MovieClip, on_click:Function = null, on_over:Function = null, on_out:Function = null, on_down:Function = null, on_up:Function = null):void {
			btn.x = int(btn.x);
			btn.y = int(btn.y);
			btn.on_click = on_click;
			btn.on_over = on_over;
			btn.on_out = on_out;
			btn.on_down = on_down;
			btn.on_up = on_up;
			if(btn.active == null) btn.active = false;
			btn.stop();
			if(btn.on_over == null) btn.gotoAndStop(1);
			if (btn.over_box != null) {
				btn.hitArea = btn.over_box;
				btn.over_box.alpha = 0;
			}
			btn.buttonMode = true;
			btn.mouseChildren = false;
			btn.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			btn.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			btn.addEventListener(MouseEvent.MOUSE_UP, onUp);
			btn.addEventListener(MouseEvent.CLICK, onClick);
			/*if (on_over) btn.addEventListener(MouseEvent.MOUSE_OVER, on_over);
			if (on_out) btn.addEventListener(MouseEvent.MOUSE_OUT, on_out);
			if (on_click) btn.addEventListener(MouseEvent.CLICK, on_click);*/
			
			list.push(btn);
		}
		public static function remove(btn:MovieClip):void {
			if (btn == null) return;
			var idx:int = list.indexOf(btn);
			list.splice(idx, 1);
			idx = tabs.indexOf(btn);
			tabs.splice(idx, 1);
			
			btn.on_click = null;
			btn.on_over = null;
			btn.on_out = null;
			btn.active = null;
			if (btn.over_box != null) {
				//btn = btn.over_box;
			}
			btn.buttonMode = false;
			btn.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			btn.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			btn.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			btn.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			btn.removeEventListener(MouseEvent.CLICK, onClick);
			
			removeTab(btn);
		}
		
		/*public static function clear():void {
			while (list.length > 0) {
				remove(list[0]);
			}
			list = [];
			tabs = [];
			select = null;
		}*/
		
		public static function clearTabs():void {
			while (tabs.length > 0) {
				remove(tabs[0]);
			}
			tabs = [];
			select = null;
		}
		
		public static function setSound(btn:Object, click:String = null, down:String = null, over:String = null):void {
			if (btn == null) {
				trace("Button not found.");
				return;
			}
			if (btn is Array) {
				for (var i:int = 0; i < btn.length; i++) {
					setSound(btn[i], click, down, over);
				}
				return;
			} else {
				btn.sfx_on_click = click;
				btn.sfx_on_down = down;
				btn.sfx_on_over = over;
			}
		}
		
		public static function activate(btn:MovieClip):void {
			/*if (!btn.enabled) {
				btn.gotoAndStop(4);
				return;
			}
			btn.active = true;
			btn.gotoAndStop(3);*/
			btn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
		}
		public static function deactivate(btn:MovieClip):void {
			/*if (!btn.enabled) {
				btn.gotoAndStop(4);
				return;
			}
			btn.active = false;
			btn.gotoAndStop(1);*/
			btn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
		}
		
		static public function addTab(btn:MovieClip, active:Boolean = false):void {
			tabs.push(btn);
			if (active || select == null) activate(btn);
		}
		static public function removeTab(btn:MovieClip):void {
			var idx:int = tabs.indexOf(btn);
			if (idx >= 0) tabs.splice(idx, 1);
		}
		
		static public function pressUp():void {
			if (tabs.length <= 0) return;
			var id:int = tabs.indexOf(select);
			if (id >= 0) {
				id--;
				if (id < 0) id = tabs.length - 1;
				activate(tabs[id]);
			} else {
				activate(tabs[0]);
			}
		}
		static public function pressDown():void {
			if (tabs.length <= 0) return;
			var id:int = tabs.indexOf(select);
			if (id >= 0) {
				id++;
				if (id >= tabs.length) id = 0;
				activate(tabs[id]);
			} else {
				activate(tabs[0]);
			}
		}
		static public function pressEnter():void {
			if (select == null) return;
			if(!select.enabled) return;
			select.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
		
		static private function keyDown(e:KeyboardEvent):void {
			if(e.keyCode == Keyboard.SPACE || e.keyCode == Keyboard.ENTER) pressEnter();
			if(e.keyCode == Keyboard.UP || e.keyCode == Keyboard.LEFT) pressUp();
			if(e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.TAB) pressDown();
		}
		
		public static function disable(btn:MovieClip):void {
			if (!btn.enabled) return;
			btn.enabled = false;
			btn.buttonMode = false;
			if (btn.on_over == null) {
				btn.gotoAndStop(4);
			}
			if (btn.over_box != null) {
				//btn = btn.over_box;
				//btn.alpha = 0;
			}
			btn.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			btn.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
			btn.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			btn.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			btn.removeEventListener(MouseEvent.CLICK, onClick);
		}
		public static function enable(btn:MovieClip):void {
			if (btn.enabled) return;
			btn.enabled = true;
			btn.buttonMode = true;
			if(btn.on_over == null) btn.gotoAndStop(1);
			if (btn.active) activate(btn);
			else deactivate(btn);
			if (btn.over_box != null) {
				//btn = btn.over_box;
				//btn.alpha = 0;
			}
			btn.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			btn.addEventListener(MouseEvent.MOUSE_OUT, onOut);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			btn.addEventListener(MouseEvent.MOUSE_UP, onUp);
			btn.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private static function onOver(e:MouseEvent):void {
			var btn:MovieClip = e.currentTarget as MovieClip;
			if (btn.name == "over_box") btn = btn.parent as MovieClip;
			if (!btn.enabled) {
				if(btn.on_over == null) btn.gotoAndStop(4);
				return;
			}
			
			if (tabs.indexOf(btn) >= 0) {
				var b:MovieClip = select;
				select = btn;
				if (b != null) {
					b.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
				}
			}
			
			if (!btn.active) {
				if(btn.on_over == null) btn.gotoAndStop(2);
			}
			if (btn.sfx_on_over != null && _playSound != null) {
				_playSound(btn.sfx_on_over);
			}
			if (btn.on_over != null) btn.on_over(e);
		}
		private static function onOut(e:MouseEvent):void {
			var btn:MovieClip = e.currentTarget as MovieClip;
			if (btn.name == "over_box") btn = btn.parent as MovieClip;
			if (!btn.enabled) {
				if(btn.on_over == null) btn.gotoAndStop(4);
				return;
			}
			if (select == btn) return;
			
			if (!btn.active) {
				if(btn.on_over == null) btn.gotoAndStop(1);
			} else {
				if(btn.on_over == null) btn.gotoAndStop(3);
			}
			if (btn.on_out != null) btn.on_out(e);
		}
		private static function onDown(e:MouseEvent):void {
			var btn:MovieClip = e.currentTarget as MovieClip;
			if (btn.name == "over_box") btn = btn.parent as MovieClip;
			if (!btn.enabled) {
				if(btn.on_over == null) btn.gotoAndStop(4);
				return;
			}
			if(btn.on_over == null) btn.gotoAndStop(3);
			if (btn.sfx_on_down != null && _playSound != null) {
				_playSound(btn.sfx_on_down);
			}
			if (btn.on_down != null) btn.on_down(e);
		}
		private static function onUp(e:MouseEvent):void {
			var btn:MovieClip = e.currentTarget as MovieClip;
			if (btn.name == "over_box") btn = btn.parent as MovieClip;
			if (!btn.enabled) {
				if(btn.on_over == null) btn.gotoAndStop(4);
				return;
			}
			if(btn.on_over == null) btn.gotoAndStop(2);
			if (btn.on_up != null) btn.on_up(e);
		}
		private static function onClick(e:MouseEvent):void {
			var btn:MovieClip = e.currentTarget as MovieClip;
			if (btn.name == "over_box") btn = btn.parent as MovieClip;
			if (btn.sfx_on_click != null && _playSound != null) {
				_playSound(btn.sfx_on_click);
			}
			if (btn.on_click != null) btn.on_click(e);
		}
	}

}