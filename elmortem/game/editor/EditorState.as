package elmortem.game.editor {
	import com.adobe.crypto.MD5;
	import com.adobe.images.BitString;
	import elmortem.states.State;
	import elmortem.types.Vec2;
	import elmortem.utils.AngleUtils;
	import fl.controls.ComboBox;
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
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public class EditorState extends State {
		static protected var _ids:int = 0;
		// layers
		protected var CAMERA:Sprite;
		protected var GAME:Sprite;
			protected var LAYERS:/*Sprite*/Array;
			protected var CELLS:Sprite;
		protected var GUI:Sprite;
		
		// gui
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
		
		// select
		protected var selectLayerIndex:int = 0;
		protected var selectLayer:int = 0;
		protected var selectIndex:int = -1;
		protected var selectClip:MovieClip = null;
		
		// modify
		protected var isModifyResize:Boolean = false;
		protected var isModifyRotate:Boolean = false;
		protected var isModifyMove:Boolean = false;
		protected var modClip:MovieClip = null;
		protected var modTarget:MovieClip = null;
		protected var modStartAngle:Number;
		protected var modStartScaleX:Number;
		protected var modStartScaleY:Number;
		
		// level ID
		protected var levelUid:String;
		
		public function EditorState(attrIn:Object = null) {
			super(attrIn);
			if (attr == null) attr = { };
		}
		override protected function init():void {
			var i:int;
			var j:int;
			var g:Graphics;
		
			super.init();
			
			var color:int = (attr.color != null)?attr.color:0xFFFFFF;
			back = new Sprite();
			g = back.graphics;
			g.beginFill(color, 1);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
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
			GAME.mouseChildren = false;
			GAME.mouseEnabled = false;
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
			
			if (attr.cells > 0) {
				g = CELLS.graphics;
				g.lineStyle(1, 0x000000, 0.1);
				for (i = 1; i < 100; i++) {
					g.moveTo(i * attr.cells, 0);
					g.lineTo(i * attr.cells, 100 * attr.cells);
				}
				for (i = 1; i < 100; i++) {
					g.moveTo(0, i * attr.cells);
					g.lineTo(100 * attr.cells, i * attr.cells);
				}
			}
			
			// gui
			gui = attr.gui;
			GUI.addChild(gui);
			if (gui.btn_help != null) {
				gui.help.visible = false;
				gui.btn_help.addEventListener(MouseEvent.CLICK, onHelpClick);
			}
			if(gui.btn_load != null) gui.btn_load.addEventListener(MouseEvent.CLICK, onLoadClick);
			gui.btn_save.addEventListener(MouseEvent.CLICK, onSaveClick);
			gui.btn_run.addEventListener(MouseEvent.CLICK, onRunClick);
			if(gui.btn_exit != null) gui.btn_exit.addEventListener(MouseEvent.CLICK, onExitClick);
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
			
			// modify
			GUI.addChild(modClip = new GuiEditorModify());
			modClip.visible = false;
			//modClip.btn_resize.buttonMode = true;
			//modClip.btn_resize.addEventListener(MouseEvent.MOUSE_DOWN, onModifyResizeStart);
			//modClip.btn_resize.addEventListener(MouseEvent.MOUSE_UP, onModifyResizeStop);
			modClip.btn_rotate.buttonMode = true;
			modClip.btn_rotate.addEventListener(MouseEvent.MOUSE_DOWN, onModifyRotateStart);
			modClip.btn_rotate.addEventListener(MouseEvent.MOUSE_UP, onModifyRotateStop);
			
			// objects
			actors = [];
			
			back.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			back.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			back.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			// activate layer
			lstLayers.selectedIndex = 0;
			lstLayers.dispatchEvent(new Event(Event.CHANGE));
			
			levelUid = "";
			
			if(attr.data != null && attr.data.levelStr != null) loadLevel(attr.data.levelStr);
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
			
			if (gui.btn_help != null) {
				gui.btn_help.removeEventListener(MouseEvent.CLICK, onHelpClick);
			}
			if(gui.btn_load != null) gui.btn_load.removeEventListener(MouseEvent.CLICK, onLoadClick);
			gui.btn_save.removeEventListener(MouseEvent.CLICK, onSaveClick);
			gui.btn_run.removeEventListener(MouseEvent.CLICK, onRunClick);
			
			lstLayers.removeEventListener(Event.CHANGE, onListLayerChange);
			lstActors.removeEventListener(Event.CHANGE, onListActorChange);
			
			gui = null;
			
			super.free();
		}
		
		protected function select(index:int = -1):void {
			// clear
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
			clip.tiled = attr.actors[selectIndex].tiled;
			clip.gotoAndStop(attr.actors[selectIndex].frame);
			clip.x = selectClip.x;
			clip.y = selectClip.y;
			actors.push( { id:id, tiled:attr.actors[selectIndex].tiled, layer:attr.layers[selectLayerIndex].name, layer_id:selectLayerIndex, type:attr.actors[selectIndex].type, clip:clip, x:clip.x, y:clip.y, angle:AngleUtils.normal(selectClip.rotation) } );
			LAYERS[selectLayer].addChild(clip);
			
			selectClip.parent.setChildIndex(selectClip, selectClip.parent.numChildren - 1);
		}
		protected function modify(x:Number, y:Number):void {
			var i:int;
			var j:int;
			var clip:MovieClip;
			
			/*for (j = 0; j < attr.layers.length; j++) {
				for (i = 0; i < LAYERS[j].numChildren; i++) {
					clip = LAYERS[j].getChildAt(i) as MovieClip;
					if (clip == null) continue;
					if (clip.hitTestPoint(x, y, true)) {
						_modifyClip("actor", clip);
						return;
					}
				}
			}*/
			for (i = 0; i < actors.length; i++) {
				clip = actors[i].clip;
				if (clip.hitTestPoint(x, y, true)) {
					_modifyClip(clip);
					return;
				}
			}
			
			unModify();
		}
		protected function unModify():void {
			modTarget = null;
			modClip.visible = false;
		}
		protected function _modifyClip(clip:MovieClip):void {
			modClip.visible = true;
			modTarget = clip;
			
			modClip.x = clip.x + GAME.x + CAMERA.x;
			modClip.y = clip.y + GAME.y + CAMERA.y;
			modClip.rotation = clip.rotation;
			var r:Rectangle = clip.getBounds(clip);
			//modClip.btn_resize.x = r.width * 0.5;
			//modClip.btn_resize.y = r.height * 0.5;
			modClip.btn_rotate.x = r.width * 0.5;
			modClip.btn_rotate.y = -r.height * 0.5;
			var v:Vec2 = new Vec2(r.width, -r.height);
			modStartAngle = AngleUtils.normal(v.angle());
		}
		
		protected function onModifyResizeStart(e:MouseEvent):void {
			isModifyResize = true;
		}
		protected function onModifyResizeStop(e:MouseEvent):void {
			isModifyResize = false;
		}
		protected function onModifyRotateStart(e:MouseEvent):void {
			isModifyRotate = true;
		}
		protected function onModifyRotateStop(e:MouseEvent):void {
			isModifyRotate = false;
		}
		
		protected function onListLayerChange(e:Event):void {
			selectLayerIndex = lstLayers.selectedItem.data;
			selectLayer = attr.layers[selectLayerIndex].id;
			
			select();
			unModify();
			
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
		
		protected function onHelpClick(e:MouseEvent):void {
			GUI.setChildIndex(gui, GUI.numChildren - 1);
			gui.help.visible = !gui.help.visible;
		}
		protected function onLoadClick(e:MouseEvent):void {
			if (attr.onLoad != null) {
				attr.onLoad();
			}
		}
		protected function onSaveClick(e:MouseEvent):void {
			if (attr.onSave != null) {
				attr.onSave(genXml());
			}
		}
		protected function onRunClick(e:MouseEvent):void {
			if (attr.onRun != null) {
				attr.onRun(genXml());
			}
		}
		protected function onExitClick(e:MouseEvent):void {
			if (attr.onExit != null) {
				attr.onExit();
			}
		}
		
		protected function onKeyDown(e:KeyboardEvent):void {
			//trace(String.fromCharCode(e.charCode)+" = "+e.keyCode);
			is_ctrl = e.ctrlKey;
			
			if (e.keyCode == Keyboard.ESCAPE) {
				if (modTarget == null) {
					select();
				} else {
					unModify();
				}
			}
			if (e.keyCode == Keyboard.DELETE || e.keyCode == Keyboard.BACKSPACE) {
				if (modTarget != null) {
					removeObject(modTarget.id);
					unModify();
				}
			}
			if (modTarget != null) {
				if (attr.cells > 0 && (!is_ctrl || modTarget.tiled)) {
					
				} else {
					if (e.keyCode == Keyboard.UP) {
						modTarget.y -= 1;
					} else if (e.keyCode == Keyboard.DOWN) {
						modTarget.y += 1;
					} else if (e.keyCode == Keyboard.LEFT) {
						modTarget.x -= 1;
					} else if (e.keyCode == Keyboard.RIGHT) {
						modTarget.x += 1;
					}
					modClip.x = modTarget.x + GAME.x + CAMERA.x;
					modClip.y = modTarget.y + GAME.y + CAMERA.y;
				}
			}
		}
		protected function onKeyUp(e:KeyboardEvent):void {
			is_ctrl = e.ctrlKey;
		}
		protected function onMouseDown(e:MouseEvent):void {
			//if (e.stageY < gui.height) return;
			
			if (modTarget != null && modTarget.hitTestPoint(e.stageX, e.stageY)) {
				//modTarget.startDrag();
				isModifyMove = true;
				return;
			}
			
			is_down = true;
			downX = e.stageX;
			downY = e.stageY;
		}
		protected function onMouseUp(e:MouseEvent):void {
			if (modTarget != null && isModifyMove) {
				isModifyMove = false;
				
				var obj:Object = getObject(modTarget.id);
				if (obj != null) {
					obj.x = int(modTarget.x);
					obj.y = int(modTarget.y);
				}
				
				return;
			}
			
			if(is_drag) {
				is_drag = false;
				GAME.stopDrag();
			} else {
				if (selectIndex != -1) {
					addSelected();
				} else {
					if (!isModifyResize && !isModifyRotate) {
						modify(e.stageX, e.stageY);
					} else {
						isModifyResize = false;
						isModifyRotate = false;
					}
				}
			}
			is_down = false;
		}
		protected function onMouseMove(e:MouseEvent):void {
			if (isModifyResize) {
				
				return;
			}
			if (isModifyRotate) {
				var v:Vec2 = new Vec2(e.stageX, e.stageY);
				var u:Vec2 = new Vec2(modClip.x, modClip.y);
				var ang:Number = u.angleTo(v) - modStartAngle;
				modClip.rotation = ang;
				if (attr.rotate != null) ang = int(ang / attr.rotate) * attr.rotate;
				if (modTarget != null) modTarget.rotation = ang;
				
				var obj:Object = getObject(modTarget.id);
				if (obj != null) {
					obj.angle = int(AngleUtils.normal(modTarget.rotation));
					//trace("Object #" + modTarget.id + " angle: " + obj.angle);
				} else {
					//trace("Object #" + modTarget.id + " not found.");
				}
				
				return;
			}
			if (isModifyMove) {
				modTarget.x = e.stageX - GAME.x - CAMERA.x;
				modTarget.y = e.stageY - GAME.y - CAMERA.y;
				if (attr.cells > 0 && !is_ctrl) {
					modTarget.x = int((modTarget.x) / attr.cells) * attr.cells + attr.cells * 0.5;
					modTarget.y = int((modTarget.y) / attr.cells) * attr.cells + attr.cells * 0.5;
				}
			}
			
			if (modTarget != null) {
				modClip.x = modTarget.x + GAME.x + CAMERA.x;
				modClip.y = modTarget.y + GAME.y + CAMERA.y;
			}
			
			if (modTarget != null && modTarget.hitTestPoint(e.stageX, e.stageY)) {
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
				if (attr.cells > 0 && (!is_ctrl || attr.actors[selectIndex].tiled)) {
					cX = int((cX) / attr.cells) * attr.cells + attr.cells * 0.5;
					cY = int((cY) / attr.cells) * attr.cells + attr.cells * 0.5;
				}
				selectClip.x = cX;
				selectClip.y = cY;
			}
		}
		
		protected function getObject(id:int):Object {
			for (var i:int = 0; i < actors.length; i++) {
				if (actors[i].id == id) {
					return actors[i];
				}
			}
			return null;
		}
		protected function removeObject(id:int):void {
			var obj:Object = getObject(id);
			if (obj == null) return;
			LAYERS[obj.layer_id].removeChild(obj.clip);
			actors.splice(actors.indexOf(obj), 1);
		}
		
		protected function genXml():String {
			var i:int;
			var j:int;
			
			var dt:Date = new Date();
			if (levelUid == null || levelUid == "") levelUid = MD5.hash(dt.valueOf().toString());
			var s:String = "<data uid='" + levelUid + "'>\n";
			
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
		public function loadLevel(str:String):Boolean {
			var xml:XML;
			try {
				xml = new XML(str);
			} catch (err:Error) {
				trace(str);
				trace(err.message);
				return false;
			}
			
			levelUid = String(xml.@uid);
			
			_ids = xml.actors.@ids;
			
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
				
				layer_id = getLayerId(String(n.@layer));
				if (layer_id < 0) continue;
				
				id = int(n.@id);
				if (id <= max_id) id = ++_ids;
				max_id = id;
				
				clip = new def.cls();
				clip.id = id;
				clip.tiled = def.tiled;
				clip.gotoAndStop(def.frame);
				clip.x = Number(n.@x);
				clip.y = Number(n.@y);
				//trace("Load object #" + clip.id + " angle: " + n.@angle);
				clip.rotation = Number(n.@angle);
				actors.push( { id:id, tiled:def.tiled, layer:LAYERS[layer_id].name, layer_id:layer_id, type:String(n.@type), clip:clip, x:clip.x, y:clip.y, angle:Number(n.@angle) } );
				LAYERS[layer_id].addChild(clip);
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
			var s:String = "<" + name + " ";
			var params:Array = [];
			for (var key:String in obj) {
				if(obj[key] is String || obj[key] is Number || obj[key] is int || obj[key] is uint) {
					s += key + "='" + obj[key] + "' ";
				}
			}
			s += "/>";
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
			
			var k:Number = 1;
			var height:int = getScreenHeight();
			if (width <= 0) {
				width = getScreenWidth();
			} else {
				k = width / getScreenWidth();
				height = getScreenHeight() * k;
			}
			
			var clip:DisplayObject = stage;
			if (clip == null) clip = CAMERA;
			
			var bd:BitmapData = new BitmapData(width, height, false, 0x000000);
			//var mtx:Matrix = CAMERA.transform.matrix.clone();
			//mtx.createBox(k, k, 0, CAMERA.x * k, CAMERA.y * k);
			var mtx:Matrix = clip.transform.matrix.clone();
			mtx.createBox(k, k, 0, clip.x * k, clip.y * k);
			bd.draw(clip, mtx, null, null, null, true);
			var bmp:Bitmap = new Bitmap(bd, "auto", true);
			
			back.visible = true;
			CELLS.visible = true;
			GUI.visible = true;
			
			return bmp;
		}
		
		protected function getScreenWidth():Number {
			return stage.stageWidth;
		}
		protected function getScreenHeight():Number {
			return stage.stageHeight;
		}
	}
}