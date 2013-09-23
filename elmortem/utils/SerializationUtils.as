package elmortem.utils {   
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import flash.xml.XMLNode;
 
	public class SerializationUtils {
		
		static public function _serialize(value:Object):String {
			if(value == null){
				throw new Error("null isn't a legal serialization candidate");
			}
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(value);
			bytes.position = 0;
			return Base64.encodeByteArray(bytes);
		}
		static public function serialize(value:Object):String {
			return _parseObject("root", value);
		}
		static private function _parseObject(name:String, o:Object):String {
			var s:String = "";
			if (o is Number) {
				s = "<value name='" + name + "' type='Number'>" + o + "</value>";
			} else if (o is String) {
				s = "<value name='" + name + "' type='String'><![CDATA[" + o + "]]></value>";
			} else if (o is Boolean) {
				s = "<value name='" + name + "' type='Boolean'>" + ((o == true)?"true":"false") + "</value>";
			} else if (o is Array) {
				s = "<array name='" + name + "'>";
				for (var i:int = 0; i < o.length; i++) {
					s += _parseObject(String(i), o[i]);
				}
				s += "</array>";
			} else {
				s = "<object name='" + name + "'>";
				for (var key:String in o) {
					s += _parseObject(key, o[key]);
				}
				s += "</object>";
			}
			return s;
		}
	 
		static public function _unserialize(value:String):Object {
			var result:ByteArray = Base64.decodeToByteArray(value);
			result.position = 0;
			return result.readObject();
		}
		static public function unserialize(value:String):Object {
			return _parseXml(new XML(value));
		}
		static private function _parseXml(n:XML):* {
			var child:XML;
			if (String(n.name()) == "value") {
				var t:String = String(n.@type);
				if (t == "Number") {
					return Number(n)
				} else if (t == "String") {
					return String(n);
				} else if (t == "Boolean") {
					if (String(n) == "true") return Boolean(true);
					else return Boolean(false);
				}
			} else if (String(n.name()) == "array") {
				var a:Array = [];
				var i:int = 0;
				for each (child in n.*) {
					a[i] = _parseXml(child);
					i++;
				}
				return a;
			} else if (String(n.name()) == "object") {
				var o:Object = { };
				for each (child in n.*) {
					o[String(child.@name)] = _parseXml(child);
				}
				return o;
			}
			return null;
		}
	}
}