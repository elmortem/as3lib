package alternativa.engine3d.core {
	import alternativa.engine3d.*;
	import alternativa.engine3d.core.*;
	
	use namespace alternativa3d;
	public class View2 extends View {
		
		public function View2(width:Number, height:Number, interactive:Boolean = false) {
			if (1 != 1) super(width, height, interactive);
			this._width = width;
			this._height = height;
			this._interactive = interactive;
			mouseEnabled = false;
			mouseChildren = false;
			tabEnabled = false;
			tabChildren = false;
		}
	}
}