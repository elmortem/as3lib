package elmortem.game.utils {

	public class Quake {
		static public const VERTICAL:int = 0;
		static public const HORIZONTAL:int = 1;
		static public const ALL:int = 2;
		static public const VERTICAL_NO_RND:int = 3;
		
		public var x:Number;
		public var y:Number;
		private var count:int;
		private var time:Number;
		private var timer:Number;
		private var power:Number;
		private var type:int;
		
		public function Quake() {
			x = 0;
			y = 0;
			count = 0;
			time = 0;
			timer = 0;
			type = ALL;
		}
		public function update(delta:Number):void {
			if (count > 0) {
				timer -= delta;
				if (timer <= 0) {
					timer = time;
					count--;
					if (count > 0) {
						if(type == VERTICAL) {
							y = power - Math.random() * power * 2;
						} else if (type == HORIZONTAL) {
							x = power - Math.random() * power * 2;
						} else if (type == ALL) {
							x = power - Math.random() * power * 2;
							y = power - Math.random() * power * 2;
						} else if (type == VERTICAL_NO_RND) {
							if (y > 0)
								y = -power;
							else
								y = power;
						}
					} else {
						x = 0;
						y = 0;
					}
				}
			}
		}
		public function start(count:int, time:Number, power:Number, type:int = ALL):void {
			if (count <= 0) {
				stop();
				return;
			}
			this.count = count;
			this.time = time / Number(count);
			this.power = power;
			timer = this.time;
			this.type = type;
		}
		public function stop():void {
			count = 0;
			x = 0;
			y = 0;
		}
		public function isStarted():Boolean {
			return (count > 0);
		}
		public function isProgress():Boolean {
			return isStarted();
		}
	}
}