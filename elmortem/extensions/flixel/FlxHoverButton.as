package elmortem.extensions.flixel
{
	import flash.events.MouseEvent;
	import org.flixel.* ;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 * A much-neutered version of FlxButton, which uses callbacks instead of FlxSprites/FlxTexts
	 */
	public class FlxHoverButton extends FlxObject
	{
		/**
		 * Used for checkbox-style behavior.
		 */
		protected var _onToggle:Boolean;
		/**
		 * This function is called when the button is clicked.
		 */
		protected var _callback:Function, _on:Function, _off:Function;
		/**
		 * Tracks whether or not the button is currently pressed.
		 */
		protected var _pressed:Boolean;
		/**
		 * Whether or not the button has initialized itself yet.
		 */
		protected var _initialized:Boolean;
		/**
		 * Helper variable for correcting its members' <code>scrollFactor</code> objects.
		 */
		protected var _sf:FlxPoint;
		
		protected var _callbackArgs:Array ;
		
		protected var _toggleVisible:Boolean ;
		
		/**
		 * Creates a new <code>FlxButton</code> object with a gray background
		 * and a callback function on the UI thread.
		 * 
		 * @param	X			The X position of the button.
		 * @param	Y			The Y position of the button.
		 * @param	Callback	The function to call whenever the button is clicked.
		 */
		public function FlxHoverButton(X:int,Y:int,W:int, H:int, Callback:Function)
		{
			super(X, Y, W, H);
			_callback = Callback;
			_onToggle = false;
			_pressed = false;
			_initialized = false;
			_sf = null;
		}
		
		/**
		 * Use this to toggle checkbox-style behavior.
		 */
		public function get on():Boolean
		{
			return _onToggle;
			_onToggle = On;
		}
		
		/**
		 * @private
		 */
		public function set on(On:Boolean):void
		{
			_onToggle = On;
			_toggleVisible = On ;
		}
		
		/**
		 * Sets the functions to call per button state.
		 * 
		 * @param	on		Function to call when button is hovered over/toggled on
		 * @param	off		Function to call when button is inactive/toggled off
		 */
		public function setHover (on:Function, off:Function):void
		{
			_on = on ;
			_off = off ;
		}
		
		/**
		 * Called by the game state when state is changed (if this object belongs to the state)
		 */
		override public function destroy():void
		{
			if(FlxG.stage != null)
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Internal function for handling the visibility of the off and on graphics.
		 * 
		 * @param	On		Whether the button should be on or off.
		 */
		protected function visibility(On:Boolean):void
		{
			if(On)
			{
				_toggleVisible = true ;
				if (_on != null)
					if (_callbackArgs)
						_on.apply (this, _callbackArgs) ;
					else
						_on();
			}
			else
			{
				_toggleVisible = false ;
				if (_off != null)
					if (_callbackArgs)
						_off.apply (this, _callbackArgs) ;
					else
						_off();
			}
		}

		override public function update():void
		{
			if(!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
			
			super.update();

			visibility(false);
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if(!FlxG.mouse.pressed())
					_pressed = false;
				else if(!_pressed)
					_pressed = true;
				visibility(!_pressed);
			}
			if(_onToggle) visibility(!_toggleVisible);
		}
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 */
		protected function onMouseUp(event:MouseEvent):void
		{	
			if (!exists || !visible || !active || !FlxG.mouse.justReleased() || (_callback == null)) return;
			if (FlxG.pause)
				return ;
			if (overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				if (_callbackArgs)
					_callback.apply (this, _callbackArgs) ;
				else
					_callback();
			}
		}
		
		public function setCallbackArgs (args:Array):void
		{
			_callbackArgs = args ;
		}
	}
}