package elmortem.core {
	import flash.net.SharedObject;
	import elmortem.utils.Data;
	
	public class Profile {
		static private var name:String = "default";
		static private var vars:Object = {};
		
		static public function setVar(name:String, value:*):void {
			//trace("setVar: "+name+" = "+value);
			var v:* = Data.clone(value);
			try {
				vars[name] = v;
			} catch(e:Error) {
				vars[name] = value;
			}
		}
		static public function getVar(name:String, defaultValue:* = null):* {
			if (vars[name] == null) return defaultValue;
			return Data.clone(vars[name]);
		}
		static public function clearVars():void {
			vars = { };
			//name = "";
		}
		static public function saveVars(name:String = null):void {
			if (name == null) name = Profile.name;
			Profile.name = name;
			var so:SharedObject = SharedObject.getLocal(name);
			so.setProperty("vars", Data.clone(vars));
			//so.data.vars = Data.clone(vars);
			so.flush();
		}
		static public function loadVars(name:String):void {
			if (name == Profile.name) return;
			Profile.name = name;
			var so:SharedObject = SharedObject.getLocal(name);
			//vars = Data.clone(so.data.vars);
			vars = so.data.vars;
			if (!vars) vars = { };
		}
		static public function clearSavesVars(name:String, is_local:Boolean = false):void {
			var so:SharedObject = SharedObject.getLocal(name);
			so.clear();
			if (is_local && Profile.name == name) vars = { };
		}
		static public function isSavedVars(name:String):Boolean {
			try {
				var so:SharedObject = SharedObject.getLocal(name);
			} catch (e:Error) {
				trace(e.message);
				return false;
			}
			return (so && so.data && so.data.vars);
		}
		
		static public function setVars(newVars:Object):void {
			vars = newVars;
			if (vars == null) vars = { };
		}
		static public function getVars():Object {
			return Data.clone(vars);
		}
	}
}