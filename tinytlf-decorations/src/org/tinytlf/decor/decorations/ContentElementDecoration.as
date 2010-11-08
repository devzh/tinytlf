package org.tinytlf.decor.decorations
{
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.FontMetrics;
	import flash.text.engine.TextLineMirrorRegion;
	
	import org.tinytlf.decor.TextDecoration;
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class ContentElementDecoration extends TextDecoration
	{
		public function ContentElementDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function setup(layer:int = 2, ... parameters):Vector.<Rectangle>
		{
			if(parameters.length < 1)
				return super.setup.apply(null, [layer, foreground].concat(parameters));
			
			var arg:* = parameters[0];
			if(!(arg is ContentElement))
				return super.setup.apply(null, [layer].concat(parameters));
			
			processContentElement(ContentElement(arg));
			
			var bounds:Vector.<Rectangle> = new Vector.<Rectangle>();
			var tlmrs:Vector.<TextLineMirrorRegion> = ContentElementUtil.getMirrorRegions(ContentElement(arg));
			var n:int = tlmrs.length;
			
			var tlmr:TextLineMirrorRegion;
			var rect:Rectangle;
			
			for(var i:int = 0; i < n; ++i)
			{
				tlmr = tlmrs[i];
				rect = processTLMR(tlmr);
				rectToContainer[rect] = ensureLayerExists(engine.layout.getContainerForLine(tlmr.textLine), layer);
				bounds.push(rect);
			}
			
			return bounds;
		}
		
		protected var emBox:Rectangle;
		
		protected function processContentElement(element:ContentElement):void
		{
			var metrics:FontMetrics = element.elementFormat.getFontMetrics();
			emBox = metrics.emBox;
		}
		
		protected function processTLMR(tlmr:TextLineMirrorRegion):Rectangle
		{
			return null;
		}
	}
}