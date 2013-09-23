package elmortem.game.states {
	import elmortem.game.entities.EntityEvent;
	
	public interface IGameplay {
		
		function loadStats():void;
		function genLevel():void;
		
		function onEnetityAdd(e:EntityEvent):void;
		function onEnetityRemove(e:EntityEvent):void;
		
		function addScore(val:Number):void;
	}
}