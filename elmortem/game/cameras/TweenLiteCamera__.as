package elmortem.game.cameras {
	import com.greensock.TweenLite;
	import elmortem.game.senses.ISense;
	import elmortem.types.Vec2;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	
	public class TweenLiteCamera__ extends EventDispatcher implements ISense, ICamera {
		public var pos:Vec2;
		private var screenWidth:Number;
		private var screenHeight:Number;
		private var screenWidthHalf:Number;
		private var screenHeightHalf:Number;
		//private var width:Number;
		//private var height:Number;
		private var rect:Rectangle;
		private var tween:TweenLite;
		
		public function TweenLiteCamera__(screenWidth:Number, screenHeight:Number) {
			this.screenWidth = screenWidth;
			this.screenHeight = screenHeight;
			this.screenWidthHalf = screenWidth * 0.5;
			this.screenHeightHalf = screenHeight * 0.5;
			rect = new Rectangle(0, 0, screenWidth, screenHeight);
			pos = new Vec2();
			tween = null;
		}
		public function free():void {
			TweenLite.killTweensOf(pos);
			pos = null;
		}
		public function setSize(width:Number, height:Number):void {
			rect.left = 0;
			rect.right = width;
			rect.top = 0;
			rect.bottom = height;
		}
		public function setSizeRect(r:Rectangle):void {
			rect = r.clone();
			
			/*screenWidthHalf = screenWidth * 0.5;
			screenHeightHalf = screenHeight * 0.5;
			
			if (rect.width < screenWidthHalf * 2) screenWidthHalf = rect.width * 0.5 + (screenWidthHalf - rect.width * 0.5) * 0.5;
			if (rect.height < screenHeightHalf * 2) screenHeightHalf = rect.height * 0.5 + (screenHeightHalf - rect.height * 0.5) * 0.5;*/
		}
		public function moveTo(pos:Vec2, duration:Number = 0, delay:Number = 0, ease:Object = null):void {
			if ((duration > 0 || delay > 0) && tween != null) {
				//trace(tween, duration, delay);
				return;
			}
			pos.x = Math.max(rect.left + screenWidthHalf, pos.x);
			pos.x = Math.min(rect.right - screenWidthHalf, pos.x);
			pos.y = Math.max(rect.top + screenHeightHalf, pos.y);
			pos.y = Math.min(rect.bottom - screenHeightHalf, pos.y);
			
			tween = TweenLite.to(this.pos, duration, { delay:delay, x:screenWidthHalf - pos.x, y:screenHeightHalf - pos.y, ease:ease, onUpdate:onProgress, onComplete:onFinish } );
			if (tween != null && !tween.active) tween = null;
			dispatchEvent(new CameraEvent(this.pos, CameraEvent.START));
		}
		public function getRect():Rectangle {
			return rect;
		}
		private function onProgress():void {
			dispatchEvent(new CameraEvent(pos, CameraEvent.PROGRESS));
		}
		private function onFinish():void {
			//trace("Camera finish.");
			tween = null;
			dispatchEvent(new CameraEvent(pos, CameraEvent.FINISH));
		}
		
		/*public function screenToCamera(x:Number, y:Number):Vec2 {
			var v:Vec2 = new Vec2(x, y);
			v.x += pos.x;// - screenWidthHalf;
			v.y += pos.y;// - screenHeightHalf;
			return v;
		}
		public function cameraToScreen(x:Number, y:Number):Vec2 {
			var v:Vec2 = new Vec2(x, y);
			v.x -= pos.x;// + screenWidthHalf;
			v.y -= pos.y;// + screenHeightHalf;
			return v;
		}*/
		public function screenToCamera(x:Number, y:Number):Vec2 {
			var v:Vec2 = new Vec2(x, y);
			v.x -= pos.x;// - screenWidthHalf;
			v.y -= pos.y;// - screenHeightHalf;
			return v;
		}
		public function cameraToScreen(x:Number, y:Number):Vec2 {
			var v:Vec2 = new Vec2(x, y);
			v.x += pos.x;// + screenWidthHalf;
			v.y += pos.y;// + screenHeightHalf;
			return v;
		}
		
		public virtual function update(delta:Number):void { }
		public function get senseName():String {
			return "camera";
		}
	}
}