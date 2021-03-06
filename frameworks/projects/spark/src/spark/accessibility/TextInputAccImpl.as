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

import mx.accessibility.AccConst;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.TextInput;

use namespace mx_internal;


/**
 *  TextInputAccImpl is a subclass of AccessibilityImplementation
 *  which implements accessibility for the TextInput class.
 *
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class TextInputAccImpl extends SkinnableTextBaseAccImpl
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the TextInput class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of TextInput are initialized,
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
        TextInput.createAccessibilityImplementation = 
            createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates a TextInput's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        component.accessibilityImplementation =
            new TextInputAccImpl(component);
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
    public function TextInputAccImpl(master:UIComponent)
    {
        super(master);
    }
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  IAccessible method for returning the text value of the TextInput
     *
     *  @param childID uint
     *
     *  @return Value String
     */
    override public function get_accValue(childID:uint):String
    {    
        // this should return E_ACCESSDENIED for password fields, 
        // but this methods return type won't allow that
        return TextInput(master).displayAsPassword ? "" : 
            super.get_accValue(childID);
    }

    /**
     *  @private
     *  IAccessible method for returning the state of the TextInput.
     *  States are predefined for all the components in MSAA.
     *  Values are assigned to each state.
     *  Depending upon the TextInput being pressed or released,
     *  a value is returned.
     *
     *  @param childID uint
     *
     *  @return State uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = super.get_accState(childID);
        if (TextInput(master).displayAsPassword)
            accState |= AccConst.STATE_SYSTEM_PROTECTED;
        return accState;
    }
}
}
