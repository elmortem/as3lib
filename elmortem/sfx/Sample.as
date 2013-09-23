package elmortem.sfx {
	import com.greensock.loading.data.VideoLoaderVars;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class Sample {
		static public const EVENT_CHANGE_VOLUME:String = "Sample.ChangeVolume";
		static public const NULL_SOUND_TRANSFORM:SoundTransform = new SoundTransform(0, 0);
		
		public var name:String;
		public var sound:Sound;
		public var channel:SoundChannel;
		public var transform:SoundTransform;
		protected var _volume:Number;
		public var loop:Boolean;
		public var starttime:Number;
		public var x:Number;
		public var y:Number;
		public var max:int;
		
		public function Sample(name:String, sound:Sound) {
			this.name = name;
			this.sound = sound;
			this.channel = null;
			this.transform = null;
			this._volume = 1;
			this.loop = false;
			this.starttime = 0;
			this.x = NaN;
			this.y = NaN;
			this.max = Sfx.maxSound;
			
			Sfx.dispatcher.addEventListener(EVENT_CHANGE_VOLUME, onVolumeChange);
		}
		public function free():void {
			Sfx.dispatcher.removeEventListener(EVENT_CHANGE_VOLUME, onVolumeChange);
			
			if(channel != null) {
				channel.stop();
				channel = null;
			}
			sound = null;
			transform = null;
			
			if (Sfx._samples[name] == this) {
				delete Sfx._samples[name];
			}
		}
		public function get isPlaying():Boolean {
			return channel != null;
		}
		
		public function play(volume:Number = 1, loop:Boolean = false, starttime:Number = 0):void {
			trace("Try play \""+name+"\" sample...");
			if (sound == null || (!loop && Sfx.count(name) >= max)) {
				trace("fail");
				return;
			}
			Sfx.countUp(name);
			this._volume = volume;
			this.loop = loop;
			this.starttime = starttime;
			this.x = NaN;
			this.y = NaN;
			transform = new SoundTransform(volume * globalVolume);
			channel = sound.play(starttime, 0, transform);
			if (channel != null) {
				channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}
		
		public function play3D(x:Number, y:Number, volume:Number = 1, loop:Boolean = false, starttime:Number = 0):void {
			if (sound == null || (!loop && Sfx.count(name) >= max)) {
				return;
			}
			Sfx.countUp(name);
			this._volume = volume;
			this.loop = loop;
			this.starttime = starttime;
			this.x = x;
			this.y = y;
			transform = new SoundTransform(0, 0);
			Sfx.getTransform3D(x, y, volume * globalVolume, transform);
			channel = sound.play(starttime, 0, transform);
			if(channel != null) {
				channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}
		
		public function set position(v:Number):void {
			if (!isPlaying) return;
			var start:Number = starttime;
			stop();
			play(volume, loop, v * 1000);
			starttime = start;
		}
		public function get position():Number {
			if (!isPlaying) return 0;
			return channel.position / 1000;
		}
		public function get length():Number {
			if (sound == null) return 0;
			return sound.length / 1000;
		}
		
		public function update3D(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
			if (!isPlaying) return;
			Sfx.getTransform3D(x, y, volume * globalVolume, transform);
			channel.soundTransform = transform;
		}
		
		public function stop():void {
			if (!isPlaying) return;
			Sfx.countDown(name);
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			channel.stop();
			channel = null;
			transform = null;
		}
		
		private function onSoundComplete(e:Event):void {
			if (!isPlaying) return;
			Sfx.countDown(name);
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			channel = null;
			
			if (loop) {
				if (!isNaN(x) && !isNaN(y)) {
					play3D(x, y, _volume, loop, starttime);
				} else {
					play(_volume, loop, starttime);
				}
			}
		}
		protected function get globalVolume():Number {
			return 1;
		}
		private function onVolumeChange(e:Event):void {
			volume = volume;
		}
		
		public function get volume():Number {
			return _volume;
		}
		public function set volume(v:Number):void {
			_volume = v;
			if (!isPlaying) return;
			
			if (!isNaN(x) && !isNaN(y)) {
				update3D(x, y);
			} else {
				transform.volume = volume * globalVolume;
				channel.soundTransform = transform;
			}
		}
	}
}