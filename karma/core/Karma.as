package karma.core {
	OS::NOWEB {
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	}
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import karma.display.RootLayer;
	import karma.display.Screen;
	import karma.display.ScreenManager;
	import karma.events.KarmaEvent;
	import karma.game.GameManager;
	import karma.input.Keyboard;
	import karma.input.Mouse;
	import starling.animation.Juggler;
	import starling.core.Starling;
	
	public class Karma {
		static public const NO_SCALE:String = StageScaleMode.NO_SCALE;
		static public const SHOW_ALL:String = StageScaleMode.SHOW_ALL;
		static public const NO_BORDER:String = StageScaleMode.NO_BORDER;
		static public const EXACT_FIT:String = StageScaleMode.EXACT_FIT;
		static public const SCALE_SMART:String = "smart";
		static public const SCALE_EXACT_SMART:String = "exactSmart";
		
		static private var _stage:Stage;
		static private var _starling:Starling = null;
		static private var _width:Number;
		static private var _height:Number;
		static private var _scaleMode:String = "";
		static private var _fps:Number = 60;
		
		static public function start(stage:Stage, viewPort:Rectangle = null):void {
			_stage = stage;
			_width = viewPort.width;
			_height = viewPort.height;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			Starling.multitouchEnabled = true;
			//Starling.handleLostContext = true; //???
			_starling = new Starling(RootLayer, stage, viewPort);
			_starling.simulateMultitouch = false;
			_starling.enableErrorChecking = CONFIG::debug;
			_starling.showStats = CONFIG::debug;
			_starling.start();
			
			stage.addEventListener(Event.RESIZE, onResize);
			
			stage.frameRate = fps;
			
			OS::NOWEB {
			try {
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivate);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
			} catch (err:Error) {
				stage.addEventListener(Event.ACTIVATE, onActivate);
				stage.addEventListener(Event.DEACTIVATE, onDeactivate);
			}
			}
			OS::WEB {
				stage.addEventListener(Event.ACTIVATE, onActivate);
				stage.addEventListener(Event.DEACTIVATE, onDeactivate);
			}
		}
		
		static public function get juggler():Juggler {
			return _starling.juggler;
		}
		
		static public function get root():RootLayer {
			return RootLayer.instance;
		}
		
		// screens
		static public function get screens():ScreenManager {
			return ScreenManager.instance;
		}
		
		// events
		static public function get eventer():EventManager {
			return EventManager.instance;
		}
		
		// mouse
		static public function get mouse():Mouse {
			return Mouse.instance;
		}
		
		// keyboard
		static public function get keyboard():Keyboard {
			return Keyboard.instance;
		}
		
		// clips
		static public function get clips():ClipFactory {
			return ClipFactory.instance;
		}
		
		// size
		static public function get width():Number {
			if (_starling == null) return 0;
			return _starling.stage.stageWidth;
		}
		static public function set width(v:Number):void {
			if (_starling == null) return;
			_starling.stage.stageWidth = v;
		}
		static public function get height():Number {
			if (_starling == null) return 0;
			return _starling.stage.stageHeight;
		}
		static public function set height(v:Number):void {
			if (_starling == null) return;
			_starling.stage.stageHeight = v;
		}
		static public function get screenWidth():Number {
			if (_starling == null) return 0;
			return _starling.viewPort.width;
		}
		static public function get screenHeight():Number {
			if (_starling == null) return 0;
			return _starling.viewPort.height;
		}
		
		static public function get fps():Number {
			return _fps;
		}
		static public function set fps(value:Number):void {
			_fps = value;
			if (_starling == null) return;
			_starling.nativeStage.frameRate = value;
		}
		
		// resize
		static public function get scaleMode():String {
			return _scaleMode;
		}
		static public function set scaleMode(v:String):void {
			if (_scaleMode == v) return;
			_scaleMode = v;
			if (_starling == null) return;
			//_starling.nativeStage.scaleMode = v;
			_starling.nativeStage.dispatchEvent(new Event(Event.RESIZE));
		}
		static private function onResize(e:Event):void {
			if (_starling == null || !_starling.isStarted) return;
			
			var stage:Stage = _starling.nativeStage;
			var viewPort:Rectangle = _starling.viewPort;
			var mod:Number;
			if (_scaleMode == NO_SCALE) {
				viewPort.x = (stage.stageWidth - viewPort.width) * 0.5;
				viewPort.y = (stage.stageHeight - viewPort.height) * 0.5;
			} else if (_scaleMode == SHOW_ALL) {
				mod = Math.min(stage.stageWidth / Karma.width, stage.stageHeight / Karma.height);
				viewPort.width = width * mod;
				viewPort.height = height * mod;
				viewPort.x = (stage.stageWidth - viewPort.width) * 0.5;
				viewPort.y = (stage.stageHeight - viewPort.height) * 0.5;
			} else if (_scaleMode == NO_BORDER) {
				mod = Math.max(stage.stageWidth / Karma.width, stage.stageHeight / Karma.height);
				viewPort.width = width * mod;
				viewPort.height = height * mod;
				viewPort.x = (stage.stageWidth - viewPort.width) * 0.5;
				viewPort.y = (stage.stageHeight - viewPort.height) * 0.5;
			} else if (_scaleMode == EXACT_FIT) {
				viewPort.width = stage.stageWidth;
				viewPort.height = stage.stageHeight;
			} else if (_scaleMode == SCALE_SMART) {
				if (_stage.stageWidth / _width > _stage.stageHeight / _height) {
					var s:int = _stage.stageWidth / _width;
					var k:Number = _stage.stageWidth / _stage.stageHeight;
					_starling.stage.stageWidth = _stage.stageHeight * k / s;
					_starling.stage.stageHeight = _stage.stageHeight / s;
				} else {
					s = _stage.stageHeight / _height;
					k = _stage.stageHeight / _stage.stageWidth;
					_starling.stage.stageWidth = _stage.stageWidth / s;
					_starling.stage.stageHeight = _stage.stageWidth * k / s;
				}
				viewPort.x = 0;
				viewPort.y = 0;
				viewPort.width = _stage.stageWidth;
				viewPort.height = _stage.stageHeight;
			} else if (_scaleMode == SCALE_EXACT_SMART) {
				if (_stage.stageWidth / _width > _stage.stageHeight / _height) {
					k = _stage.stageWidth / _stage.stageHeight;
					_starling.stage.stageWidth = _height * k;
					_starling.stage.stageHeight = _height;
				} else {
					k = _stage.stageHeight / _stage.stageWidth;
					_starling.stage.stageWidth = _width;
					_starling.stage.stageHeight = _width * k;
				}
				viewPort.x = 0;
				viewPort.y = 0;
				viewPort.width = _stage.stageWidth;
				viewPort.height = _stage.stageHeight;
			}
			
			CONFIG::debug {
				trace("==========");
				trace("ContentScaleFactor="+_starling.contentScaleFactor);
				trace("ViewPort.x=" + viewPort.x);
				trace("ViewPort.y="+viewPort.y);
				trace("ViewPort.width=" + viewPort.width);
				trace("ViewPort.height="+viewPort.height);
				trace("StarlingStage.x=" + _starling.stage.x);
				trace("StarlingStage.y=" + _starling.stage.y);
				trace("StarlingStage.width=" + _starling.stage.stageWidth);
				trace("StarlingStage.height=" + _starling.stage.stageHeight);
				trace("StarlingStage.width2=" + _starling.stage.width);
				trace("StarlingStage.height2=" + _starling.stage.height);
				trace("Stage.x=" + stage.x);
				trace("Stage.y="+ stage.y);
				trace("Stage.width=" + stage.stageWidth);
				trace("Stage.height=" + stage.stageHeight);
				trace("Stage.width2=" + stage.width);
				trace("Stage.height2=" + stage.height);
				trace("Stage3D.x=" + _starling.stage3D.x);
				trace("Stage3D.y=" + _starling.stage3D.y);
			}
			
			_starling.viewPort = viewPort;
			screens.resizeAll();
		}
		static private function onActivate(e:Event):void {
			if (_starling == null) return;
			
			_starling.start();
			
			var stage:Stage = _starling.nativeStage;
			//stage.addEventListener(Event.RESIZE, onResize);
			
			OS::NOWEB {
			try {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			} catch (err:Error) { }
			}
			
			stage.frameRate = fps;
			
			screens.activate();
		}
		static private function onDeactivate(e:Event):void {
			if (_starling == null) return;
			
			screens.deactivate();
			
			var stage:Stage = _starling.nativeStage;
			//stage.removeEventListener(Event.RESIZE, onResize);
			
			OS::NOWEB {
			try {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;
			} catch (err:Error) { }
			}
			
			stage.frameRate = 0;
			
			_starling.stop();
			
			// auto-close
			//NativeApplication.nativeApplication.exit();
		}
		
		public function get isAir():Boolean {
			return (Capabilities.playerType == "Desktop");
		}
	};
}