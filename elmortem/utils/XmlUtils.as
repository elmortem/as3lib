package elmortem.utils {
	
	public class XmlUtils {
		
		static public function nodeAttributesToObject(node:XML):Object {
			if (node == null) return null;
			var o:Object = { };
			for each (var item:XML in node.attributes()) {
				o[String(item.name())] = String(item);
			}
			return o;
		}
	}
}