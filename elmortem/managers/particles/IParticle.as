package elmortem.managers.particles {
	
	interface IParticle {
		public function get x():Number;
		public function set x(v:Number):void;
		public function get y():Number;
		public function set y(v:Number):void;
		public function get scaleX():Number;
		public function set scaleX(v:Number):void;
		public function get scaleY():Number;
		public function set scaleY(v:Number):void;
		public function get velocityX():Number;
		public function set velocityX(v:Number):void;
		public function get velocityY():Number;
		public function set velocityY(v:Number):void;
		public function get age():Number;
		public function get ageMax():Number;
	}
}