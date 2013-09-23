package elmortem.actions {
	import com.greensock.TweenLite;
	import elmortem.loaders.DataLoader;
	import elmortem.utils.UrlUtils;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.xml.XMLNode;
	
	public class Actions {
		static private const URL_API:String = "http://elmapis.appspot.com/api";
		static public var actions:Array = [];
		
		static public function createAction(clip:Sprite, game:String, action:String, random:Number = 1):void {
			try {
				if (Math.random() < random) {
					trace("Action '"+game+"."+action+"' loading...");
					actions.push( { clip:clip, game:game, action:action, loader:DataLoader.loadData(URL_API, { game:game, action:action }, onLoad, null, onError), list:[] } );
				}
			} catch (err:Error) {
				trace(err.getStackTrace());
			}
		}
		static public function clearActions():void {
			try {
				for (var i:int = 0; i < actions.length; i++) {
					for (var j:int = 0; j < actions[i].list.length; j++) {
						var o:Object = actions[i].list[j];
						if (o.type == "button") {
							o.button.removeChild(o.loader);
							o.loader.unload();
							o.button.removeEventListener(MouseEvent.CLICK, onClick_Button);
							actions[i].clip.removeChild(o.button);
							o.button = null;
							o.loader = null;
						}
					}
					actions[i].list = null;
					actions[i].clip = null;
				}
				actions = [];
			} catch (err:Error) {
				trace(err.getStackTrace());
			}
		}
		
		static private function onLoad(e:Event):void {
			var i:int;
			var xml:XML;
			try {
				xml = new XML(e.target.data);
				trace(e.target.data);
			} catch (err:Error) {
				trace(err.getStackTrace());
			}
			
			if (xml == null) return;
			
			var o:Object = null;
			for (i = 0; i < actions.length; i++) {
				if (actions[i].loader == e.target) {
					o = actions[i];
					break;
				}
			}
			if (o == null) return;
			trace("Action '"+o.game+"."+o.action+"' loaded.");
			
			try {
				for (i = 0; i < xml.actions.action.length(); i++) {
					var n:XML = xml.actions.action[i];
					if (String(n.@enable) == "false") continue;
					if (String(n.@type) == "button") {
						var ldr:Loader = DataLoader.loadImage(n.image.@url, onButtonLoad, null, onButtonError);
						ldr.alpha = 0;
						var s:Sprite = new Sprite();
						s.x = int(n.image.@x);
						s.y = int(n.image.@y);
						s.addChild(ldr);
						s.buttonMode = true;
						s.addEventListener(MouseEvent.CLICK, onClick_Button);
						var act:Object = { type:String(n.@type), loader:ldr, button:s, url:String(n.click.@url) };
						o.list.push( act );
						o.clip.addChild(s);
						if (Number(n.@timer) > 0) {
							TweenLite.delayedCall(Number(n.@timer), removeButton, [act]);
						}
					}
				}
			} catch (err:Error) {
				trace(err.getStackTrace());
			}
			
			o.loader = null;
		}
		static private function onError(e:IOErrorEvent):void {
			trace("Action.onError");
			trace(e.toString());
		}
		
		static private function onButtonLoad(e:Event):void {
			TweenLite.to(e.target.loader, 1, { alpha:1, overwrite:1 } );
		}
		static private function onButtonError(e:IOErrorEvent):void {
			trace("Action.onButtonError");
			trace(e.toString());
		}
		static private function removeButton(o:Object):void {
			try {
				for (var i:int = 0; i < actions.length; i++) {
					for (var j:int = 0; j < actions[i].list.length; j++) {
						if (actions[i].list[j].type == "button" && actions[i].list[j] == o) {
							o.button.removeChild(o.loader);
							o.loader.unload();
							o.button.removeEventListener(MouseEvent.CLICK, onClick_Button);
							actions[i].clip.removeChild(o.button);
							o.button = null;
							o.loader = null;
							actions[i].list.splice(j, 1);
							break;
						}
					}
				}
			} catch (err:Error) {
				trace(err.getStackTrace());
			}
		}
		
		static private function onClick_Button(e:MouseEvent):void {
			try {
				for (var i:int = 0; i < actions.length; i++) {
					for (var j:int = 0; j < actions[i].list.length; j++) {
						if (actions[i].list[j].type == "button" && actions[i].list[j].button == e.currentTarget) {
							UrlUtils.open(actions[i].list[j].url);
							break;
						}
					}
				}
			} catch (err:Error) {
				trace(err.getStackTrace());
			}
		}
	}
}