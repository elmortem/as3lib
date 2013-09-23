package elmortem.core {
	import elmortem.sound.Mus;
	import elmortem.sound.Snd;
	import elmortem.sound.SndChannel;
	import elmortem.types.Vec2;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
	
	public class Sfx {
		static private var list:Object = { };
		
		static private var is_mute:Boolean = false;
		static private var music_volume:Number = 1;
		static private var sound_volume:Number = 1;
		
		static public var size:Vec2 = new Vec2(1, 1);
		static public var center:Vec2 = new Vec2(1, 1);
		static public var sndChannelMax:int = 20;
		static public var sndSoundMax:int = 50;
		
		static public var sndChannels:Vector.<SndChannel> = new Vector.<SndChannel>();
		static public var sndSounds:Object = { };
		
		static public var vol_mod:Number = 0.8;
		static public var pan_mod:Number = 2.5;
		
		static public function set musicVolume(v:Number):void {
			music_volume = Math.max(0, Math.min(1, v));
		}
		static public function get musicVolume():Number {
			if (is_mute) return 0;
			return music_volume;
		}
		static public function set soundVolume(v:Number):void {
			sound_volume = Math.max(0, Math.min(1, v));
		}
		static public function get soundVolume():Number {
			if (is_mute) return 0;
			return sound_volume;
		}
		static public function set mute(value:Boolean):void {
			is_mute = value;
		}
		static public function get mute():Boolean {
			return is_mute;
		}
		
		static public function getSnd(name:String):Snd {
			if (list[name] == null) {
				return list[name] = new Snd(createSample(name), name);
			}
			return list[name];
		}
		static public function getMus(name:String):Mus {
			return new Mus(createSample(name), name);
		}
		
		static public function cache(arr:Array):void {
			if (arr == null || arr.length <= 0) return;
			for (var i:int = 0; i < arr.length; i++) {
				getSnd(arr[i]);
			}
		}
		
		static private function createSample(name:String):Sound {
			var def:Object = null;
			try {
				def = getDefinitionByName(name);
			} catch (error:Error) {
				trace("Sample '"+name+"' not found.");
				return null;
			}
			if (def == null) return null;
			var classDefintion:Class = def as Class;
			return new classDefintion();
		}
		
		static public function getTransform3D(x:Number, y:Number, volume:Number):SoundTransform {
			var dist_x:Number = ((x - Sfx.center.x) / Sfx.size.x);
			var dist_y:Number = ((y - Sfx.center.y) / Sfx.size.y);
			var vol_x:Number = (1 - Math.abs(dist_x * vol_mod));
			var vol_y:Number = (1 - Math.abs(dist_y * vol_mod));
			var vol:Number = Math.min(1, Math.min(vol_x, vol_y) * volume);
			if (vol <= 0) return null;
			var pan:Number = dist_x * pan_mod;
			pan = Math.min(1, Math.max( -1, pan));
			return new SoundTransform(vol, pan);
		}
	}
}