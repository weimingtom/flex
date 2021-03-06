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

import mx.accessibility.AccImpl;
import mx.accessibility.AccConst;
import mx.core.mx_internal;
import mx.core.UIComponent;

import spark.components.WindowedApplication;

use namespace mx_internal;

/**
 *  WindowedApplicationAccImpl is a subclass of AccessibilityImplementation
 *  which implements accessibility for the WindowedApplication class.
 *
 *  @langversion 3.0
 *  @playerversion AIR 2
 *  @productversion Flex 4
 */
public class WindowedApplicationAccImpl extends AccImpl
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Enables accessibility in the WindowedApplication class.
     *
     *  <p>This method is called by application startup code
     *  that is autogenerated by the MXML compiler.
     *  Afterwards, when instances of WindowedApplication are initialized,
     *  their <code>accessibilityImplementation</code> property
     *  will be set to an instance of this class.</p>
     *
     *  @langversion 3.0
     *  @playerversion AIR 2
     *  @productversion Flex 4
     */
    public static function enableAccessibility():void
    {
		WindowedApplication.createAccessibilityImplementation =
			createAccessibilityImplementation;
    }

    /**
     *  @private
     *  Creates WindowedApplications's AccessibilityImplementation object.
     *  This method is called from UIComponent's
     *  initializeAccessibility() method.
     */
    mx_internal static function createAccessibilityImplementation(
                                component:UIComponent):void
    {
        // FIXME: attach to titleBar?
		component.accessibilityImplementation =
			new WindowedApplicationAccImpl(component);
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
     *  @playerversion AIR 2
     *  @productversion Flex 4
     */
    public function WindowedApplicationAccImpl(master:UIComponent)
    {
        super(master);

        role = AccConst.ROLE_SYSTEM_GROUPING;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccessibilityImplementation
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  IAccessible method for returning the state of the WindowedApplication.
     *  States are predefined for all the components in MSAA.
	 *  Values are assigned to each state.
     *  Depending upon the WindowedApplication being Focusable,
	 *  Focused and Moveable, a value is returned.
     *
     *  @param childID:int
     *
     *  @return State:uint
     */
    override public function get_accState(childID:uint):uint
    {
        var accState:uint = getState(childID);

        return accState;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods: AccImpl
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Method for returning the name of the WindowedApplication
     *  which is spoken out by the screen reader
     *  The WindowedApplication should return the title as the name.
     *
     *  @param childID:uint
     *
     *  @return Name:String
     */
    override protected function getName(childID:uint):String
    {
        return WindowedApplication(master).title;
    }
}

}
