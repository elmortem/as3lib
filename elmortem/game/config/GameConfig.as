package elmortem.game.config {
	import elmortem.loaders.DataLoader;
	import elmortem.utils.StringUtils;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	/**
	 * ...
	 * @author elmortem
	 */
	public class GameConfig extends EventDispatcher {
		static public const EVENT_ERROR:String = "GameConfig.Error";
		static public const EVENT_LOADED:String = "GameConfig.Loaded";
		
		public var constants:Object;
		public var data:Object;
		public var loaded:Boolean;
		
		public function GameConfig() {
			constants = { };
			data = { };
			loaded = false;
		}
		public function loadFromUrl(url:String):void {
			DataLoader.loadData(url, null, onLoad, null, onError);
		}
		private function onLoad(e:Event):void {
			loadFromString(e.target.data);
		}
		private function onError(e:IOErrorEvent):void {
			trace(e);
			dispatchEvent(new Event(EVENT_ERROR));
		}
		
		public function loadFromString(str:String):void {
			var xml:XML;
			try {
				xml = new XML(str);
			} catch (err:Error) {
				dispatchEvent(new Event(EVENT_ERROR));
				trace(err.message);
				trace(str);
				return;
			}
			
			data = parse(xml);
			loaded = true;
			
			dispatchEvent(new Event(EVENT_LOADED));
		}
		
		private function parse(xml:XML):Object {
			//trace(xml);
			var i:int;
			var c:XMLList;
			var type:String = String(xml.@type);
			
			if(type == "" || type == "object" || type == "obj" || type == "o") {
				c = xml.child("*");
				var obj:Object = { };
				for (i = 0; i < c.length(); i++) {
					obj[c[i].localName()] = parse(c[i]);
				}
				return obj;
			} else if(type == "array" || type == "arr" || type == "a") {
				c = xml.child("*");
				var arr:Array = [];
				for (i = 0; i < c.length(); i++) {
					arr.push(parse(c[i]));
				}
				return arr;
			} else if (type == "string" || type == "str" || type == "s") {
				c = xml.child("*");
				if(c == null) {
					return fromConst(String(xml));
				} else {
					var s:String = "";
					for (i = 0; i < c.length(); i++) {
						s += fromConst(String(c[i]));
					}
					s = StringUtils.replace(s, "\\n", "\n");
					return s;
				}
			} else if (type == "int" || type == "i") {
				return int(fromConst(String(xml)));
			} else if (type == "number" || type == "num" || type == "n") {
				return Number(fromConst(String(xml)));
			} else if (type == "boolean" || type == "bool") {
				return toBool(fromConst(String(xml)));
			} else if (type == "list" || type == "lst" || type == "l") {
				var list:Array = fromConst(String(xml)).split("|");
				for (i = 0; i < list.length; i++) {
					var r:Array = String(list[i]).split(":");
					if (r[0] == "i") {
						list[i] = int(r[1]);
					} else if (r[0] == "b") {
						list[i] = toBool(r[1]);
					} else {
						if (r.length < 2) {
							r[0] = 1;
							r[1] = list[i];
						}
						var cnt:int = Math.max(1, r[0]);
						var value:* = getConst(r[1]);
						list[i] = value;
						for (var j:int = 1; j < cnt; j++) {
							list.splice(i, 0, value);
						}
						i += cnt - 1;
					}
				}
				return list;
			}
			return null;
		}
		
		public function fromConst(str:String):String {
			if (str.indexOf("%") == -1) return str;
			
			for (var key:String in constants) {
				if (key == "") continue;
				str = StringUtils.replace(str, "%" + key, constants[key]);
			}
			return str;
		}
		public function getConst(name:String):* {
			if (constants[name] == null) return name;
			return constants[name];
		}
		
		static public function toBool(d:*):Boolean {
			if (d is String && d == "true") return true;
			if (d is int && d == 1) return true;
			return false;
		}
	}
}