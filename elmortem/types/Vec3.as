package elmortem.types {
	
	public class Vec3 {
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function Vec3(x:Number = 0, y:Number = 0, z:Number = 0) {
			this.x = x; this.y = y; this.z = z;
		}
		public function setXYZ(x:Number = 0, y:Number = 0, z:Number = 0):void {
			this.x = x; this.y = y; this.z = z;
		}
		public function setV(v:Vec3):void {
			x = v.x;
			y = v.y;
			z = v.z;
		}
		public function clone():Vec3 {
			return new Vec3(x, y, z);
		}
	}
}