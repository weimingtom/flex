////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2009 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.accessibility
{
    
    import flash.accessibility.Accessibility;
    import flash.events.Event;
    
import mx.accessibility.AccConst;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.accessibility.AccImpl;
    import spark.components.supportClasses.DropDownListBase;
    
    use namespace mx_internal;
    
    /**
     *  DropDownListBaseAccImpl is a subclass of AccessibilityImplementation
     *  which implements accessibility for the DropDownListBase class.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public class DropDownListBaseAccImpl extends ListBaseAccImpl
    {
        include "../core/Version.as";
        
        //-------------------------------------------------------------------------
        //
        //  Class methods
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Enables accessibility in the DropDownListBase class.
         *
         *  <p>This method is called by application startup code
         *  that is autogenerated by the MXML compiler.
         *  Afterwards, when instances of DropDownListBase are initialized,
         *  their <code>accessibilityImplementation</code> property
         *  will be set to an instance of this class.</p>
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public static function enableAccessibility():void
        {
            DropDownListBase.createAccessibilityImplementation =
                createAccessibilityImplementation;
        }
        
        /**
         *  @private
         *  Creates a DropDownListBase AccessibilityImplementation object.
         *  This method is called from UIComponent's
         *  initializeAccessibility() method.
         */
        mx_internal static function createAccessibilityImplementation(
            component:UIComponent):void
        {
            component.accessibilityImplementation =
                new DropDownListBaseAccImpl(component);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        
        /**
         *  Constructor.
         *
         *  @param master The UIComponent instance that this AccImpl instance
         *  is making accessible.
         *
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion Flex 4
         */
        public function DropDownListBaseAccImpl(master:UIComponent)
        {
            super(master);
            
            role = AccConst.ROLE_SYSTEM_COMBOBOX;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden properties: AccImpl
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------
        //  eventsToHandle
        //----------------------------------
        
        /**
         *  @private
         *  Array of events that we should listen for from the master component.
         */
        override protected function get eventsToHandle():Array
        {
            return super.eventsToHandle.concat(["open", "close"]);
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden methods: AccessibilityImplementation
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  IAccessible method for returning the value of the DropDownListBase
         *  (which would be the text of the item selected).
         *  The DropDownListBase should return the content of the selected item as the value.
         *
         *  @param childID uint
         *
         *  @return Value String
         */
        override public function get_accValue(childID:uint):String
        {
            if (childID == 0)
                return getName(DropDownListBase(master).selectedIndex + 1);
            return null;
        }
        
        /**
         *  @private
         */
        override public function get_accState(childID:uint):uint
        {
            var accState:uint = super.get_accState(childID);
            
            if (childID == 0)
            {
                if (DropDownListBase(master).isDropDownOpen)
                    accState |= AccConst.STATE_SYSTEM_EXPANDED;
                else
                    accState |= AccConst.STATE_SYSTEM_COLLAPSED;
            }
            
            return accState;
        }
        
        //--------------------------------------------------------------------------
        //
        //  Overridden event handlers: AccImpl
        //
        //--------------------------------------------------------------------------
        
        /**
         *  @private
         *  Override the generic event handler.
         *  All AccImpl must implement this
         *  to listen for events from its master component.
         */
        override protected function eventHandler(event:Event):void
        {
            switch (event.type)
            {
                case "open":
                {
                    Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_STATECHANGE);
                    
                    var index:uint = DropDownListBase(master).selectedIndex;
                    if (index >= 0)
                    {
                        Accessibility.sendEvent(master, index + 1,
                            AccConst.EVENT_OBJECT_FOCUS);
                    }
                    break;
                }
                case "close":
                {
                    Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_STATECHANGE);
                    Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_FOCUS);
                    break;
                }
                case "change":
                {
                    if (!(DropDownListBase(master).isDropDownOpen))
                    {
                        Accessibility.sendEvent(master, 0, 
                            AccConst.EVENT_OBJECT_VALUECHANGE, true);
                        break;
                    }
                }
                case "caretChange":
                {
                    if (!(DropDownListBase(master).isDropDownOpen))
                        break;
                }
                default:
                {
                    super.eventHandler(event);
                    break;
                }
            }
        }
        
    }
    
}
