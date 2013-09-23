package elmortem.game.cameras {
	import elmortem.types.Vec2;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	public class CameraBase extends EventDispatcher implements ICamera {
		private var _half_width:Number;
		private var _half_height:Number;
		
		private var layer:DisplayObject;
		public var pos:Vec2;
		private var pos_d:Vec2;
		private var speed:Vec2;
		private var timer:Number;
		private var width:Number;
		private var height:Number;
		

		public function CameraBase(layerIn:Sprite, widthIn:Number, heightIn:Number) {
			super();
			
			layer = layerIn;
			width = widthIn;
			height = heightIn;
			
			_half_width = layer.stage.stageWidth * 0.5;
			_half_height = layer.stage.stageHeight * 0.5;
			
			pos = new Vec2();
			pos_d = new Vec2();
			speed = new Vec2();
			timer = 0;
			
			calculate();
		}
		public function free():void {
			layer = null;
		}
		
		public function move(x:Number, y:Number, time:Number = 0):void {
			pos_d.Set(x, y);
			timer = time;
			calculate();
		}
		public function moveV(v:Vec2, time:Number = 0):void {
			move(v.x, v.y, time);
		}
		public function moveBetween(x1:Number, y1:Number, x2:Number, y2:Number, time:Number = 0):void {
			var bx:Number = x1 + (x2 - x1) * 0.5;
			var by:Number = y1 + (y2 - y1) * 0.5;
			move(bx, by, time);
		}
		public function moveBetweenV(v1:Vec2, v2:Vec2, time:Number = 0):void {
			moveBetween(v1.x, v1.y, v2.x, v2.y, time);
		}
		public function calculate():void {
			// rect
			if(pos_d.x < _half_width) pos_d.x = _half_width;
			if(pos_d.y < _half_height) pos_d.y = _half_height;
			if(pos_d.x > width - _half_width) pos_d.x = width - _half_width;
			if(pos_d.y > height - _half_height) pos_d.y = height - _half_height;
			
			if(timer <= 0) {
				var d:Vec2 = new Vec2(pos.x, pos.y);
				d.Subtract(pos_d);
				dispatchEvent(new CameraEvent(d, CameraEvent.PROGRESS));
				pos.SetV(pos_d);
				if(layer != null) {
					layer.x = -(pos.x - _half_width);
					layer.y = -(pos.y - _half_height);
				}
			} else {
				speed.x = (pos_d.x - pos.x) / timer;
				speed.y = (pos_d.y - pos.y) / timer;
			}
		}
		public function update(delta:Number):void {
			if(timer > 0) {
				timer -= delta;
				if(timer <= 0) {
					calculate();
				} else {
					var d:Vec2 = new Vec2(speed.x * delta, speed.y * delta);
					dispatchEvent(new CameraEvent(d, CameraEvent.PROGRESS));
					pos.x += d.x;
					pos.y += d.y;
					if(layer != null) {
						layer.x = -(pos.x - _half_width);
						layer.y = -(pos.y - _half_height);
					}
				}
			}
		}
		
		public function localToGlobal(x:Number, y:Number):Vec2 {
			var v:Vec2 = new Vec2(x, y);
			v.x += pos.x - _half_width;
			v.y += pos.y - _half_height;
			return v;
		}
		public function globalToLocal(x:Number, y:Number):Vec2 {
			var v:Vec2 = new Vec2(x, y);
			v.x -= pos.x + _half_width;
			v.y -= pos.y + _half_height;
			return v;
		}
	}
}