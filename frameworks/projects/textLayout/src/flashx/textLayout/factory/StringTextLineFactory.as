//========================================================================================
//  $File: //a3t/argon/dev/textLayout_core/src/flashx/textLayout/factory/StringTextLineFactory.as $
//  $DateTime: 2009/10/30 16:50:45 $
//  $Revision: #10 $
//  $Change: 725673 $
//  
//  ADOBE CONFIDENTIAL
//  
//  Copyright 2008 Adobe Systems Incorporated. All rights reserved.
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
//========================================================================================
package flashx.textLayout.factory
{
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.debug.assert;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.IConfiguration;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.formats.BlockProgression;
	import flashx.textLayout.formats.ITextLayoutFormat;
	import flashx.textLayout.formats.LineBreak;
	import flashx.textLayout.tlf_internal;

	use namespace tlf_internal;

/**
 * The StringTextLineFactory class provides a simple way to create TextLines from a string. 
 * 
 * <p>The text lines are static and are created using a single format and a single paragraph. 
 * The lines are created to fit in the specified bounding rectangle.</p>
 * 
 * <p>The StringTextLineFactory provides an efficient way to create TextLines, since it reuses single TextFlow,
 * ParagraphElement, SpanElement, and ContainerController objects across many repeated invocations. You can create a
 * single factory, and use it again and again. You can also reuse all the parts that are the same each time
 * you call it; for instance, you can reuse the various formats and the bounds.</p> 
 *
 * <p><b>Note:</b> To create static lines that use multiple formats or paragraphs, or that include
 * inline graphics, use a TextFlowTextLineFactory and a TextFlow object. </p>
 * 
 * @includeExample examples\StringTextLineFactory_example.as -noswf
 * 
 * @playerversion Flash 10
 * @playerversion AIR 1.5
 * @langversion 3.0
 *
 * @see flashx.textLayout.factory.TextFlowTextLineFactory TextFlowTextLineFactory
*/
	public final class StringTextLineFactory extends TextLineFactoryBase
	{
		private var _tf:TextFlow;
		private var _para:ParagraphElement;
		private var _span:SpanElement;
		private var _formatsChanged:Boolean;

		static private var _defaultConfiguration:Configuration = null;
		
		private var _configuration:IConfiguration;
		
		/** 
		 * The configuration used by the internal TextFlow object.
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get configuration():IConfiguration
		{
			return _configuration; 
		}
		
		/** 
		 * The default configuration used by this factory if none is specified. 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		static public function get defaultConfiguration():IConfiguration
		{
			if (!_defaultConfiguration)
			{
				_defaultConfiguration = TextFlow.defaultConfiguration.clone();
				_defaultConfiguration.flowComposerClass = getDefaultFlowComposerClass();
				_defaultConfiguration.textFlowInitialFormat = null;
			}
			return _defaultConfiguration;
		}
		
		/** 
		 * Creates a StringTextLineFactory object.  
		 * 
		 * @param configuration The configuration object used to set the properties of the 
		 * internal TextFlow object used to compose lines produced by this factory. 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function StringTextLineFactory(configuration:IConfiguration = null):void
		{
			super();
			initialize(configuration);
		}
		
		private function initialize(config:IConfiguration):void
		{	
			_configuration = Configuration(config ? config : defaultConfiguration).getImmutableClone();
			_tf = new TextFlow(_configuration);
			_para = new ParagraphElement();
			_span = new SpanElement();
			_para.replaceChildren(0, 0, _span);
			_tf.replaceChildren(0, 0, _para);
			
			_tf.flowComposer.addController(containerController);
			_formatsChanged = true;
		}
		
		/** 
		 * The character format. 
		 * 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get spanFormat():ITextLayoutFormat
		{
			return _span.format;
		}
		public function set spanFormat(format:ITextLayoutFormat):void
		{
			_span.format = format;
			_formatsChanged = true;
		}
		/** 
		 * The paragraph format. 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get paragraphFormat():ITextLayoutFormat
		{
			return _para.format;
		}
		public function set paragraphFormat(format:ITextLayoutFormat):void
		{
			_para.format = format;
			_formatsChanged = true;
		}
		
		/** 
		 * The text flow format.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get textFlowFormat():ITextLayoutFormat
		{
			return _tf.format;
		}
		public function set textFlowFormat(format:ITextLayoutFormat):void
		{
			_tf.format = format;
			_formatsChanged = true;
		}
		
		/** 
		 * The text to convert into TextLine objects.
		 * 
		 * <p>To produce TextLines, call <code>createTextLines()</code> after setting this
		 * <code>text</code> property and the desired formats.</p> 
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function get text():String
		{ return _span.text; }
		public function set text(string:String):void
		{
			_span.text = string;
		}
		
		/** @private  Used for measuring the truncation indicator */
		static private var _measurementFactory:StringTextLineFactory = null;
		static private function measurementFactory():StringTextLineFactory
		{
			if (_measurementFactory == null)
				_measurementFactory = new StringTextLineFactory();
			return _measurementFactory;
		}
		static private var _measurementLines:Array = null;
		static private function measurementLines():Array
		{
			if (_measurementLines == null)
				_measurementLines = new Array();
			return _measurementLines;
		}
		
		/** 
		 * Creates TextLine objects using the text currently assigned to this factory object.
		 * 
		 * <p>The text lines are created using the currently assigned text and formats and
		 * are composed to fit the bounds assigned to the <code>compositionBounds</code> property.
		 * As each line is created, the factory calls the function specified in the 
		 * <code>callback</code> parameter. This function is passed the TextLine object and
		 * is responsible for displaying the line.</p>
		 * 
		 * <p>To create a different set of lines, change any properties desired and call
		 * <code>createTextLines()</code> again.</p>
		 *  
		 * @param callback	The callback function called for each TextLine object created.
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @langversion 3.0
		 */
		public function createTextLines(callback:Function):void
		{
			createTextLinesInternal(callback);
			_factoryComposer._lines.splice(0);
			if (_pass0Lines)
				_pass0Lines.splice(0);
		}
		
		/** Internal version preserves generated lines
		 */
		private function createTextLinesInternal(callback:Function):void
		{
			var measureWidth:Boolean  = !compositionBounds || isNaN(compositionBounds.width);
			var measureHeight:Boolean = !compositionBounds || isNaN(compositionBounds.height);

			CONFIG::debug { assert(_tf.flowComposer.numControllers == 1,"DisplayController bad number containers"); }
			CONFIG::debug { assert(containerController == _tf.flowComposer.getControllerAt(0),"ContainerController mixup"); }
			var bp:String = _tf.computedFormat.blockProgression;

			containerController.setCompositionSize(compositionBounds.width, compositionBounds.height);
			// override scroll policy if truncation options are set
			containerController.verticalScrollPolicy = truncationOptions ? ScrollPolicy.OFF : verticalScrollPolicy;
			containerController.horizontalScrollPolicy = truncationOptions ? ScrollPolicy.OFF : horizontalScrollPolicy;

			if (_formatsChanged)
			{
				_tf.normalize();
				_formatsChanged = false;
			}

			_isTruncated = false;
			_truncatedText = text;			

			_tf.flowComposer.swfContext = swfContext;

			_tf.flowComposer.compose();
			
			// Need truncation if all the following are true
			// - truncation options exist
			// - content doesn't fit		
			if (truncationOptions && !doesComposedTextFit(truncationOptions.lineCountLimit, _tf.textLength, bp))
			{
				_isTruncated = true;
				var somethingFit:Boolean = false; // were we able to fit something?
				var originalText:String = _span.text;
				
				computeLastAllowedLineIndex (truncationOptions.lineCountLimit);	
				if (_truncationLineIndex >= 0)
				{
					// Estimate the initial truncation position using the following steps 
					
					// 1. Measure the space that the truncation indicator will take
					measureTruncationIndicator (compositionBounds, truncationOptions.truncationIndicator);
					
					// 2. Move target line for truncation higher by as many lines as the number of full lines taken by the truncation indicator
					_truncationLineIndex -= (_measurementLines.length -1);
					if (_truncationLineIndex >= 0)
					{
						var truncateAtCharPosition:int;
						
						if (_tf.computedFormat.lineBreak == LineBreak.EXPLICIT || (bp == BlockProgression.TB ? measureWidth : measureHeight))
						{
							// 3., 4. Initial truncation position: end of the last allowed line 
							var line:TextLine = _factoryComposer._lines[_truncationLineIndex] as TextLine; 
							truncateAtCharPosition =  line.userData + line.rawTextLength;
						}
						else
						{
							// 3. Calculate allowed width (width left over from the last line of the truncation indicator)
							var targetWidth:Number = (bp == BlockProgression.TB ? compositionBounds.width : compositionBounds.height); 
							if (paragraphFormat)
							{
								targetWidth -= (Number(paragraphFormat.paragraphSpaceAfter) + Number(paragraphFormat.paragraphSpaceBefore));
								if (_truncationLineIndex == 0)
									targetWidth -= paragraphFormat.textIndent;
							}
							
							var allowedWidth:Number = targetWidth - (_measurementLines[_measurementLines.length-1] as TextLine).unjustifiedTextWidth;
													
							// 4. Get the initial truncation position on the target line given this allowed width 
							truncateAtCharPosition = getTruncationPosition(_factoryComposer._lines[_truncationLineIndex], allowedWidth);
						}
						
						// Save off the original lines: used in getNextTruncationPosition
						if (!_pass0Lines)
							_pass0Lines = new Array();
						_pass0Lines = _factoryComposer.swapLines(_pass0Lines);
						
						// Note that for the original lines to be valid when used, the containing text block should not be modified
						// Cloning the paragraph ensures this 
						_para = _para.deepCopy() as ParagraphElement; 
						_span = _para.getChildAt(0) as SpanElement;
						_tf.replaceChildren(0, 1, _para);
						_tf.normalize();
						
						// Replace all content starting at the inital truncation position with the truncation indicator
						_span.replaceText(truncateAtCharPosition, _span.textLength, truncationOptions.truncationIndicator);
						
						// The following loop executes repeatedly composing text until it fits
						// In each iteration, an atoms's worth of characters of original content is dropped
						do
						{
							_tf.flowComposer.compose();
							
							if (doesComposedTextFit(truncationOptions.lineCountLimit, _tf.textLength, bp))
							{
								somethingFit = true;
								break; 
							}		
							
							if (truncateAtCharPosition == 0)
								break; // no original content left to make room for truncation indicator
							
							// Try again by truncating at the beginning of the preceding atom
							var newTruncateAtCharPosition:int = getNextTruncationPosition(truncateAtCharPosition);
							_span.replaceText(newTruncateAtCharPosition, truncateAtCharPosition, null);
							truncateAtCharPosition = newTruncateAtCharPosition;
							
						} while (true);
					}
					_measurementLines.splice(0);	// cleanup
				}
				
				if (somethingFit)
					_truncatedText = _span.text;
				else
				{
					_truncatedText = "";
					_factoryComposer._lines.splice(0); // return no lines
				}
				
				 _span.text = originalText;
			}
			
			var xadjust:Number = compositionBounds.x;
			// toptobottom sets zero to the right edge - adjust the locations
			var controllerBounds:Rectangle = containerController.getContentBounds();
			if (bp == BlockProgression.RL)
				xadjust += (measureWidth ? controllerBounds.width : compositionBounds.width);
				
			// apply x and y adjustment to the bounds
			controllerBounds.left += xadjust;
			controllerBounds.right += xadjust;
			controllerBounds.top += compositionBounds.y;
			controllerBounds.bottom += compositionBounds.y;			

			callbackWithTextLines(callback,xadjust,compositionBounds.y);

			setContentBounds(controllerBounds);
		}
		
		
		/** @private 
		 * Gets the text that is composed in the preceding call to <code>createTextLines</code>
		 * If no truncation is performed, a string equal to <code>text</code> is returned. 
		 * If truncation is performed, but nothing fits, an empty string is returned.
		 * Otherwise, a substring of <code>text</code> followed by the truncation indicator is returned. 
		 */
		tlf_internal function get truncatedText():String
		{ return _truncatedText; }
		private var _truncatedText:String;
		
		/** 
		 * Measures the truncation indicator using the same bounds and formats, but without truncation options
		 * Resultant lines are added to _measurementLines
		 */
		private function measureTruncationIndicator (compositionBounds:Rectangle, truncationIndicator:String):void
		{
			var originalLines:Array = _factoryComposer.swapLines(measurementLines()); // ensure we don't overwrite original lines
			var measureFactory:StringTextLineFactory = measurementFactory();
			measureFactory.compositionBounds = compositionBounds;
			measureFactory.text = truncationIndicator;
			measureFactory.spanFormat = spanFormat;
			measureFactory.paragraphFormat = paragraphFormat;
			measureFactory.textFlowFormat = textFlowFormat;
			measureFactory.truncationOptions = null;
			measureFactory.createTextLinesInternal(noOpCallback);
			_factoryComposer.swapLines(originalLines); // restore
		}
		

		/** 
		 * Gets the truncation position on a line given the allowed width 
		 * - Must be at an atom boundary
		 * - Must scan the line for atoms in logical order, not physical position order
		 * For example, given bi-di text ABאבCD
		 * atoms must be scanned in this order 
		 * A, B, א
         * ג, C, D  
		 */
		private function getTruncationPosition (line:TextLine, allowedWidth:Number):uint
		{			
			var consumedWidth:Number = 0;
			var charPosition:int = line.userData; 						// start of line
			
			while (charPosition < line.userData + line.rawTextLength)	// end of line
			{
				var atomIndex:int = line.getAtomIndexAtCharIndex(charPosition);
				var atomBounds:Rectangle = line.getAtomBounds(atomIndex); 
				consumedWidth += atomBounds.width;
				if (consumedWidth > allowedWidth)
					break;
					
				charPosition = line.getAtomTextBlockEndIndex(atomIndex);
			}
			
			line.flushAtomData();
			return charPosition;
		}
		
		
		private function noOpCallback(line:TextLine):void
		{	
		}
		
	}
}