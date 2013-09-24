package alternativa.engine3d.display 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.display.Skin;
	import alternativa.types.Matrix3D;

	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Scene3D;
	import alternativa.engine3d.core.Sprite3D;
	import alternativa.engine3d.display.View;
	import alternativa.engine3d.materials.SpriteMaterial;

	use namespace alternativa3d

	/**
	* This class creates a sprite in place of object and renders it in other view.
	* Both object and camera must be unscaled and placed in scene root (if you need
	* to scale object, wrap it into empty Object3D).
	* @author makc
	*/
	public class SubView extends SpriteMaterial
	{
		private var _object:Object3D;
		private var _mainView:View;
		private var _scene:Scene3D;

		private var _view:View;
		public function get view ():View { return _view; }
		
		private var timer:int = 0;

		public function SubView (object:Object3D, mainView:View) 
		{
			super (1, "normal");

			_object = object;
			_mainView = mainView;

			// free object
			if (_object.parent != null) _object.parent.removeChild (_object);

			// create empty scene and place our objects in
			_scene = new Scene3D; _scene.root = new Object3D; _scene.root.addChild (_object);
			_view = new View; _view.camera = new Camera3D; _scene.root.addChild (_view.camera);

			// create sprite to replace our object in main view
			var s:Sprite3D = new Sprite3D; s.material = this;
		}

		override alternativa3d function draw (camera:Camera3D, skin:Skin):void {
			/*timer++;
			if (timer < 30) {
				_scene.calculate();
				return;
			}
			timer = 0;*/
			
			// do what parent did not
			skin.alpha = _alpha;
			skin.blendMode = _blendMode;

			// add view to skin
			if (!skin.contains (_view)) skin.addChild (_view);

			// sync view to main view
			_view.width = _mainView.width;
			_view.height = _mainView.height;
			_view.x = _view.width * -0.5;
			_view.y = _view.height * -0.5;

			// sync cameras
			var cam:Camera3D = _view.camera;
			var sourceCam:Camera3D = _mainView.camera;
			cam.fov = sourceCam.fov;

			// this sync code assumes rotation + translation only

			var matCam:Matrix3D = sourceCam.transformation;
			var matObj:Matrix3D = sprite.transformation;
			matObj.invert (); matCam.combine (matObj);

			var sinY:Number = matCam.i;
			if (-1 < sinY && sinY < 1) {
				cam.rotationY = -Math.asin(sinY);
				cam.rotationX = Math.atan2(matCam.j, matCam.k);
				cam.rotationZ = Math.atan2(matCam.e, matCam.a);
			} else {
				cam.rotationY = (sinY > 0) ? -Math.PI / 2 : Math.PI / 2;
				cam.rotationX = 0;
				cam.rotationZ = Math.atan2(-matCam.b, matCam.f);
			}

			cam.x = matCam.d;
			cam.y = matCam.h;
			cam.z = matCam.l;

			// render view
			_scene.calculate();
		}

		override alternativa3d function clear(skin:Skin):void {
			if (sprite.parent == null)
				if (skin.contains (_view))
					skin.removeChild (_view);

			super.clear (skin);
		}
	}
	
}