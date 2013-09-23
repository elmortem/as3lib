package elmortem.api.mofunzone {
	import elmortem.api.BaseAPI;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.Security;
	import MoFunZoneAPI.MFZEasyAPI;


	public class MofunzoneAPI extends BaseAPI {
		
		/*
		 * 
		 */
		public function MofunzoneAPI(attr:Object) {
			super();
			MFZEasyAPI.displayConfig.workspaceWidth = attr.width;
			MFZEasyAPI.displayConfig.workspaceHeight = attr.height;
			MFZEasyAPI.displayConfig.autoPosition = "cc";
			MFZEasyAPI.displayConfig.dialogScale = 1;
			MFZEasyAPI.userInfoEnabled = attr.userInfo;
			//Enabled achievement Feature
			MFZEasyAPI.achievementEnabled = true; 
			MFZEasyAPI.achievementConfig.gameID = attr.gameId;
			MFZEasyAPI.achievementConfig.testMode = attr.testMode;
			
			MFZEasyAPI.readyCallBack(attr.onReady);
			MFZEasyAPI.downloadAPI(attr.stage);
		}
		
		private function loadComplete(event:Event):void {
			
		}
		
		override public function getNickname():String {
			return MFZEasyAPI.getUserName();
		}
		override public function unlockAchievement(Id:Object):void {
			MFZEasyAPI.success(Id as String);
		}
	}
}