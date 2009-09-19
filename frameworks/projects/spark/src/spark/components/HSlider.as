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

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IDataRenderer;

import spark.components.supportClasses.Slider;

//--------------------------------------
//  Other metadata
//--------------------------------------

[IconFile("HSlider.png")]
[DefaultTriggerEvent("change")]

/**
 *  The HSlider (horizontal slider) control lets users select a value
 *  by moving a slider thumb between the end points of the slider track.
 *  The HSlider control has a horizontal direction. The slider track stretches
 *  from left to right.
 *  The current value of the slider is determined by the relative location
 *  of the thumb between the end points of the slider, corresponding to the
 *  slider's minimum and maximum values.
 *
 *  <p>The slider can allow a continuous range of values between its minimum
 *  and maximum values or it can be restricted to values at specific intervals
 *  between the minimum and maximum value. The slider can contain a data tip
 *  to show its current value.</p>
 *
 *  <p>The HSlider control has the following default characteristics:</p>
 *     <table class="innertable">
 *        <tr>
 *           <th>Characteristic</th>
 *           <th>Description</th>
 *        </tr>
 *        <tr>
 *           <td>Default size</td>
 *           <td>100 pixels wide by 11 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Minimum size</td>
 *           <td>100 pixels wide and 100 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Maximum size</td>
 *           <td>10000 pixels wide and 10000 pixels high</td>
 *        </tr>
 *        <tr>
 *           <td>Default skin classes</td>
 *           <td>spark.skins.spark.HSliderSkin
 *              <p>spark.skins.spark.HSliderThumbSkin</p>
 *              <p>spark.skins.spark.HSliderTrackSkin</p></td>
 *        </tr>
 *     </table>
 *
 *  @mxml
 *
 *  <p>The <code>&lt;s:HSlider&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds no tag attributes:</p>
 *  <pre>
 *  &lt;s:HSlider/&gt;
 *  </pre>
 *
 *  @see spark.skins.spark.HSliderSkin
 *  @see spark.skins.spark.HSliderThumbSkin
 *  @see spark.skins.spark.HSliderTrackSkin
 *  @includeExample examples/HSliderExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class HSlider extends Slider
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function HSlider()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    // Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function pointToValue(x:Number, y:Number):Number
    {
        if (!thumb || !track)
            return 0;

        var range:Number = maximum - minimum;
        var thumbRange:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
        return minimum + ((thumbRange != 0) ? (x / thumbRange) * range : 0); 
    }

    /**
     *  @private
     */
    override protected function updateSkinDisplayList():void
    {
        if (!thumb || !track)
            return;
    
        var thumbRange:Number = track.getLayoutBoundsWidth() - thumb.getLayoutBoundsWidth();
        var range:Number = maximum - minimum;
        var thumbPos:Number = (range > 0) ? ((pendingValue - minimum) / range) * thumbRange : 0;
        thumb.setLayoutBoundsPosition(Math.round(track.getLayoutBoundsX() + thumbPos), thumb.getLayoutBoundsY());
    }

    
    /**
     *  @private
     *  FIXME (jszeto): Update this to also use the ILayoutElement API SDK-22045
     */
    override protected function updateDataTip(dataTipInstance:IDataRenderer, initialPosition:Point):void
    {
        var tipAsDisplayObject:DisplayObject = dataTipInstance as DisplayObject;
        
        if (tipAsDisplayObject && thumb)
        {
            var relX:Number = thumb.getLayoutBoundsX() - 
                                (tipAsDisplayObject.width - thumb.getLayoutBoundsWidth()) / 2;
            var o:Point = new Point(relX, initialPosition.y);
            var r:Point = localToGlobal(o);     
            
            // Get the screen bounds
            var screenBounds:Rectangle = systemManager.getVisibleApplicationRect();
            // Get the tips bounds. We only care about the dimensions.
            var tipBounds:Rectangle = tipAsDisplayObject.getBounds(tipAsDisplayObject.parent);
            
            // Make sure the tip doesn't exceed the bounds of the screen
            r.x = Math.floor( Math.max(screenBounds.left, 
                                Math.min(screenBounds.right - tipBounds.width, r.x)));
            r.y = Math.floor( Math.max(screenBounds.top, 
                                Math.min(screenBounds.bottom - tipBounds.height, r.y)));
            
            r = tipAsDisplayObject.parent.globalToLocal(r);
            
            tipAsDisplayObject.x = r.x;
            tipAsDisplayObject.y = r.y;
        }
    }
}

}