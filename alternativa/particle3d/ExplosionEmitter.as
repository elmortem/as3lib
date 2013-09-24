package alternativa.particle3d {
	import alternativa.types.Point3D;
	import alternativa.types.Texture;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	
	public class ExplosionEmitter extends Emitter {
		protected var par_life_min:Number = 0.5;
		protected var par_life_max:Number = 1;
		protected var par_life_rnd:Number = 0.5;
		protected var par_alpha_begin:Number = 1;
		protected var par_alpha_end:Number = 0;
		protected var par_alpha_d:Number;
		protected var par_scale_begin:Number = 0;
		protected var par_scale_end:Number = 1;
		protected var par_scale_d:Number;
		protected var par_blend:String = BlendMode.ADD;
		//protected var par_speed:Point3D = new Point3D(Math.random() * 100, Math.random() * 100, Math.random() * 100);
		protected var par_speed:Number = 100;
		//protected var par_speed_rnd:Number = 0.5;
		protected var par_speed_rnd:Point3D = new Point3D(0.5, 0.5, 0.5);
		protected var par_gravity:Point3D = new Point3D();
		protected var par_smooth:Boolean = false;
		protected var par_pos_rnd:Point3D = new Point3D(10, 10, 10);
		protected var textures:Array;
		
		public function ExplosionEmitter(attrIn:Object) {
			super(attrIn);
			
			if(attr.particle) {
				if (attr.particle.life_min != undefined) par_life_min = attr.particle.life_min;
				if (attr.particle.life_max != undefined) par_life_max = attr.particle.life_max;
				if (attr.particle.life_rnd != undefined) par_life_rnd = attr.particle.life_rnd;
				if (attr.particle.alpha_begin != undefined) par_alpha_begin = attr.particle.alpha_begin;
				if (attr.particle.alpha_end != undefined) par_alpha_end = attr.particle.alpha_end;
				if (attr.particle.scale_begin != undefined) par_scale_begin = attr.particle.scale_begin;
				if (attr.particle.scale_end != undefined) par_scale_end = attr.particle.scale_end;
				if (attr.particle.blend != undefined) par_blend = attr.particle.blend;
				if (attr.particle.speed != undefined) par_speed = attr.particle.speed;
				if (attr.particle.speed_rnd != undefined) par_speed_rnd = attr.particle.speed_rnd.clone();
				if (attr.particle.gravity != undefined) par_gravity = attr.particle.gravity.clone();
				if (attr.particle.smooth != undefined) par_smooth = attr.particle.smooth;
				if (attr.particle.pos_rnd != undefined) {
					if(attr.particle.pos_rnd is Point3D) {
						par_pos_rnd = attr.particle.pos_rnd.clone();
					} else {
						par_pos_rnd.x = par_pos_rnd.y = par_pos_rnd.z = Number(attr.particle.pos_rnd);
					}
				}
			}
			par_alpha_d = (par_alpha_end - par_alpha_begin) / par_life_min;
			par_scale_d = (par_scale_end - par_scale_begin) / par_life_min;
			
			textures = [];
			for (var i:int = 0; i < attr.bitmaps.length; i++) {
				try {
					var bd:BitmapData = new attr.bitmaps[i].cls(attr.bitmaps[i].width, attr.bitmaps[i].height);
					textures.push(new Texture(bd));
				} catch (e:Error) {
					trace(e.message);
					return;
				}
			}
			
			for (var i:int = 0; i < max; i++) add();
		}
		
		public override function add():void {
			if (textures.length <= 0) return;
			var life:Number = par_life_min * par_life_rnd + Math.random() * (1 - par_life_rnd) * (par_life_max - par_life_min);
			var speed:Point3D = new Point3D();
			speed.x = par_speed * par_speed_rnd.x * Math.random(); // + Math.random() * (1 - par_speed_rnd.x) * par_speed;
			speed.y = par_speed * par_speed_rnd.y * Math.random(); // + Math.random() * (1 - par_speed_rnd.y) * par_speed;
			speed.z = par_speed * par_speed_rnd.z * Math.random(); // + Math.random() * (1 - par_speed_rnd.z) * par_speed;
			var p:Particle = new Particle( {texture:textures[Math.floor(Math.random() * textures.length)], blend:par_blend, smooth:par_smooth, alpha:par_alpha_begin } );
			p.life = life;
			p.alpha_d = (par_alpha_end - par_alpha_begin) / life;
			p.scaleX = p.scaleY = p.scaleZ = par_scale_begin;
			p.scale_d = (par_scale_end - par_scale_begin) / life;
			p.speed = speed;
			p.x = pos.x + par_pos_rnd.x * Math.random() * 2 - par_pos_rnd.x;
			p.y = pos.y + par_pos_rnd.y * Math.random() * 2 - par_pos_rnd.y;
			p.z = pos.z + par_pos_rnd.z * Math.random() * 2 - par_pos_rnd.z;
			particles.push(p);
			addChild(p);
		}
		public override function update(delta:Number):void {
			if (!particles) return;
			for (var i:int = 0; i < particles.length; i++) {
				if (particles[i].life <= 0) {
					remove(i);
					i--;
					continue;
				}
				particles[i].life -= delta;
				particles[i].speed.x += delta * par_gravity.x;
				particles[i].speed.y += delta * par_gravity.y;
				particles[i].speed.z += delta * par_gravity.z;
				particles[i].x += delta * particles[i].speed.x;
				particles[i].y += delta * particles[i].speed.y;
				particles[i].z += delta * particles[i].speed.z;
				particles[i].material.alpha += delta * particles[i].alpha_d;
				particles[i].scaleX = particles[i].scaleY = particles[i].scaleZ = particles[i].scaleX + delta * particles[i].scale_d;
			}
			
			super.update(delta);
		}
	}
}