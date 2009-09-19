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
import flash.text.TextFormat;
import flash.text.engine.FontLookup;

import flashx.textLayout.compose.ITextLineCreator;
import flashx.textLayout.conversion.ConversionType;
import flashx.textLayout.conversion.ITextExporter;
import flashx.textLayout.conversion.ITextImporter;
import flashx.textLayout.conversion.TextConverter;
import flashx.textLayout.elements.TextFlow;
import flashx.textLayout.events.DamageEvent;
import flashx.textLayout.factory.StringTextLineFactory;
import flashx.textLayout.factory.TextFlowTextLineFactory;
import flashx.textLayout.factory.TextLineFactoryBase;
import flashx.textLayout.factory.TruncationOptions;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.IEmbeddedFontRegistry;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.IUIComponent;
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.managers.ISystemManager;

import spark.components.supportClasses.TextBase;
import spark.core.CSSTextLayoutFormat;

use namespace mx_internal;

//--------------------------------------
//  Styles
//--------------------------------------

include "../styles/metadata/BasicInheritingTextStyles.as"
include "../styles/metadata/BasicNonInheritingTextStyles.as"
include "../styles/metadata/AdvancedInheritingTextStyles.as"
include "../styles/metadata/AdvancedNonInheritingTextStyles.as"

//--------------------------------------
//  Other metadata
//--------------------------------------

[DefaultProperty("content")]

[IconFile("RichText.png")]

/**
 *  RichText is a low-level UIComponent that can display one or more lines
 *  of richly-formatted text and embedded images.
 *
 *  <p>For performance reasons, it does not support scrolling,
 *  selection, editing, clickable hyperlinks, or images loaded from URLs.
 *  If you need those capabilities, please see the RichEditableText
 *  class.</p>
 *
 *  <p>RichText, which is new with Flex 4, makes use of the new
 *  Text Layout Framework (TLF) library, which in turn builds on
 *  the new Flash Text Engine (FTE) in Flash Player 10.
 *  In combination, they provide rich text layout using
 *  high-quality international typography.</p>
 *
 *  <p>The Spark architecture provides three text "primitives" -- 
 *  Label, RichText, and RichEditableText --
 *  as part of its pay-only-for-what-you-need philosophy.
 *  Label is the fastest and most lightweight
 *  because it uses only FTE, not TLF,
 *  but it is limited in its capabilities: no rich text,
 *  no scrolling, no selection, and no editing.
 *  RichText adds the ability to display rich text
 *  with complex layout, but is still completely non-interactive.
 *  RichEditableText is the slowest and heaviest,
 *  but offers most of what TLF can do.
 *  You should use the fastest text primitive that meets your needs.</p>
 *
 *  <p>RichText is similar to the MX control mx.controls.Text.
 *  The MX control used the older TextField class, instead of TLF,
 *  to display text.</p>
 *
 *  <p>The most important differences to understand are
 *  <ul>
 *    <li>RichText offers better typography, better support
 *        for international languages, and better text layout than Text.</li>
 *    <li>RichText has an object-oriented model of what it displays,
 *        while Text does not.</li>
 *    <li>Text is selectable, while RichText does not support selection.</li>
 *  </ul></p>
 *
 *
 *  <p>RichText uses TLF's object-oriented model of rich text,
 *  in which text layout elements such as divisions, paragraphs, spans,
 *  and images are represented at runtime by ActionScript objects
 *  which can be programmatically accessed and manipulated.
 *  The central object in TLF for representing rich text is a
 *  TextFlow, and you specify what RichText should display
 *  by setting its <code>textFlow</code> property to a TextFlow instance.
 *  (Please see the description of the <code>textFlow</code>
 *  property for information about how to create one.)
 *  You can also set the <code>text</code> property that
 *  is inherited from TextBase, but if you don't need
 *  the richness of a TextFlow, you should consider using
 *  Label instead.</p>
 *
 *  <p>At compile time, you can simply put TLF markup tags inside
 *  the RichText tag, as in
 *  <pre>
 *  &lt;s:RichText&gt;Hello &lt;s:span fontWeight="bold"&gt;World!&lt;/s:span&gt;&lt;/s:RichText&gt;
 *  </pre>
 *  In this case, the MXML compiler sets the <code>content</code>
 *  property, causing a TextFlow to be automatically created
 *  from the FlowElements that you specify.</p>
 *
 *  <p>The default text formatting is determined by CSS styles
 *  such as <code>fontFamily</code>, <code>fontSize</code>.
 *  Any formatting information in the TextFlow overrides
 *  the default formatting provided by the CSS styles.</p>
 *
 *  <p>You can control the spacing between lines with the
 *  <code>lineHeight</code> style and the spacing between
 *  paragraphs with the <code>paragraphSpaceBefore</code>
 *  and <code>paragraphSpaceAfter</code> styles.
 *  You can align or justify the text using the <code>textAlign</code>
 *  and <code>textAlignLast</code> styles.
 *  You can inset the text from the component's edges using the
 *  <code>paddingLeft</code>, <code>paddingTop</code>, 
 *  <code>paddingRight</code>, and <code>paddingBottom</code> styles.</p>
 *
 *  <p>If you don't specify any kind of width for a RichText,
 *  then the longest line, as determined by these explicit line breaks,
 *  will determine the width of the Label.</p>
 *
 *  <p>When you specify some kind of width, the text wraps at the right
 *  edge of the component and the text is clipped when there is more
 *  text than fits.
 *  If you set the <code>lineBreak</code> style to <code>"explicit"</code>,
 *  new lines will start only at explicit lines breaks, such as
 *  if you use CR (<code>"\r"</code>), LF (<code>"\n"</code>),
 *  or CR+LF (<code>"\r\n"</code>) in <code>text</code>
 *  or if you use <code>&lt;p&gt;</code> and <code>&lt;br/&gt;</code>
 *  in TLF markup.
 *  In that case, lines that are wider than the control
 *  will be clipped.</p>
 *
 *  <p>If you have more text than you have room to display it,
 *  RichText can truncate the text for you.
 *  Truncating text means replacing excess text
 *  with a truncation indicator such as "...".
 *  See the inherited properties <code>maxDisplayedLines</code>
 *  and <code>isTruncated</code>.</p>
 *
 *  <p>By default,RichText has no background,
 *  but you can draw one using the <code>backgroundColor</code>
 *  and <code>backgroundAlpha</code> styles.
 *  Borders are not supported.
 *  If you need a border, or a more complicated background, use a separate
 *  graphic element, such as a Rect, behind the RichText.</p>
 *
 *  <p>Because RichText uses TLF,
 *  it supports displaying left-to-right (LTR) text such as French,
 *  right-to-left (RTL) text such as Arabic, and bidirectional text
 *  such as a French phrase inside of an Arabic one.
 *  If the predominant text direction is right-to-left,
 *  set the <code>direction</code> style to <code>"rtl"</code>.
 *  The <code>textAlign</code> style defaults to <code>"start"</code>,
 *  which makes the text left-aligned when <code>direction</code>
 *  is <code>"ltr"</code> and right-aligned when <code>direction</code>
 *  is <code>"rtl"</code>.
 *  To get the opposite alignment,
 *  set <code>textAlign</code> to <code>"end"</code>.</p>
 *
 *  <p>RichText uses TLF's StringTextFlowFactory and TextFlowTextLineFactory
 *  classes to create one or more TextLine objects to statically display
 *  its text.
 *  For performance, its TextLines do not contain information
 *  about individual glyphs; for more info, see
 *  flash.text.engine.TextLineValidity.STATIC.</p>
 *
 *  @see spark.components.RichEditableText
 *  @see spark.components.Label
 *  
 *  @includeExample examples/RichTextExample.mxml
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class RichText extends TextBase implements IFontContextComponent
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private static var classInitialized:Boolean = false;
    
	/**
	 *  @private
	 *  This TLF object composes TextLines from a text String.
	 *  We use it when the 'text' property is set to a String
	 *  that doesn't contain linebreaks.
	 */
	private static var staticStringFactory:StringTextLineFactory;
	
	/**
	 *  @private
	 *  This TLF object composes TextLines from a TextFlow.
	 *  We use it when the 'textFlow' or 'content' property is set,
	 *  and when the 'text' property is set to a String
	 *  that contains linebreaks (and therefore is interpreted
	 *  as multiple paragraphs).
	 */
	private static var staticTextFlowFactory:TextFlowTextLineFactory;
	
	/**
	 *  @private
	 *  This TLF object is used to import a 'text' String
	 *  containing linebreaks to create a multiparagraph TextFlow.
	 */
	private static var staticPlainTextImporter:ITextImporter;
	
	/**
	 *  @private
	 *  This TLF object is used to export a TextFlow as plain 'text',
	 *  by walking the leaf FlowElements in the TextFlow.
	 */
	private static var staticPlainTextExporter:ITextExporter;
	
    /**
     *  @private
     *  Used to call isFontFaceEmbedded() in getEmbeddedFontContext().
     */
    private static var staticTextFormat:TextFormat;
    
	//--------------------------------------------------------------------------
    //
    //  Class properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  embeddedFontRegistry
    //----------------------------------

    /**
     *  @private
     *  Storage for the _embeddedFontRegistry property.
     *  Note: This gets initialized on first access,
     *  not when this class is initialized, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _embeddedFontRegistry:IEmbeddedFontRegistry;

    /**
     *  @private
     *  A reference to the embedded font registry.
     *  Single registry in the system.
     *  Used to look up the moduleFactory of a font.
     */
    private static function get embeddedFontRegistry():IEmbeddedFontRegistry
    {
        if (!_embeddedFontRegistry)
        {
            _embeddedFontRegistry = IEmbeddedFontRegistry(
                Singleton.getInstance("mx.core::IEmbeddedFontRegistry"));
        }

        return _embeddedFontRegistry;
    }

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  This method initializes the static vars of this class.
	 *  Rather than calling it at static initialization time,
	 *  we call it in the constructor to do the class initialization
	 *  when the first instance is created.
	 *  (It does an immediate return if it has already run.)
	 *  By doing so, we avoid any static initialization issues
	 *  related to whether this class or the TLF classes
	 *  that it uses are initialized first.
	 */
	private static function initClass():void
	{
		if (classInitialized)
			return;
			
		staticStringFactory = new StringTextLineFactory();
		
		staticTextFlowFactory = new TextFlowTextLineFactory();
		
		staticTextFormat = new TextFormat();
		
		staticPlainTextImporter =
			TextConverter.getImporter(TextConverter.PLAIN_TEXT_FORMAT);
		
		staticPlainTextExporter =
			TextConverter.getExporter(TextConverter.PLAIN_TEXT_FORMAT);
			
		classInitialized = true;
	}
	
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
    public function RichText()
    {
        super();
        
        initClass();
        
        text = "";
    }
     
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  This object determines the default text formatting used
     *  by this component, based on its CSS styles.
     *  It is set to null by stylesInitialized() and styleChanged(),
     *  and recreated whenever necessary in commitProperties().
     */
    private var hostFormat:ITextLayoutFormat;

    /**
     *  @private
     *  Holds the last recorded value of the textFlow generation for _textFlow.  
     *  Used to determine whether to return immediately from damage event if 
     *  there have been no changes.
     */
    private var lastGeneration:uint = 0;    // 0 means not set
        
	/**
     *  @private
     *  Holds the last recorded value of the module factory
     *  used to create the font.
     */
    mx_internal var embeddedFontContext:IFlexModuleFactory;
    
	/**
	 *  @private
	 *  Specifies whether the StringTextLineFactory
	 *  or the TextFlowTextLineFactory is used to create the TextLines.
	 *  A StringTextLineFactory is more efficient; it is used
	 *  by default to render the default text ""
	 *  and when 'text' is set to a string without linebreaks;
	 *  otherwise, a TextFlowTextLineFactory is used.
	 */
	private var factory:TextLineFactoryBase;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  text
    //----------------------------------

    // Compiler will strip leading and trailing whitespace from text string.
    [CollapseWhiteSpace]
    
    // The _text storage var is mx_internal in TextBase.
    
	/**
	 *  @private
	 */
	private var textChanged:Boolean = false;
	
	/**
     *  @private
     */
    override public function get text():String
    {
        // Extracting the plaintext from a TextFlow is somewhat expensive,
        // as it involves iterating over the leaf FlowElements in the TextFlow.
        // Therefore we do this extraction only when necessary, namely when
        // you first set the 'content' or the 'textFlow'
        // (or mutate the TextFlow), and then get the 'text'.
        if (_text == null)
        {
        	// If 'content' was last set,
        	// we have to first turn that into a TextFlow.
        	if (_content != null)
            {
	        	_textFlow = createTextFlowFromContent(_content);
                lastGeneration = _textFlow.generation;
            }
	        		
            // Once we have a TextFlow, we can export its plain text.
            _text = staticPlainTextExporter.export(
            	_textFlow, ConversionType.STRING_TYPE) as String;
        }

        return _text;
    }

    /**
     *  @private
     *  This will create a TextFlow with a single paragraph with a single span 
     *  with exactly the text specified.  If there is whitespace and line 
     *  breaks in the text, they will remain, regardless of the settings of
     *  the lineBreak and whiteSpaceCollapse styles.
     */
    override public function set text(value:String):void
    {
    	// Treat setting the 'text' to null
    	// as if it were set to the empty String
    	// (which is the default state).
    	if (value == null)
    		value = "";
    	
    	// Don't return early if value is the same as _text,
    	// because _text might have been produced from setting
    	// 'textFlow' or 'content'.
    	// For example, if you set a TextFlow corresponding to
    	// "Hello <span color="OxFF0000">World</span>"
    	// and then get the 'text', it will be the String "Hello World"
    	// But if you then set the 'text' to "Hello World"
    	// this represents a change: the "World" should no longer be red.
    	
    	_text = value;
    	textChanged = true;
    	
    	// If more than one of 'text', 'textFlow', and 'content' is set,
    	// the last one set wins.
    	textFlowChanged = false;
    	contentChanged = false;
    	
		// The other two are now invalid and must be recalculated when needed.
		_textFlow = null;
    	_content = null;
    	
    	factory = staticStringFactory;
    	
		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}
    
    //--------------------------------------------------------------------------
    //
    //  Properties: IFontContextComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  fontContext
    //----------------------------------
    
    /**
     *  @private
     */
    private var _fontContext:IFlexModuleFactory;

    /**
     *  @inheritDoc
     */
    public function get fontContext():IFlexModuleFactory
    {
        return _fontContext;
    }

    /**
     *  @private
     */
    public function set fontContext(value:IFlexModuleFactory):void
    {
        _fontContext = value;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  content
    //----------------------------------

    /**
     *  @private
     *  Storage for the content property.
     */
    protected var _content:Object;
    
	/**
	 *  @private
	 */
	private var contentChanged:Boolean = false;
	
    /**
     *  @private
     *  This metadata tells the MXML compiler to disable some of its default
     *  interpretation of the value specified for the 'content' property.
     *  Normally, for properties of type Object, it assumes that things
     *  looking like numbers are numbers and things looking like arrays
     *  are arrays. But <content>1</content> should generate code to set the
     *  content to  the String "1", not the int 1, and <content>[1]</content>
     *  should set it to the String "[1]", not the Array [ 1 ].
     *  However, {...} continues to be interpreted as a databinding
     *  expression, and @Resource(...), @Embed(...), etc.
     *  as compiler directives.
     *  Similar metadata on TLF classes causes the same rules to apply
     *  within <p>, <span>, etc.
     */
    [RichTextContent]
    
	/**
	 *  This property is intended for use in MXML at compile time;
	 *  to get or set rich text content at runtime,
	 *  please use the <code>textFlow</code> property instead.
	 *
	 *  <p>The <code>content</code> property is the default property
	 *  for RichText, so that you can write MXML such as
	 *  <pre>
	 *  &lt;s:RichText&gt;Hello &lt;s:span fontWeight="bold"/&gt;World&lt;/s:span&gt;&lt;/s:RichText&gt;
	 *  </pre>
	 *  and have the String and SpanElement that you specify
	 *  as the content be used to create a TextFlow.</p>
	 *
	 *  <p>This property is typed as Object because you can set it to
	 *  to a String, a FlowElement, or an Array of Strings and FlowElements.
	 *  In the example above, you are specifying the content
	 *  to be a 2-element Array whose first element is the String
	 *  "Hello" and whose second element is a SpanElement with the text
	 *  "World" in boldface.</p>
	 * 
	 *  <p>No matter how you specify the content, it gets converted
	 *  into a TextFlow, and when you get this property, you will get
	 *  the resulting TextFlow.</p>
	 * 
	 *  <p>Adobe recommends using <code>textFlow</code> property
	 *  to get and set rich text content at runtime,
	 *  because it is strongly typed as a TextFlow
	 *  rather than as an Object.
	 *  A TextFlow is the canonical representation
	 *  for rich text content in the Text Layout Framework.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
    public function get content():Object
    {
    	return textFlow;
    }
    
    /**
     *  @private
     */   
    public function set content(value:Object):void
    {
    	// Treat setting the 'content' to null
    	// as if 'text' were being set to the empty String
    	// (which is the default state).
    	if (value == null)
    	{
    		text = "";
    		return;
    	}
    	
    	if (value == _content)
    		return;
    	
        _content = value;
        contentChanged = true;
        
		// If more than one of 'text', 'textFlow', and 'content' is set,
		// the last one set wins.
		textChanged = false;
        textFlowChanged = false;
        
		// The other two are now invalid and must be recalculated when needed.
		_text = null;
		_textFlow = null;
		        
		factory = staticTextFlowFactory;
		
		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
    }
    
	//----------------------------------
	//  textFlow
	//----------------------------------
	
	/**
	 *  @private
	 *  Storage for the textFlow property.
	 */
	private var _textFlow:TextFlow;
	
	/**
	 *  @private
	 */
	private var textFlowChanged:Boolean = false;
	
	/**
     *  The TextFlow representing the rich text displayed by this component.
     * 
     *  <p>A TextFlow is the most important class
     *  in the Text Layout Framework (TLF).
     *  It is the root of a tree of FlowElements
     *  representing rich text content.</p>
	 *
	 *  <p>You normally create a TextFlow from TLF markup
	 *  using the <code>TextFlowUtil.importFromString()</code>
	 *  or <code>TextFlowUtil.importFromXML()</code> methods.
	 *  Alternately, you can use TLF's TextConverter class
	 *  (which can import a subset of HTML) or build a TextFlow
	 *  using methods like <code>addChild()</code> on TextFlow.</p>
     * 
	 *  <p>Setting this property affects the <code>text</code> property
     *  and vice versa.</p>
     *
     *  <p>If you set the <code>textFlow</code> and get the <code>text</code>,
	 *  the text in each paragraph will be separated by a single
     *  LF ("\n").</p>
     *
     *  <p>If you set the <code>text</code> to a String such as
	 *  <code>"Hello World"</code> and get the <code>textFlow</code>,
	 *  it will be a TextFlow containing a single ParagraphElement
	 *  with a single SpanElement.</p>
     *
     *  <p>If the text contains explicit line breaks --
     *  CR ("\r"), LF ("\n"), or CR+LF ("\r\n") --
     *  then the content will be set to a TextFlow
     *  which contains multiple paragraphs, each with one span.</p>
     *
	 *  <p>To turn a TextFlow object into TLF markup,
	 *  use the <code>TextFlowUtil.export()</code> markup.</p>
	 *
	 *  @see spark.utils.TextFlowUtil#importFromString()
	 *  @see spark.utils.TextFlowUtil#importFromXML()
     *  @see spark.components.RichEditableText#text
	 */
	public function get textFlow():TextFlow
	{
		// We might not have a valid _textFlow for two reasons:
		// either because the 'text' was set (which is the state
		// after construction) or because the 'content' was set.
		if (!_textFlow)
		{
			if (_content != null)
				_textFlow = createTextFlowFromContent(_content);
			else
				_textFlow = staticPlainTextImporter.importToFlow(_text);
            
            lastGeneration = _textFlow ? _textFlow.generation : 0;
		}
		
		return _textFlow;
	}
	
	/**
	 *  @private
	 */
	public function set textFlow(value:TextFlow):void
	{
		// Treat setting the 'textFlow' to null
		// as if 'text' were being set to the empty String
		// (which is the default state).
		if (value == null)
		{
			text = "";
			return;
		}
		
		if (value == _textFlow)
			return;
			
		_textFlow = value;
		textFlowChanged = true;
		
		// If more than one of 'text', 'textFlow', and 'content' is set,
		// the last one set wins.
		textChanged = false;
		contentChanged = false;
		
		// The other two are now invalid and must be recalculated when needed.
		_text = null
		_content = null;
		
		factory = staticTextFlowFactory;

		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}
	
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------
    
	/**
	 *  @private
	 */
	override protected function commitProperties():void
    {
    	super.commitProperties();
    	
    	// Only one of textChanged, textFlowChanged, and contentChanged
    	// will be true; the other two will be false because each setter
    	// guarantees this.
    	if (textChanged)
    	{
			// If the text has linebreaks (CR, LF, or CF+LF)
			// create a multi-paragraph TextFlow from it
			// and use the TextFlowTextLineFactory to render it.
			// Otherwise the StringTextLineFactory will put
			// all of the lines into a single paragraph
			// and FTE performance will degrade on a large paragraph.
			if (_text.indexOf("\n") != -1 || _text.indexOf("\r") != -1)
			{
				_textFlow = staticPlainTextImporter.importToFlow(_text);
				factory = staticTextFlowFactory;
			}
			textChanged = false;
    	}
    	else if (textFlowChanged)
    	{
    		// Nothing to do at commitProperties() time.
    		textFlowChanged = false;
    	}
    	else if (contentChanged)
    	{
			_textFlow = createTextFlowFromContent(_content);
			contentChanged = false;
    	}
    
        lastGeneration = _textFlow ? _textFlow.generation : 0;
        
    	// At this point we know which TextLineFactory we're going to use
    	// and we know the _text or _textFlow that it will compose.

		var oldEmbeddedFontContext:IFlexModuleFactory = embeddedFontContext;
		
		// If the CSS styles for this component specify an embedded font,
		// embeddedFontContext will be set to the module factory that
		// should create TextLines (since they must be created in the
		// SWF where the embedded font is.)
		// Otherwise, this will be null.
		embeddedFontContext = getEmbeddedFontContext();
		
		if (embeddedFontContext != oldEmbeddedFontContext)
		{
			staticTextFlowFactory.textLineCreator =
				ITextLineCreator(embeddedFontContext)
			staticStringFactory.textLineCreator = 
				ITextLineCreator(embeddedFontContext)
		}
				
		// If the styles have changed, hostFormat will have
		// been set to null to indicate that it is invalid.
		// In that case, create a new one.
		if (!hostFormat)
		{
			hostFormat = new CSSTextLayoutFormat(this);
			// Note: CSSTextLayoutFormat has special processing
			// for the fontLookup style. If it is "auto",
			// the fontLookup format is set to either
			// "device" or "embedded" depending on whether
			// embeddedFontContext is null or non-null.
		}
		
		if (_textFlow)
		{
			// We might have a new TextFlow, or a new hostFormat,
			// so attach the latter to the former.
			_textFlow.hostFormat = hostFormat;
		
			if (_textFlow.flowComposer)
			{
				_textFlow.flowComposer.textLineCreator = 
					staticTextFlowFactory.textLineCreator;
			}
		}
	}
    
    /**
     *  @private
     */
    override public function stylesInitialized():void
    {
        super.stylesInitialized();

		// The old hostFormat is invalid
		// and a new one must be created.
		hostFormat = null;
    }

    /**
     *  @private
     */
    override public function styleChanged(styleProp:String):void
    {
        super.styleChanged(styleProp);

        // The old hostFormat is invalid
        // and a new one must be created.
        hostFormat = null;
        
		invalidateTextLines();
		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: TextBase
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 *  Returns true to indicate all lines were composed.
	 */
	override mx_internal function composeTextLines(width:Number = NaN,
												   height:Number = NaN):Boolean
	{
		super.composeTextLines(width, height);
		
		// Don't want this handler firing when we're re-composing the text lines.
		if (factory is TextFlowTextLineFactory && _textFlow != null)
		{
			_textFlow.removeEventListener(DamageEvent.DAMAGE,
										  textFlow_damageHandler);
		}
		
		
		// Set the composition bounds to be used by createTextLines().
		// If the width or height is NaN, it will be computed by this method
		// by the time it returns.
		// The bounds are then used by the addTextLines() method
		// to determine the isOverset flag.
		// The composition bounds are also reported by the measure() method.
		bounds.x = 0;
		bounds.y = 0;
		bounds.width = isNaN(width) ? maxWidth : width;
		bounds.height = height;
		
		removeTextLines();
		releaseTextLines();
		
		createTextLines();
		
        // TODO (rfrishbe): can we optimize the "this" away since we know what the displayObject is now
		addTextLines(this);
		
		// Figure out if the text overruns the available space for composition.
		isOverset = isTextOverset(width, height);
		
		// Just recomposed so reset.
		invalidateCompose = false;
		
		// Listen for "damage" events in case the textFlow is 
		// modified programatically.
		if (factory is TextFlowTextLineFactory && _textFlow != null)
		{
			_textFlow.addEventListener(DamageEvent.DAMAGE, 
									   textFlow_damageHandler);
		}  
		
		// Created all lines.
		return true;      
	}
	
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
	private function createTextFlowFromContent(content:Object):TextFlow
	{
		var textFlow:TextFlow ;
		
		if (content is TextFlow)
		{
			textFlow = content as TextFlow;
		}
		else if (content is Array)
		{
			textFlow = new TextFlow();
			textFlow.whiteSpaceCollapse = getStyle("whiteSpaceCollapse");
			textFlow.mxmlChildren = content as Array;
			textFlow.whiteSpaceCollapse = undefined;
		}
		else
		{
			textFlow = new TextFlow();
			textFlow.whiteSpaceCollapse = getStyle("whiteSpaceCollapse");
			textFlow.mxmlChildren = [ content ];
			textFlow.whiteSpaceCollapse = undefined;
		}
		
		return textFlow;
	}
	
	/**
	 *  @private
	 */
	private function getEmbeddedFontContext():IFlexModuleFactory
	{
		var moduleFactory:IFlexModuleFactory;
		
		var fontLookup:String = getStyle("fontLookup");
		if (fontLookup != FontLookup.DEVICE)
		{
			var font:String = getStyle("fontFamily");
			var bold:Boolean = getStyle("fontWeight") == "bold";
			var italic:Boolean = getStyle("fontStyle") == "italic";
			
			moduleFactory = embeddedFontRegistry.getAssociatedModuleFactory(
				font, bold,	italic,
				this, fontContext);
			
			// If we found the font, then it is embedded. 
			// But some fonts are not listed in info()
			// and are therefore not in the above registry.
			// So we call isFontFaceEmbedded() which gets the list
			// of embedded fonts from the player.
			if (!moduleFactory) 
			{
				var sm:ISystemManager;
				if (fontContext != null && fontContext is ISystemManager)
					sm = ISystemManager(fontContext);
				else if (parent is IUIComponent)
					sm = IUIComponent(parent).systemManager;
				
				staticTextFormat.font = font;
				staticTextFormat.bold = bold;
				staticTextFormat.italic = italic;
				
				if (sm != null && sm.isFontFaceEmbedded(staticTextFormat))
					moduleFactory = sm;
			}
		}
		
		if (!moduleFactory && fontLookup == FontLookup.EMBEDDED_CFF)
		{
			// if we couldn't find the font and somebody insists it is
			// embedded, try the default fontContext
			moduleFactory = fontContext;
		}
		
		return moduleFactory;
	}
		
	/**
	 *  @private
	 *  Uses TextLineFactory to compose the textFlow
	 *  into as many TextLines as fit into the bounds.
	 */
	private function createTextLines():void
	{
		// Clear any previously generated TextLines from the textLines Array.
		textLines.length = 0;
		
		// Note: Even if we have nothing to compose, we nevertheless
		// use the StringTextLineFactory to compose an empty string.
		// Since it appends the paragraph terminator "\u2029",
		// it actually creates and measures one TextLine.
		// Its width is 0 but its height is equal to the font's
		// ascent plus descent.
        
        factory.compositionBounds = bounds;   
        
        // Set up the truncation options.
        var truncationOptions:TruncationOptions;
        if (maxDisplayedLines != 0)
        {
            truncationOptions = new TruncationOptions();
            truncationOptions.lineCountLimit = maxDisplayedLines;
            truncationOptions.truncationIndicator =
                TextBase.truncationIndicatorResource;
        }        
		factory.truncationOptions = truncationOptions;
		
        if (factory is StringTextLineFactory)
        {
			// We know text is non-null since it got this far.
			staticStringFactory.text = _text;
			staticStringFactory.textFlowFormat = hostFormat;
			staticStringFactory.createTextLines(addTextLine);
		}
        else if (factory is TextFlowTextLineFactory)
        {
            staticTextFlowFactory.createTextLines(addTextLine, _textFlow);
        }
        
        bounds = factory.getContentBounds();
        _isTruncated = factory.isTruncated;
    }

    /**
     *  @private
     *  Callback passed to createTextLines().
     */
    private function addTextLine(textLine:DisplayObject):void
    {
        textLines.push(textLine);
    }
  
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Called when the TextFlow dispatches a 'damage' event
     *  to indicate it has been modified.  This could mean the styles changed
     *  or the content changed, or both changed.
     */
    private function textFlow_damageHandler(event:DamageEvent):void
    {
        // If the target is the current textFlow then check the generation.
        // If there are no changes, don't recompose.  The TextFlowFactory
        // createTextLines dispatches damage events every time the textFlow
        // is composed, even if there are no changes.
        if (TextFlow(event.target) == _textFlow)
        { 
            if (_textFlow.generation == lastGeneration)
                return;
            
            // Update the last know generation for _textFlow.
            lastGeneration = _textFlow.generation;
        }

        // Invalidate _text and _content.
        _text = null;
        _content = null;
        
        // After the TextFlow has been mutated,
        // we must render it, not the 'text' String.
        factory = staticTextFlowFactory;
        
        // Force recompose since text and/or styles may have changed.
        invalidateTextLines();
        
        // We don't need to call invalidateProperties()
        // because the hostFormat and the _textFlow are still valid.

        // This is smart enough not to remeasure if the explicit width/height
        // were specified.
        invalidateSize();
        
        invalidateDisplayList();  
    }    
}

}