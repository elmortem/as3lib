package elmortem.game.editor {
	import com.adobe.crypto.MD5;
	import com.adobe.images.BitString;
	import com.senocular.display.TransformTool;
	import elmortem.states.State;
	import elmortem.types.Vec2;
	import elmortem.utils.AngleUtils;
	import elmortem.utils.KeyboardUtils;
	import elmortem.utils.StringUtils;
	import elmortem.utils.XmlUtils;
	import fl.controls.ComboBox;
	import fl.controls.TextInput;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class Editor2State extends State {
		static protected var _ids:int = 0;
		// options
		//private var 
		
		// layers
		protected var CAMERA:Sprite;
		protected var GAME:Sprite;
			protected var LAYERS:/*Sprite*/Array;
			protected var CELLS:Sprite;
		protected var GUI:Sprite;
		
		// gui
		protected var bgColor:int;
		protected var back:Sprite;
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
		
		// transform
		private var transformTool:TransformTool;
		private var lastTarget:MovieClip = null;
		private var currentCells:int;
		
		// property
		private var property:GuiProperty;
		
		// level ID
		protected var mapUid:String;
		
		public function Editor2State(attrIn:Object = null) {
			super(attrIn);
			if (attr == null) attr = { };
		}
		override protected function init():void {
			var i:int;
			var j:int;
			var g:Graphics;
		
			super.init();
			
			bgColor = (attr.color != null)?attr.color:0xffffff;
			back = new Sprite();
			g = back.graphics;
			g.lineStyle();
			g.beginFill(bgColor, 1);
			g.drawRect(0, 0, 100, 100);
			g.endFill();
			addChild(back);
			
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
			GUI = createLayer("GAME", this);
			
			if (attr.maxWidth == null) attr.maxWidth = getScreenWidth();
			if (attr.maxHeight == null) attr.maxHeight = getScreenHeight();
			
			/*g = GAME.graphics;
			g.lineStyle(1, 0x990000, 0.7);
			g.beginFill(0x00, 0);
			g.drawRect(0, 0, attr.maxWidth, attr.maxHeight);
			g.endFill();*/
				
			g = GAME.graphics;
			g.lineStyle(1, 0x999999, 0.7);
			g.beginFill(0x00, 0);
			g.drawRect(0, 0, getScreenWidth(), getScreenHeight());
			g.endFill();
			
			// gui
			gui = attr.gui;
			GUI.addChild(gui);
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
			
			// transform
			transformTool = new TransformTool();
			transformTool.registrationEnabled = false;
			transformTool.rememberRegistration = false;
			transformTool.skewEnabled = false;
			transformTool.addEventListener(TransformTool.TRANSFORM_TARGET, onTransformTarget);
			transformTool.addEventListener(TransformTool.NEW_TARGET, onNewTarget);
			stage.addChild(transformTool);
			
			// property
			stage.addChild(property = new GuiProperty());
			//property.x = getScreenWidth() - 200;
			property.x = 0;
			property.y = 40; 
			
			// objects
			actors = [];
			
			back.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			back.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			back.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			stage.addEventListener(Event.RESIZE, onResize);
			
			// activate layer
			lstLayers.selectedIndex = 0;
			lstLayers.dispatchEvent(new Event(Event.CHANGE));
			
			mapUid = "";
			
			if (attr.data != null && attr.data.levelStr != null) loadLevel(attr.data.levelStr);
			
			stage.focus = stage;
			
			onResize(null);
		}
		override public function free():void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			back.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			back.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			back.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			lstLayers.removeEventListener(Event.CHANGE, onListLayerChange);
			lstActors.removeEventListener(Event.CHANGE, onListActorChange);
			
			actors = [];
			
			removeAllChilds();
			
			lstLayers.removeEventListener(Event.CHANGE, onListLayerChange);
			lstActors.removeEventListener(Event.CHANGE, onListActorChange);
			
			gui = null;
			
			transformTool.target = null;
			stage.removeChild(transformTool);
			
			stage.removeChild(property);
			property.free();
			property = null;
			
			super.free();
		}
		
		protected function select(index:int = -1):void {
			// clear
			unModify();
			if (selectIndex != -1) {
				selectClip.parent.removeChild(selectClip);
				selectClip = null;
				selectIndex = -1;
			}
			
			// add
			selectIndex = index;
			
			if (selectIndex == -1) {
				lstActors.selectedIndex = 0;
				return;
			}
			
			var act:Object = attr.actors[selectIndex];
			
			selectClip = new act.cls();
			selectClip.gotoAndStop(int(act.frame));
			selectClip.mouseChildren = false;
			selectClip.mouseEnabled = false;
			selectClip.alpha = 0.7;
			LAYERS[selectLayer].addChild(selectClip);
		}
		protected function addSelected():void {
			var clip:MovieClip;
			var id:int = ++_ids;
			clip = new attr.actors[selectIndex].cls();
			clip.id = id;
			clip.layer_id = selectLayerIndex;
			clip.tiled = attr.actors[selectIndex].tiled;
			clip.rotate = attr.actors[selectIndex].rotate;
			clip.resize = attr.actors[selectIndex].resize;
			clip.props = attr.actors[selectIndex].props;
			clip.gotoAndStop(attr.actors[selectIndex].frame);
			clip.x = selectClip.x;
			clip.y = selectClip.y;
			clip.funcTransform = attr.actors[selectIndex].funcTransform;
			actors.push( { id:id, tiled:attr.actors[selectIndex].tiled, rotate:attr.actors[selectIndex].rotate, resize:attr.actors[selectIndex].resize, funcTransform:attr.actors[selectIndex].funcTransform, layer:attr.layers[selectLayerIndex].name, layer_id:selectLayerIndex, type:attr.actors[selectIndex].type, title:attr.actors[selectIndex].title, clip:clip, x:clip.x, y:clip.y, angle:AngleUtils.normal(clip.rotation), props:{} } );
			LAYERS[selectLayer].addChild(clip);
			
			/*var o:Object = getObject(id);
			property.show(o.title, o.props, clip.props);*/
			showProperty(clip);
			property.hide();
			
			selectClip.parent.setChildIndex(selectClip, selectClip.parent.numChildren - 1);
		}
		protected function modifyFind(x:Number, y:Number):void {
			var i:int;
			var j:int;
			var clip:MovieClip;
			
			for (i = actors.length-1; i >= 0; --i) {
				clip = actors[i].clip;
				if (clip.hitTestPoint(x, y, true)) {
					modifyClip(clip);
					return;
				}
			}
			
			unModify();
		}
		protected function modifyClip(clip:MovieClip):void {
			if (transformTool.target != clip) property.hide();
			lstLayers.selectedIndex = clip.layer_id;
			lstLayers.dispatchEvent(new Event(Event.CHANGE));
			//GAME.addChild(transformTool);
			transformTool.parent.setChildIndex(transformTool, transformTool.parent.numChildren - 1);
			transformTool.target = clip;
			var rotate:Number = Number((transformTool.target as MovieClip).rotate);
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
			}
			if (!Boolean((transformTool.target as MovieClip).resize)) {
				transformTool.scaleEnabled = false;
			} else {
				transformTool.scaleEnabled = true;
			}
			lastTarget = clip;
			
			showProperty(clip);
		}
		protected function unModify():void {
			transformTool.target = null;
			property.hide();
		}
		
		protected function onListLayerChange(e:Event):void {
			selectLayerIndex = lstLayers.selectedItem.data;
			selectLayer = attr.layers[selectLayerIndex].id;
			
			select();
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
			var g:Graphics = CELLS.graphics;
			g.clear();
			var cells:int = currentCells = int(attr.layers[selectLayerIndex].cells);
			if (cells > 0) {
				/*var cellsCount:int = int(attr.layers[selectLayerIndex].cellsCount);
				if (cellsCount <= 0) cellsCount = 100;*/
				var cellsCount:int;
				g.lineStyle(1, 0x000000, 0.05);
				cellsCount = attr.maxWidth / cells;
				for (i = 1; i < cellsCount; i++) {
					g.moveTo(i * cells, 0);
					g.lineTo(i * cells, attr.maxHeight);
				}
				cellsCount = attr.maxHeight / cells;
				for (i = 1; i < cellsCount; i++) {
					g.moveTo(0, i * cells);
					g.lineTo(attr.maxWidth, i * cells);
				}
			}
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
		
		protected function onKeyDown(e:KeyboardEvent):void {
			if (!visible) return;
			if (stage.focus is TextField) {
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
					
				if (transformTool.target == null) {
					select();
				} else {
					unModify();
				}
			}
			if (e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.BACKSPACE) {
				if (transformTool.target != null) {
					removeObject((transformTool.target as MovieClip).id);
					unModify();
				}
			}
			
			if (e.keyCode == KeyboardUtils.F) {
				if (transformTool.target != null) {
					objectToFront((transformTool.target as MovieClip).id);
				}
			} else if (e.keyCode == KeyboardUtils.B) {
				if (transformTool.target != null) {
					objectToBack((transformTool.target as MovieClip).id);
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
			
				if (transformTool.target != null) {
					if (currentCells > 0) {
						
					} else {
						if (e.keyCode == Keyboard.UP) {
							transformTool.target.y -= 1;
						} else if (e.keyCode == Keyboard.DOWN) {
							transformTool.target.y += 1;
						} else if (e.keyCode == Keyboard.LEFT) {
							transformTool.target.x -= 1;
						} else if (e.keyCode == Keyboard.RIGHT) {
							transformTool.target.x += 1;
						}
						//modClip.x = modTarget.x + GAME.x + CAMERA.x;
						//modClip.y = modTarget.y + GAME.y + CAMERA.y;
						transformTool.toolMatrix = transformTool.target.transform.concatenatedMatrix;
					}
					
					if (e.keyCode == 80/*P*/) {
						showProperty(transformTool.target as MovieClip);
					}
				}
				
			}
			
			if (e.keyCode == Keyboard.TAB) {
				if (transformTool.target != null) {
					clip = transformTool.target as MovieClip;
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
			if (transformTool.target != null) {
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
			if (transformTool.target != null) {
				return;
			}
			
			if (is_down && !is_drag) {
				if (Math.abs(downX - e.stageX) > 10 || Math.abs(downY - e.stageY) > 10) {
					is_drag = true;
					GAME.startDrag();
				}
			}
			
			if (selectClip != null) {
				var cX:Number = e.stageX - GAME.x - CAMERA.x;
				var cY:Number = e.stageY - GAME.y - CAMERA.y;
				if (currentCells > 0 && (!is_ctrl || attr.actors[selectIndex].tiled)) {
					cX = int((cX) / currentCells) * currentCells + currentCells * 0.5;
					cY = int((cY) / currentCells) * currentCells + currentCells * 0.5;
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
			}
		}
		protected function objectToBack(id:int):void {
			var a:Object = getObject(id);
			var idx:int = actors.indexOf(a);
			if(idx >= 0) {
				actors.splice(idx, 1);
				actors.unshift(a);
			}
		}
		
		protected function genXml():String {
			unModify();
			
			var i:int;
			var j:int;
			var dt:Date = new Date();
			if (mapUid == null || mapUid == "") mapUid = MD5.hash(dt.valueOf().toString());
			var s:String = "<data uid='" + mapUid + "' map='" + mapUid + "' author='" + String(attr.username) + "'>\n";
			
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
				
				layer_id = getLayerId(String(n.@layer));
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
				clip.props = def.props;
				clip.funcTransform = def.funcTransform;
				clip.gotoAndStop(def.frame);
				clip.x = Number(n.@x);
				clip.y = Number(n.@y);
				trace("scaleX:", n.@scaleX, ", scaleY:", n.@scaleY);
				if(String(n.@scaleX) != "") clip.scaleX = Number(n.@scaleX);
				if(String(n.@scaleY) != "") clip.scaleY = Number(n.@scaleY);
				if (clip.x < minGameX) minGameX = clip.x;
				if (clip.y < minGameY) minGameY = clip.y;
				//trace("Load object #" + clip.id + " angle: " + n.@angle);
				clip.rotation = Number(n.@angle);
				var actor_props:Object = XmlUtils.nodeAttributesToObject(n.props[0]);
				if (actor_props == null) actor_props = { };
				actors.push( { id:id, tiled:def.tiled, rotate:def.rotate, resize:def.resize, funcTransform:def.funcTransform, layer:LAYERS[layer_id].name, layer_id:layer_id, type:String(n.@type), clip:clip, x:clip.x, y:clip.y, angle:Number(n.@angle), scaleX:clip.scaleX, scaleY:clip.scaleY, props:actor_props } );
				LAYERS[layer_id].addChild(clip);
				
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
		
		public function getSnapshot(width:int = 0):Bitmap {
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
			
			for (i = 0; i < LAYERS.length; i++) {
				LAYERS[i].visible = true;
			}
			back.visible = true;
			CELLS.visible = true;
			GUI.visible = true;
			
			return bmp;
		}
		
		private function onTransformTarget(e:Event):void {
			if (currentCells > 0 && (!is_ctrl || (transformTool.target as MovieClip).tiled)) {
				transformTool.target.x = int((transformTool.target.x - currentCells * 0.5) / currentCells) * currentCells + currentCells * 0.5;
				transformTool.target.y = int((transformTool.target.y - currentCells * 0.5) / currentCells) * currentCells + currentCells * 0.5;
			}
			
			if ((transformTool.target as MovieClip).funcTransform != null) {
				(transformTool.target as MovieClip).funcTransform(transformTool.target);
			}
			
			//transformTool.toolMatrix = transformTool.target.transform.concatenatedMatrix;
		}
		private function onNewTarget(e:Event):void {
			if (lastTarget == null) return;
			var o:Object = getObject(lastTarget.id);
			if (o != null) {
				o.x = lastTarget.x;
				o.y = lastTarget.y;
				o.scaleX = lastTarget.scaleX;
				o.scaleY = lastTarget.scaleY;
				o.angle = AngleUtils.normal(lastTarget.rotation);
			}
			lastTarget = null;
		}
		
		protected function showProperty(clip:MovieClip):void {
			if (clip.props != null) {
				var o:Object = getObject(clip.id);
				property.show(getActorTitle(o.type), o.props, clip.props);
			}
		}
		
		protected function getScreenWidth():Number {
			return stage.stageWidth;
		}
		protected function getScreenHeight():Number {
			return stage.stageHeight;
		}
	}
}