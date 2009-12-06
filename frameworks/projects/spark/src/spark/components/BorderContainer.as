////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components
{
import mx.graphics.IFill;
import mx.graphics.IStroke;

import spark.components.SkinnableContainer;

/**
 *  Background image of a container.  
 *  If you have both a <code>backgroundColor</code> and a
 *  <code>backgroundImage</code> set at the same time,  <code>backgroundColor</code>
 *  is ignored.  
 *  The default value is <code>undefined</code>, meaning "not set".
 *  If this style and the <code>backgroundColor</code> style are undefined,
 *  the component has a transparent background.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundImage", type="Object", format="File", inherit="no")]

/**
 *  Determines how the background image fills in the dimensions. 
 *  If you set the value of this property in MXML, use the string (such as "repeat"). 
 *  If you set the value of this property in ActionScript, 
 *  use the constant (such as <code>BitmapFillMode.CLIP</code>).
 * 
 *  <p>When set to <code>BitmapFillMode.CLIP</code> ("clip"), the image
 *  ends at the edge of the region.</p>
 * 
 *  <p>When set to <code>BitmapFillMode.REPEAT</code> ("repeat"), the image 
 *  repeats to fill the region.</p>
 *
 *  <p>When set to <code>BitmapFillMode.SCALE</code> ("scale"), the image
 *  stretches to fill the region.</p>
 * 
 *  @default <code>BitmapFillMode.SCALE</code>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="backgroundImageFillMode", type="String", enumeration="scale,clip,repeat", inherit="no")]

/**
 *  Alpha level of the color defined by the <code>borderColor</code> style.
 *  
 *  Valid values range from 0.0 to 1.0. 
 *  
 *  @default 1.0
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderAlpha", type="Number", inherit="no")]

/**
 *  Color of the border.
 *  
 *  @default 0xB7BABC
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderColor", type="uint", format="Color", inherit="no")]

/**
 *  Bounding box style.
 *  The possible values are <code>"solid"</code> and <code>"inset"</code>.
 * 
 *  @default solid
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderStyle", type="String", enumeration="inset,solid", inherit="no")]

/**
 *  Determines if the border is visible or not. 
 *  If <code>false</code>, then no border is visible
 *  except a border set by using the <code>borderStroke</code> property. 
 *   
 *  @default true
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderVisible", type="Boolean", inherit="no")]

/**
 *  The stroke weight for the border. 
 *
 *  @default 1
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="borderWeight", type="Number", format="Length", inherit="no")]

/**
 *  Radius of the curved corners of the border.
 *
 *  @default 0
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="cornerRadius", type="Number", format="Length", inherit="no")]

/**
 *  If <code>true</code>, the container has a visible
 *  drop shadow.
 *  
 *  @default false
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Style(name="dropShadowVisible", type="Boolean", inherit="no")]

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("BorderContainer.png")]

/**
 *  The BorderContainer class defines a set of CSS styles that control
 *  the appearance of the border and background fill of the container. 
 *
 *  <p><b>Note: </b>Because you use CSS styles and class properties to control 
 *  the appearance of the BorderContainer, you typically do not create a custom skin for it.
 *  If you do create a custom skin, your skin class should apply any styles to control the 
 *  appearance of the container.</p>
 *
 *  <p>By default, the stroke of the border is rounded. 
 *  If you do not want rounded corners, set the <code>joints</code> property of 
 *  the stroke to <code>JointStyle.MITER</code>. </p>
 *  
 *  <p>The BorderContainer container has the following default characteristics:</p>
 *  <table class="innertable">
 *     <tr><th>Characteristic</th><th>Description</th></tr>
 *     <tr><td>Default size</td><td>112 pixels wide by 112 pixels high</td></tr>
 *     <tr><td>Minimum size</td><td>112 pixels wide by 112 pixels high</td></tr>
 *     <tr><td>Maximum size</td><td>10000 pixels wide and 10000 pixels high</td></tr>
 *     <tr><td>Default skin class</td><td>spark.skins.spark.BorderContainerSkin</td></tr>
 *  </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;mx:BorderContainer&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:BorderContainer
 *    <b>Properties</b>
 *    backgroundFill="null"
 *    borderStroke="null"
 * 
 *    <b>Styles</b>
 *    backgroundImage="undefined"
 *    backgroundImageFillMode="scale"
 *    borderAlpha="1.0"
 *    borderColor="0xB7BABC"
 *    borderStyle="solid"
 *    borderVisible="true"
 *    borderWeight="1"
 *    cornerRadius="0"
 *    dropShadowVisible="false"
 *  /&gt;
 *  </pre>
 * 
 *  @see spark.skins.spark.BorderContainerSkin
 *  @includeExample examples/BorderContainerExample.mxml
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */ 
public class BorderContainer extends SkinnableContainer
{
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function BorderContainer()
    {
        super(); 
    }
     
    private var _backgroundFill:IFill;
    
    /**
     *  Defines the background of the BorderContainer. 
     *  Setting this property override the <code>backgroundAlpha</code>, 
     *  <code>backgroundColor</code>, <code>backgroundImage</code>, 
     *  and <code>backgroundImageFillMode</code> styles.
     * 
     *  <p>The following example uses the <code>backgroundFill</code> property
     *  to set the background color to red:</p>
     *
     *  <pre>
     *  &lt;s:BorderContainer cornerRadius="10"&gt; 
     *     &lt;s:backgroundFill&gt; 
     *         &lt;s:SolidColor 
     *             color="red" 
     *             alpha="1"/&gt; 
     *     &lt;/s:backgroundFill&gt; 
     *  &lt;/s:BorderContainer&gt; </pre>
     *
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get backgroundFill():IFill
    {
        return _backgroundFill;
    }
    
    /**
     *  @private
     */ 
    public function set backgroundFill(value:IFill):void
    {
        if (value == _backgroundFill)
           return;
        
        _backgroundFill = value;
        
        if (skin)
            skin.invalidateDisplayList();
    }
    
    private var _borderStroke:IStroke;
    
    /**
     *  Defines the stroke of the BorderContainer container. 
     *  Setting this property override the <code>borderAlpha</code>, 
     *  <code>borderColor</code>, <code>borderStyle</code>, <code>borderVisible</code>, 
     *  and <code>borderWeight</code> styles.  
     * 
     *  <p>The following example sets the <code>borderStroke</code> property:</p>
     *
     *  <pre>
     *  &lt;s:BorderContainer cornerRadius="10"&gt; 
     *     &lt;s:borderStroke&gt; 
     *         &lt;mx:SolidColorStroke 
     *             color="black" 
     *             weight="3"/&gt; 
     *     &lt;/s:borderStroke&gt; 
     *  &lt;/s:BorderContainer&gt; </pre>
     *
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get borderStroke():IStroke
    {
        return _borderStroke;
    }
    
    /**
     *  @private
     */ 
    public function set borderStroke(value:IStroke):void
    {
        if (value == _borderStroke)
           return;
        
        _borderStroke = value;
        
        if (skin)
            skin.invalidateDisplayList();
    }
}
}