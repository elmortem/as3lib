package elmortem.game.entities.effects {
	import com.greensock.TweenLite;
	import elmortem.game.entities.Entity;
	import elmortem.game.senses.layers.LayerManager;
	import elmortem.game.Simulation;
	import elmortem.utils.SpriteUtils;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class ParticleSystem extends Entity {
		public var gfx:Sprite;
		public var list:Vector.<DisplayObject>;
		
		public var is_dead:Boolean;
		public var effect:String;
		public var life:Number;
		public var max:int;
		public var add_particle_timer:Number;
		public var emitter:IEmitter;
		
		public function ParticleSystem() {
			super();
		}
		override public function init(sim:Simulation):void {
			super.init(sim);
			
			gfx = new Sprite();
			gfx.x = pos.x;
			gfx.y = pos.y;
			var layerManager:LayerManager = sim.getSense("layerManager") as LayerManager;
			layerManager.find("effect").addChild(gfx);
			gfx.rotation = int(attr.angle);
			
			list = new Vector.<DisplayObject>();
			
			is_dead = false;
			effect = attr.props.effect;
			life = Number(attr.props.life);
			max = int(attr.props.max);
			add_particle_timer = 0;
			if (attr.emitter is Class) emitter = new attr.emitter();
			else emitter = attr.emitter;
			emitter.init(this);
		}
		override public function free():void {
			SpriteUtils.removeAllChilds(gfx);
			gfx.parent.removeChild(gfx);
			gfx = null;
			
			list = null;
			if(emitter != null) {
				//emitter.free();
				emitter = null;
			}
			
			super.free();
		}
		
		override public function update(delta:Number):void {
			super.update(delta);
			
			if(life > 0) {
				life -= delta;
				if (life < 0) is_dead = true;
			}
			
			var i:int = 0;
			while (i < list.length) {
				if (emitter.updateParticle(list[i], delta)) {
					if(list[i].parent != null) list[i].parent.removeChild(list[i]);
					list.splice(i, 1);
					continue;
				}
				++i;
			}
			
			if (add_particle_timer > 0) {
				add_particle_timer -= delta;
			} else {
				if (!is_dead && list.length < max) {
					add_particle_timer = emitter.addParticle();
				}
			}
			
			gfx.x = pos.x;
			gfx.y = pos.y;
			
			if (list.length <= 0) die();
		}
		
		/*override public function moveTo(x:Number, y:Number, delay:Number, duration:Number):void {
			TweenLite.to(pos, duration, { delay:delay, x:x, y:y, overwrite:1, onUpdate:onMoveUpdate } );
		}
		private function onMoveUpdate():void {
			gfx.x = pos.x;
			gfx.y = pos.y;
		}*/
		
		public function set angle(value:Number):void {
			gfx.rotation = value;
		}
		public function get angle():Number {
			return gfx.rotation;
		}
	}
}