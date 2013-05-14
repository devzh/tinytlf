package org.tinytlf.html
{
	import asx.array.last;
	import asx.array.map;
	import asx.fn.I;
	import asx.fn.K;
	import asx.fn.apply;
	import asx.fn.guard;
	import asx.object.merge;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineCreationResult;
	
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.wrapTextNodes;
	
	import raix.interactive.Enumerable;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	import trxcllnt.ds.HRTree;

	public class Paragraph extends Block implements TTLFContainer
	{
		public function Paragraph(node:XML)
		{
			super(node);
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="inline")]
		public var createElement:Function;
		
		private const _cache:HRTree = new HRTree();
		public function get cache():HRTree {
			return _cache;
		}
		
		override public function set children(value:Array):void {
			unflatten();
			
			// TODO: Object pool this shit.
			
			const lineHeight:Number = getStyle('lineHeight') || 0;
			
			super.children = map(value, function(line:TextLine):Image {
				
				const data:BitmapData = new BitmapData(line.specifiedWidth, Math.ceil(Math.max(lineHeight, line.textHeight)));
				
				const mtx:Matrix = new Matrix();
				mtx.createBox(1, 1, 0, 0, line.ascent);
				data.draw(line, mtx);
				
				const image:Image = new Image(Texture.fromBitmapData(data, false, true));
				image.x = line.x;
				image.y = line.y;
				return image;
			});
			
			flatten();
		}
		
		private var lastWidth:Number = 0;
		
		override public function update(value:XML, viewport:Rectangle):Boolean {
			
			if(lastWidth == viewport.width) return true;
			
			merge(styles, css.lookup(readKey(value)));
			
			// TODO: Refactor this to use a static TextBlock and TextLine, to
			// pull the TextLine's BitmapData immediately, and only render the
			// lines in the viewport.
			const block:TextBlock = new TextBlock(createElement(wrapTextNodes(value)));
			
			const lineHeight:Number = getStyle('lineHeight');
			const textIndent:Number = getStyle('textIndent') || 0;
			
			children = Enumerable.generate(0, K(true), I, I).
				scan([0, null], guard(apply(function(h:Number, last:TextLine):Array {
					
					const w:Number = last == null ? viewport.width - textIndent : viewport.width;
					const line:TextLine = block.createTextLine(last, w);
					
					if(line) {
						
						line.y = h;
						
						if(line.previousLine == null) line.x = textIndent;
						
						if(lineHeight == lineHeight) return [h + lineHeight, line];
						
						return [h + line.textHeight, line];
					}
					
					return [h, null];
				}))).
				map(last).
				takeWhile(function(line:TextLine):Boolean {
					return line != null && block.textLineCreationResult != TextLineCreationResult.COMPLETE;
				}).
				toArray();
			
			lastWidth = viewport.width;
			
			return true;
		}
	}
}