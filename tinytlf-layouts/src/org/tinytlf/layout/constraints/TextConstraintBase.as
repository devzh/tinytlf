package org.tinytlf.layout.constraints
{
	import flash.display.DisplayObject;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.layout.properties.TextFloat;
	import org.tinytlf.util.fte.ContentElementUtil;
	import org.tinytlf.util.fte.TextLineUtil;
	
	/**
	 * The base text constraint.
	 */
	public class TextConstraintBase implements ITextConstraint
	{
		public function TextConstraintBase(constraintElement:ContentElement = null)
		{
			if(constraintElement)
				initialize(constraintElement);
		}
		
		protected var engine:ITextEngine;
		protected var lp:LayoutProperties = new LayoutProperties();
		
		public function initialize(e:ContentElement):void
		{
			element = e;
			marker = e.userData;
			
			if(e is GraphicElement)
			{
				var g:GraphicElement = GraphicElement(e);
				var dObj:DisplayObject = g.graphic;
				var line:TextLine = ContentElementUtil.getTextLines(g)[0];
				engine = ITextEngine(line.userData);
				
				lp = new LayoutProperties(engine.styler.describeElement(g.userData));
				
				lp.x = line.x;
				lp.y = line.y;
				
				if(lp.float)
				{
					dObj.x = lp.paddingLeft;
					dObj.y = lp.paddingTop;
				}
				else
				{
					lp.width = dObj.width || g.elementWidth;
					lp.height = dObj.height || g.elementHeight;
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
		
		private var element:ContentElement;
		public function get content():ContentElement
		{
			return element;
		}
		
		public function get majorValue():Number
		{
			return 0;
		}
		
		public function get majorSize():Number
		{
			return 0;
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