package karma.particles {
	import starling.display.Sprite;
	
	public class ParticleSystem extends Sprite {
		private var _list:Vector.<ParticleEmitter>;
		
		public function ParticleSystem() {
			_list = new Vector.<ParticleEmitter>();
		}
		override public function dispose():void {
			for (var i:int = 0; i < _list.length; i++) {
				_list[i].removeFromParent(true);
			}
			_list.length = 0;
			_list = null;
			
			super.dispose();
		}
	}
}