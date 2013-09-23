package elmortem.game.editor {
	import com.adobe.crypto.MD5;
	import com.adobe.images.BitString;
	import com.senocular.display.TransformTool;
	import elmortem.managers.SenocularTransformManager;
	import elmortem.states.State;
	import elmortem.types.Vec2;
	import elmortem.utils.AngleUtils;
	import elmortem.utils.Data;
	import elmortem.utils.KeyboardUtils;
	import elmortem.utils.SpriteUtils;
	import elmortem.utils.StringUtils;
	import elmortem.utils.XmlUtils;
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class Editor4State extends State {
		static protected var _ids:int = 0;
		
		protected var is_loading:Boolean;
		
		// layers
		protected var CAMERA:Sprite;
			protected var GAME:Sprite;
				protected var LAYERS:/*Sprite*/Array;
				protected var CELLS:Sprite;
		protected var GUI:Sprite;
		
		// gui
		protected var bgColor:int;
		protected var back:Sprite;
		protected var maxBorder:Sprite;
		protected var gui:MovieClip;
		protected var lstLayers:ComboBox;
		protected var lstActors:ComboBox;
		
		// objects
		protected var actors:Array;
		
		// control
		protected var is_down:Boolean = false;
		protected var is_drag:Boolean = false;
		protected var downX:Number;
		protected var downY:Number;
		protected var is_ctrl:Boolean = false;
		protected var is_shift:Boolean = false;
		
		// select
		protected var selectLayerIndex:int = 0;
		protected var selectLayer:int = 0;
		protected var selectIndex:int = -1;
		protected var selectClip:MovieClip = null;
		protected var selectOffset:Point = new Point();
		protected var selectFrame:Sprite;
		protected var lastSelection:MovieClip;
		
		// tiles
		protected var is_tiles:Boolean = false;
		protected var cellSize:int = 0;
		protected var addCellX:int = NaN;
		protected var addCellY:int = NaN;
		
		// transform
		//private var transformTool:TransformTool;
		protected var transformManager:SenocularTransformManager;
		protected var lastTarget:MovieClip = null;
		
		// property
		protected var property:GuiProperty;
		protected var map_props:Object = { };
		
		// level ID
		protected var mapUid:String;
		protected var mapId:int;
		
		public function Editor4State(attrIn:Object = null) {
			super(attrIn);
			if (attr == null) attr = { };
		}
		override protected function init():void {
			var i:int;
			var j:int;
			var g:Graphics;
		
			super.init();
			
			is_loading = true;
			
			this.tabChildren = false;
			
			bgColor = (attr.color != null)?attr.color:0xffffff;
			back = new Sprite();
			g = back.graphics;
			g.lineStyle();
			g.beginFill(0xffffff, 1);
			g.drawRect(0, 0, 100, 100);
			g.endFill();
			addChild(back);
			var ct:ColorTransform = back.transform.colorTransform;
			ct.color = bgColor;
			back.transform.colorTransform = ct;
			
			// layers
			CAMERA = createLayer("CAMERA", this);
			CAMERA.x = getScreenWidth() * 0.5;
			CAMERA.y = getScreenHeight() * 0.5;
			CAMERA.mouseChildren = false;
			CAMERA.mouseEnabled = false;
			GAME = createLayer("GAME", CAMERA);
			GAME.x = -CAMERA.x;
			GAME.y = -CAMERA.y;
			//GAME.mouseChildren = false;
			//GAME.mouseEnabled = false;
			LAYERS = [];
			for (i = 0; i < attr.layers.length; i++) {
				j = LAYERS.push(createLayer(attr.layers[i].name, GAME)) - 1;
				attr.layers[i].id = j;
				
				/*g = LAYERS[j].graphics;
				g.lineStyle(1, 0xFF0000, 0.5);
				g.moveTo( -1000, 0);
				g.lineTo(1000, 0);
				g.moveTo(0, -1000);
				g.lineTo(0, 1000);*/
			}
			CELLS = createLayer("CELLS", GAME);
			CELLS.mouseEnabled = false;
			GUI = createLayer("GAME", this);
			
			if (attr.maxWidth == null) attr.maxWidth = getScreenWidth();
			if (attr.maxHeight == null) attr.maxHeight = getScreenHeight();
			
			if (attr.drawMax) {
				maxBorder = new Sprite();
				GAME.addChild(maxBorder);
				g = maxBorder.graphics;
				g.lineStyle(1, 0x990000, 0.7, false, LineScaleMode.NONE);
				g.beginFill(0x00, 0);
				g.drawRect(0, 0, 100, 100);
				g.endFill();
				
				maxBorder.scaleX = attr.maxWidth / 100;
				maxBorder.scaleY = attr.maxHeight / 100;
			}
			
			if(attr.drawScreen) {
				g = GAME.graphics;
				g.lineStyle(1, 0x999999, 0.7);
				g.beginFill(0x00, 0);
				g.drawRect(0, 0, getScreenWidth(), getScreenHeight());
				g.endFill();
			}
			
			// gui
			gui = attr.gui;
			GUI.addChild(gui);
			GUI.tabChildren = false;
			
			GAME.y += 40;
			// layers
			lstLayers = gui.lst_layers as ComboBox;
			while (lstLayers.length > 0) lstLayers.removeItemAt(0);
			if (attr.layers != null && attr.layers is Array && attr.layers.length > 0) {
				for (i = 0; i < attr.layers.length; i++) {
					lstLayers.addItem( { label:attr.layers[i].title, data:i } );
				}
				lstLayers.addEventListener(Event.CHANGE, onListLayerChange);
				selectLayerIndex = 0;
				selectLayer = attr.layers[0].id;
			}
			// actors
			lstActors = gui.lst_actors as ComboBox;
			lstActors.addEventListener(Event.CHANGE, onListActorChange);
			// props
			gui.btn_props.addEventListener(MouseEvent.CLICK, onClick_Props);
			map_props = { };
			
			// transform
			/*transformTool = new TransformTool();
			transformTool.registrationEnabled = false;
			transformTool.rememberRegistration = false;
			transformTool.skewEnabled = false;
			transformTool.addEventListener(TransformTool.TRANSFORM_TARGET, onTransformTarget);
			transformTool.addEventListener(TransformTool.NEW_TARGET, onNewTarget);
			stage.addChild(transformTool);*/
			addChild(transformManager = new SenocularTransformManager(this));
			transformManager.tool.addEventListener(TransformTool.TRANSFORM_TARGET, onTransformTarget);
			transformManager.tool.addEventListener(TransformTool.TRANSFORM_TOOL, onTransformTarget);
			transformManager.tool.addEventListener(TransformTool.CHANGE_TARGET, onChangeTarget);
			
			// property
			stage.addChild(property = new GuiProperty());
			//property.x = getScreenWidth() - 200;
			property.x = 0;
			property.y = 40;
			
			// select frame
			stage.addChild(selectFrame = new Sprite());
			selectFrame.mouseEnabled = false;
			selectFrame.mouseChildren = false;
			g = selectFrame.graphics;
			g.beginFill(0x00000000, 0);
			g.lineStyle(1, 0xff0000, 1, false, LineScaleMode.NONE);
			g.drawRect(0, 0, 100, 100);
			selectFrame.visible = false;
			lastSelection = null;
			
			// objects
			actors = [];
			
			back.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			back.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			//back.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.addEventListener(Event.RESIZE, onResize);
			
			// activate layer
			lstLayers.selectedIndex = 0;
			lstLayers.dispatchEvent(new Event(Event.CHANGE));
			
			mapUid = "";
			mapId = -1;
			
			is_loading = false;
			
			if (attr.data != null && attr.data.levelStr != null) loadLevel(attr.data.levelStr);
			
			stage.focus = stage;
			
			onResize(null);
			onClick_Props(null);
		}
		override public function free():void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			back.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			back.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			//back.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			//stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			lstLayers.removeEventListener(Event.CHANGE, onListLayerChange);
			lstActors.removeEventListener(Event.CHANGE, onListActorChange);
			
			actors = [];
			
			lstLayers.removeEventListener(Event.CHANGE, onListLayerChange);
			lstActors.removeEventListener(Event.CHANGE, onListActorChange);
			
			gui.btn_props.removeEventListener(MouseEvent.CLICK, onClick_Props);
			
			gui = null;
			
			//transformTool.target = null;
			//stage.removeChild(transformTool);
			transformManager.clear();
			this.removeChild(transformManager);
			
			stage.removeChild(property);
			property.free();
			property = null;
			
			selectFrame = null;
			lastSelection = null;
			
			removeAllChilds();
			
			super.free();
		}
		
		protected function select(index:int = -1):void {
			// clear
			if (selectIndex != -1) {
				selectClip.parent.removeChild(selectClip);
				selectClip = null;
				selectIndex = -1;
				unModify();
				showMapProperty();
			}
			
			// add
			selectIndex = index;
			
			if (selectIndex == -1) {
				lstActors.selectedIndex = 0;
				return;
			}
			
			var act:Object = attr.actors[selectIndex];
			
			selectClip = new act.cls();
			SpriteUtils.stopAll(selectClip);
			selectClip.gotoAndStop(int(act.frame));
			selectClip.mouseChildren = false;
			selectClip.mouseEnabled = false;
			selectClip.alpha = 0.7;
			LAYERS[selectLayer].addChild(selectClip);
			var r:Rectangle = selectClip.getBounds(selectClip);
			selectOffset.x = r.left + r.width * 0.5;
			selectOffset.y = r.top + r.height * 0.5;
			//trace("offsetX: " + selectOffset.x + ", offsetY: " + selectOffset.y);
		}
		protected function addSelected():void {
			var clip:MovieClip;
			var id:int = ++_ids;
			clip = new attr.actors[selectIndex].cls();
			SpriteUtils.stopAll(clip);
			clip.id = id;
			clip.layer_id = selectLayerIndex;
			clip.tiled = StringUtils.toBoolean(attr.actors[selectIndex].tiled, true);
			clip.rotate = attr.actors[selectIndex].rotate;
			clip.resize = attr.actors[selectIndex].resize;
			clip.maxScaleX = (attr.actors[selectIndex].maxScaleX != null)?attr.actors[selectIndex].maxScaleX:Infinity;
			clip.maxScaleY = (attr.actors[selectIndex].maxScaleY != null)?attr.actors[selectIndex].maxScaleY:Infinity;
			clip.minScaleX = (attr.actors[selectIndex].minScaleX != null)?attr.actors[selectIndex].minScaleX:0;
			clip.minScaleY = (attr.actors[selectIndex].minScaleY != null)?attr.actors[selectIndex].minScaleY:0;
			clip.scaleXStep = attr.actors[selectIndex].scaleXStep;
			clip.scaleYStep = attr.actors[selectIndex].scaleYStep;
			clip.props = attr.actors[selectIndex].props;
			clip.gotoAndStop(attr.actors[selectIndex].frame);
			clip.x = selectClip.x;
			clip.y = selectClip.y;
			clip.funcTransform = attr.actors[selectIndex].funcTransform;
			var p:Object = (attr.actors[selectIndex].param != null)?Data.clone(attr.actors[selectIndex].param): { };
			p.name = "a" + id;
			actors.push( { id:id, tiled:clip.tiled, rotate:clip.rotate, resize:clip.resize, maxScaleX:clip.maxScaleX, maxScaleY:clip.maxScaleY, minScaleX:clip.minScaleX, minScaleY:clip.minScaleY, scaleXStep:clip.scaleXStep, scaleYStep:clip.scaleYStep, funcTransform:attr.actors[selectIndex].funcTransform, layer:attr.layers[selectLayerIndex].name, layer_id:selectLayerIndex, type:attr.actors[selectIndex].type, title:attr.actors[selectIndex].title, clip:clip, x:clip.x, y:clip.y, angle:AngleUtils.normal(clip.rotation), props:p, scaleX:1, scaleY:1 } );
			LAYERS[selectLayer].addChild(clip);
			
			/*var o:Object = getObject(id);
			property.show(o.title, o.props, clip.props);*/
			showProperty(clip);
			property.hide();
			
			if(selectClip != null) selectClip.parent.setChildIndex(selectClip, selectClip.parent.numChildren - 1);
		}
		protected function addActor(type:String, x:Number, y:Number, props:Object):MovieClip {
			var clip:MovieClip;
			var id:int = ++_ids;
			var def:Object = getActorDef(type);
			clip = new def.cls();
			SpriteUtils.stopAll(clip);
			clip.id = id;
			clip.layer_id = selectLayerIndex;
			clip.tiled = def.tiled;
			clip.rotate = def.rotate;
			clip.resize = def.resize;
			clip.maxScaleX = (def.maxScaleX != null)?def.maxScaleX:Infinity;
			clip.maxScaleY = (def.maxScaleY != null)?def.maxScaleY:Infinity;
			clip.minScaleX = (def.minScaleX != null)?def.minScaleX:0;
			clip.minScaleY = (def.minScaleY != null)?def.minScaleY:0;
			clip.scaleXStep = def.scaleXStep;
			clip.scaleYStep = def.scaleYStep;
			clip.props = def.props;
			clip.gotoAndStop(def.frame);
			clip.x = x;
			clip.y = y;
			clip.funcTransform = def.funcTransform;
			var p:Object = (def.param != null)?Data.clone(def.param): { };
			for (var key:String in props) {
				p[key] = props[key];
			}
			p.name = "a" + id;
			var layer_id:int = getLayerId(def.layer);
			actors.push( { id:id, tiled:clip.tiled, rotate:clip.rotate, resize:clip.resize, maxScaleX:clip.maxScaleX, maxScaleY:clip.maxScaleY, minScaleX:clip.minScaleX, minScaleY:clip.minScaleY, scaleXStep:clip.scaleXStep, scaleYStep:clip.scaleYStep, funcTransform:def.funcTransform, layer:def.layer, layer_id:layer_id, type:def.type, title:def.title, clip:clip, x:clip.x, y:clip.y, angle:AngleUtils.normal(clip.rotation), props:p, scaleX:1, scaleY:1 } );
			LAYERS[layer_id].addChild(clip);
			
			return clip;
		}
		protected function modifyFind(x:Number, y:Number):void {
			var i:int;
			var j:int;
			var clip:MovieClip;
			
			var a:Array = actors.concat([]);
			a.sort(_sortByLayer);
			
			for (i = a.length-1; i >= 0; --i) {
				clip = a[i].clip;
				if (clip.hitTestPoint(x, y, true)) {
					modifyClip(clip);
					return;
				}
			}
			
			if (!is_shift) {
				unModify();
				showMapProperty();
			}
		}
		protected function objectFind(x:Number, y:Number, halfsize:Number):Object {
			var i:int;
			var j:int;
			var clip:MovieClip;
			
			var a:Array = actors.concat([]);
			a.sort(_sortByLayer);
			
			var r:Rectangle = new Rectangle(x - halfsize, y - halfsize, halfsize * 2, halfsize * 2);
			
			for (i = a.length-1; i >= 0; --i) {
				clip = a[i].clip;
				if (r.containsPoint(new Point(clip.x, clip.y))) {
					return getObject(clip.id);
				}
			}
			return null;
		}
		protected function modifyClip(clip:MovieClip):void {
			//if (transformTool.target != clip) property.hide();
			if (transformManager.length == 1 && transformManager.getObjectAt(0) != clip) property.hide();
			
			//GAME.addChild(transformTool);
			//transformTool.parent.setChildIndex(transformTool, transformTool.parent.numChildren - 1);
			transformManager.tool.parent.setChildIndex(transformManager.tool, transformManager.tool.parent.numChildren - 1);
			//transformTool.target = clip;
			/*var rotate:Number = Number((transformTool.target as MovieClip).rotate);
			if (rotate > 0) {
				if (rotate >= 360) {
					transformTool.rotationEnabled = false;
				} else {
					transformTool.rotationEnabled = true;
					transformTool.constrainRotation = true;
					transformTool.constrainRotationAngle = rotate;
				}
			} else {
				transformTool.rotationEnabled = true;
				transformTool.constrainRotation = false;
				//transformTool.constrainRotationAngle = 0;
			}
			if (!Boolean((transformTool.target as MovieClip).resize)) {
				transformTool.scaleEnabled = false;
			} else {
				transformTool.scaleEnabled = true;
			}
			lastTarget = clip;*/
			
			if (!is_shift) transformManager.clear();
			if(transformManager.length == 0) {
				lstLayers.selectedIndex = clip.layer_id;
				lstLayers.dispatchEvent(new Event(Event.CHANGE));
			}
			
			transformManager.add(clip, clip.resize, clip.rotate < 360, clip.rotate, clip.maxScaleX, clip.maxScaleY, clip.minScaleX, clip.minScaleY);
			showProperty(clip);
			
			lastSelection = clip;
		}
		protected function unModify():void {
			//transformTool.target = null;
			if (transformManager.length > 0) {
				transformManager.clear();
			}
			property.hide();
		}
		
		protected function onListLayerChange(e:Event):void {
			selectLayerIndex = lstLayers.selectedItem.data;
			selectLayer = attr.layers[selectLayerIndex].id;
			
			select(-1);
			unModify();
			is_down = false;
			is_drag = false;
			GAME.stopDrag();
			
			stage.focus = null;
			
			var i:int;
			while (lstActors.length > 0) lstActors.removeItemAt(0);
			if (attr.actors != null && attr.actors is Array && attr.actors.length > 0) {
				lstActors.addItem({label:"[ No selection ]", data:-1});
				for (i = 0; i < attr.actors.length; i++) {
					if(attr.actors[i].layer == attr.layers[selectLayerIndex].name) {
						lstActors.addItem( { label:attr.actors[i].title, data:i } );
					}
				}
			}
			updateCells();
		}
		protected function onListActorChange(e:Event):void {
			if (lstActors.selectedIndex <= 0) {
				select();
				return;
			}
			
			select(lstActors.selectedItem.data);
			unModify();
			
			stage.focus = null;
		}
		
		protected function updateCells():void {
			var i:int;
			var g:Graphics = CELLS.graphics;
			g.clear();
			var cells:int = cellSize = int(attr.layers[selectLayerIndex].cells);
			if (cells > 0) {
				/*var cellsCount:int = int(attr.layers[selectLayerIndex].cellsCount);
				if (cellsCount <= 0) cellsCount = 100;*/
				var cellsCount:int;
				g.lineStyle(1, 0x000000, 0.05);
				cellsCount = /*attr.maxWidth*/stage.stageWidth / cells + 10;
				for (i = 1; i < cellsCount; i++) {
					g.moveTo(i * cells, 0);
					g.lineTo(i * cells, stage.stageHeight + cells * 10);
					
					if (i % 10 == 0) {
						g.beginFill(0xff0000, 0.02);
						g.drawRect(i * cells, 0, cells, stage.stageHeight + cells * 10);
						g.endFill();
					}
				}
				cellsCount = /*attr.maxHeight*/stage.stageHeight / cells + 10;
				for (i = 1; i < cellsCount; i++) {
					g.moveTo(0, i * cells);
					g.lineTo(stage.stageWidth + cells * 10, i * cells);
					
					if (i % 10 == 0) {
						g.beginFill(0xff0000, 0.02);
						g.drawRect(0, i * cells, stage.stageWidth + cells * 10, cells);
						g.endFill();
					}
				}
				CELLS.x = -int(CELLS.parent.x / (cellSize * 10)) * cellSize * 10 - CAMERA.x;
				CELLS.y = -int(CELLS.parent.y / (cellSize * 10)) * cellSize * 10 - CAMERA.y;
				//CELLS.x = -int((GAME.x) / (cellSize * 10)) * cellSize * 10 - CAMERA.x;// + 8;
				//CELLS.y = -int((GAME.y) / (cellSize * 10)) * cellSize * 10 - CAMERA.y;// + 6;
			}
		}
		
		protected function onKeyDown(e:KeyboardEvent):void {
			if (!visible) return;
			if (stage.focus is TextField) {
				//trace("stage.focus: "+stage.focus);
				return;
			}
			
			var i:int;
			var clip:MovieClip;
			
			trace(String.fromCharCode(e.charCode) + " = " + e.keyCode);
			
			is_ctrl = e.ctrlKey;
			is_shift = e.shiftKey;
			
			if (e.keyCode == Keyboard.ESCAPE) {
				is_down = false;
				is_drag = false;
				GAME.stopDrag();
					
				//if (transformTool.target == null) {
				if(transformManager.length == 0) {
					select(-1);
				} else {
					unModify();
				}
			}
			if (e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.BACKSPACE) { // delete blocks
				//if (transformTool.target != null) {
				if(transformManager.length > 0) {
					//removeObject((transformTool.target as MovieClip).id);
					for (i = 0; i < transformManager.length; i++) {
						removeObject((transformManager.getObjectAt(i) as MovieClip).id);
					}
					unModify();
				}
			}
			
			if (e.keyCode == KeyboardUtils.F) { // to front
				//if (transformTool.target != null) {
				if(transformManager.length > 0) {
					//objectToFront((transformTool.target as MovieClip).id);
					for (i = 0; i < transformManager.length; i++) {
						objectToFront((transformManager.getObjectAt(i) as MovieClip).id);
					}
				}
			} else if (e.keyCode == KeyboardUtils.B) { // to back
				//if (transformTool.target != null) {
				if(transformManager.length > 0) {
					//objectToBack((transformTool.target as MovieClip).id);
					for (i = 0; i < transformManager.length; i++) {
						objectToBack((transformManager.getObjectAt(i) as MovieClip).id);
					}
				}
			}
			
			if (is_shift) {
				var p:Object = { x:0, y:0 };
				if (e.keyCode == Keyboard.UP) {
					p.y -= 1;
				} else if (e.keyCode == Keyboard.DOWN) {
					p.y += 1;
				} else if (e.keyCode == Keyboard.LEFT) {
					p.x -= 1;
				} else if (e.keyCode == Keyboard.RIGHT) {
					p.x += 1;
				}
				for (i = 0; i < actors.length; i++) {
					actors[i].clip.x += p.x;
					actors[i].clip.y += p.y;
				}
			} else {
			
				//if (transformTool.target != null) {
				if(transformManager.length > 0) {
					if (cellSize > 0) {
						
					} else {
						if (e.keyCode == Keyboard.UP) {
							//transformTool.target.y -= 1;
							transformManager.tool.target.y -= 1;
						} else if (e.keyCode == Keyboard.DOWN) {
							//transformTool.target.y += 1;
							transformManager.tool.target.y += 1;
						} else if (e.keyCode == Keyboard.LEFT) {
							//transformTool.target.x -= 1;
							transformManager.tool.target.x -= 1;
						} else if (e.keyCode == Keyboard.RIGHT) {
							//transformTool.target.x += 1;
							transformManager.tool.target.x += 1;
						}
						//modClip.x = modTarget.x + GAME.x + CAMERA.x;
						//modClip.y = modTarget.y + GAME.y + CAMERA.y;
						//transformTool.toolMatrix = transformTool.target.transform.concatenatedMatrix;
						transformManager.tool.toolMatrix = transformManager.tool.target.transform.concatenatedMatrix; //???
					}
					
					if (e.keyCode == KeyboardUtils.P) {
						//showProperty(transformTool.target as MovieClip);
						if (transformManager.length == 1) {
							showProperty(transformManager.getObjectAt(0) as MovieClip);
						}
					}
				}
				
			}
			
			if (is_ctrl) {
				if (e.keyCode == KeyboardUtils.D) {
					var arr:Array = [];
					var o:Object;
					for (i = 0; i < transformManager.length; i++) {
						arr.push(transformManager.getObjectAt(i));
					}
					transformManager.clear();
					for (i = 0; i < arr.length; i++) {
						clip = arr[i];
						o = getObject(clip.id);
						clip = addActor(o.type, clip.x + 20, clip.y + 20, o.props);
						
						transformManager.add(clip, clip.resize, clip.rotate < 360, clip.rotate, clip.maxScaleX, clip.maxScaleY, clip.minScaleX, clip.minScaleY, false);
					}
					transformManager.updateSelection();
					if (transformManager.length == 1) showProperty(clip);
				}
			}
			
			if (e.keyCode == Keyboard.TAB) {
				//if (transformTool.target != null) {
				if(transformManager.length == 1) {
					//clip = transformTool.target as MovieClip;
					clip = transformManager.getObjectAt(0) as MovieClip;
					var aidx:int = getObjectIdx(clip.id);
					if (is_shift) {
						aidx--;
					} else {
						aidx++;
					}
					if (aidx < 0) aidx = actors.length - 1;
					if (aidx >= actors.length) aidx = 0;
					
					//transformTool.target = actors[aidx].clip;
					modifyClip(actors[aidx].clip);
				} else if(actors.length > 0) {
					//transformTool.target = actors[0].clip;
					modifyClip(actors[0].clip);
				}
				stage.focus = stage;
			}
		}
		protected function onKeyUp(e:KeyboardEvent):void {
			if (!visible) return;
			is_ctrl = e.ctrlKey;
			is_shift = e.shiftKey;
		}
		protected function onMouseDown(e:MouseEvent):void {
			if (!visible) return;
			is_down = true;
			downX = e.stageX;
			downY = e.stageY;
			
			if (selectIndex < 0) {
				modifyFind(e.stageX, e.stageY);
			}
		}
		protected function onMouseUp(e:MouseEvent):void {
			if (!visible) return;
			
			addCellX = NaN;
			addCellY = NaN;
			
			if (selectIndex < 0 && is_ctrl && is_down) {
				var a:Array = actors.concat([]);
				a.sort(_sortByLayer);
				
				var r:Rectangle = new Rectangle();
				if (selectFrame.scaleX > 0)
					r.x = selectFrame.x;
				else
					r.x = selectFrame.x - selectFrame.width;
				r.width = selectFrame.width;
				if (selectFrame.scaleY > 0)
					r.y = selectFrame.y;
				else
					r.y = selectFrame.y - selectFrame.height;
				r.height = selectFrame.height;
				var clip:MovieClip;
				var ish:Boolean = is_shift;
				is_shift = true;
				
				property.hide();
				transformManager.clear();
				for (var i:int = a.length-1; i >= 0; --i) {
					clip = a[i].clip;
					if (selectFrame.hitTestObject(clip)) {
						//modifyClip(clip);
						transformManager.add(clip, clip.resize, clip.rotate < 360, clip.rotate, clip.maxScaleX, clip.maxScaleY, clip.minScaleX, clip.minScaleY, false);
					}
				}
				transformManager.updateSelection();
				if (transformManager.length == 1) showProperty(clip);
				is_shift = ish;
				selectFrame.visible = false;
				is_down = false;
				return;
			}
			
			//if (transformTool.target != null) {
			if (transformManager.length > 0) {
				is_down = false;
				return;
			}
			
			if(is_drag) {
				is_drag = false;
				GAME.stopDrag();
			} else {
				if (selectIndex != -1) {
					addSelected();
				}
			}
			
			is_down = false;
		}
		protected function onMouseMove(e:MouseEvent):void {
			if (!visible) return;
			
			var cellX:int = int((e.stageX - GAME.x - CAMERA.x) / cellSize);
			if (e.stageX < 0) cellX--;
			var cellY:int = int((e.stageY - GAME.y - CAMERA.y) / cellSize);
			if (e.stageY < 0) cellY--;
			
			//if (transformTool.target != null) {
			if (transformManager.length > 0) {
				return;
			}
			
			if (is_ctrl && is_down) {
				selectFrame.visible = true;
				selectFrame.x = downX;
				selectFrame.y = downY;
				selectFrame.scaleX = (e.stageX - selectFrame.x) / 100;
				selectFrame.scaleY = (e.stageY - selectFrame.y) / 100;
				
				return;
			}
			
			
			
			if (!is_ctrl && is_down && is_tiles && cellSize > 0 && selectClip != null) {
				trace("TILE DRAW...");
				if (cellX != addCellX || cellY != addCellY) {
					trace("CELLS DONE!!!");
					var o:Object = objectFind(cellX * cellSize + cellSize * 0.5, cellY * cellSize + cellSize * 0.5, cellSize * 0.1);
					if(o != null) {
						removeObject(o.id);
					}
					addSelected();
					addCellX = cellX;
					addCellY = cellY;
				}
				
				updateSelectPosition(e);
				
				return;
			}
			
			if (is_down && !is_drag) {
				if (Math.abs(downX - e.stageX) > 3 || Math.abs(downY - e.stageY) > 3) {
					is_drag = true;
					GAME.startDrag();
				}
			}
			if (is_down && is_drag && cellSize > 0) {
				CELLS.x = -int(CELLS.parent.x / (cellSize * 10)) * cellSize * 10 - CAMERA.x;
				CELLS.y = -int(CELLS.parent.y / (cellSize * 10)) * cellSize * 10 - CAMERA.y;
			}
			
			updateSelectPosition(e);
		}
		private function updateSelectPosition(e:MouseEvent):void {
			if (selectClip != null) {
				var cX:Number = e.stageX - GAME.x - CAMERA.x;// + selectOffset.x;
				var cY:Number = e.stageY - GAME.y - CAMERA.y;// + selectOffset.y;
				if (cX < 0) cX -= cellSize;
				if (cY < 0) cY -= cellSize;
				if (cellSize > 0 && (is_ctrl != attr.actors[selectIndex].tiled)) {
				//if (cellSize > 0 && (isTiled(selectClip))) {
					cX = int((cX) / cellSize) * cellSize + cellSize * 0.5;
					cY = int((cY) / cellSize) * cellSize + cellSize * 0.5;
				} else {
					cX -= selectOffset.x;
					cY -= selectOffset.y;
				}
				selectClip.x = cX;
				selectClip.y = cY;
			}
		}
		private function onMouseLeave(e:Event):void {
			//trace("Mouse leave.");
			//unModify();
			if(is_drag) {
				is_drag = false;
				GAME.stopDrag();
			}
			is_down = false;
		}
		private function onResize(e:Event):void {
			if (stage == null) return;
			back.scaleX = stage.stageWidth / 100;
			back.scaleY = stage.stageHeight / 100;
			
			updateCells();
			
			trace(back.width, back.height);
		}
		
		protected function getObject(id:int):Object {
			var idx:int = getObjectIdx(id);
			if (idx < 0) return null;
			return actors[idx];
		}
		protected function getObjectIdx(id:int):int {
			for (var i:int = 0; i < actors.length; i++) {
				if (actors[i].id == id) {
					return i;
				}
			}
			return -1;
		}
		protected function getActorTitle(type:String):String {
			for (var i:int = 0; i < attr.actors.length; i++) {
				if (attr.actors[i].type == type) return attr.actors[i].title;
			}
			return "Unknown object";
		}
		protected function removeObject(id:int):void {
			var obj:Object = getObject(id);
			if (obj == null) return;
			LAYERS[obj.layer_id].removeChild(obj.clip);
			actors.splice(actors.indexOf(obj), 1);
		}
		protected function objectToFront(id:int):void {
			var a:Object = getObject(id);
			var idx:int = actors.indexOf(a);
			if(idx >= 0) {
				actors.splice(idx, 1);
				actors.push(a);
				SpriteUtils.toFront(a.clip);
			}
		}
		protected function objectToBack(id:int):void {
			var a:Object = getObject(id);
			var idx:int = actors.indexOf(a);
			if(idx >= 0) {
				actors.splice(idx, 1);
				actors.unshift(a);
				SpriteUtils.toBack(a.clip);
			}
		}
		
		protected function genXml():String {
			onChangeTarget();
			unModify();
			
			var i:int;
			var j:int;
			var dt:Date = new Date();
			if (mapUid == null || mapUid == "") mapUid = MD5.hash(dt.valueOf().toString());
			if (map_props.map != null) {
				mapId = int(map_props.map);
			}
			
			var s:String = "<data uid='" + mapUid + "' map='" + mapId + "' author='" + String(attr.author) + "'>\n";
			
			// properties
			s += "\t" + _genNodeFromObject("properties", map_props) + "\n";
			
			// layers
			s += "\t<layers>\n";
			for (i = 0; i < attr.layers.length; i++) {
				s += "\t\t"+_genNodeFromObject("layer", attr.layers[i])+"\n";
			}
			s += "\t</layers>\n";
			
			// actors
			s += "\t<actors ids='"+_ids+"'>\n";
			for (i = 0; i < actors.length; i++) {
				s += "\t\t"+_genNodeFromObject("actor", actors[i])+"\n";
			}
			s += "\t</actors>\n";
			
			s += "</data>";
			
			return s;
		}
		public function clear():void {
			unModify();
			select();
			for (var i:int = 0; i < actors.length; i++) {
				if (actors[i].clip != null && actors[i].clip.parent != null) {
					actors[i].clip.parent.removeChild(actors[i].clip);
				}
			}
			actors = [];
		}
		public function loadLevel(str:String):Boolean {
			is_loading = true;
			
			addCellX = addCellY = NaN;
			
			var xml:XML;
			try {
				xml = new XML(str);
			} catch (err:Error) {
				trace(str);
				trace(err.message);
				return false;
			}
			
			//trace("XML:\n"+str);
			
			mapUid = String(xml.@uid);
			mapId = int(xml.@map);
			map_props = XmlUtils.nodeAttributesToObject(xml.properties[0]);
			if (map_props == null) map_props = { };
			
			_ids = int(xml.actors.@ids);
			
			var minGameX:Number = Number.MAX_VALUE;
			var minGameY:Number = Number.MAX_VALUE;
			var focusActorClip:MovieClip = null;
			
			var id:int;
			var max_id:int = -1;
			var clip:MovieClip;
			var n:XML;
			var def:Object;
			var layer_id:int;
			for (var i:int = 0; i < xml.actors.actor.length(); i++) {
				n = xml.actors.actor[i];
				
				def = getActorDef(String(n.@type));
				if (def == null) continue;
				//trace("Actor: " + def.type);
				
				//layer_id = getLayerId(String(n.@layer));
				layer_id = getLayerId(def.layer);
				if (layer_id < 0) continue;
				//trace("Layer: "+n.@layer+", #"+layer_id);
				
				id = int(n.@id);
				if (id <= max_id) id = ++_ids;
				max_id = id;
				
				clip = new def.cls();
				clip.id = id;
				clip.layer_id = layer_id;
				clip.tiled = def.tiled;
				clip.rotate = def.rotate;
				clip.resize = def.resize;
				clip.maxScaleX = def.maxScaleX;
				clip.maxScaleY = def.maxScaleY;
				clip.minScaleX = def.minScaleX;
				clip.minScaleY = def.minScaleY;
				clip.scaleXStep = def.scaleXStep;
				clip.scaleYStep = def.scaleYStep;
				clip.props = def.props;
				clip.funcTransform = def.funcTransform;
				clip.gotoAndStop(def.frame);
				clip.x = Number(n.@x);
				clip.y = Number(n.@y);
				//trace("scaleX:", n.@scaleX, ", scaleY:", n.@scaleY);
				if(String(n.@scaleX) != "") clip.scaleX = Number(n.@scaleX);
				if(String(n.@scaleY) != "") clip.scaleY = Number(n.@scaleY);
				if (clip.x < minGameX) minGameX = clip.x;
				if (clip.y < minGameY) minGameY = clip.y;
				//trace("Load object #" + clip.id + " angle: " + n.@angle);
				clip.rotation = Number(n.@angle);
				var actor_props:Object = XmlUtils.nodeAttributesToObject(n.props[0]);
				if (actor_props == null) actor_props = { };
				actors.push( {
					id:id, tiled:def.tiled, 
					rotate:def.rotate, 
					resize:def.resize, maxScaleX:def.maxScaleX, maxScaleY:def.maxScaleY, minScaleX:def.minScaleX, minScaleY:def.minScaleY, scaleXStep:def.scaleXStep, scaleYStep:def.scaleYStep, 
					funcTransform:def.funcTransform, 
					layer:LAYERS[layer_id].name, layer_id:layer_id, 
					type:String(n.@type), 
					clip:clip, x:clip.x, y:clip.y, angle:Number(n.@angle), scaleX:clip.scaleX, scaleY:clip.scaleY, 
					props:actor_props 
				} );
				LAYERS[layer_id].addChild(clip);
				
				var o:Object = getObject(clip.id);
				property.show(getActorTitle(o.type), o.props, clip.props, o);
				property.hide();
				
				if (def.type == attr.focusActorType) {
					focusActorClip = clip;
				}
			}
			
			if(focusActorClip == null) {
				GAME.x = 100 - minGameX - CAMERA.x;
				GAME.y = 100 - minGameY - CAMERA.y;
			} else {
				GAME.x = -focusActorClip.x;
				GAME.y = -focusActorClip.y;
			}
			
			is_loading = false;
			
			return true;
		}
		protected function getActorDef(type:String):Object {
			for (var i:int = 0; i < attr.actors.length; i++) {
				if (attr.actors[i].type == type) return attr.actors[i];
			}
			return null;
		}
		protected function getLayerId(name:String):int {
			for (var i:int = 0; i < LAYERS.length; i++) {
				if (LAYERS[i].name == name) return i;
			}
			return -1;
		}
		protected function _genNodeFromObject(name:String, obj:Object):String {
			var key:String;
			var s:String = "<" + name + " ";
			var params:Array = [];
			var once:Boolean = true;
			var ss:String;
			for (key in obj) {
				if (obj[key] is String || obj[key] is Number) {
					//ss = obj[key];
					//ss = StringUtils.replace(obj[key], "\"", "\\\"");
					ss = StringUtils.replace(obj[key], "\"", "&quot;");
					ss = StringUtils.replace(ss, "\'", "&#039;");
					s += key + "='" + ss + "' ";
				}
			}
			/*for (key in obj) {
				if (!(obj[key] is String) && !(obj[key] is Number) && obj[key] is Object) {
					if (once) {
						s += ">\n";
						once = false;
					}
					s += _genNodeFromObject(key, obj[key]);
				}
			}*/
			if (obj["props"] != null) {
				once = false;
				s += ">\n";
				s += "\t\t\t"+_genNodeFromObject("props", obj["props"])+"\n";
			}
			if (once) s += "/>";
			else s += "\t\t</"+name+">";
			return s;
		}
		protected function _copyObject(src:Object, dst:Object = null):void {
			//if()
		}
		
		public function startPreview():void {
			select();
			unModify();
			
			back.visible = false;
			CELLS.visible = false;
			GUI.visible = false;
			property.hide();
			
			var i:int;
			for (i = 0; i < attr.layers.length; i++) {
				if (attr.layers[i].snapshot != null && attr.layers[i].snapshot == false) {
					LAYERS[attr.layers[i].id].visible = false;
				}
			}
		}
		public function endPrevieew():void {
			var i:int;
			for (i = 0; i < LAYERS.length; i++) {
				LAYERS[i].visible = true;
			}
			back.visible = true;
			CELLS.visible = true;
			GUI.visible = true;
		}
		
		public function getMapSnapshot(width:int = 0):Bitmap {
			startPreview();
			
			var k:Number = 1;
			var height:int = getScreenHeight();
			if (width <= 0) {
				width = getScreenWidth();
			} else {
				k = width / getScreenWidth();
				height = getScreenHeight() * k;
			}
			
			var clip:DisplayObject = stage;
			if (clip == null) clip = this;
			if (clip == null) clip = CAMERA;
			
			var bd:BitmapData = new BitmapData(width, height, false, bgColor);
			//var mtx:Matrix = CAMERA.transform.matrix.clone();
			//mtx.createBox(k, k, 0, CAMERA.x * k, CAMERA.y * k);
			var mtx:Matrix = clip.transform.matrix.clone();
			mtx.createBox(k, k, 0, clip.x * k, clip.y * k);
			bd.draw(clip, mtx, null, null, null, true);
			var bmp:Bitmap = new Bitmap(bd, "auto", true);
			
			endPrevieew();
			
			return bmp;
		}
		
		private function onTransformTarget(e:Event = null):void {
			//if (transformManager.length == 0 || transformManager.length > 1) return;
			//var target:MovieClip = transformManager.getObjectAt(0) as MovieClip;
			
			/*if (currentCells > 0 && (!is_ctrl || target.tiled)) {
				target.x = int(int((target.x - currentCells * 0.5) / currentCells) * currentCells + currentCells * 0.5);
				target.y = int(int((target.y - currentCells * 0.5) / currentCells) * currentCells + currentCells * 0.5);
			}*/
			/*if (target.scaleXStep != null && target.scaleXStep > 0) {
				target.scaleX = int(target.scaleX / target.scaleXStep) * target.scaleXStep;
			}
			if (target.scaleYStep != null && target.scaleYStep > 0) {
				target.scaleY = int(target.scaleY / target.scaleYStep) * target.scaleYStep;
			}*/
			
			onChangeTarget();
			
			//transformManager.toolMatrix = target.transform.concatenatedMatrix.clone();
			
			/*if (currentCells > 0 && (!is_ctrl || (transformTool.target as MovieClip).tiled)) {
				transformTool.target.x = int((transformTool.target.x - currentCells * 0.5) / currentCells) * currentCells + currentCells * 0.5;
				transformTool.target.y = int((transformTool.target.y - currentCells * 0.5) / currentCells) * currentCells + currentCells * 0.5;
			}
			
			if ((transformTool.target as MovieClip).funcTransform != null) {
				(transformTool.target as MovieClip).funcTransform(transformTool.target);
			}
			
			transformTool.toolMatrix = transformTool.target.transform.concatenatedMatrix;*/
		}
		private function onChangeTarget(e:Event = null):void {
			trace("onChangeTarget");
			//if (lastTarget == null) return;
			var i:int;
			var len:int = transformManager.length;
			var target:MovieClip;
			var cells:int;
			for (i = 0; i < len; ++i) {
				target = transformManager.getObjectAt(i) as MovieClip;
				var o:Object = getObject(target.id);
				trace(i + ". " + target + ", " + o.type, target.scaleX, target.scaleY);
				if (o != null) {
					cells = int(attr.layers[target.layer_id].cells);
					//if (cells > 0 && (!is_ctrl || target.tiled)) {
					if (cells > 0 && isTiled(target)) {
						target.x = int(int((target.x - (target.x < 0?cells:0) /*- cells * 0.5*/) / cells) * cells + cells * 0.5);
						target.y = int(int((target.y - (target.y < 0?cells:0)/*- cells * 0.5*/) / cells) * cells + cells * 0.5);
					}
					if (target.scaleXStep != null && target.scaleXStep > 0) {
						target.scaleX = int(target.scaleX / target.scaleXStep) * target.scaleXStep;
					}
					if (target.scaleYStep != null && target.scaleYStep > 0) {
						target.scaleY = int(target.scaleY / target.scaleYStep) * target.scaleYStep;
					}
					o.x = int(target.x);
					o.y = int(target.y);
					o.scaleX = target.scaleX;
					o.scaleY = target.scaleY;
					o.angle = AngleUtils.normal(target.rotation);
				}
			}
			//lastTarget = null;
		}
		
		protected function isTiled(target:MovieClip):Boolean {
			return is_ctrl != target.tiled;
		}
		
		private function onClick_Props(e:MouseEvent):void {
			showMapProperty();
		}
		
		protected function showProperty(clip:MovieClip):void {
			if (clip != null && transformManager.length <= 1 && clip.props != null) {
				var o:Object = getObject(clip.id);
				property.show(getActorTitle(o.type), o.props, clip.props, o);
			}
		}
		protected function showMapProperty():void {
			property.show("Properties", map_props, attr.props);
		}
		
		protected function getScreenWidth():Number {
			return stage.stageWidth;
		}
		protected function getScreenHeight():Number {
			return stage.stageHeight;
		}
		
		private function _sortByLayer(p1:Object, p2:Object):int {
			if (p1.layer_id < p2.layer_id) return -1;
			else if (p1.layer_id > p2.layer_id) return 1;
			else return 0;
		}
	}
}