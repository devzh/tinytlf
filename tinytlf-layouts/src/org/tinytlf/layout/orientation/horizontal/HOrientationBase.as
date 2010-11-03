package org.tinytlf.layout.orientation.horizontal
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.IConstraintTextContainer;
	import org.tinytlf.layout.orientation.TextFlowOrientationBase;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	
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
	}
}