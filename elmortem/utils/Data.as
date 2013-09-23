package elmortem.utils {
	import com.dynamicflash.util.Base64;
	import flash.display.DisplayObject;
	import flash.utils.ByteArray;

	public class Data {
		
		static public function clone(source:*):* {
			try {
				var copier:ByteArray = new ByteArray();
				copier.writeObject(source);
				copier.position = 0;
				return (copier.readObject());
			} catch(e:Error) {
				trace(e.message);
				return source;
			}
		}
		static public function toBool(d:*):Boolean {
			if (d is String && d == "true") return true;
			if (d is int && d == 1) return true;
			return false;
		}
		
		public static function serialize(value:Object):String{
			if(value == null){
				throw(new Error("null isn't a legal serialization candidate"));
			}
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(value);
			bytes.position = 0;
			return Base64.encodeByteArray(bytes);
		}

		public static function unserialize(value:String):Object {
			var result:ByteArray = Base64.decodeToByteArray(value);
			result.position=0;
			return result.readObject();
		}  
	}
}