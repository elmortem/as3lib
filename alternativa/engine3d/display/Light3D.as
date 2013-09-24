package alternativa.engine3d.display
{
	import alternativa.types.Point3D;
	
	/**
	* This class specifies directional light source in global coordinates.
	* @author makc
	*/
	public class Light3D 
	{
		private var _direction:Point3D = new Point3D (0, 0, 1);
		
		/**
		 * Direction of light in global coordinates, normalized.
		 */
		public function get direction ():Point3D { return _direction.clone (); }
		
		/**
		 * @private setter
		 */
		public function set direction (dir:Point3D):void {
			_direction.copy (dir);

			if (_direction.lengthSqr > 0)
				_direction.normalize ();
			else
				_direction.z = 1;
		}

		/**
		 * Sets direction from two points in global coordinates.
		 */
		public function setDirection (from:Point3D, to:Point3D):void {
			var dir:Point3D = to.clone (); dir.subtract (from); direction = dir;
		}

		/**
		 * Power of light.
		 */
		public var power:Number = 1;
		
	}
	
}