package alternativa.utils {
	import alternativa.engine3d.display.View;
	import alternativa.types.Point3D;
	import flash.geom.Point;
	
	public class ViewUtils {
		private static var view:View;
		
		public static function init(viewIn:View):void {
			view = viewIn;
		}
		public static function free():void {
			view = null;
		}
		
		public static function getPoint3DByPlane(point:Point, position:Point3D, normal:Point3D):Point3D {
			if (!view || !view.camera) return null;
			var rayFrom:Point3D = new Point3D();
			var rayTo:Point3D = view.get3DCoords(point, 1);
			rayFrom = view.camera.localToGlobal(rayFrom);
			rayTo = view.camera.localToGlobal(rayTo);
			var direction:Point3D = Point3D.difference(rayTo, rayFrom);
			var dot:Number = Point3D.dot(direction, normal);
			var fromOffset:Number = Point3D.dot(rayFrom, normal) - Point3D.dot(position, normal);
			if ((dot >= 0 && fromOffset > 0) || (dot <= 0 && fromOffset < 0)) {
				return null;
			} else {
				var k:Number = -fromOffset / dot;
				var x:Number = rayFrom.x + direction.x*k;
				var y:Number = rayFrom.y + direction.y*k;
				var z:Number = rayFrom.z + direction.z*k;
				return new Point3D(x, y, z);
			}
		}
	}
}