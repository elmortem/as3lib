package elmortem.sound {
	import com.greensock.TweenLite;
	import elmortem.core.Sfx;
	import flash.events.Event;
	import flash.media.SoundTransform;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Mus {
		private var _name:String;
		private var sound:Sound = null;
		private var channel:SoundChannel = null;
		private var vol:Number;
		
		public function Mus(sound:Sound, name:String = null) {
			_name = name;
			this.sound = sound;
			volume = 1;
		}
		
		public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null):SoundChannel {
			if (sound == null) return null;
			//if (Sfx.musicVolume <= 0) return null;
			if (sndTransform != null) {
				sndTransform.volume *= Sfx.musicVolume;
			} else {
				sndTransform = new SoundTransform(Sfx.musicVolume, 0);
			}
			channel = sound.play(startTime, loops, sndTransform);
			if (channel != null) {
				channel.addEventListener(Event.SOUND_COMPLETE, onStop);
			}
			return channel;
		}
		public function playS(volume:Number, loop:Boolean = false):SoundChannel {
			vol = volume;
			return play(0.1, loop?9999:0, new SoundTransform(volume));
		}
		public function stop():void {
			if (channel != null) {
				channel.stop();
				channel.removeEventListener(Event.SOUND_COMPLETE, onStop);
				channel = null;
			}
		}
		private function onStop(e:Event):void {
			stop();
		}
		
		public function set volume(value:Number):void {
			if (channel == null) return;
			vol = value;
			if (channel == null) return;
			var st:SoundTransform = channel.soundTransform;
			st.volume = Sfx.musicVolume * vol;
			channel.soundTransform = st;
		}
		public function get volume():Number {
			return vol;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get isPlaying():Boolean {
			return channel != null;
		}
		
		public function fadeVolume(vol:Number, time:Number = 1, is_stop:Boolean = false):void {
			TweenLite.killTweensOf(this);
			TweenLite.to(this, time, { volume:vol, overwrite:1, onComplete:is_stop?stop:null } );
		}
	}
}