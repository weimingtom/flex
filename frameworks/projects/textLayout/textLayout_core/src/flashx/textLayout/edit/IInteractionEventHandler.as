package flashx.textLayout.edit
{
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	/**
	 * The IInteractionEventHandler interface defines the event handler functions that
	 * are handled by a Text Layout Framework selection or edit manager.
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 */
	public interface IInteractionEventHandler
	{
		/** 
		 * Processes an edit event.
		 * 
		 * <p>Edit events are dispatched for cut, copy, paste, and selectAll commands.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */	
		function editHandler(event:Event):void;
		
		/** 
		* Processes a keyDown event.
		*  
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
		*/	
		function keyDownHandler(event:KeyboardEvent):void;
		
		/** 
		* Processes a keyUp event.
		* 
		* @playerversion Flash 10
		* @playerversion AIR 1.5
 		* @langversion 3.0
		*/	
		function keyUpHandler(event:KeyboardEvent):void;		
		
		/** 
		 * Processes a TextEvent.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */
		function textInputHandler(event:TextEvent):void;

		/** 
		 * Processes a mouseDown event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */	
		function mouseDownHandler(event:MouseEvent):void;

		/** 
		 * Processes a mouseMove event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */	
		function mouseMoveHandler(event:MouseEvent):void;
		
		/** 
		 * Processes a mouseUp event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */	
		function mouseUpHandler(event:MouseEvent):void;		
		
		/** 
		 * Processes a mouseDoubleClick event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */	
		function mouseDoubleClickHandler(event:MouseEvent):void;

		/** 
		 * Processes a mouseOver event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */			
		function mouseOverHandler(event:MouseEvent):void;

		/** 
		 * Processes a mouseOut event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */					
		function mouseOutHandler(event:MouseEvent):void;
		
		/** 
		 * Processes a focusIn event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */
		function focusInHandler(event:FocusEvent):void;
		 
		/** 
		 * Processes a focusOut event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */
		function focusOutHandler(event:FocusEvent):void;

		/** 
		 * Processes an activate event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */				
		function activateHandler(event:Event):void;
		
		/** 
		 * Processes a deactivate event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */				
		function deactivateHandler(event:Event):void;
		
		/** 
		 * Processes a focusChange event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */				
		function focusChangeHandler(event:FocusEvent):void
		
		/** 
		 * Processes a menuSelect event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */				
		function menuSelectHandler(event:ContextMenuEvent):void
		
		/** 
		 * Processes a mouseWheel event.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
 		 * @langversion 3.0
		 */				
		function mouseWheelHandler(event:MouseEvent):void
	}
}