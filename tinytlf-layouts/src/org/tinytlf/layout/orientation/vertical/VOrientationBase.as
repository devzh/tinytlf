package org.tinytlf.layout.orientation.vertical
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.IConstraintTextContainer;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.layout.orientation.TextFlowOrientationBase;
	
	public class VOrientationBase extends TextFlowOrientationBase
	{
		public function VOrientationBase(target:IConstraintTextContainer)
		{
			super(target);
		}
		
		override public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			var totalHeight:Number = getTotalSize(block);
			
			if(previousLine == null)
				totalHeight -= lp.textIndent;
			
			return totalHeight - lp.paddingTop - lp.paddingBottom;
		}
		
		override public function position(line:TextLine):void
		{
			var props:LayoutProperties = TinytlfUtil.getLP(line);
			var totalHeight:Number = getTotalSize(line);
			
			var lineWidth:Number = line.width;
			var y:Number = 0;
			
			if(!line.previousLine)
				y += props.textIndent;
			
			switch(props.textAlign)
			{
				case TextAlign.LEFT:
				case TextAlign.JUSTIFY:
					y += props.paddingLeft;
					break;
				case TextAlign.CENTER:
					y = (totalHeight - lineWidth) * 0.5;
					break;
				case TextAlign.RIGHT:
					y = totalHeight - lineWidth + props.paddingRight;
					break;
			}
			
			line.y = y;
		}
		
		override protected function getTotalSize(from:Object = null):Number
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(from);
			
			if(lp.height)
				return lp.height;
			
			if(target.explicitHeight != target.explicitHeight)
				return TextLine.MAX_LINE_WIDTH;
			
			return target.explicitHeight;
		}
	}
}