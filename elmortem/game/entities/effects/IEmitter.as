package elmortem.game.entities.effects {
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author elmortem
	 */
	public interface IEmitter {
		function init(system:ParticleSystem):void;
		function addParticle():Number; // return particle adding time
		function updateParticle(p:Object, delta:Number):Boolean; // return dead or life particle
	}
	
}