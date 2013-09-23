package elmortem.states.faders {
	import elmortem.utils.SpriteUtils;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	public class ColorFader extends Sprite implements IFader {
		private var time:Number;
		private var timer:Number;
		private var delta:Number;
		private var callback:Function;
		private var callback_params:Array;
		private var isOut:Boolean;
		
		public function ColorFader(width:Number, height:Number, color:uint) {
			var g:Graphics = graphics;
			g.lineStyle();
			g.beginFill(color);
			g.drawRect(0, 0, width, height);
			g.endFill();
			
			time = 0;
			timer = 0;
			visible = false;
		}
		public function free():void {
			callback = null;
			callback_params = null;
		}
		
		public function fadeIn(time:Number, callback:Function = null, callback_params:Array = null, force:Boolean = false):void {
			if (parent == null || (!force && this.time > 0)) return;
			
			this.time = time;
			timer = 0;
			
			/*var ct:ColorTransform = new ColorTransform();
			ct.color = color;
			transform.colorTransform = ct;*/
			alpha = 0;
			visible = true;
			
			this.callback = callback;
			this.callback_params = callback_params;
			
			delta = 1 / stage.frameRate;
			isOut = false;
			parent.setChildIndex(this, parent.numChildren - 1);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		public function fadeOut(time:Number, callback:Function = null, callback_params:Array = null, force:Boolean = false):void {
			fadeIn(time, callback, callback_params, force);
			alpha = 1;
			isOut = true;
		}
		
		private function onFrame(e:Event):void {
			if (timer >= time) {
				var c:Function = callback;
				var cp:Array = callback_params;
				time = 0;
				timer = 0;
				callback = null;
				callback_params = null;
				if(alpha <= 0) visible = false;
				removeEventListener(Event.ENTER_FRAME, onFrame);
				if (c != null) c.apply(null, cp);
				return;
			}
			
			timer += delta;
			if (timer > time) timer = time;
			if(!isOut) {
				alpha = timer / time;
			} else {
				alpha = 1 - timer / time;
			}
		}
	}
}