package elmortem.preloaders {
	import elmortem.actions.Actions;
	import elmortem.ads.ABSLoader;
	import elmortem.ads.CPMStarLoader;
	import elmortem.ads.NoneLoader;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	//import elmortem.ads.NewgroundsLoader;
	import elmortem.utils.UrlUtils;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	import mochi.as3.MochiAd;
	import mochi.as3.MochiServices;
	import Playtomic.Log;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public dynamic class BasePreloader extends MovieClip {
		private var info:Object = { };
		
		private var cpmstar:CPMStarLoader = null;
		//private var newgrounds:NewgroundsLoader = null;
		private var abs:ABSLoader = null;
		private var none:NoneLoader = null;
		private var bar:PreloaderBar = null;
		
		protected var progress:Number;
		private var byteLoaded:Number;
		private var byteTotal:Number;
		private var finished:Boolean;
		
		static private var debug:TextField = null;
		
		public function BasePreloader() {
			CONFIG::debug {
				addChild(debug = new TextField());
				debug.x = 5;
				debug.y = 5;
				debug.width = 500 - 10;
				debug.height = 400 - 10;
				debug.mouseEnabled = false;
				debug.textColor = 0xffffff;
				debug.filters = [new GlowFilter(0x000000, 1, 4, 4, 3, 1)];
			}
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			finished = false;
			
			info = getInfo();
			if (info.adBlock != null && info.adBlock is Array) {
				if (UrlUtils.isUrl(info.adBlock, stage, true)) info.ad = "";
			}
			
			if(info.playtomicSwfId != null) {
				Log.View(info.playtomicSwfId, info.playtomicGuid, info.playtomicApiKey, root.loaderInfo.loaderURL);
			}
			
			// Progress Bar
			if(info.ad != "mochi") {
				addChild(bar = new PreloaderBar());
				if (info.barGfx != null) {
					bar.initWidthGfx(info.barGfx);
				} else {
					bar.init(info.barColor, info.barWidth, info.barHeight);
				}
				bar.x = int(info.barX);
				bar.y = int(info.barY);
			}
			
			// CPMStar
			if (info.ad == "cpmstar") {
				addChild(cpmstar = new CPMStarLoader(info.cpmstarTime, info.spmstarContantSpotId));
				cpmstar.x = (stage.stageWidth - 300) * 0.5;
				cpmstar.y = (stage.stageHeight - 250) * 0.5;
			}
			
			// Mochi
			if (info.ad == "mochi") {
				MochiAd.showPreGameAd( { clip:this, id:info.mochiId, res:info.mochiRes, background:0xB0F7FD, color:0x3482DC, outline:0x7DA2B4, no_bg:true, no_progress_bar:false, ad_started:function ():void { }, ad_finished:loadingFinished, ad_progress:onAdProgress } );
			}
			
			// Newgrounds
			/*if (info.ad == "newgrounds") {
				addChild(newgrounds = new NewgroundsLoader(20, loaderInfo, info.newgroundsId, info.newgroundsKey, UrlUtils.isUrl(["newgrounds.com"], stage)));
				newgrounds.x = (720 - 300) * 0.5;
				newgrounds.y = (480 - 275) * 0.5;
			}*/
			
			// ABS
			if (info.ad == "abs") {
				addChild(abs = new ABSLoader(info.absTime));
				abs.x = (stage.stageWidth - 300) * 0.5;
				abs.y = (stage.stageHeight - 250) * 0.5;
			}
			
			if (info.ad == "") {
				addChild(none = new NoneLoader(int(info.time)));
			}
			
			progress = 0;
			byteLoaded = root.loaderInfo.bytesLoaded;
			byteTotal = root.loaderInfo.bytesTotal;
			
			log("byteTotal: "+byteTotal);
			
			addEventListener(Event.ENTER_FRAME, checkFrame);
			root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			root.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);
		}
		
		private function ioError(e:IOErrorEvent):void {
			log(e.text);
		}
		
		private function onProgress(e:ProgressEvent):void {
			// TODO update loader
			byteLoaded = e.bytesLoaded;
			byteTotal = e.bytesTotal;
			if (byteTotal == 0) {
				log("Fail total bytes...");
				byteTotal = (info.byteTotal != null)?info.byteTotal:5000000;
			}
			if (byteLoaded > byteTotal) byteLoaded = byteTotal;
			progress = byteLoaded / byteTotal;
		}
		private function onAdProgress(val:Number):void {
			progress = val / 100;
		}
		
		protected function checkFrame(e:Event):void {
			if(cpmstar != null) {
				progress = Math.min(cpmstar.progress(), byteLoaded / byteTotal);
			}
			/*if(newgrounds != null) {
				progress = Math.min(newgrounds.progress(), bLoaded / bTotal);
			}*/
			if (abs != null) {
				progress = Math.min(abs.progress(), byteLoaded / byteTotal);
			}
			if (none != null) {
				progress = Math.min(none.progress(), byteLoaded / byteTotal);
			}
			if (bar != null) {
				//bar.scaleX = 700 / 100 * progress;
				bar.progress = progress;
				//log("Loading " + int(progress * 100) + "%..." + " (" + bLoaded + " of " + bTotal + ") " + bar.progress);
			}
			
			if (progress >= 1 && currentFrame == totalFrames && (!info.mochiService || MochiServices.connected)) {
				log("stop");
				stop();
				showPlay();
			}
		}
		
		protected function showPlay():void {
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			if (bar != null) {
				bar.visible = false;
			}
			
			//startup();
			loadingFinished();
		}
		
		protected function loadingFinished():void {
			if (finished) return;
			finished = true;
			
			log("loadingFinished");
			if (cpmstar != null) {
				removeChild(cpmstar);
				cpmstar = null;
			}
			/*if (newgrounds != null) {
				removeChild(newgrounds);
				newgrounds = null;
			}*/
			if (abs != null) {
				abs.free();
				removeChild(abs);
				abs = null;
			}
			if (none != null) {
				removeChild(none);
				none = null;
			}
			if(bar != null) {
				removeChild(bar);
				bar = null;
			}
			root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			root.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			startup();
		}
		
		private function startup():void {
			clear();
			log("startup");
			if (info.lock != null && !UrlUtils.isUrl(info.lock, stage)) 
			{
				CONFIG::release {
					if (!UrlUtils.open(info.lock_url, "_self")) {
						UrlUtils.open(info.lock_url);
					}
				}
				CONFIG::debug {
					log("Current URL: "+UrlUtils.getDomain(stage, false));
					for (var i:int = 0; i < info.lock.length; i++) {
						log(info.lock[i]);
					}
				}
				return;
			}
			var mainClass:Class = getDefinitionByName(info.app) as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
		protected function clear():void {}
		protected function getInfo():Object {
			return { };
		}
		
		private function log(str:String):void {
			CONFIG::debug {
				trace(str);
				debug.parent.setChildIndex(debug, debug.parent.numChildren - 1);
				debug.appendText(str + "\n");
				debug.scrollV = debug.maxScrollV;
			}
		}
	}
	
}