package elmortem.game.editor {
	import fl.controls.ComboBox;
	import fl.controls.Label;
	import fl.controls.TextInput;
	import fl.controls.CheckBox;
	import fl.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	public class GuiProperty extends GuiPropertyProto {
		static public const EVENT_CHANGE:String = "property.change";
		private var list:/*UIComponent*/Array;
		private var target:Object;
		private var owner:Object;
		
		public function GuiProperty() {
			list = [];
			target = null;
			owner = null;
			visible = false;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			dragbox.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStopDrag);
			btn_close.addEventListener(MouseEvent.CLICK, onClick_Close);
			back.addEventListener(MouseEvent.CLICK, onLostFocus);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
		}
		private function onRemoveFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemoveFromStage);
			
			dragbox.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);
			btn_close.removeEventListener(MouseEvent.CLICK, onClick_Close);
			back.removeEventListener(MouseEvent.CLICK, onLostFocus);
		}
		public function free():void {
			hide();
			list = null;
			target = null;
		}
		
		public function show(title:String, target:Object, props:Array, owner:Object = null):void {
			if (target == null || props == null || props.length <= 0) {
				trace("Property not show: "+title+", "+target+", "+props);
				return;
			}
			if (visible) hide();
			
			visible = true;
			this.target = target;
			this.owner = owner;
			
			var c:DisplayObject;
			var l:Label;
			
			l = new Label();
			l.width = 180;
			l.height = 20;
			l.text = (title != null)?title:"";
			l.setStyle("fontWeight", "bold");
			l.x = 5;
			//l.y = back.y + 5;
			l.mouseEnabled = false;
			l.mouseChildren = false;
			addChild(l);
			list.push(l);
			
			var lastY:Number = back.y + 5;
			for (var i:int = 0; i < props.length; i++) {
				c = null;
				
				if (props[i].type == "input") {
					c = createTextInput(props[i].name, props[i].def, target[props[i].name], props[i].ro);
				} else if (props[i].type == "combobox") {
					c = createComboBox(props[i].name, props[i].data, target[props[i].name]);
				} else if (props[i].type == "line") {
					c = createLine();
				} else if (props[i].type == "checkbox") {
					c = createCheckBox(props[i].name, props[i].title, props[i].checked, target[props[i].name]);
				}
				
				if (c != null) {
					if (props[i].label != null) {
						l = new Label();
						l.width = 180;
						l.height = 20;
						l.text = props[i].label;
						
						addChild(l);
						l.x = 10;
						l.y = lastY;
						list.push(l);
						lastY += l.height - 5;
					}
					
					addChild(c);
					//c.x = 10;
					c.y = lastY;
					list.push(c);
					lastY += c.height + 5;
					
					c.dispatchEvent(new Event(Event.CHANGE));
				}
			}
			
			back.height = lastY - dragbox.height + 5;
		}
		public function hide():void {
			for (var i:int = 0; i < list.length; i++) {
				if (list[i] is ComboBox) {
					(list[i] as ComboBox).close();
				}
				removeChild(list[i]);
			}
			list = [];
			visible = false;
			if(stage != null) stage.focus = stage;
		}
		
		public function getComponentByName(name:String):UIComponent
		{
			for (var i:int = 0; i < list.length; i++) {
				if (list[i].name == name) {
					return list[i];
				}
			}
			return null;
		}
		
		private function createTextInput(name:String, def:String, value:* = null, readonly:Boolean = false):TextInput {
			if (name == null) return null;
			var t:TextInput = new TextInput();
			t.x = 10;
			t.width = 180;
			t.height = 20;
			t.name = name;
			t.text = String((value == null)?def:value);
			t.addEventListener(Event.CHANGE, onTextInputChange);
			t.addEventListener(FocusEvent.FOCUS_OUT, onLostFocus);
			t.editable = !readonly;
			return t;
		}
		private function onTextInputChange(e:Event):void {
			if (target == null) return;
			target[e.currentTarget.name] = e.currentTarget.text;
			dispatchEvent(new EditorEvent(EVENT_CHANGE, { owner:owner, target:target, name:e.currentTarget.name, value:target[e.currentTarget.name] } ));
		}
		private function createComboBox(name:String, data:Array, value:* = null):ComboBox {
			if (name == null) return null;
			var c:ComboBox = new ComboBox();
			c.x = 10;
			c.width = 180;
			c.height = 20;
			c.name = name;
			for (var i:int = 0; i < data.length; i++) {
				c.addItem( { label:data[i].n, data:data[i].v } );
				if (data[i].v == value) {
					c.selectedIndex = c.length - 1;
				}
			}
			if (c.selectedIndex < 0) c.selectedIndex = 0;
			c.addEventListener(Event.CHANGE, onComboBoxChange);
			return c;
		}
		private function onComboBoxChange(e:Event):void {
			if (target == null) return;
			target[e.currentTarget.name] = e.currentTarget.selectedItem.data;
			//trace(e.currentTarget.name+" = "+e.currentTarget.selectedItem.data);
			dispatchEvent(new EditorEvent(EVENT_CHANGE, { owner:owner, target:target, name:e.currentTarget.name, value:target[e.currentTarget.name] } ));
		}
		private function createLine():Sprite {
			var c:Sprite = new Sprite();
			c.graphics.lineStyle(1, 0x666666, 0.8);
			c.graphics.moveTo(0, 0);
			c.graphics.lineTo(200, 0);
			c.graphics.lineStyle(1, 0xFFFFFF, 0.5);
			c.graphics.moveTo(0, 1);
			c.graphics.lineTo(200, 1);
			return c;
		}
		private function createCheckBox(name:String, title:String, checked:String, value:* = null):CheckBox {
			if (name == null) return null;
			var c:CheckBox = new CheckBox();
			c.x = 10;
			c.width = 180;
			c.height = 20;
			c.name = name;
			c.label = title;
			c.selected = (((value == null)?checked:value) == "0")?false:true;
			c.addEventListener(Event.CHANGE, onCheckBoxChange);
			return c;
		}
		private function onCheckBoxChange(e:Event):void {
			if (target == null) return;
			target[e.currentTarget.name] = (e.currentTarget.selected)?"1":"0";
			dispatchEvent(new EditorEvent(EVENT_CHANGE, { owner:owner, target:target, name:e.currentTarget.name, value:target[e.currentTarget.name] } ));
		}
		
		private function onStartDrag(e:MouseEvent):void {
			this.startDrag(false);
		}
		private function onStopDrag(e:MouseEvent):void {
			this.stopDrag();
		}
		private function onLostFocus(e:Event):void {
			// e: MouseEvent/FocusEvent
			//trace("focus lost");
			stage.focus = stage;
		}
		
		private function onClick_Close(e:MouseEvent):void {
			hide();
		}
	}
	
}