package elmortem.sound {
	import elmortem.core.Sfx;
	import elmortem.types.Vec2;
	import flash.media.SoundCodec;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Snd {
		public var name:String;
		private var sound:Sound = null;
		
		public function Snd(sound:Sound, name:String = "") {
			this.sound = sound;
			this.name = name;
		}
		
		public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SndChannel {
			if (isMany) return null;
			if (sound == null) return null;
			if (Sfx.soundVolume <= 0) return null;
			
			if (sndTransform != null) {
				sndTransform.volume *= Sfx.soundVolume;
			} else {
				sndTransform = new SoundTransform(Sfx.soundVolume, 0);
			}
			
			var chnl:SoundChannel = sound.play(startTime, loops, sndTransform);
			if (chnl != null) {
				var channel:SndChannel = new SndChannel(this, chnl);
				if (Sfx.sndChannels.length >= Sfx.sndChannelMax) {
					var ch:SndChannel = Sfx.sndChannels.shift();
					if(ch.sound != null) {
						ch.free();
					}
				}
				Sfx.sndChannels.push(channel);
			}
			return channel;
		}
		public function playS(volume:Number = 1, loop:Boolean = false, startTime:Number = 0):SndChannel {
			if (sound == null) return null;
			if (Sfx.soundVolume <= 0) return null;
			
			return play(startTime, loop?9999:0, new SoundTransform(volume));
		}
		public function play3D(x:Number, y:Number, volume:Number, loop:Boolean = false, startTime:Number = 0):SndChannel {
			if (isMany || Sfx.soundVolume <= 0) return null;
			var st:SoundTransform = Sfx.getTransform3D(x, y, volume);
			if (st == null) return null;
			return play(startTime, loop?9999:0, st);
		}
		
		public function get length():Number {
			if (sound != null) return sound.length;
			return 0;
		}
		
		private function get isMany():Boolean {
			return int(Sfx.sndSounds[name]) >= Sfx.sndSoundMax;
		}
	}
}