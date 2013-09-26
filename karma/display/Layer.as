package karma.display {
	import starling.display.Sprite;
	
	public dynamic class Layer extends Sprite {
		private var _scrollFactorX:Number;
		private var _scrollFactorY:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		
		public function Layer(name:String, scrollFactorX:Number = 1, scrollFactorY:Number = 1):void {
			this.name = name;
			_scrollFactorX = scrollFactorX;
			_scrollFactorY = scrollFactorY;
			_offsetX = 0;
			_offsetY = 0;
		}
		
		public function get scrollFactorX():Number {
			return _scrollFactorX;
		}
		public function set scrollFactorX(v:Number):void {
			if (isNaN(v)) return;
			_scrollFactorX = v;
		}
		public function get scrollFactorY():Number {
			return _scrollFactorY;
		}
		public function set scrollFactorY(v:Number):void {
			if (isNaN(v)) return;
			_scrollFactorY = v;
		}
		
		/*public function resetOffsets():void {
			_offsetX = x;
			_offsetY = y;
		}*/
		public function get offsetX():Number {
			return _offsetX;
		}
		public function set offsetX(v:Number):void {
			if (isNaN(v)) return;
			_offsetX = v;
		}
		public function get offsetY():Number {
			return _offsetY;
		}
		public function set offsetY(v:Number):void {
			if (isNaN(v)) return;
			_offsetY = v;
		}
		
		override public function set x(value:Number):void {
			super.x = value * _scrollFactorX + _offsetX;
		}
		override public function set y(value:Number):void {
			super.y = value * _scrollFactorY + _offsetY;
		}
	}
}