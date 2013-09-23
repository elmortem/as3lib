package elmortem.core {
	import flash.net.SharedObject;
	import elmortem.utils.Data;
	
	public class Config {
		static public function setVar(name:String, value:*):void {
			//trace("setConfig: "+name+" = "+value);
			var so:SharedObject = SharedObject.getLocal("elmortem__config");
			so.data[name] = Data.clone(value);
			so.flush();
		}
		static public function getVar(name:String, def:* = ""):* {
			//trace("getConfig: "+name);
			var so:SharedObject = SharedObject.getLocal("elmortem__config");
			if (so.data[name] != undefined) return so.data[name]; else return def;
		}
		static public function clear():void {
			var so:SharedObject = SharedObject.getLocal("elmortem__config");
			for (var key:String in so.data) {
				//trace(key+" = "+so.data[key]);
				so.data[key] = null;
				delete so.data[key];
			}
			so.flush();
		}
		static public function getVars():Object {
			var so:SharedObject = SharedObject.getLocal("elmortem__config");
			var v:Object = { };
			for (var key:String in so.data) {
				v[key] = Data.clone(so.data[key]);
			}
			return v;
		}
		static public function setVars(v:Object):void {
			clear();
			var so:SharedObject = SharedObject.getLocal("elmortem__config");
			for (var key:String in v) {
				so.data[key] = Data.clone(v[key]);
			}
			so.flush();
		}
	}
}