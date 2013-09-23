package elmortem.managers {
	import com.senocular.display.TransformTool;
	import elmortem.types.DynamicShape;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class SenocularTransformManager extends Sprite {
		private var _tool:TransformTool;
		private var list:Vector.<Object>;
		// used for manage multiple transformations
		private var anchor_matrix:Matrix;
		private var canvas_matrix:Matrix;
		private var canvas_inverted_matrix:Matrix; 
		
		public function SenocularTransformManager(clip:Sprite) {
			_tool = new TransformTool();
			_tool.addEventListener(TransformTool.CONTROL_MOVE, onControlMove);
			_tool.addEventListener(TransformTool.CONTROL_DOWN, onControlDown);
			_tool.addEventListener(TransformTool.CONTROL_UP, onControlUp);
			clip.addChild(_tool);
			list = new Vector.<Object>();
		}
		
		public function add(o:DisplayObject, scale:Boolean = true, rotate:Boolean = true, rotateAngle:Number = 0, maxScaleX:Number = Infinity, maxScaleY:Number = Infinity, minScaleX:Number = 0, minScaleY:Number = 0, update:Boolean = true):void {
			list.push( { obj:o, scale:scale, rotate:rotate, rotateAngle:rotateAngle, maxScaleX:maxScaleX, maxScaleY:maxScaleY, minScaleX:minScaleX, minScaleY:minScaleY } );
			
			if(update) updateSelection();
		}
		public function remove(o:DisplayObject):void {
			var i:int;
			var len:int = list.length;
			var idx:int = -1;
			for (i = 0; i < len; ++i) {
				if (list[i].obj == o) {
					idx = i;
					break;
				}
			}
			if (idx >= 0) {
				list.splice(idx, 1);
				updateSelection();
			}
		}
		public function clear():void {
			list.length = 0;
			updateSelection();
		}
		
		public function updateSelection():void {
			this.transform.matrix = this.parent.transform.matrix.clone();
			clearShapes();
			
			_tool.target = null;
			_tool.scaleEnabled = true;
			_tool.rotationEnabled = true;
			_tool.constrainRotation = true;
			_tool.constrainRotationAngle = 0;
			_tool.skewEnabled = false;
			if (list.length <= 0) return;
			
			updateCanvasMatrix();
			
			var obj:Object;
			var o:DisplayObject;
			var bounds:Rectangle;
			var shape:DynamicShape;
			var temp_matrix:Matrix;
			var i:int;
			var len:int = list.length;
			for (i = 0; i < len; ++i) {
				o = list[i].obj;
				bounds = o.getBounds(o);
				shape = new DynamicShape();
				shape.obj = o;
				shape.graphics.lineStyle();
				shape.graphics.beginFill(0, 0.1);
				shape.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
				shape.graphics.endFill();
				
				if (len == 1) {
					this.transform.matrix = o.transform.concatenatedMatrix.clone();
					updateCanvasMatrix(o);
				}
				temp_matrix = o.transform.concatenatedMatrix.clone();
				temp_matrix.concat(canvas_inverted_matrix);
				
				shape.transform.matrix = temp_matrix;
				this.addChild(shape);
				
				_tool.scaleEnabled = _tool.scaleEnabled && list[i].scale;
				_tool.rotationEnabled = _tool.rotationEnabled && list[i].rotate && list[i].rotateAngle < 360;
				_tool.constrainRotationAngle = list[i].rotateAngle;
				_tool.maxScaleX = list[i].maxScaleX;
				_tool.maxScaleY = list[i].maxScaleY;
				_tool.minScaleX = list[i].minScaleX;
				_tool.minScaleY = list[i].minScaleY;
			}
			_tool.constrainRotation = _tool.rotationEnabled && _tool.constrainRotationAngle > 0;
			_tool.scaleEnabled = _tool.scaleEnabled && list.length == 1;
			
			_tool.target = this;
			if (list.length == 1 && bounds.left == 0 && bounds.top == 0) {
				_tool.registration = _tool.boundsTopLeft;
				_tool.registrationEnabled = false;
			} else {
				//_tool.registration = _tool.boundsCenter;
				_tool.registrationEnabled = _tool.constrainRotationAngle < 360;
			}
		}
		
		private function clearShapes():void {
			while (numChildren > 0) removeChildAt(0);
		}
		private function updateCanvasMatrix(o:DisplayObject = null):void {
			if (o == null) o = parent;
			canvas_matrix = o.transform.concatenatedMatrix.clone();
			canvas_inverted_matrix = canvas_matrix.clone();
			canvas_inverted_matrix.invert();
		}
		
		public function get tool():TransformTool {
			return _tool;
		}
		public function get length():int {
			return list.length;
		}
		public function getObjectAt(num:int):DisplayObject {
			if (num < 0 || num >= list.length) return null;
			return list[num].obj;
		}
		public function set toolMatrix(matrix:Matrix):void {
			_tool.toolMatrix = matrix;
		}
		
		
		// ------------------------------
		// TransformTool event listeners
		// ------------------------------

		private function onControlDown(event:Event):void {
			updateCanvasMatrix();
			anchor_matrix = this.transform.concatenatedMatrix.clone( );
			onControlMove(null);
		}
		
		private function onControlUp(event:Event):void {
			if (length == 1) {
				updateSelection();
			}
			anchor_matrix = null;
		}
		
		/**
		 * Transform tool move handler.
		 * 
		 */
		private function onControlMove(event:Event):void {
			// every time the transform tool is moved
			// we need to update the matrix of every selected item, using
			// the transformed matrix of its 'copy' in the outline_container
			 
			var outline_matrix:Matrix = this.transform.concatenatedMatrix.clone();
			var temp:Matrix = outline_matrix.clone();
			outline_matrix.invert();
			outline_matrix.concat(anchor_matrix);
			outline_matrix.invert();
			
			anchor_matrix.concat(canvas_inverted_matrix);
			
			var i:int;
			var len:int = numChildren;
			var shape:DynamicShape;
			var target:DisplayObject;
			for (i = 0; i < len; ++i) {
				shape = this.getChildAt(i) as DynamicShape;
				target = shape.obj;
				var item_c_matrix:Matrix = shape.transform.concatenatedMatrix.clone();
				var parent_matrix:Matrix = target.parent.transform.concatenatedMatrix.clone();
				parent_matrix.invert();
				item_c_matrix.concat(parent_matrix);
				target.transform.matrix = item_c_matrix;
			}
			anchor_matrix = temp.clone();
		}
	}
}