package elmortem.api.flashfang {
	import com.greensock.TweenLite;
	import elmortem.api.BaseAPI;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import mochi.as3.MochiScores;

	public class FlashFangAPI extends BaseAPI {
		private var clip:Sprite;
		private var key:String;
		private var on_load:Function;
		private var on_stat:Function;
		private var on_error:Function;
		private var api:Object;
		private var username:String;
		private var character:Object;
		private var friends:Vector.<Object>;
		private var stats:Object;
		
		public var errorMessage:String;

		public function FlashFangAPI(Clip:Sprite, GameKey:String, OnLoad:Function = null, OnStat:Function = null, OnError:Function = null) {
			clip = Clip;
			key = GameKey;
			on_load = OnLoad;
			on_stat = OnStat;
			on_error = OnError;
			api = null;
			username = "anonymous";
			character = { strength:1, dexterity:1, luck:1 };
			friends = new Vector.<Object>();
			stats = { };
			
			errorMessage = "";
			
			connect();
		}
		private function connect():void {
			
			trace("FlashFang.connect");
			try {
				var api_url:String = "http://flashfang.com/api/as3/flashkarma_api_as3.swf?"+int(Math.random() * int.MAX_VALUE);
				
				Security.loadPolicyFile("http://flashfang.com/crossdomain.xml");
				Security.loadPolicyFile("http://flashfang.com/api/crossdomain.xml");
				
				var context:LoaderContext = new LoaderContext();
				if (Security.sandboxType != 'localTrusted') context.securityDomain = SecurityDomain.currentDomain;
				context.applicationDomain = ApplicationDomain.currentDomain;
				context.checkPolicyFile = true;
				
				Security.allowDomain('*');
				
				var urlLoader:Loader = new Loader();
				urlLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.load(new URLRequest(api_url), context);
				clip.stage.addChild(urlLoader);
			} catch(err:String) {
				trace(err);
			}
		}
		private function onComplete(e:Event):void {
			trace("FlashFang.onComplete");
			api = e.currentTarget.content;
			if (api != null) {
				api.setCallbacks(onCallback, onError);
				api.connect(key);
				api.getUser();
				api.getFriends();
				if (on_load != null) {
					on_load(true);
				}
			} else {
				trace("FlashFang: Api not loaded.");
			}
		}
		private function onIoError(e:IOErrorEvent):void {
			trace("FlashFang: Score API IO error.");
			if (on_error != null) on_error(e.toString());
		}
		
		private function onCallback(data:String):void {
			trace(data);
			var i:int;
			if (on_error != null) on_error(data);
			var xml:XML = new XML(data);
			var act:String = String(xml.@action);
			if (act == "error") {
				errorMessage = String(xml.@msg);
			} else if (act == "get_user") {
				username = String(xml.users.user[0].@login);
				character.strength = int(xml.users.user[0].strength);
				character.dexterity = int(xml.users.user[0].dexterity);
				character.luck = int(xml.users.user[0].luck);
			} else if (act == "get_friends") {
				friends.length = 0;
				for (i = 0; i < xml.users.user.length(); i++) {
					var frnd:Object = { id:int(xml.users.user[i].@id), nickname:String(xml.users.user[i].@login) };
					friends.push(frnd);
				}
			} else if (act == "load_stat") {
				//
			}
		}
		private function onError(str:String):void {
			trace("FlashFang Error: " + str);
			if (on_error != null) on_error(str);
		}
		
		override public function sendScore(Score:int, Mode:String = null):void {
			if (api == null) {
				TweenLite.delayedCall(3, sendScore, [Score, Mode]);
				return;
			}
			try {
				api.submitScore(Score, Mode);
				try {
					MochiScores.showLeaderboard( { boardID:Mode, score:Score, onDisplay:onLeaderboardDisplay, onClose:onLeaderboardClose } );
				} catch (err2:Error) {
					if (on_error != null) on_error(err2.message);
				}
			} catch (err:Error) {
				trace(err);
				if (on_error != null) on_error(err.message);
			}
		}
		override public function showLeaderboard(Mode:String = null):void {
			try {
				MochiScores.showLeaderboard( { boardID:Mode, onDisplay:onLeaderboardDisplay, onClose:onLeaderboardClose } );
			} catch (err:Error) {
				if (on_error != null) on_error(err.message);
			}
		}
		override public function unlockAchievement(Id:Object):void {
			if (api == null) {
				TweenLite.delayedCall(3, unlockAchievement, [Id]);
				return;
			}
			try {
				api.addAchievement(Id);
			} catch (err:Error) {
				trace(err);
				if (on_error != null) on_error(err.message);
			}
		}
		override public function getNickname():String {
			return username;
		}
		
		override public function getParam(name:String, on_value:Function = null):Object {
			switch(name) {
				case "username":
				case "login":
				case "nickname":
					return username;
				break;
				case "strength":
					return character.strength;
				break;
				case "dexterity":
					return character.dexterity;
				break;
				case "luck":
					return character.luck;
				break;
				case "friends":
					return friends;
				break;
				
			}
			return null;
		}
		
		private function onLeaderboardDisplay():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_SHOW));
		}
		private function onLeaderboardClose():void {
			dispatchEvent(new Event(BaseAPI.EVENT_LEADERBOARD_HIDE));
		}
	}
}