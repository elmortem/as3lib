package karma.core {
	import elmortem.utils.AngleUtils;
	import elmortem.utils.StringUtils;
	import flash.geom.Rectangle;
	import flash.xml.XMLNode;
	import karma.display.ExtendedSprite;
	import karma.display.ExtendedMovieClip;
	//import karma.starling.extensions.BlendImage;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	/**
	 * ...
	 * @author Karma Team
	 */
	public class ClipFactory {
		static private var _this:ClipFactory = null;
		private var info:Object;
		private var atlases:Vector.<TextureAtlas>;
		
		static public function get instance():ClipFactory {
			if (_this == null) new ClipFactory();
			return _this;
		}
		
		public function ClipFactory() {
			_this = this;
			info = {};
			atlases = new Vector.<TextureAtlas>();
		}
		public function free():void {
			info = null;
			clear();
			atlases = null;
		}
		
		public function clear():void {
			info = { };
			for (var i:int = 0; i < atlases.length; i++) {
				atlases[i].dispose();
			}
			atlases.length = 0;
		}
		public function load(infoXml:XML, atlasesXml:XML, ...args):void {
			var o:Object = _convertXmlToObject(infoXml);
			for (var k:String in o) {
				info[k] = o[k];
			}
			
			for (var i:int = 0; i < args.length; i++) {
				atlases.push(new TextureAtlas(Texture.fromBitmap(args[i]), atlasesXml.TextureAtlas[i]));
			}
		}
		
		public function getClip(name:String, parent:ExtendedSprite = null):DisplayObject {
			var i:int;
			
			var t:Texture;
			var im:Image;
			
			if (info[name] == null) {
				t = getTexture(name);
				if (t == null) return null;
				im = new Image(t);
				if (parent != null) parent.addChild(im);
				return im;
			}
			
			var o:Object = info[name];
			
			if (o.movieclip) {
				var ts:Vector.<Texture> = new <Texture>[];
				for (i = 0; i < o.frames.length; i++) {
					t = getTexture(o.frames[i].type);
					if (t == null) return null;
					/*if (t.frame == null) */t.frame = new Rectangle(0, 0, t.width, t.height);
					t.frame.x -= o.frames[i].x;
					t.frame.y -= o.frames[i].y;
					ts.push(t);
				}
				
				var m:ExtendedMovieClip = new ExtendedMovieClip(ts);
				//m.touchable = false;
				if (parent != null) parent.addChild(m);
				return m;
			} else if (info[name].sprite) {
				var s:ExtendedSprite = parent as ExtendedSprite;
				if (s == null) s = new ExtendedSprite();
				//s.touchable = false;
				for (i = 0; i < o.clips.length; i++) {
					var chld:DisplayObject = getClip(o.clips[i].type);
					if (chld == null) continue;
					chld.x = o.clips[i].x;
					chld.y = o.clips[i].y;
					chld.scaleX = o.clips[i].scaleX;
					chld.scaleY = o.clips[i].scaleY;
					chld.rotation = AngleUtils.toRad(o.clips[i].angle);
					chld.alpha = o.clips[i].alpha;
					chld.name = o.clips[i].name;
					if (info[o.clips[i].type].textfield) {
						TextField(chld).width = o.clips[i].width;
						TextField(chld).height = o.clips[i].height;
						TextField(chld).text = o.clips[i].text;
					}
					s.addChild(chld);
					s[o.clips[i].name] = chld;
				}
				return s;
			} else if (o.textfield) {
				var tf:TextField = new TextField(10, 10, "", o.fontName, o.size, o.color, o.bold);
				//tf.touchable = false;
				tf.italic = o.italic;
				tf.kerning = o.kerning;
				tf.hAlign = o.align;
				tf.vAlign = VAlign.TOP;
				tf.border = true;
				return tf;
			}/* else if(o.blendimage) {
				t = getTexture(o.type);
				if (t == null) return null;
				if (t.frame == null) t.frame = new Rectangle(0, 0, t.width, t.height);
				//t.frame.x -= o.offsetX;
				//t.frame.y -= o.offsetY;
				var bim:BlendImage = new BlendImage(t);
				//bim.touchable = false;
				bim.pivotX = -o.offsetX;
				bim.pivotY = -o.offsetY;
				if (parent != null) parent.addChild(bim);
				return bim;
			}*/ else {
				t = getTexture(o.type);
				if (t == null) return null;
				if (t.frame == null) t.frame = new Rectangle(0, 0, t.width, t.height);
				//t.frame.x -= o.offsetX;
				//t.frame.y -= o.offsetY;
				im = new Image(t);
				//im.touchable = false;
				im.pivotX = -o.offsetX;
				im.pivotY = -o.offsetY;
				if (parent != null) parent.addChild(im);
				return im;
			}
			
			return null;
		}
		
		public function getTexture(name:String):Texture {
			var t:Texture = null;
			for (var i:int = 0; i < atlases.length; i++) {
				t = atlases[i].getTexture(name);
				if (t != null) return t;
			}
			return null;
		}
		
		private function _convertXmlToObject(node:XML):Object {
			if (node == null) return { };
			var o:Object = { };
			if (node.children().length() > 1 || (node.children().length() == 1 && node.children()[0].name() == "item")) {
				var j:int = 0;
				var ch:XMLList = node.children();
				while (ch[j]) {
					if (ch[j].name() == "item") {
						if (!(o is Array)) o = [];
						o.push(_convertXmlToObject(ch[j++]));
					} else {
						o[ch[j].name()] = _convertXmlToObject(ch[j++]);
					}
				}
			} else {
				var s:String = node.toString();
				if (isNaN(Number(s))) {
					if (StringUtils.isBoolean(s)) {
						return StringUtils.toBoolean(s);
					}
					return s;
				}
				return Number(s);
			}
			return o;
		}
	}

}