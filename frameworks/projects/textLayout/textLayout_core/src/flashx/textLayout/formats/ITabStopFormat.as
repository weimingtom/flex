//========================================================================================
//  $File: //a3t/argon/dev/textLayout_core/src/flashx/textLayout/formats/ITabStopFormat.as $
//  $DateTime: 2009/07/14 04:51:58 $
//  $Revision: #7 $
//  $Change: 709357 $
//  
//  ADOBE CONFIDENTIAL
//  
//  Copyright 2007-08 Adobe Systems Incorporated. All rights reserved.
//  
//  NOTICE:  All information contained herein is, and remains
//  the property of Adobe Systems Incorporated and its suppliers,
//  if any.  The intellectual and technical concepts contained
//  herein are proprietary to Adobe Systems Incorporated and its
//  suppliers and may be covered by U.S. and Foreign Patents,
//  patents in process, and are protected by trade secret or copyright law.
//  Dissemination of this information or reproduction of this material
//  is strictly forbidden unless prior written permission is obtained
//  from Adobe Systems Incorporated.
//  
//  WARNING: THIS FILE IS GENERATED BY A SCRIPT.  DO NOT EDIT
//  
//========================================================================================
package flashx.textLayout.formats
{
	/** This interface provides read access to tab stop-related properties. */
	public interface ITabStopFormat
	{
		/**
		 * The position of the tab stop, in pixels, relative to the start of the line.
		 * <p>Legal values are from 0 to 10000 and flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is 0.</p>
		 * <p>Values may be undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have its default value.</p>
		 * @see FormatValue#INHERIT
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		function get position():*;

		/**
		 * The tab alignment for this tab stop. 
		 * <p>Legal values are flash.text.engine.TabAlignment.START, flash.text.engine.TabAlignment.CENTER, flash.text.engine.TabAlignment.END, flash.text.engine.TabAlignment.DECIMAL, flashx.textLayout.formats.FormatValue.INHERIT.</p>
		 * <p>Default value is START.</p>
		 * <p>Values may be undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have its default value.</p>
		 * @see FormatValue#INHERIT
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 * @see flash.text.engine.TabAlignment
		 */
		function get alignment():*;

		/**
		 * The alignment token to be used if the alignment is DECIMAL.
		 * <p>Default value is null.</p>
		 * <p>Values may be undefined indicating not set.</p>
		 * <p>If undefined during the cascade this property will have its default value.</p>
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		function get decimalAlignmentToken():*;
	}
}