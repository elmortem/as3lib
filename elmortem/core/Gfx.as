package elmortem.core {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Osokin <elmortem> Makar
	 */
	public class Gfx {
		static public var LAST_ERROR:String = "";
		
		static public function createMovieClip(idName:String, obj:Object = null, loaderInfo:LoaderInfo = null):MovieClip {
			return createDisplayObject(idName, obj, loaderInfo) as MovieClip;
		}
		static public function createDisplayObject(idName:String, obj:Object = null, loaderInfo:LoaderInfo = null):DisplayObject {
			var classDefintion:Class = getClassByName(idName, loaderInfo);
			if(classDefintion != null) {
				var instance:* = new classDefintion();
				if (instance is BitmapData) {
					instance = new Bitmap(instance, "auto", true);
				}
				if (obj) for (var key:String in obj) instance[key] = obj[key];
				return instance;
			} else {
				return null;
			}
		}
		static public function createBitmapData(idName:String):BitmapData {
			var classDefintion:Class = getClassByName(idName);
			if(classDefintion != null) {
				var instance:* = new classDefintion(0, 0);
				return instance as BitmapData;
			} else {
				return null;
			}
		}
		static public function createBitmap(idName:String, is_smooth:Boolean = true):Bitmap {
			var bitmap_data:BitmapData = createBitmapData(idName);
			if(bitmap_data != null) {
				return new Bitmap(bitmap_data, "auto", is_smooth);
			}
			return null;
		}
		static public function getClassByName(name:String, loaderInfo:LoaderInfo = null):Class {
			var def:Object = null;
			try {
				if(loaderInfo == null) {
					def = getDefinitionByName(name);
				} else {
					def = loaderInfo.applicationDomain.getDefinition(name);
				}
			} catch (err:Error) {
				trace("getClassByName error...");
				trace(err.message);
				LAST_ERROR = err.message;
				return null;
			}
			if (def is Class) return def as Class;
			trace(name+" is not a Class.");
			return null;
		}
		static public function isClassExists(name:String, loaderInfo:LoaderInfo = null):Boolean {
			if (loaderInfo == null) {
				return getDefinitionByName(name) != null;
			} else {
				return loaderInfo.applicationDomain.hasDefinition(name);
			}
		}
	}
}