////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.accessibility.AccessibilityImplementation;
import flash.accessibility.AccessibilityProperties;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

import mx.accessibility.AccConst;
import mx.containers.Form;
import mx.containers.FormHeading;
import mx.containers.FormItem;
import mx.controls.Label;
import mx.core.Container;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.managers.SystemManager;
import mx.resources.ResourceManager;
import mx.resources.IResourceManager;

use namespace mx_internal;

[ResourceBundle("controls")]

/**
 *  The AccImpl class is Flex's base class for implementing accessibility
 *  in UIComponents.
 *  It is a subclass of the Flash Player's AccessibilityImplementation class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */ 
public class AccImpl extends AccessibilityImplementation
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Method for supporting Form Accessibility.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getFormName(component:UIComponent):String
    {
        var formName:String = "";
        
        // Return nothing if we are a container 
        if (component is Container)
            return formName;

        // keeping this DisplayObjectContainer since parent returns
        // that as root is not a UIComponent.
        var par:DisplayObjectContainer = component.parent; 
        // continue looking up the parent chain
        // until root (or application) or FormItem is found.
        while (par && !(par is FormItem) &&
               !(par is SystemManager) && par != component.root)
        {
            par = par.parent;
        }

        if (par && par is FormItem)
            formName = updateFormItemString(FormItem(par));

        return formName;
    }
    
    /**
     *  @private
     *  Method for supporting Form Accessibility.
     */
    private static function joinWithSpace(s1:String,s2:String):String
    {
		// Single space treated as null so developers can override default name elements with " ".
		if (s1 == " ")
			s1 = "";
		if (s2 == " ")
			s2 = "";
        if (s1 && s2)
            s1 += " " +s2;
        else if (s2)
            s1 = s2;
        // else we have non-empty s1 and empty s2, so do nothing.
        return s1;
    }
    
    /**
     *  @private
     *  Method for supporting Form Accessibility.
     */
    private static function updateFormItemString(formItem:FormItem):String
    {
        var formName:String = "";
        var resourceManager:IResourceManager = ResourceManager.getInstance();
        
        const itemLabel:Label = formItem.itemLabel;
        const accProp:AccessibilityProperties = (itemLabel ? itemLabel.accessibilityProperties : null);
        if (accProp && accProp.silent)
            // We already calculated this label's name below, so just return it.
            // FIXME gosmith: Caching this will cause problems if
            // formItem, item label, or form header changes dynamically.
            return accProp.name;

        var form:UIComponent = UIComponent(formItem.parent);

        // If we are located within a Form, then look for the first FormHeading
        // that is a sibling that is above us in the parent's child hierarchy
        if (form is Form)
        {
            var formItemIndex:int = form.getChildIndex(formItem);
            for (var i:int = formItemIndex; i >= 0; i--)
            {
                var child:UIComponent = UIComponent(form.getChildAt(i));
                if (child is FormHeading)
                {
                    // Accessible name if it exists, else label text.
                    if (FormHeading(child).accessibilityProperties)
                        formName = 
                        FormHeading(child).accessibilityProperties.name;
                    if (formName == "") 
                        formName = FormHeading(child).label;
                    break;
                }
            }
        }

        // Add in "Required Field" text if we are a required field
        if (formItem.required)
            formName = joinWithSpace(formName,
                resourceManager.getString("controls","requiredField"))

        // Add in the label from the formItem
        // Accessible name if it exists, else label text.
        var f:String = "";
        if (formItem.accessibilityProperties)
            f = formItem.accessibilityProperties.name
        if (f == "")
            f = formItem.label;
            
        formName = joinWithSpace(formName, f);

        /* 
         * Disable form item label accessibility so the form item label and the 
         * text from the form item label are not both seen in the virtual view of       
         * a screen reader.
         * Otherwise, the formItem would appear with a name, followed
         * by the component being labeled, with a duplicate of that name.
         * Setting silent here also causes code above to avoid recalculating the name.
         * FIXME gosmith: If the caching above is removed, remove the above comment also.
         */
        if (accProp && !accProp.silent)
        {
            accProp.silent = true;
            accProp.name = formName;
        }

        return formName;
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function AccImpl(master:UIComponent)
    {
        super();

        this.master = master;
        
        stub = false;
        
        // Hook in UIComponentAccProps setup here!
        if (!master.accessibilityProperties)
            master.accessibilityProperties = new AccessibilityProperties();
        
        // Hookup events to listen for
        var events:Array = eventsToHandle;
        if (events)
        {
            var n:int = events.length;
            for (var i:int = 0; i < n; i++)
            {
                master.addEventListener(events[i], eventHandler);
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  A reference to the UIComponent instance that this AccImpl instance
     *  is making accessible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var master:UIComponent;
    
    /**
     *  Accessibility role of the component being made accessible.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected var role:uint;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    /**
     *  All subclasses must override this function by returning an array
     *  of strings of the events to listen for.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function get eventsToHandle():Array
    {
        return [ "errorStringChanged", "toolTipChanged", "show", "hide" ];
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Returns the system role for the component.
     *
     *  @param childID uint.
     *
     *  @return Role associated with the component.
     *
     *  @tiptext Returns the system role for the component
     *  @helpid 3000
     */
    override public function get_accRole(childID:uint):uint
    {
        return role;
    }
    
    /**
     *  @private
     *  Returns the name of the component.
     *
     *  @param childID uint.
     *
     *  @return Name of the component.
     *
     *  @tiptext Returns the name of the component
     *  @helpid 3000
     */
    override public function get_accName(childID:uint):String
    {
        var accName:String;

        // For simple children, do not include anything but the default name.
        // Examples: combo box items, list items, etc.
        if (childID)
        {
            accName = getName(childID);
            // Historical: Return null and not "" for empty and null values.
            return (accName != null && accName != "") ? accName : null;
        }

        // Start with form header and/or formItem label text.
        // Also includes "Required Field" where appropriate.
        accName = getFormName(master);

        // Now the component's name or toolTip.
        if (master.accessibilityProperties && 
            master.accessibilityProperties.name != null && 
            master.accessibilityProperties.name != "")
        {
			// An accName is set, so use only that.
            accName = joinWithSpace(accName, master.accessibilityProperties.name);
        }
        else
        {
			// No accName set; use default name, or toolTip if that is empty.
            accName = joinWithSpace(accName, getName(0) || master.toolTip);
        }
        
        accName = joinWithSpace(accName, getStatusName());
        
        // Historical: Return null and not "" for empty and null values.
        return (accName != null && accName != "") ? accName : null;
    }
  
    /**
     *  @private
     *  Method to return an array of childIDs.
     *
     *  @return Array
     */
    override public function getChildIDArray():Array
    {
        return [];
    }
    
    /**
     *  @private
     *  IAccessible method for giving focus to a child item in the component
     *  (but not to the component itself; accSelect() is never called
     *  with a childID of 0).
     *  Even though this method does nothing, without it the Player
     *  causes an IAccessible "Member not found" error.
     */
    override public function accSelect(selFlag:uint, childID:uint):void
    {
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns the name of the accessible component.
     *  All subclasses must implement this
     *  instead of implementing get_accName().
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getName(childID:uint):String
    {
        return null;
    }
    
    /**
     *  Utility method to determine state of the accessible component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function getState(childID:uint):uint
    {
        var accState:uint = AccConst.STATE_SYSTEM_NORMAL;
        
        if (!UIComponent(master).enabled)
        {
            accState &= ~AccConst.STATE_SYSTEM_FOCUSABLE;
            accState |= AccConst.STATE_SYSTEM_UNAVAILABLE;
        }
        else
        {
            accState |= AccConst.STATE_SYSTEM_FOCUSABLE
        
            if (UIComponent(master) == UIComponent(master).getFocus())
                accState |= AccConst.STATE_SYSTEM_FOCUSED;
        }

        return accState;
    }
    
    /**
     *  @private
     */
    protected function createChildIDArray(n:int):Array
    {
        var a:Array = new Array(n);
        
        for (var i:int = 0; i < n; i++)
        {
            a[i] = i + 1;
        }
        
        return a;
    }
    
    /**
     *  @private
     */
    private function getStatusName():String
    {
        var statusName:String = "";

        if (master is UIComponent && UIComponent(master).errorString)
            statusName = UIComponent(master).errorString;

        return statusName;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  Generic event handler.
     *  All AccImpl subclasses must implement this
     *  to listen for events from its master component. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    protected function eventHandler(event:Event):void
    {
        $eventHandler(event);
    }

    /**
     *  @private
     *  Handles events common to all accessible UIComponents.
     */
    protected final function $eventHandler(event:Event):void
    {
        switch (event.type)
        {
            case "errorStringChanged":
            case "toolTipChanged":
            {
                Accessibility.sendEvent(master, 0,
										AccConst.EVENT_OBJECT_NAMECHANGE);
                Accessibility.updateProperties();
                break;
            }

            case "show":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_SHOW);
                Accessibility.updateProperties();
                break;
            }

            case "hide":
            {
                Accessibility.sendEvent(master, 0, AccConst.EVENT_OBJECT_HIDE);
                Accessibility.updateProperties();
                break;
            }
        }
    }
}

}
