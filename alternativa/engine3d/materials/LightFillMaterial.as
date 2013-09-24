package alternativa.engine3d.materials {
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Face;
	import alternativa.engine3d.core.Vertex;
	import alternativa.engine3d.display.Light3D;
	import alternativa.engine3d.display.Skin;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.types.Point3D;
	import flash.display.BlendMode;

	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;

	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;

	public class LightFillMaterial extends FillMaterial {
		private static var _defaultColorTransform:ColorTransform;
		public static var globalLight:Light3D = null;
		
		private var _lights:Array = null;
		private var _transforms:Dictionary;
		
		public var ambient:Number = 0.2;
		public var diffuse:Number = 0.8;
		public var is_dynamic:Boolean = false;
		
		public function LightFillMaterial(color:uint, alpha:Number = 1, blendMode:String = BlendMode.NORMAL, wireThickness:Number = -1, wireColor:uint = 0) {
			super(color, alpha, blendMode, wireThickness, wireColor);
			_transforms = new Dictionary(true);
		}

		public function get lights():Array {
			return _lights;
		}
		public function set lights(staticLights:Array):void {
			_lights = staticLights;
		}

		override alternativa3d function draw(camera:Camera3D, skin:Skin, vertexCount:uint, vertices:Array):void {
			// draw texture
			super.draw(camera, skin, vertexCount, vertices);
			
			if (globalLight != null || _lights != null) {
				var face:Face = skin.primitive.face;
				var faceTransform:ColorTransform = _transforms[face];
				
				if (faceTransform == null || is_dynamic) {
					if(faceTransform == null) {
						faceTransform = new ColorTransform();
						_transforms[face] = faceTransform;
					}
					
					var power:Number = ambient;
					if (globalLight != null) {
						power += diffuse * globalLight.power * Math.max(0, -Point3D.dot(globalLight.direction, face.globalNormal));
					}
					if (_lights != null) {
						for each (var light:Light3D in _lights) {
							power += diffuse * light.power * Math.max(0, -Point3D.dot(light.direction, face.globalNormal));
						}
					}
					
					var multiplier:Number = Math.max(0, Math.min(1, power));
					var offset:Number = 0;
					if (power > 1)
						offset = 255 * Math.min(1, power - 1);
					
					faceTransform.redMultiplier = faceTransform.greenMultiplier = faceTransform.blueMultiplier = multiplier;
					faceTransform.alphaMultiplier = alpha;
					faceTransform.redOffset = faceTransform.greenOffset = faceTransform.blueOffset = offset;
				}
				
				skin.transform.colorTransform = faceTransform;
			}
		}

		override public function clone():Material {
			var mat:LightFillMaterial = new LightFillMaterial(color, alpha, blendMode, wireThickness, wireColor);
			mat.ambient = ambient;
			mat.diffuse = diffuse;
			mat.lights = lights;
			mat.is_dynamic = is_dynamic;
			return mat;
		}

		override alternativa3d function clear(skin:Skin):void {
			super.clear(skin);
			if (_defaultColorTransform == null)
				_defaultColorTransform = new ColorTransform();
			skin.transform.colorTransform = _defaultColorTransform;
		}

		private function _fallOff(r:Number):Number {
			r = Math.max(0.00001, Math.abs(r));
			var f:Number = (1 - Math.exp( -r)) / r;
			return f * f / 1e-4;
		}
	}
}