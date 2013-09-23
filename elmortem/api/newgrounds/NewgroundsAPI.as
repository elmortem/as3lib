package elmortem.api.newgrounds {
	import elmortem.api.BaseAPI;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	import flash.utils.ByteArray;


	public class NewgroundsAPI extends BaseAPI {
		
		[Embed(source="library.bin", mimeType="application/octet-stream")]
		private const apiClass:Class;
		
		private var stage:Stage;
		private var movieId:String;
		private var encryptionKey:String;
		
		private var loader:Loader;
		private var isLoaded:Boolean;
		
		private var API:Class;
		private var APIEvent:Class;
		private var MedalPopup:Class;
		private var ScoreTable:Class;
		private var ScoreBoardPeriod:Class;
		
		public function NewgroundsAPI(stage:Stage, MovieId:String, EncryptionKey:String, onReady:Function = null) {
			this.stage = stage;
			movieId = MovieId;
			encryptionKey = EncryptionKey;
			
			if(onReady != null) addEventListener(BaseAPI.EVENT_READY, onReady);
			
			isLoaded = false;
			loader = new Loader();
			loader.addEventListener(Event.COMPLETE, onLoad);
			var ba:ByteArray = new apiClass();
			loader.loadBytes(ba);
		}
		
		private function onLoad(e:Event):void {
			trace("onLoad");
			loader.removeEventListener(Event.COMPLETE, onLoad);
			isLoaded = true;
			
			//API = CLASS("API");
			//APIEvent = CLASS("APIEvent");
			//MedalPopup = CLASS("com.newgrounds.components.MedalPopup");
			//ScoreTable = CLASS("com.newgrounds.components.ScoreTable");
			//ScoreBoardPeriod = CLASS("ScoreBoardPeriod");
			
			//API["addEventListener"](APIEvent["MOVIE_CONNECTED"], onComplete);
			//API.connect(loaderInfo, "MovieID", "EncryptionKey");
			//API["connect"](stage, movieId, encryptionKey);
		}
		
		private function onComplete(e:Event):void {
			trace("onComplete");
			//addChild( new com.newgrounds.components.MedalPopup );
			//stage.addChild(new MedalPopup());
			//addChild( new com.newgrounds.components.ScoreTable("High Scores", ScoreBoardPeriod.TODAY) );
			//stage.addChild(new ScoreTable("High Scores", ScoreBoardPeriod["TODAY"]));
			
			dispatchEvent(new Event(BaseAPI.EVENT_READY));
		}
		
		override public function unlockAchievement(Id:Object):void {
			API["unlockMedal"](Id as String);
		}
		override public function sendScore(Score:int, Mode:String = null):void {
			API["postScore"](Mode, Score.toString());
		}
		override public function showLeaderboard(Mode:String = null):void {
			stage.addChild(API["getScoreBoardByName"](Mode));
		}
		
		
		private function CLASS(name:String):Class {
			return loader.content.loaderInfo.applicationDomain.getDefinition(name) as Class;
		}
	}
}