package elmortem.managers.particles {
	
	public class Emitter {
		private var _list:Vector.<IParticle>;
		private var _render:IRender;
		
		
		
		public function Emitter(render:IRender, setting:Object):void {
			_list = new Vector.<IParticle>();
			_render = render;
		}

		public function update(delta:Number):void {
			
		}
	}
}