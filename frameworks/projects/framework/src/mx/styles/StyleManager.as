////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2003-2007 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.styles
{

import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;
import flash.system.SecurityDomain;

import mx.core.FlexVersion;
import mx.core.mx_internal;
import mx.core.Singleton;

/**
 *  The StyleManager class manages the following:
 *  <ul>
 *    <li>Which CSS style properties the class inherits</li>
 *    <li>Which style properties are colors, and therefore get special handling</li>
 *    <li>A list of strings that are aliases for color values</li>
 *  </ul>
 *
 *  @see mx.styles.CSSStyleDeclaration
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class StyleManager
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    /**
     *  The <code>getColorName()</code> method returns this value if the passed-in
     *  String is not a legitimate color name.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static const NOT_A_COLOR:uint = 0xFFFFFFFF;

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  Linker dependency on implementation class.
     */
    private static var implClassDependency:StyleManagerImpl;

    /**
     *  @private
     *  Storage for the impl getter.
     *  This gets initialized on first access,
     *  not at static initialization time, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _impl:IStyleManager2;

    /**
     *  @private
     *  The singleton instance of StyleManagerImpl which was
     *  registered as implementing the IStyleManager2 interface.
     */
    private static function get impl():IStyleManager2
    {
        if (!_impl)
        {
            // FIXME (pfarland): Do we need to check compatibility first?

            _impl = IStyleManager2(
                Singleton.getInstance("mx.styles::IStyleManager2"));
        }

        return _impl;
    }

    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The root of all proto chains used for looking up styles.
     *  This object is initialized once by initProtoChainRoots() and
     *  then updated by calls to setStyle() on the global CSSStyleDeclaration.
     *  It is accessed by code that needs to construct proto chains,
     *  such as the initProtoChain() method of UIComponent.
     */
    mx_internal static function get stylesRoot():Object
    {
        return impl.stylesRoot;
    }
    mx_internal static function set stylesRoot(value:Object):void
    {
        impl.stylesRoot = value;
    }

    /**
     *  @private
     *  Set of inheriting non-color styles.
     *  This is not the complete set from CSS.
     *  Some of the omitted we don't support at all,
     *  others may be added later as needed.
     *  The method registerInheritingStyle() adds to this set
     *  and isInheritingStyle() queries this set.
     */
    mx_internal static function get inheritingStyles():Object
    {
        return impl.inheritingStyles;
    }
    mx_internal static function set inheritingStyles(value:Object):void
    {
        impl.inheritingStyles = value;
    }

    /**
     *  @private
     */
    private static var _qualifiedTypeSelectors:Boolean = true;

    /**
     *  @private
     *  Qualified type selectors were added in Flex 4 to support styling
     *  components with the same local name, e.g. 'spark.components.Button'.
     *  Prior to this type selectors were always unqualified class names  e.g.
     *  'Button'. To ease migration of Flex 3 application, this property can
     *  control whether CSS type selectors must be fully qualified class names
     *  when the compatibility version is 4 or later.
     */
    mx_internal static function get qualifiedTypeSelectors():Boolean
    {
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
            return false;
        else
            return _qualifiedTypeSelectors; 
    }
    mx_internal static function set qualifiedTypeSelectors(value:Boolean):void
    {
        _qualifiedTypeSelectors = value;
    }

    /**
     *  @private
     */
    mx_internal static function get typeHierarchyCache():Object
    {
        return impl.typeHierarchyCache;
    }
    mx_internal static function set typeHierarchyCache(value:Object):void
    {
        impl.typeHierarchyCache = value;
    }

    /**
     *  @private
     */
    mx_internal static function get typeSelectorCache():Object
    {
        return impl.typeSelectorCache;
    }
    mx_internal static function set typeSelectorCache(value:Object):void
    {
        impl.typeSelectorCache = value;
    }

    /**
     *  @private
     *  This method is called by code autogenerated by the MXML compiler,
     *  after StyleManager.styles is popuplated with CSSStyleDeclarations.
     */
    mx_internal static function initProtoChainRoots():void
    {
        impl.initProtoChainRoots();
    }

    /**
     *  Returns an Array of all the CSS selectors that are registered with the StyleManager.
     *  You can pass items in this Array to the <code>getStyleDeclaration()</code> method to get the corresponding CSSStyleDeclaration object.
     *  Class selectors are prepended with a period.
     *  
     *  @return An Array of all of the selectors
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */ 
    public static function get selectors():Array
    {
        return impl.selectors;
    }

    /**
     *  @private 
     *  Determines whether any of the selectors declared a pseudo selector
     *  for the given state. This is used to avoid unnecessary style
     *  regeneration between state changes.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    mx_internal static function hasPseudoCondition(value:String):Boolean
    {
        return impl.hasPseudoCondition(value);
    }

    /**
     *  @private
     *  Determines whether any of the selectors registered with the style
     *  manager have been advanced selectors (descendant selector, id selector,
     *  non-global class selector, or pseudo selector).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    mx_internal static function hasAdvancedSelectors():Boolean
    {
        return impl.hasAdvancedSelectors();
    }

    /**
     *  @private
     *  Gets the list of style declarations for the given subject. The subject
     *  is the right most simple type selector in a potential selector chain.
     * 
     *  @param subject The style subject.
     *  @return Array of StyleDeclarations for this subject.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    mx_internal static function getStyleDeclarations(subject:String):Array
    {
        return impl.getStyleDeclarations(subject);
    }

    /**
     *  Gets the CSSStyleDeclaration object that stores the rules
     *  for the specified CSS selector.
     *
     *  <p>If the <code>selector</code> parameter starts with a period (.),
     *  the returned CSSStyleDeclaration is a class selector and applies only to those instances
     *  whose <code>styleName</code> property specifies that selector
     *  (not including the period).
     *  For example, the class selector <code>".bigMargins"</code>
     *  applies to any UIComponent whose <code>styleName</code>
     *  is <code>"bigMargins"</code>.</p>
     *
     *  <p>If the <code>selector</code> parameter does not start with a period,
     *  the returned CSSStyleDeclaration is a type selector and applies to all instances
     *  of that type.
     *  For example, the type selector <code>"Button"</code>
     *  applies to all instances of Button and its subclasses.</p>
     *
     *  <p>The <code>global</code> selector is similar to a type selector
     *  and does not start with a period.</p>
     *
     *  @param selector The name of the CSS selector.
     *
     *  @return The style declaration whose name matches the <code>selector</code> property.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getStyleDeclaration(
                                selector:String):CSSStyleDeclaration
    {
        return impl.getStyleDeclaration(selector);
    }

    /**
     *  Sets the CSSStyleDeclaration object that stores the rules
     *  for the specified CSS selector.
     *
     *  <p>If the <code>selector</code> parameter starts with a period (.),
     *  the specified selector is a "class selector" and applies only to those instances
     *  whose <code>styleName</code> property specifies that selector
     *  (not including the period).
     *  For example, the class selector <code>".bigMargins"</code>
     *  applies to any UIComponent whose <code>styleName</code>
     *  is <code>"bigMargins"</code>.</p>
     *
     *  <p>If the <code>selector</code> parameter does not start with a period,
     *  the specified selector is a "type selector" and applies to all instances
     *  of that type.
     *  For example, the type selector <code>"Button"</code>
     *  applies to all instances of Button and its subclasses.</p>
     *
     *  <p>The <code>global</code> selector is similar to a type selector
     *  and does not start with a period.</p>
     *
     *  @param selector The name of the CSS selector.
     *  @param styleDeclaration The new style declaration.
     *  @param update Set to <code>true</code> to force an immediate update of the styles; internally, Flex
     *  calls the <code>styleChanged()</code> method of UIComponent.
     *  Set to <code>false</code> to avoid an immediate update of the styles in the application.
     * 
     *  <p>The styles will be updated the next time one of the following methods is called with
     *  the <code>update</code> property set to <code>true</code>:
     *  <ul>
     *   <li><code>clearStyleDeclaration()</code></li>
     *   <li><code>loadStyleDeclarations()</code></li>
     *   <li><code>setStyleDeclaration()</code></li>
     *   <li><code>unloadStyleDeclarations()</code></li>
     *  </ul>
     *  </p>
     * 
     *  <p>Typically, if you call the one of these methods multiple times, 
     *  you set this property to <code>true</code> only on the last call,
     *  so that Flex does not call the <code>styleChanged()</code> method multiple times.</p>
     * 
     *  <p>If you call the <code>getStyle()</code> method, Flex returns the style value 
     *  that was last applied to the UIComponent through a call to the <code>styleChanged()</code> method. 
     *  The component's appearance might not reflect the value returned by the <code>getStyle()</code> method. This occurs
     *  because one of these style declaration methods might not yet have been called with the 
     *  <code>update</code> property set to <code>true</code>.</p>
     *  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function setStyleDeclaration(
                                selector:String,
                                styleDeclaration:CSSStyleDeclaration,
                                update:Boolean):void
    {
        impl.setStyleDeclaration(selector, styleDeclaration, update);
    }

    /**
     *  Clears the CSSStyleDeclaration object that stores the rules
     *  for the specified CSS selector.
     *
     *  <p>If the specified selector is a class selector (for example, ".bigMargins" or ".myStyle"),
     *  you must be sure to start the
     *  <code>selector</code> property with a period (.).</p>
     *
     *  <p>If the specified selector is a type selector (for example, "Button"), do not start the
     *  <code>selector</code> property with a period.</p>
     *
     *  <p>The <code>global</code> selector is similar to a type selector
     *  and does not start with a period.</p>
     *
     *  @param selector The name of the CSS selector to clear.
     *  @param update Set to <code>true</code> to force an immediate update of the styles.
     *  Set to <code>false</code> to avoid an immediate update of the styles in the application.
     *  For more information about this method, see the description in the <code>setStyleDeclaration()</code>
     *  method.
     *  
     *  @see #setStyleDeclaration()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function clearStyleDeclaration(selector:String,
                                                 update:Boolean):void
    {
        impl.clearStyleDeclaration(selector, update);
    }

    /**
     *  @private
     *  After an entire selector is added, replaced, or removed,
     *  this method updates all the DisplayList trees.
     */
    mx_internal static function styleDeclarationsChanged():void
    {
        impl.styleDeclarationsChanged();
    }

    /**
     *  Adds to the list of styles that can inherit values
     *  from their parents.
     *
     *  <p><b>Note:</b> Ensure that you avoid using duplicate style names, as name
     *  collisions can result in decreased performance if a style that is
     *  already used becomes inheriting.</p>
     *
     *  @param styleName The name of the style that is added to the list of styles that can inherit values.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function registerInheritingStyle(styleName:String):void
    {
        impl.registerInheritingStyle(styleName);
    }

    /**
     *  Tests to see if a style is inheriting.
     *
     *  @param styleName The name of the style that you test to see if it is inheriting.
     *
     *  @return Returns <code>true</code> if the specified style is inheriting.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isInheritingStyle(styleName:String):Boolean
    {
        return impl.isInheritingStyle(styleName);
    }

    /**
     *  Test to see if a TextFormat style is inheriting.
     *
     *  @param styleName The name of the style that you test to see if it is inheriting.
     *
     *  @return Returns <code>true</code> if the specified TextFormat style
     *  is inheriting.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isInheritingTextFormatStyle(styleName:String):Boolean
    {
        return impl.isInheritingTextFormatStyle(styleName);
    }

    /**
     *  Adds to the list of styles which may affect the measured size
     *  of the component.
     *  When one of these styles is set with <code>setStyle()</code>,
     *  the <code>invalidateSize()</code> method is automatically called on the component
     *  to make its measured size get recalculated later.
     *
     *  @param styleName The name of the style that you add to the list.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function registerSizeInvalidatingStyle(styleName:String):void
    {
        impl.registerSizeInvalidatingStyle(styleName);
    }

    /**
     *  Tests to see if a style changes the size of a component.
     *
     *  <p>When one of these styles is set with the <code>setStyle()</code> method,
     *  the <code>invalidateSize()</code> method is automatically called on the component
     *  to make its measured size get recalculated later.</p>
     *
     *  @param styleName The name of the style to test.
     *
     *  @return Returns <code>true</code> if the specified style is one
     *  which may affect the measured size of the component.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isSizeInvalidatingStyle(styleName:String):Boolean
    {
        return impl.isSizeInvalidatingStyle(styleName);
    }

    /**
     *  Adds to the list of styles which may affect the measured size
     *  of the component's parent container.
     *  <p>When one of these styles is set with <code>setStyle()</code>,
     *  the <code>invalidateSize()</code> method is automatically called on the component's
     *  parent container to make its measured size get recalculated
     *  later.</p>
     *
     *  @param styleName The name of the style to register.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function registerParentSizeInvalidatingStyle(styleName:String):void
    {
        impl.registerParentSizeInvalidatingStyle(styleName);
    }

    /**
     *  Tests to see if the style changes the size of the component's parent container.
     *
     *  <p>When one of these styles is set with <code>setStyle()</code>,
     *  the <code>invalidateSize()</code> method is automatically called on the component's
     *  parent container to make its measured size get recalculated
     *  later.</p>
     *
     *  @param styleName The name of the style to test.
     *
     *  @return Returns <code>true</code> if the specified style is one
     *  which may affect the measured size of the component's
     *  parent container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isParentSizeInvalidatingStyle(styleName:String):Boolean
    {
        return impl.isParentSizeInvalidatingStyle(styleName);
    }

    /**
     *  Adds to the list of styles which may affect the appearance
     *  or layout of the component's parent container.
     *  When one of these styles is set with <code>setStyle()</code>,
     *  the <code>invalidateDisplayList()</code> method is auomatically called on the component's
     *  parent container to make it redraw and/or relayout its children.
     *
     *  @param styleName The name of the style to register.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function registerParentDisplayListInvalidatingStyle(
                                styleName:String):void
    {
        impl.registerParentDisplayListInvalidatingStyle(styleName);
    }

    /**
     *  Tests to see if this style affects the component's parent container in
     *  such a way as to require that the parent container redraws itself when this style changes.
     *
     *  <p>When one of these styles is set with <code>setStyle()</code>,
     *  the <code>invalidateDisplayList()</code> method is auomatically called on the component's
     *  parent container to make it redraw and/or relayout its children.</p>
     *
     *  @param styleName The name of the style to test.
     *
     *  @return Returns <code>true</code> if the specified style is one
     *  which may affect the appearance or layout of the component's
     *  parent container.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isParentDisplayListInvalidatingStyle(
                                styleName:String):Boolean
    {
        return impl.isParentDisplayListInvalidatingStyle(styleName);
    }

    /**
     *  Adds a color name to the list of aliases for colors.
     *
     *  @param colorName The name of the color to add to the list; for example, "blue".
     *  If you later access this color name, the value is not case-sensitive.
     *
     *  @param colorValue Color value, for example, 0x0000FF.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function registerColorName(colorName:String, colorValue:uint):void
    {
        impl.registerColorName(colorName, colorValue);
    }

    /**
     *  Tests to see if the given String is an alias for a color value. For example,
     *  by default, the String "blue" is an alias for 0x0000FF.
     *
     *  @param colorName The color name to test. This parameter is not case-sensitive.
     *
     *  @return Returns <code>true</code> if <code>colorName</code> is an alias
     *  for a color.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isColorName(colorName:String):Boolean
    {
        return impl.isColorName(colorName);
    }

    /**
     *  Returns the numeric RGB color value that corresponds to the
     *  specified color string.
     *  The color string can be either a case-insensitive color name
     *  such as <code>"red"</code>, <code>"Blue"</code>, or
     *  <code>"haloGreen"</code>, a hexadecimal value such as 0xFF0000, or a #-hexadecimal String
     *  such as <code>"#FF0000"</code>.
     *
     *  <p>This method returns a uint, such as 4521830, that represents a color. You can convert
     *  this uint to a hexadecimal value by passing the numeric base (in this case, 16), to
     *  the uint class's <code>toString()</code> method, as the following example shows:</p>
     *  <pre>
     *  import mx.styles.StyleManager;
     *  private function getNewColorName():void {
     *      StyleManager.registerColorName("soylentGreen",0x44FF66);
     *      trace(StyleManager.getColorName("soylentGreen").toString(16));
     *  }
     *  </pre>
     *
     *  @param colorName The color name.
     *
     *  @return Returns a uint that represents the color value or <code>NOT_A_COLOR</code>
     *  if the value of the <code>colorName</code> property is not an alias for a color.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getColorName(colorName:Object):uint
    {
        return impl.getColorName(colorName);
    }

    /**
     *  Converts each element of the colors Array from a color name
     *  to a numeric RGB color value.
     *  Each color String can be either a case-insensitive color name
     *  such as <code>"red"</code>, <code>"Blue"</code>, or
     *  <code>"haloGreen"</code>, a hexadecimal value such as 0xFF0000, or a #-hexadecimal String
     *  such as <code>"#FF0000"</code>..
     *
     *  @param colors An Array of color names.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function getColorNames(colors:Array /* of Number or String */):void
    {
        impl.getColorNames(colors);
    }

    /**
     *  Determines if a specified parameter is a valid style property. For example:
     *
     *  <pre>
     *  trace(StyleManager.isValidStyleValue(myButton.getStyle("color")).toString());
     *  </pre>
     *
     *  <p>This can be useful because some styles can be set to values
     *  such as 0, <code>NaN</code>,
     *  the empty String (<code>""</code>), or <code>null</code>, which can
     *  cause an <code>if (value)</code> test to fail.</p>
     *
     *  @param value The style property to test.
     *
     *  @return If you pass the value returned by a <code>getStyle()</code> method call
     *  to this method, it returns <code>true</code> if the style
     *  was set and <code>false</code> if it was not set.
     *
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function isValidStyleValue(value:*):Boolean
    {
        return impl.isValidStyleValue(value);
    }

    /**
     *  Loads a style SWF.
     *
     *  @param url Location of the style SWF.
     *
     *  @param update Set to <code>true</code> to force
     *  an immediate update of the styles.
     *  Set to <code>false</code> to avoid an immediate update
     *  of the styles in the application.
     *  This parameter is optional and defaults to <code>true</code>
     *  For more information about this parameter, see the description
     *  in the <code>setStyleDeclaration()</code> method.
     *
     *  @param trustContent Obsolete, no longer used.
     *  This parameter is optional and defaults to <code>false</code>.
     *
     *  @param applicationDomain The ApplicationDomain passed to the
     *  <code>load()</code> method of the IModuleInfo that loads the style SWF.
     *  This parameter is optional and defaults to <code>null</code>.
     *
     *  @param securityDomain The SecurityDomain passed to the
     *  <code>load()</code> method of the IModuleInfo that loads the style SWF.
     *  This parameter is optional and defaults to <code>null</code>.
     * 
     *  @return An IEventDispatcher implementation that supports
     *          StyleEvent.PROGRESS, StyleEvent.COMPLETE, and
     *          StyleEvent.ERROR.
     *
     *  @see #setStyleDeclaration()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function loadStyleDeclarations(
                         url:String, update:Boolean = true,
                         trustContent:Boolean = false,
                         applicationDomain:ApplicationDomain = null,
                         securityDomain:SecurityDomain = null):IEventDispatcher
    {
        return impl.loadStyleDeclarations2(url, update,
                                           applicationDomain, securityDomain);
    }

    /**
     *  Unloads a style SWF.
     *
     *  @param url Location of the style SWF.
     *  @param update Set to <code>true</code> to force an immediate update of the styles.
     *  Set to <code>false</code> to avoid an immediate update of the styles in the application.
     *  For more information about this method, see the description in the <code>setStyleDeclaration()</code>
     *  method.
     *  
     *  @see #setStyleDeclaration()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public static function unloadStyleDeclarations(
                                url:String, update:Boolean = true):void
    {
        impl.unloadStyleDeclarations(url, update);
    }
}

}