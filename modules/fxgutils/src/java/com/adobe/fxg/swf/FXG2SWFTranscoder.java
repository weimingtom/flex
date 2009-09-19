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

package com.adobe.fxg.swf;

import java.awt.geom.Ellipse2D;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Stack;
import java.util.Random;

import com.adobe.fxg.FXGTranscoder;
import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGVersion;
import com.adobe.internal.fxg.dom.AbstractShapeNode;
import com.adobe.internal.fxg.dom.BitmapGraphicNode;
import com.adobe.internal.fxg.dom.DefinitionNode;
import com.adobe.internal.fxg.dom.EllipseNode;
import com.adobe.internal.fxg.dom.FillNode;
import com.adobe.internal.fxg.dom.FilterNode;
import com.adobe.internal.fxg.dom.GradientEntryNode;
import com.adobe.internal.fxg.dom.GraphicContentNode;
import com.adobe.internal.fxg.dom.GraphicContext;
import com.adobe.internal.fxg.dom.GraphicNode;
import com.adobe.internal.fxg.dom.GroupDefinitionNode;
import com.adobe.internal.fxg.dom.GroupNode;
import com.adobe.internal.fxg.dom.LineNode;
import com.adobe.internal.fxg.dom.MaskableNode;
import com.adobe.internal.fxg.dom.MaskingNode;
import com.adobe.internal.fxg.dom.PathNode;
import com.adobe.internal.fxg.dom.PlaceObjectNode;
import com.adobe.internal.fxg.dom.RectNode;
import com.adobe.internal.fxg.dom.RichTextNode;
import com.adobe.internal.fxg.dom.StrokeNode;
import com.adobe.internal.fxg.dom.TextGraphicNode;
import com.adobe.internal.fxg.dom.fills.BitmapFillNode;
import com.adobe.internal.fxg.dom.fills.LinearGradientFillNode;
import com.adobe.internal.fxg.dom.fills.RadialGradientFillNode;
import com.adobe.internal.fxg.dom.fills.SolidColorFillNode;
import com.adobe.internal.fxg.dom.filters.BevelFilterNode;
import com.adobe.internal.fxg.dom.filters.BlurFilterNode;
import com.adobe.internal.fxg.dom.filters.ColorMatrixFilterNode;
import com.adobe.internal.fxg.dom.filters.DropShadowFilterNode;
import com.adobe.internal.fxg.dom.filters.GlowFilterNode;
import com.adobe.internal.fxg.dom.filters.GradientBevelFilterNode;
import com.adobe.internal.fxg.dom.filters.GradientGlowFilterNode;
import com.adobe.internal.fxg.dom.strokes.LinearGradientStrokeNode;
import com.adobe.internal.fxg.dom.strokes.RadialGradientStrokeNode;
import com.adobe.internal.fxg.dom.strokes.SolidColorStrokeNode;
import com.adobe.internal.fxg.dom.transforms.ColorTransformNode;
import com.adobe.internal.fxg.dom.transforms.MatrixNode;
import com.adobe.internal.fxg.dom.types.BevelType;
import com.adobe.internal.fxg.dom.types.BlendMode;
import com.adobe.internal.fxg.dom.types.Caps;
import com.adobe.internal.fxg.dom.types.InterpolationMethod;
import com.adobe.internal.fxg.dom.types.Joints;
import com.adobe.internal.fxg.dom.types.MaskType;
import com.adobe.internal.fxg.dom.types.ScaleMode;
import com.adobe.internal.fxg.dom.types.ScalingGrid;
import com.adobe.internal.fxg.dom.types.SpreadMethod;
import com.adobe.internal.fxg.dom.types.Winding;
import com.adobe.internal.fxg.swf.ImageHelper;
import com.adobe.internal.fxg.swf.ShapeHelper;
import com.adobe.internal.fxg.swf.TypeHelper;
import com.adobe.internal.fxg.types.FXGMatrix;

import flash.swf.SwfConstants;
import flash.swf.Tag;
import flash.swf.builder.types.PathIteratorWrapper;
import flash.swf.builder.types.ShapeBuilder;
import flash.swf.builder.types.ShapeIterator;
import flash.swf.tags.DefineBits;
import flash.swf.tags.DefineScalingGrid;
import flash.swf.tags.DefineShape;
import flash.swf.tags.DefineSprite;
import flash.swf.tags.DefineTag;
import flash.swf.tags.PlaceObject;
import flash.swf.types.BevelFilter;
import flash.swf.types.BlurFilter;
import flash.swf.types.CXFormWithAlpha;
import flash.swf.types.ColorMatrixFilter;
import flash.swf.types.DropShadowFilter;
import flash.swf.types.FillStyle;
import flash.swf.types.Filter;
import flash.swf.types.FocalGradient;
import flash.swf.types.GlowFilter;
import flash.swf.types.GradRecord;
import flash.swf.types.Gradient;
import flash.swf.types.GradientBevelFilter;
import flash.swf.types.GradientGlowFilter;
import flash.swf.types.LineStyle;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.types.Shape;
import flash.swf.types.ShapeRecord;
import flash.swf.types.ShapeWithStyle;
import flash.swf.types.TagList;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.util.FXGResourceResolver;

/**
 * Transcodes an FXG DOM into a tree of SWF DefineSprites which use SWF graphics
 * primitives to draw the document.
 * Note that in this implementation, since FTE based text
 * has no equivalent in SWF tags, text nodes are ignored.
 * 
 * @author Peter Farland
 */
public class FXG2SWFTranscoder implements FXGTranscoder
{
    protected HashMap<String, DefineSprite> definitions;
    protected Stack<DefineSprite> spriteStack;
    protected FXGResourceResolver resourceResolver;
    protected int spriteCount;
    protected static Random random = new Random();

    public FXG2SWFTranscoder newInstance()
    {
        return new FXG2SWFTranscoder();
    }
    
    public void setResourceResolver(FXGResourceResolver resolver)
    {
        resourceResolver = resolver;
    }

    public Object transcode(FXGNode fxgNode)
    {
        GraphicNode node = (GraphicNode)fxgNode;
        DefineSprite sprite = createDefineSprite("Graphic");
        spriteStack.push(sprite);

        // Process mask (if present)
        if (node.mask != null)
            mask(node, sprite);

        // Handle 'scale 9' grid definition
        if (node.definesScaleGrid())
        {
            DefineScalingGrid grid = createDefineScalingGrid(node.getScalingGrid());
            grid.scalingTarget = sprite;
            sprite.scalingGrid = grid;
        }

        // Process child nodes
        if (node.children != null)
            graphicContentNodes(node.children);

        spriteStack.pop();
        return sprite;
    }

    public FXG2SWFTranscoder()
    {
        spriteStack = new Stack<DefineSprite>();
    }
    

    private PlaceObject bitmapWithClip(DefineBits imageTag, BitmapGraphicNode node)
    {
        DefineSprite imageSprite = createDefineSprite("BitmapGraphic");
        spriteStack.push(imageSprite);

        // First, generate the clipping mask
        DefineSprite clipSprite = createDefineSprite("BitmapGraphic_Clip");
        spriteStack.push(clipSprite);
        GraphicContext context = node.createGraphicContext();
        List<ShapeRecord> shapeRecords = ShapeHelper.rectangle(0.0, 0.0, imageTag.width, imageTag.height);
        DefineShape clipShape = createDefineShape(shapeRecords, new SolidColorFillNode(), null, context.getTransform());
        placeObject(clipShape, new GraphicContext());
        spriteStack.pop();
        
        //place the clipping mask in the imageSprite
        PlaceObject po3clip = placeObject(clipSprite, context);
        po3clip.setClipDepth(po3clip.depth+1);
        
        // Then, process the image
        DefineShape imageShape = ImageHelper.createShapeForImage(imageTag, node);
        placeObject(imageShape, context);        
        spriteStack.pop();
        
        PlaceObject po3 = placeObject(imageSprite, new GraphicContext());
        return po3;
    }
    
    // --------------------------------------------------------------------------
    //
    // Graphic Content Nodes
    //
    // --------------------------------------------------------------------------
    protected PlaceObject bitmap(BitmapGraphicNode node)
    {
        double width = node.width;
        double height = node.height;
        GraphicContext context = node.createGraphicContext();
        if (node.visible)
        {
            String source = parseSource(node.source);
            if (source == null)
            {
                // Source is required after FXG 1.0
                // Exception: Missing source attribute in <BitmapGraphic> or <BitmapFill>.
                throw new FXGException(node.getStartLine(), node.getStartColumn(), "MissingSourceAttribute");
            }
            DefineBits imageTag = createDefineBits(node, source, width, height);
        
            DefineShape imageShape;
            ScalingGrid scalingGrid = context.scalingGrid;
            if (scalingGrid != null)
            {
                Rect grid = TypeHelper.rect(scalingGrid.scaleGridLeft, scalingGrid.scaleGridTop, scalingGrid.scaleGridRight, scalingGrid.scaleGridBottom);
                imageShape = ImageHelper.create9SlicedShape(imageTag, grid, Double.NaN, Double.NaN);
                PlaceObject po3 = placeObject(imageShape, context);
                return po3;
            }
            else
            {
            	if (ImageHelper.bitmapNeedsClipping(imageTag, node))
            	{
            		PlaceObject p03 = bitmapWithClip(imageTag, node);
            		return p03;
            	}
            	else
            	{
            		imageShape = ImageHelper.createShapeForImage(imageTag, node);
            		PlaceObject po3 = placeObject(imageShape, context);
            		return po3;
            	}
            }            
        }
        else
        {
            List<ShapeRecord>  shapeRecords = ShapeHelper.rectangle(0.0, 0.0, width, height);        
            DefineShape shape = createDefineShape(shapeRecords, null, null, context.getTransform());
            PlaceObject po3 = placeObject(shape, context);
            return po3;
        }

    }

    protected void graphicContentNodes(List<GraphicContentNode> nodes)
    {
        Iterator<GraphicContentNode> iterator = nodes.iterator();
        while (iterator.hasNext())
        {
            GraphicContentNode node = iterator.next();
            graphicContentNode(node);
        }
    }

    protected PlaceObject graphicContentNode(GraphicContentNode node)
    {
        PlaceObject po3 = null;

    	if (!node.visible)
        {
            ColorTransformNode ct = new ColorTransformNode();
            ct.alphaMultiplier = 0;
            ct.alphaOffset = 0;
            ct.blueMultiplier = 1;
            ct.blueOffset = 0;
            ct.greenMultiplier = 1;
            ct.greenOffset = 0;
            ct.redMultiplier = 1;
            ct.redOffset = 0;
            node.colorTransform = ct;
            
            if (node instanceof AbstractShapeNode) 
            {
                AbstractShapeNode shapeNode = (AbstractShapeNode)node;
                shapeNode.fill = null;
                shapeNode.stroke = null;
            }
            
        }

        if (node instanceof GroupNode)
        {
            group((GroupNode)node);
        }
        else
        {
            // For non-group nodes, we process mask to clip only this shape
            // node. Process the mask first to ensure the depth is correct.
            if (node.mask != null)
            {
                DefineSprite parentSprite = spriteStack.peek();
                mask(node, parentSprite);
            }
            
            if (node instanceof EllipseNode)
                po3 = ellipse((EllipseNode)node);
            else if (node instanceof LineNode)
                po3 = line((LineNode)node);
            else if (node instanceof PathNode)
                po3 = path((PathNode)node);
            else if (node instanceof RectNode)
                po3 = rect((RectNode)node);
            else if (node instanceof PlaceObjectNode)
                po3 = placeObjectInstance((PlaceObjectNode)node);
            else if (node instanceof BitmapGraphicNode)
                po3 = bitmap((BitmapGraphicNode)node);
            else if (node instanceof TextGraphicNode)
                po3 = text((TextGraphicNode)node);
            else if (node instanceof RichTextNode)
                po3 = richtext((RichTextNode)node);
        }

        return po3;
    }

    protected PlaceObject ellipse(EllipseNode node)
    {
        // Note that we will apply node.x and node.y as a translation operation
        // in the PlaceObject3 Matrix and instead start the shape from the
        // origin (0.0, 0.0).
        Ellipse2D.Double ellipse = new Ellipse2D.Double(0.0, 0.0, node.width, node.height);
        GraphicContext context = node.createGraphicContext();
        
        DefineShape shape = createDefineShape(ellipse, node.fill, node.stroke, context.getTransform());
        PlaceObject po3 = placeObject(shape, context);
        return po3;
    }

    protected PlaceObject group(GroupNode node)
    {
    	//handle blendMode "auto"
        if (node.blendMode == BlendMode.AUTO)
        {
        	if ((node.alpha == 0) || (node.alpha == 1))
        		node.blendMode = BlendMode.NORMAL;
        	else
        		node.blendMode = BlendMode.LAYER;
        }
        
        DefineSprite groupSprite = createDefineSprite("Group");
        GraphicContext context = node.createGraphicContext();
        
        // Handle 'scale 9' grid definition
        if (node.definesScaleGrid())
        {
            DefineScalingGrid grid = createDefineScalingGrid(context.scalingGrid);
            grid.scalingTarget = groupSprite;
            groupSprite.scalingGrid = grid;
        }

        PlaceObject po3 = placeObject(groupSprite, context);
        spriteStack.push(groupSprite);

        // First, process mask (if present)
        if (node.mask != null)
            mask(node, groupSprite);

        // Then process child nodes.
        if (node.children != null)
            graphicContentNodes(node.children);

        spriteStack.pop();
        return po3;
    }

    protected PlaceObject line(LineNode node)
    {
        List<ShapeRecord> shapeRecords = ShapeHelper.line(node.xFrom, node.yFrom, node.xTo, node.yTo);
        GraphicContext context = node.createGraphicContext();
        DefineShape shape = createDefineShape(shapeRecords, node.fill, node.stroke, context.getTransform());
        PlaceObject po3 = placeObject(shape, context);
        return po3;
    }

    protected PlaceObject mask(MaskableNode node, DefineSprite parentSprite)
    {
        PlaceObject po3 = null;

        MaskingNode mask = node.getMask();
        if (mask instanceof GroupNode)
        {
            // According to FXG Spec.: The masking element inherits the target 
            // group's coordinate space, as though it were a direct child 
            // element. In the case when mask is inside a shape, it doesn't 
            // automatically inherit the coordinates from the shape node 
            // but inherits from its parent node which is also parent of 
            // the shape node. To fix it, specifically concatenating the 
            // shape node matrix to the masking node matrix.
            if (!(node instanceof GroupNode || node instanceof GraphicNode))
            {
                FXGMatrix nodeMatrix = null;
                MatrixNode matrixNodeShape = ((GraphicContentNode)node).matrix;
                if (matrixNodeShape == null)
                    // Convert shape node's discreet transform attributes to 
                    // matrix.
                    nodeMatrix = FXGMatrix.convertToMatrix(((GraphicContentNode)node).scaleX, ((GraphicContentNode)node).scaleY, ((GraphicContentNode)node).rotation, ((GraphicContentNode)node).x, ((GraphicContentNode)node).y);
                else
                    nodeMatrix = new FXGMatrix(matrixNodeShape);
                // Get masking node matrix.
                MatrixNode matrixNodeMasking = ((GraphicContentNode)mask).matrix;
                // Create a new MatrixNode if the masking node doesn't have one.
                if (matrixNodeMasking == null)
                {
                    // Convert masking node's transform attributes to matrix
                    // so we can concatenate the shape node's matrix to it.
                    ((GraphicContentNode)mask).convertTransformAttrToMatrix();
                    matrixNodeMasking = ((GraphicContentNode)mask).matrix;
                }
                FXGMatrix maskMatrix = new FXGMatrix(matrixNodeMasking);
                // Concatenate the shape node's matrix to the masking node's 
                // matrix.
                maskMatrix.concat(nodeMatrix);
                // Set the masking node's matrix with the concatenated values.
                maskMatrix.setMatrixNodeValue(matrixNodeMasking);
            }
            po3 = group((GroupNode)mask);
        }
        else if (mask instanceof PlaceObjectNode)
        {
            po3 = placeObjectInstance((PlaceObjectNode)mask);
        }

        if (po3 != null)
        {
            int clipDepth = 1;

            // If we had a graphic or group, clip the depths for all children.
            if (node instanceof GroupNode)
            {
                GroupNode group = (GroupNode)node;
                if (group.children != null)
                    clipDepth = parentSprite.depthCounter + group.children.size();
            }
            else if (node instanceof GraphicNode)
            {
                GraphicNode graphic = (GraphicNode)node;
                if (graphic.children != null)
                    clipDepth = parentSprite.depthCounter + graphic.children.size();
            }
            // ... otherwise, just clip the shape itself.
            else
            {
                clipDepth = po3.depth + 1;
            }

            po3.setClipDepth(clipDepth);

            if (node.getMaskType() == MaskType.ALPHA)
            {
                po3.setCacheAsBitmap(true);
            }
        }

        return po3;
    }

    protected PlaceObject path(PathNode node)
    {
        List<ShapeRecord> shapeRecords = ShapeHelper.path(node.data, (node.fill != null));
        GraphicContext context = node.createGraphicContext();
        DefineShape shape = createDefineShape(shapeRecords, node.fill, node.winding, node.stroke, context.getTransform());
        PlaceObject po3 = placeObject(shape, context);
        return po3;
    }

    protected void setPixelBenderBlendMode(PlaceObject po, BlendMode blendMode)
    {
        
    }
    
    protected void setAlphaMask(PlaceObject po)
    {
        po.setCacheAsBitmap(true);
    }
    
    protected void setLuminosityMask(PlaceObject po)
    {
       
    }
    
    protected PlaceObject placeObject(DefineTag symbol, GraphicContext context)
    {
        DefineSprite sprite = spriteStack.peek();

        PlaceObject po3 = new PlaceObject(Tag.stagPlaceObject3);
        // po3.setName(name);
        po3.setRef(symbol);
        po3.depth = ++sprite.depthCounter;

        if (context.blendMode != null)
        {
            if (!context.blendMode.needsPixelBenderSupport())
            {
                int blendMode = createBlendMode(context.blendMode);
                po3.setBlendMode(blendMode);
            }
            else
            {
                setPixelBenderBlendMode(po3, context.blendMode);
            }
        }

        if (context.filters != null)
        {
            List<Filter> filters = createFilters(context.filters);
            po3.setFilterList(filters);
        }

        // FXG angles are always clockwise.
        Matrix matrix = context.getTransform().toSWFMatrix();
        po3.setMatrix(matrix);

        if (context.colorTransform != null)
        {
            ColorTransformNode t = context.colorTransform;
            CXFormWithAlpha cx = TypeHelper.cxFormWithAlpha(t.alphaMultiplier, t.redMultiplier, t.greenMultiplier, t.blueMultiplier, t.alphaOffset, t.redOffset, t.greenOffset, t.blueOffset);
            po3.setCxform(cx);
        }

        
        if (context.maskType == MaskType.ALPHA)
        {
            setAlphaMask(po3);
        }
        else if (context.maskType == MaskType.LUMINOSITY)
        {
            setLuminosityMask(po3);
        }

        sprite.tagList.placeObject3(po3);
        return po3;
    }

    protected PlaceObject rect(RectNode node)
    {
        // Note that we will apply node.x and node.y as a translation operation
        // in the PlaceObject3 Matrix and instead start the shape from the
        // origin (0.0, 0.0).
        GraphicContext context = node.createGraphicContext();
        List<ShapeRecord> shapeRecords;
        if (node.radiusX != 0.0 || node.radiusY != 0.0 
        		|| !Double.isNaN(node.topLeftRadiusX) || !Double.isNaN(node.topLeftRadiusY)
        		|| !Double.isNaN(node.topRightRadiusX) || !Double.isNaN(node.topRightRadiusY)
        		|| !Double.isNaN(node.bottomLeftRadiusX) || !Double.isNaN(node.bottomLeftRadiusY)
        		|| !Double.isNaN(node.bottomRightRadiusX) || !Double.isNaN(node.bottomRightRadiusY))
        {
             shapeRecords  = ShapeHelper.rectangle(0.0, 0.0, node.width, node.height, 
            		 node.radiusX, node.radiusY, node.topLeftRadiusX, node.topLeftRadiusY,
            		 node.topRightRadiusX, node.topRightRadiusY, node.bottomLeftRadiusX, node.bottomLeftRadiusY,
            		 node.bottomRightRadiusX, node.bottomRightRadiusY);
        }
        else
        {
             shapeRecords = ShapeHelper.rectangle(0.0, 0.0, node.width, node.height);
        }
        
        DefineShape shape = createDefineShape(shapeRecords, node.fill, node.stroke, context.getTransform());
        PlaceObject po3 = placeObject(shape, context);
        return po3;
    }

    protected PlaceObject text(TextGraphicNode node)
    {
        // No operation - text is ignored in this implementation.
        return null;
    }

    protected PlaceObject richtext(RichTextNode node)
    {
        // No operation - richtext is ignored in this implementation.
        return null;
    }

    // --------------------------------------------------------------------------
    //
    // FXG Library Definitions
    //
    // --------------------------------------------------------------------------

    protected PlaceObject placeObjectInstance(PlaceObjectNode node)
    {
        String definitionName = node.getNodeName();

        if (definitions == null)
            definitions = new HashMap<String, DefineSprite>();

        DefineSprite definitionSprite = definitions.get(definitionName);
        if (definitionSprite == null)
        {
            definitionSprite = createDefineSprite("Definition");
            FXG2SWFTranscoder graphics = newInstance();
            graphics.setResourceResolver(resourceResolver);
            definitions.put(definitionName, definitionSprite);
            graphics.definitions = definitions;
            graphics.definition(node.definition, definitionSprite);
        }

        PlaceObject po3 = placeObject(definitionSprite, node.createGraphicContext());
        return po3;
    }

    protected void definition(DefinitionNode node, DefineSprite definitionSprite)
    {
        GroupDefinitionNode groupDefinition = node.groupDefinition;
        
        if (groupDefinition == null) 
        {
          //Exception:Definitions must define a single Group child node.
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "MissingGroupChildNode");
        }
        spriteStack.push(definitionSprite);

        if (groupDefinition.definesScaleGrid())
        {
            definitionSprite.scalingGrid = createDefineScalingGrid(groupDefinition.getScalingGrid());
            definitionSprite.scalingGrid.scalingTarget = definitionSprite;
        }

        graphicContentNodes(groupDefinition.children);

        spriteStack.pop();
    }

    // --------------------------------------------------------------------------
    //
    // SWF Tags and Types Helper Methods
    //
    // --------------------------------------------------------------------------

    protected DefineBits createDefineBits(FXGNode node, String source, double width,
            double height)
    {
        try
        {
            InputStream stream = resourceResolver.openStream(source);
            DefineBits imageTag = ImageHelper.createDefineBits(stream, ImageHelper.guessMimeType(source));
            return imageTag;
        }
        catch (IOException ioe)
        {
            // Exception:Error {0} occurred while embedding image {1}.
            throw new FXGException(node.getStartLine(), node.getStartColumn(), "ErrorEmbeddingImage", ioe.getMessage(), source);
        }
    }

    protected DefineScalingGrid createDefineScalingGrid(ScalingGrid grid)
    {
        DefineScalingGrid scalingGrid = new DefineScalingGrid();
        scalingGrid.rect = TypeHelper.rect(grid.scaleGridLeft, grid.scaleGridTop, grid.scaleGridRight, grid.scaleGridBottom);
        return scalingGrid;
    }

    protected DefineSprite createDefineSprite(String name)
    {
        DefineSprite sprite = new DefineSprite();
        sprite.tagList = new TagList();
        sprite.framecount = 1;
        if (name == null) name = "";
        sprite.name = name + random.nextInt();
        return sprite;
    }

    protected DefineShape createDefineShape(java.awt.Shape shape2d,
            FillNode fill, StrokeNode stroke, FXGMatrix transform)
    {
        ShapeBuilder builder = new ShapeBuilder();
        ShapeIterator iterator = new PathIteratorWrapper(shape2d.getPathIterator(null));
        builder.processShape(iterator);
        Shape shape = builder.build();
        return createDefineShape(shape.shapeRecords, fill, stroke, transform);
    }

    protected DefineShape createDefineShape(List<ShapeRecord> shapeRecords,
            FillNode fill, StrokeNode stroke, FXGMatrix transform)
    {
        // Calculate the bounds of the shape outline (without strokes)
        Rect bounds = ShapeHelper.getBounds(shapeRecords, null);
        Rect edgeBounds = bounds;

        ShapeWithStyle sws = new ShapeWithStyle();
        sws.shapeRecords = shapeRecords;

        int lineStyleIndex = stroke == null ? 0 : 1;
        int fillStyle0Index = fill == null ? 0 : 1;
        int fillStyle1Index = 0;
        ShapeHelper.setStyles(shapeRecords, lineStyleIndex, fillStyle0Index, fillStyle1Index);

        
        if (fill != null)
        {
            FillStyle fillStyle = createFillStyle(fill, bounds, transform);
            sws.fillstyles = new ArrayList<FillStyle>(1);
            sws.fillstyles.add(fillStyle);
        }

        if (stroke != null)
        {
            LineStyle lineStyle = createLineStyle(stroke, bounds, transform);
            sws.linestyles = new ArrayList<LineStyle>(1);
            sws.linestyles.add(lineStyle);

            // Consider linestyle stroke widths with bounds calculation
            edgeBounds = ShapeHelper.getBounds(shapeRecords, sws.linestyles);
        }

        DefineShape defineShape4 = new DefineShape(Tag.stagDefineShape4);
        defineShape4.shapeWithStyle = sws;
        defineShape4.bounds = bounds;
        defineShape4.edgeBounds = edgeBounds;
         
        return defineShape4;
    }
    
    
    protected DefineShape createDefineShape(List<ShapeRecord> shapeRecords, FillNode fill,
            Winding windingValue, StrokeNode stroke, FXGMatrix transform)
    {
 
        // Calculate the bounds of the shape outline (without strokes)
        Rect edgeBounds = ShapeHelper.getBounds(shapeRecords, null);
        Rect bounds = edgeBounds;

        ShapeWithStyle sws = new ShapeWithStyle();
        sws.shapeRecords = shapeRecords;

        int lineStyleIndex = stroke == null ? 0 : 1;
        int fillStyle0Index = fill == null ? 0 : 1;
        int fillStyle1Index = 0;
        ShapeHelper.setPathStyles(shapeRecords, lineStyleIndex, fillStyle0Index, fillStyle1Index);

        if (fill != null)
        {
            FillStyle fillStyle = createFillStyle(fill, edgeBounds, transform);
            sws.fillstyles = new ArrayList<FillStyle>(1);
            sws.fillstyles.add(fillStyle);
        }

        if (stroke != null)
        {
            LineStyle lineStyle = createLineStyle(stroke, edgeBounds, transform);
            sws.linestyles = new ArrayList<LineStyle>();
            sws.linestyles.add(lineStyle);

            // Consider linestyle stroke widths with bounds calculation
            bounds = ShapeHelper.getBounds(shapeRecords, sws.linestyles);
        }

        DefineShape defineShape4 = new DefineShape(Tag.stagDefineShape4);
        defineShape4.shapeWithStyle = sws;
        defineShape4.bounds = bounds;
        defineShape4.edgeBounds = edgeBounds;
        if (fill != null)
            defineShape4.usesFillWindingRule = (windingValue == Winding.NON_ZERO);
         
        return defineShape4;
    }
    
    protected FillStyle createFillStyle(FillNode fill, Rect bounds, FXGMatrix transform)
     {
        if (fill instanceof SolidColorFillNode)
            return createFillStyle((SolidColorFillNode)fill);
        else if (fill instanceof LinearGradientFillNode)
            return createFillStyle((LinearGradientFillNode)fill, bounds, transform);
        else if (fill instanceof RadialGradientFillNode)
            return createFillStyle((RadialGradientFillNode)fill, bounds, transform);
        else if (fill instanceof BitmapFillNode)
            return createFillStyle((BitmapFillNode)fill, bounds);
        else
            return null;
    }

    protected FillStyle createFillStyle(SolidColorFillNode fill)
    {
        FillStyle fs = new FillStyle();
        fs.color = TypeHelper.colorARGB(fill.color, fill.alpha);
        fs.type = FillStyle.FILL_SOLID;
        return fs;
    }

    protected FillStyle createFillStyle(BitmapFillNode fill, Rect bounds)
    {        
        FillStyle fs = new FillStyle();
        if (fill.repeat)
            fs.type = FillStyle.FILL_BITS;
        else
            fs.type = FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP;

        String sourceFormatted = parseSource(fill.source);
        
        if (sourceFormatted == null && !fill.getFileVersion().equals(FXGVersion.v1_0))
        {
            // Source is required after FXG 1.0
            // Exception: Missing source attribute in <BitmapGraphic> or <BitmapFill>.
            throw new FXGException(fill.getStartLine(), fill.getStartColumn(), "MissingSourceAttribute");
        }

        String source = parseSource(sourceFormatted);
        fs.bitmap = createDefineBits(fill, source, Double.NaN, Double.NaN);

        fs.matrix = TypeHelper.bitmapFillMatrix(fill, bounds);

        return fs;
    }

    protected FillStyle createFillStyle(LinearGradientFillNode node, Rect bounds, FXGMatrix transform)
    {
        FillStyle fs = new FillStyle();
        fs.type = FillStyle.FILL_LINEAR_GRADIENT;
        fs.matrix = TypeHelper.linearGradientMatrix(node, bounds, transform);
        Gradient gradient = new Gradient();
        populateGradient(gradient, node.entries, node.interpolationMethod, node.spreadMethod);
        fs.gradient = gradient;

        return fs;
    }

    protected FillStyle createFillStyle(LinearGradientStrokeNode node, Rect bounds, FXGMatrix transform)
    {
        FillStyle fs = new FillStyle();
        fs.type = FillStyle.FILL_LINEAR_GRADIENT;
        fs.matrix = TypeHelper.linearGradientMatrix(node, bounds, transform);
        Gradient gradient = new Gradient();
        populateGradient(gradient, node.entries, node.interpolationMethod, node.spreadMethod);
        fs.gradient = gradient;

        return fs;
    }

    protected FillStyle createFillStyle(RadialGradientFillNode node, Rect bounds, FXGMatrix transform)
    {
        FillStyle fs = new FillStyle();
        fs.type = FillStyle.FILL_FOCAL_RADIAL_GRADIENT;
        fs.matrix = TypeHelper.radialGradientMatrix(node, bounds, transform);
        FocalGradient gradient = new FocalGradient();
        populateGradient(gradient, node.entries, node.interpolationMethod, node.spreadMethod);
        gradient.focalPoint = (float)node.focalPointRatio;
        fs.gradient = gradient;

        return fs;
    }

    protected FillStyle createFillStyle(RadialGradientStrokeNode node, Rect bounds, FXGMatrix transform)
    {
        FillStyle fs = new FillStyle();
        fs.type = FillStyle.FILL_FOCAL_RADIAL_GRADIENT;
        fs.matrix = TypeHelper.radialGradientMatrix(node, bounds, transform);
        FocalGradient gradient = new FocalGradient();
        populateGradient(gradient, node.entries, node.interpolationMethod, node.spreadMethod);
        gradient.focalPoint = (float)node.focalPointRatio;
        fs.gradient = gradient;

        return fs;
    }
    
    protected LineStyle createLineStyle(StrokeNode stroke, Rect bounds, FXGMatrix transform)
    {
        if (stroke instanceof SolidColorStrokeNode)
            return createLineStyle((SolidColorStrokeNode)stroke);
        else if (stroke instanceof LinearGradientStrokeNode)
            return createLineStyle((LinearGradientStrokeNode)stroke, bounds, transform);
        else if (stroke instanceof RadialGradientStrokeNode)
            return createLineStyle((RadialGradientStrokeNode)stroke, bounds, transform);
        else
            return null;
    }

    protected LineStyle createLineStyle(SolidColorStrokeNode stroke)
    {
        LineStyle ls = new LineStyle();
        ls.width = (int)StrictMath.rint(stroke.getWeight() * SwfConstants.TWIPS_PER_PIXEL);
        ls.color = TypeHelper.colorARGB(stroke.color, stroke.alpha);

        int flags = 0;
        int startCapStyle = createCaps(stroke.caps);
        int endCapStyle = startCapStyle;
        int jointStyle = createJoints(stroke.joints);
        int noHorizonalScale = 1;
        int noVerticalScale = 1;

        // First set of 8 bit flags
        if (stroke.scaleMode == ScaleMode.VERTICAL || stroke.scaleMode == ScaleMode.NONE)
            flags |= noHorizonalScale << 1;
        if (stroke.scaleMode == ScaleMode.HORIZONTAL || stroke.scaleMode == ScaleMode.NONE)
            flags |= noVerticalScale << 2;
        flags |= jointStyle << 4;
        flags |= startCapStyle << 6;

        // Second set of 8 bit flags
        flags |= endCapStyle << 8;

        if (jointStyle == 2)
        {
            // Encoded in SWF as an 8.8 fixed point value
            ls.miterLimit = TypeHelper.fixed8(stroke.miterLimit);
        }

        ls.flags = flags;
        return ls;
    }

    protected LineStyle createLineStyle(LinearGradientStrokeNode stroke, Rect bounds, FXGMatrix transform)
    {
        LineStyle ls = new LineStyle();
        ls.width = (int)StrictMath.rint(stroke.getWeight() * SwfConstants.TWIPS_PER_PIXEL);
        ls.fillStyle = createFillStyle(stroke, bounds, transform);

        int flags = 0;
        int hasFillStyle = 1; // Gradient strokes require a FillStyle
        int startCapStyle = createCaps(stroke.caps);
        int endCapStyle = startCapStyle;
        int jointStyle = createJoints(stroke.joints);
        int noHorizonalScale = 1;
        int noVerticalScale = 1;

        // First set of 8 bit flags
        if (stroke.scaleMode == ScaleMode.VERTICAL || stroke.scaleMode == ScaleMode.NONE)
            flags |= noHorizonalScale << 1;
        if (stroke.scaleMode == ScaleMode.HORIZONTAL || stroke.scaleMode == ScaleMode.NONE)
            flags |= noVerticalScale << 2;
        flags |= hasFillStyle << 3;
        flags |= jointStyle << 4;
        flags |= startCapStyle << 6;

        // Second set of 8 bit flags
        flags |= endCapStyle << 8;

        if (jointStyle == 2)
        {
            // Encoded in SWF as an 8.8 fixed point value
            ls.miterLimit = TypeHelper.fixed8(stroke.miterLimit);
        }

        ls.flags = flags;
        return ls;
    }

    protected LineStyle createLineStyle(RadialGradientStrokeNode stroke, Rect edgeBounds, FXGMatrix transform)
    {
        LineStyle ls = new LineStyle();
        ls.width = (int)StrictMath.rint(stroke.getWeight() * SwfConstants.TWIPS_PER_PIXEL);
        // Convert twips bounds to pixels
        ls.fillStyle = createFillStyle(stroke, edgeBounds, transform);

        int flags = 0;
        int hasFillStyle = 1; // Gradient strokes require a FillStyle
        int startCapStyle = createCaps(stroke.caps);
        int endCapStyle = startCapStyle;
        int jointStyle = createJoints(stroke.joints);
        int noHorizonalScale = 1;
        int noVerticalScale = 1;

        // First set of 8 bit flags
        if (stroke.scaleMode == ScaleMode.VERTICAL || stroke.scaleMode == ScaleMode.NONE)
            flags |= noHorizonalScale << 1;
        if (stroke.scaleMode == ScaleMode.HORIZONTAL || stroke.scaleMode == ScaleMode.NONE)
            flags |= noVerticalScale << 2;
        flags |= hasFillStyle << 3;
        flags |= jointStyle << 4;
        flags |= startCapStyle << 6;

        // Second set of 8 bit flags
        flags |= endCapStyle << 8;

        if (jointStyle == 2)
        {
            // Encoded in SWF as an 8.8 fixed point value
            ls.miterLimit = TypeHelper.fixed8(stroke.miterLimit);
        }

        ls.flags = flags;
        return ls;
    }

    protected int createCaps(Caps value)
    {
        if (value != null)
            return value.ordinal();
        else
            return Caps.NONE.ordinal();
    }

    protected int createJoints(Joints value)
    {
        if (value != null)
            return value.ordinal();
        else
            return Joints.ROUND.ordinal();
    }

    protected int createSpreadMode(SpreadMethod value)
    {
        return value.ordinal();
    }

    protected int createBlendMode(BlendMode value)
    {
    	if (value == BlendMode.AUTO)
    		value = BlendMode.NORMAL;
        return value.ordinal();
    }

    protected int createInterpolationMode(InterpolationMethod value)
    {
        return value.ordinal();
    }

    protected List<Filter> createFilters(List<FilterNode> list)
    {
        List<Filter> filters = new ArrayList<Filter>(list.size());
        Iterator<FilterNode> iterator = list.iterator();
        while (iterator.hasNext())
        {
            FilterNode f = iterator.next();
            if (f instanceof BevelFilterNode)
            {
                BevelFilterNode node = (BevelFilterNode)f;
                BevelFilter filter = createBevelFilter(node);
                filters.add(filter);
            }
            else if (f instanceof BlurFilterNode)
            {
                BlurFilterNode node = (BlurFilterNode)f;
                BlurFilter filter = createBlurFilter(node);
                filters.add(filter);
            }
            else if (f instanceof ColorMatrixFilterNode)
            {
                ColorMatrixFilterNode node = (ColorMatrixFilterNode)f;
                ColorMatrixFilter filter = new ColorMatrixFilter();
                filter.values = node.matrix;
                filters.add(filter);
            }
            else if (f instanceof DropShadowFilterNode)
            {
                DropShadowFilterNode node = (DropShadowFilterNode)f;
                DropShadowFilter filter = createDropShadowFilter(node);
                filters.add(filter);
            }
            else if (f instanceof GlowFilterNode)
            {
                GlowFilterNode node = (GlowFilterNode)f;
                GlowFilter filter = createGlowFilter(node);
                filters.add(filter);
            }
            else if (f instanceof GradientBevelFilterNode)
            {
                GradientBevelFilterNode node = (GradientBevelFilterNode)f;
                GradientBevelFilter filter = createGradientBevelFilter(node);
                filters.add(filter);
            }
            else if (f instanceof GradientGlowFilterNode)
            {
                GradientGlowFilterNode node = (GradientGlowFilterNode)f;
                GradientGlowFilter filter = createGradientGlowFilter(node);
                filters.add(filter);
            }
        }
        return filters;
    }

    protected BevelFilter createBevelFilter(BevelFilterNode node)
    {
        BevelFilter filter = new BevelFilter();
        filter.angle = TypeHelper.fixed(node.angle*Math.PI/180.0);
        filter.blurX = TypeHelper.fixed(node.blurX);
        filter.blurY = TypeHelper.fixed(node.blurY);
        filter.distance = TypeHelper.fixed(node.distance);
        filter.strength = TypeHelper.fixed8(node.strength);
        filter.shadowColor = TypeHelper.colorARGB(node.shadowColor, node.shadowAlpha);
        filter.highlightColor = TypeHelper.colorARGB(node.highlightColor, node.highlightAlpha);
        filter.flags = node.quality;
        if (node.type == BevelType.FULL)
            filter.flags |= 1 << 4;
        filter.flags |= 1 << 5; // Always a composite source
        if (node.knockout)
            filter.flags |= 1 << 6;
        if (node.type == BevelType.INNER)
            filter.flags |= 1 << 7;
        return filter;
    }

    protected BlurFilter createBlurFilter(BlurFilterNode node)
    {
        BlurFilter filter = new BlurFilter();
        filter.blurX = TypeHelper.fixed(node.blurX);
        filter.blurY = TypeHelper.fixed(node.blurY);
        filter.passes = node.quality << 3;
        return filter;
    }

    protected DropShadowFilter createDropShadowFilter(DropShadowFilterNode node)
    {
        DropShadowFilter filter = new DropShadowFilter();
        filter.color = TypeHelper.colorARGB(node.color, node.alpha);
        filter.angle = TypeHelper.fixed(node.angle*Math.PI/180.0);
        filter.blurX = TypeHelper.fixed(node.blurX);
        filter.blurY = TypeHelper.fixed(node.blurY);
        filter.distance = TypeHelper.fixed(node.distance);
        filter.strength = TypeHelper.fixed8(node.strength);
        filter.flags = node.quality;
        if (!node.hideObject) // Set CompositeSource bit for non-hiddenObject
            filter.flags |= 1 << 5; 
        if (node.knockout)
            filter.flags |= 1 << 6;
        if (node.inner)
            filter.flags |= 1 << 7;
        return filter;
    }

    protected GlowFilter createGlowFilter(GlowFilterNode node)
    {
        GlowFilter filter = new GlowFilter();
        filter.color = TypeHelper.colorARGB(node.color, node.alpha);
        filter.blurX = TypeHelper.fixed(node.blurX);
        filter.blurY = TypeHelper.fixed(node.blurY);
        filter.strength = TypeHelper.fixed8(node.strength);
        filter.flags = node.quality;
        filter.flags |= 1 << 5; // Always a composite source
        if (node.knockout)
            filter.flags |= 1 << 6;
        if (node.inner)
            filter.flags |= 1 << 7;

        return filter;
    }

    protected GradientBevelFilter createGradientBevelFilter(
            GradientBevelFilterNode node)
    {
        GradientBevelFilter filter = new GradientBevelFilter();
        if (node.entries != null)
        {
            byte count = (byte)node.entries.size();
            filter.numcolors = count;
            filter.gradientColors = new int[count];
            filter.gradientRatio = new int[count];

            GradRecord[] records = createGradRecords(node.entries);
            for (int i = 0; i < records.length; i++)
            {
                GradRecord record = records[i];
                filter.gradientColors[i] = record.color;
                filter.gradientRatio[i] = record.ratio;
            }
        }

        filter.angle = TypeHelper.fixed(node.angle*Math.PI/180.0);
        filter.blurX = TypeHelper.fixed(node.blurX);
        filter.blurY = TypeHelper.fixed(node.blurY);
        filter.distance = TypeHelper.fixed(node.distance);
        filter.strength = TypeHelper.fixed8(node.strength);
        filter.flags = node.quality; // Quality encoded with 4 bits
        if (node.type == BevelType.FULL)
            filter.flags |= 1 << 4;
        filter.flags |= 1 << 5; // Always a composite source
        if (node.knockout)
            filter.flags |= 1 << 6;
        if (node.type == BevelType.INNER)
            filter.flags |= 1 << 7;

        return filter;
    }

    protected GradientGlowFilter createGradientGlowFilter(
            GradientGlowFilterNode node)
    {
        GradientGlowFilter filter = new GradientGlowFilter();

        if (node.entries != null)
        {
            byte count = (byte)node.entries.size();
            filter.numcolors = count;
            filter.gradientColors = new int[count];
            filter.gradientRatio = new int[count];

            GradRecord[] records = createGradRecords(node.entries);
            for (int i = 0; i < records.length; i++)
            {
                GradRecord record = records[i];
                filter.gradientColors[i] = record.color;
                filter.gradientRatio[i] = record.ratio;
            }
        }

        filter.angle = TypeHelper.fixed(node.angle*Math.PI/180.0);
        filter.blurX = TypeHelper.fixed(node.blurX);
        filter.blurY = TypeHelper.fixed(node.blurY);
        filter.distance = TypeHelper.fixed(node.distance);
        filter.strength = TypeHelper.fixed8(node.strength);
        filter.flags = node.quality; // Quality encoded with 4 bits
        filter.flags |= 1 << 5; // Always a composite source
        if (node.knockout)
            filter.flags |= 1 << 6;
        if (node.inner)
            filter.flags |= 1 << 7;

        return filter;
    }

    protected void populateGradient(Gradient gradient,
            List<GradientEntryNode> entries, InterpolationMethod interpolation,
            SpreadMethod spread)
    {

        gradient.records = createGradRecords(entries);

        if (interpolation != null)
            gradient.interpolationMode = createInterpolationMode(interpolation);

        if (spread != null)
            gradient.spreadMode = createSpreadMode(spread);
    }

    protected GradRecord[] createGradRecords(List<GradientEntryNode> entries)
    {
        int count = entries.size();
        GradRecord[] records = new GradRecord[count];
        double previousRatio = 0.0;
        for (int currentIndex = 0; currentIndex < count; currentIndex++)
        {
            GradientEntryNode entry = entries.get(currentIndex);
            double thisRatio = entry.ratio;

            // Auto-calculate gradient ratio if omitted from an entry.
            if (Double.isNaN(thisRatio))
            {
                // The first ratio is assumed to be 0.0.
                if (currentIndex == 0)
                {
                    thisRatio = 0.0;
                }
                // The last ratio is assumed to be 1.0.
                else if (currentIndex == count - 1)
                {
                    thisRatio = 1.0;
                }
                else
                {
                    // Other omitted ratios are divided evenly between the last
                    // ratio and the next specified ratio (or 1.0 if none).
                    double nextRatio = 1.0;
                    int nextIndex = count - 1;
                    for (int i = currentIndex; i < count; i++)
                    {
                        GradientEntryNode nextEntry = entries.get(i);
                        if (!Double.isNaN(nextEntry.ratio))
                        {
                            nextRatio = nextEntry.ratio;
                            nextIndex = i;
                            break;
                        }
                    }

                    int entryGap = nextIndex - (currentIndex - 1);
                    if (entryGap > 0)
                    {
                        thisRatio = previousRatio + ((nextRatio - previousRatio) / (entryGap));
                    }
                    else
                    {
                        thisRatio = previousRatio;
                    }
                }
            }

            GradRecord record = new GradRecord();
            record.color = TypeHelper.colorARGB(entry.color, entry.alpha);
            record.ratio = TypeHelper.gradientRatio(thisRatio);
            records[currentIndex] = record;

            // Remember this ratio as the last one specified
            previousRatio = thisRatio;
        }

        return records;
    }

    protected String parseSource(String source)
    {
        // TODO: Create a standard @Embed() parser.
        if (source != null)
        {
            source = source.trim();

            if (source.startsWith("@Embed("))
            {
                source = source.substring(7).trim();

                if (source.endsWith(")"))
                {
                    source = source.substring(0, source.length() - 1).trim();
                }

                if (source.charAt(0) == '\'' && source.charAt(source.length() - 1) == '\'')
                {
                    source = source.substring(1, source.length() - 1).trim();
                }
            }
        }

        return source;
    }
}