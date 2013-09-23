package elmortem.sfx {
	import com.greensock.TweenLite;
	import elmortem.types.Vec2;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.getDefinitionByName;
	
	public class Sfx {
		static private var _soundVolume:Number = 1;
		static private var _musicVolume:Number = 1;
		static private var _mute:Boolean = false;
		
		static internal var _samples:Object = { };
		static internal var _sound_counts:Object = { };
		static internal var _music:Sample = null;
		static internal var _sound_groups:Object = { };
		
		static public var center:Vec2 = new Vec2();
		static public var size:Vec2 = new Vec2();
		static public var vol_mod:Number = 0.8;
		static public var pan_mod:Number = 2.5;
		
		static public var maxSound:int = 3;
		static public var dispatcher:EventDispatcher = new EventDispatcher();
		
		static public function get soundVolume():Number {
			return (_mute)?0:_soundVolume;
		}
		static public function set soundVolume(v:Number):void {
			_soundVolume = v;
			
			dispatcher.dispatchEvent(new Event(Sample.EVENT_CHANGE_VOLUME));
		}
		static public function get musicVolume():Number {
			return (_mute)?0:_musicVolume;
		}
		static public function set musicVolume(v:Number):void {
			_musicVolume = v;
			
			dispatcher.dispatchEvent(new Event(Sample.EVENT_CHANGE_VOLUME));
		}
		static public function get mute():Boolean {
			return _mute;
		}
		static public function set mute(v:Boolean):void {
			_mute = v;
			
			dispatcher.dispatchEvent(new Event(Sample.EVENT_CHANGE_VOLUME));
		}
		
		static public function playSound(name:String, volume:Number = 1, group:int = -1, groupForce:Boolean = false):void {
			if (mute) return;
			if (group >= 0 && (!groupForce && _sound_groups[group] != null)) return;
			var s:Sample = getSound(name);
			if (s == null) return;
			fadeClear(s);
			s.play(volume, false, 0.2);
			
			addToGroup(s, group, groupForce);
		}
		static public function playSound3D(name:String, x:Number, y:Number, volume:Number = 1, group:int = -1):void {
			if (mute) return;
			if (group >= 0 && _sound_groups[group] != null) return;
			var s:Sample = getSound(name);
			if (s == null) return;
			fadeClear(s);
			s.play3D(x, y, volume, false, 0.1);
			
			addToGroup(s, group);
		}
		static internal function addToGroup(s:Sample, group:int, force:Boolean = false):void {
			if (group >= 0) {
				if (force && _sound_groups[group] != null) {
					fadeVolume(_sound_groups[group], 0, 0.4, true);
					_sound_groups[group] = null;
				}
				if (s.channel != null) {
					s.channel.addEventListener(Event.SOUND_COMPLETE, onGroupSoundComplete);
					_sound_groups[group] = s;
				}
			}
		}
		static private function onGroupSoundComplete(e:Event):void {
			for (var k:String in _sound_groups) {
				if (_sound_groups[k].channel == e.target || !_sound_groups[k].isPlaying) {
					_sound_groups[k] = null;
				}
			}
		}
		static internal function getSound(name:String):Sample {
			var s:Sample = _samples[name];
			if (s == null) {
				s = createSound(name);
				if (s == null) return null;
				_samples[name] = s;
			}
			return s;
		}
		static public function playMusic(name:String, fade_time:Number = 3, position:Number = -1, force:Boolean = false):Sample {
			if (_music != null) {
				if (!force && _music.name == name) return _music;
				fadeVolume(_music, 0, fade_time, true, true);
			}
			
			_music = createMusic(name);
			_music.play(0, true, 0.2);
			if(position >= 0) _music.position = position;
			fadeVolume(_music, 1, fade_time);
			return _music;
		}
		static public function playMusicFromClass(snd:Class, fade_time:Number = 3, position:Number = -1):Sample {
			if (_music != null) {
				fadeVolume(_music, 0, fade_time, true, true);
			}
			
			_music = new MusicSample("music", new snd());
			_music.play(0, true, 0.2);
			if(position >= 0) _music.position = position;
			fadeVolume(_music, 1, fade_time);
			return _music;
		}
		static public function stopMusic(fade_time:Number = 3):void {
			if (_music != null) {
				fadeVolume(_music, 0, fade_time, true, true);
				_music = null;
			}
		}
		static public function get music():Sample {
			return _music;
		}
		
		static public function createSound(name:String):Sample {
			return new SoundSample(name, createSoundByName(name));
		}
		static public function createMusic(name:String):Sample {
			return new MusicSample(name, createSoundByName(name));
		}
		
		static private function createSoundByName(name:String):Sound {
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
		static public function getTransform3D(x:Number, y:Number, volume:Number, st:SoundTransform = null):SoundTransform {
			var dist_x:Number = ((x - center.x) / size.x);
			var dist_y:Number = ((y - center.y) / size.y);
			var vol_x:Number = (1 - Math.abs(dist_x * vol_mod));
			var vol_y:Number = (1 - Math.abs(dist_y * vol_mod));
			var vol:Number = Math.min(1, Math.min(vol_x, vol_y) * volume);
			if (vol <= 0) return st;
			var pan:Number = dist_x * pan_mod;
			pan = Math.min(1, Math.max( -1, pan));
			if (st == null) {
				st = new SoundTransform(vol, pan);
			} else {
				st.volume = vol;
				st.pan = pan;
			}
			return st;
		}
		
		
		// FADE
		static public function fadeVolume(sample:Sample, vol:Number, time:Number = 1, is_stop:Boolean = false, is_free:Boolean = false):void {
			if (sample == null) return;
			TweenLite.to(sample, time, { volume:vol, overwrite:1, onComplete:onFadeVolumeComplete, onCompleteParams:[sample, is_stop || is_free, is_free] } );
			if (is_free) {
				delete _samples[sample.name];
			}
		}
		static public function fadeClear(sample:Sample):void {
			if (sample == null) return;
			TweenLite.killTweensOf(sample);
		}
		static public function isFade(sample:Sample):Boolean {
			if (sample == null) return false;
			return sample in TweenLite.masterList;
		}
		static private function onFadeVolumeComplete(sample:Sample, is_stop:Boolean, is_free:Boolean):void {
			if (is_stop) {
				sample.stop();
				if (sample == _music) {
					_music = null;
				}
			}
			if (is_free) {
				sample.free();
			}
		}
		
		static internal function count(name:String):int {
			return int(_sound_counts[name]);
		}
		static internal function countUp(name:String):void {
			if (_sound_counts[name] == null) _sound_counts[name] = 0;
			_sound_counts[name] += 1;
		}
		static internal function countDown(name:String):void {
			if (_sound_counts[name] == null) _sound_counts[name] = 0;
			_sound_counts[name] -= 1;
		}
	}
}