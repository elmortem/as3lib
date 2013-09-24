package alternativa.particle3d {
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.engine3d.materials.SpriteTextureMaterial;
	import alternativa.types.Point3D;
	import alternativa.types.Texture;
	
	public class Particle extends Sprite3D {
		public var life:Number = 0;
		public var speed:Point3D = new Point3D();
		public var alpha_d:Number = 0;
		public var scale_d:Number = 0;
		
		public function Particle(attr:Object) {
			material = new SpriteTextureMaterial(attr.texture, attr.alpha, attr.smooth, attr.blend);
		}
		public function free():void {
			
		}
	}
}