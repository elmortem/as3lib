package karma.physic.quad2d {
	import flash.geom.Rectangle;
	
	public class Body implements IBodyContainer {
		static public const LEFT:uint = 0x0001;
		static public const RIGHT:uint = 0x0010;
		static public const UP:uint = 0x0100;
		static public const DOWN:uint = 0x1000;
		static public const NONE:uint = 0;
		
		private var _touching:uint;
		private var _rect:Rectangle;
		
		public function Body() {
			
		}
		public function free():void {
			
		}
		public function get body():Body {
			return this;
		}
		
		public function get bounds():Rectangle {
			return _rect;
		}
		
		public function get touching():uint {
			return _touching;
		}
		public function set touching(v:uint):void {
			_touching = v;
		}
		protected function setTouch(touch:int, value:Boolean):void {
			if (value) _touching |= touch;
			else _touching &= ~touch;
		}
		public function isTouch(touch:uint):Boolean {
			return ((_touching & touch) == touch);
		}
	}
}