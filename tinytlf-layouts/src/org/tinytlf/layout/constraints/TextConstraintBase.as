package org.tinytlf.layout.constraints
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.text.engine.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.util.fte.ContentElementUtil;
	
	/**
	 * The base text constraint.
	 */
	public class TextConstraintBase implements ITextConstraint
	{
		public function TextConstraintBase(constraintElement:* = null)
		{
			if(constraintElement)
				initialize(constraintElement);
		}
		
		protected var engine:ITextEngine;
		protected var lp:LayoutProperties;
		
		public function initialize(e:*):void
		{
			element = e;
			
			if(e is ContentElement)
			{
				marker = ContentElement(e).userData;
			}
			
			if(e is GraphicElement)
			{
				var g:GraphicElement = GraphicElement(e);
				var dObj:DisplayObject = g.graphic;
				var line:TextLine = ContentElementUtil.getTextLines(g)[0];
				engine = ITextEngine(line.userData);
				
				lp = new LayoutProperties(g.userData);
				
				lp.x = line.x;
				lp.y = line.y;
				
				if(lp.float)
				{
					dObj.x = lp.paddingLeft;
					dObj.y = lp.paddingTop;
				}
				else
				{
					var bounds:Rectangle = dObj.getBounds(line);
					
					lp.x = bounds.x;
					lp.y = line.y;
					lp.width = bounds.width || g.elementWidth;
					lp.height = bounds.height || g.elementHeight;
				}
			}
		}
		
		private var marker:Object;
		public function get constraintMarker():Object
		{
			return marker;
		}
		
		public function get float():String
		{
			return lp.float;
		}
		
		private var element:*;
		public function get content():*
		{
			return element;
		}
		
		public function get majorValue():Number
		{
			return 0;
		}
		
		public function set majorValue(value:Number):void
		{
		}
		
		public function get majorSize():Number
		{
			return 0;
		}
		
		public function set majorSize(value:Number):void
		{
		}

		public function getMajorValue(atMinor:Number, fromMajor:Number):Number
		{
			return -1;
		}
		
		protected function get totalWidth():Number
		{
			return lp.width + lp.paddingLeft + lp.paddingRight;
		}
		
		protected function get totalHeight():Number
		{
			return lp.height + lp.paddingTop + lp.paddingBottom;
		}
	}
}