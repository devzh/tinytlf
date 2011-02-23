package org.tinytlf.layout.orientation.horizontal
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineValidity;
	import flash.utils.Dictionary;
	
	import org.tinytlf.layout.IConstraintTextContainer;
	import org.tinytlf.layout.orientation.TextFlowOrientationBase;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextBlockUtil;
	
	/**
	 * The base class for the IMajorOrientation and IMinorOrientation classes
	 * for horizontal-based languages. Languages which are left-to-right
	 * (typically the Romance languages) or right-to-left (Hebrew, Arabic, etc.)
	 * use either the LTR or RTL major orientations for their horizontal
	 * alignment and spacing, but rely on the same (vertical) minor orientation.
	 */
	public class HOrientationBase extends TextFlowOrientationBase
	{
		public function HOrientationBase(target:IConstraintTextContainer)
		{
			super(target);
		}
		
		override public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			var totalWidth:Number = getTotalSize(block);
			
			if(previousLine == null)
				totalWidth -= lp.textIndent;
			
			return totalWidth - lp.paddingLeft - lp.paddingRight;
		}
		
		override public function position(line:TextLine):void
		{
			var props:LayoutProperties = TinytlfUtil.getLP(line);
			var totalWidth:Number = getTotalSize(line);
			
			var lineWidth:Number = line.width;
			var x:Number = 0;
			
			if(!line.previousLine)
				x += props.textIndent;
			
			switch(props.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					x += props.paddingLeft;
					break;
				case TextAlign.CENTER:
					x = (totalWidth - lineWidth) * 0.5;
					break;
				case TextAlign.RIGHT:
					x = totalWidth - lineWidth + props.paddingRight;
					break;
			}
			
			line.x = x;
		}
		
		override protected function getTotalSize(from:Object = null):Number
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(from);
			
			if(lp.width)
				return lp.width;
			
			if(target.explicitWidth != target.explicitWidth)
				return TextLine.MAX_LINE_WIDTH;
			
			return target.explicitWidth;
		}
		
		private const importantLines:Vector.<TextLine> = new <TextLine>[];
		
		override public function checkTargetBounds(latestLine:TextLine):Boolean
		{
			if(super.checkTargetBounds(latestLine))
				return true;
			
			importantLines.push(latestLine);
			
			return false;
		}
		
		override public function postTextBlock(block:TextBlock):void
		{
			super.postTextBlock(block);
			
			var props:LayoutProperties = TinytlfUtil.getLP(block);
			var info:TextBlockInfo = new TextBlockInfo(block);
			
			if(target.hasLine(block.firstLine))
				props.height = 0;
			
			var lines:Vector.<TextLine> = info.lines;
			for(var i:int = 0, n:int = lines.length; i < n; i += 1)
			{
				props.height += lines[i].height + props.leading;
			}
		}
		
		override public function postLayout():void
		{
			super.postLayout();
			
			//Attempt to calculate the measured height of the target container.
			
			var measuredHeight:Number = 0;
			
			// A dictionary of blocks, but also stores the number of lines
			// from each block that exist in this container.
			var blocks:Dictionary = new Dictionary(true);
			var info:TextBlockInfo;
			var block:TextBlock;
			var props:LayoutProperties;
			
			for(var i:int = 0, n:int = importantLines.length; i < n; i += 1)
			{
				if(importantLines[i].validity != TextLineValidity.VALID)
					continue;
				
				block = importantLines[i].textBlock;
				
				if(block in blocks)
					continue;
				
				blocks[block] = true;
				
				info = new TextBlockInfo(block);
				props = info.props;
				
				if(target.hasLine(block.firstLine))
					measuredHeight += props.paddingTop;
				
				if(info.rendered && target.hasLine(block.lastLine))
					measuredHeight += props.paddingBottom;
				
				measuredHeight += props.height;
			}
			
			target.measuredHeight = measuredHeight;
			
			//Don't hold onto these lines, they will be reused later.
			importantLines.length = 0;
		}
	}
}

import flash.text.engine.*;

import org.tinytlf.layout.properties.LayoutProperties;
import org.tinytlf.util.TinytlfUtil;
import org.tinytlf.util.fte.TextBlockUtil;

internal class TextBlockInfo
{
	public function TextBlockInfo(block:TextBlock)
	{
		_rendered = !TextBlockUtil.isInvalid(block);
		lp = TinytlfUtil.getLP(block);
		
		var line:TextLine = block.firstLine;
		while(line)
		{
			++allLines;
			textLines.push(line);
			line = line.nextLine;
		}
	}
	
	private const textLines:Vector.<TextLine> = new <TextLine>[];
	
	public function get lines():Vector.<TextLine>
	{
		return textLines.concat();
	}
	
	private var lineCount:int = 0;
	public function get numLines():int
	{
		return lineCount;
	}
	
	public function set numLines(value:int):void
	{
		lineCount = value;
	}
	
	private var allLines:int = 0;
	public function get totalLines():int
	{
		return allLines;
	}
	
	private var _rendered:Boolean = false;
	public function get rendered():Boolean
	{
		return _rendered;
	}
	
	private var lp:LayoutProperties;
	public function get props():LayoutProperties
	{
		return lp;
	}
}