package org.tinytlf.html
{
	import asx.array.last;
	import asx.array.map;
	import asx.array.max;
	import asx.array.pluck;
	import asx.fn.I;
	import asx.fn.K;
	import asx.fn.apply;
	import asx.fn.guard;
	import asx.number.sum;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineCreationResult;
	
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.events.validateEvent;
	
	import raix.interactive.Enumerable;
	
	import starling.display.Image;
	import starling.textures.Texture;

	public class Paragraph extends Block implements TTLFContainer
	{
		public function Paragraph()
		{
			super();
		}
		
		public function get renderedWidth():Number {
			return width;
		}
		
		public function get renderedHeight():Number {
			return height;
		}
		
		// NOTE: I'm not actually using SwiftSuspenders to inject this value,
		// I'm just annotating it so people know this function isn't magic.
		[Inject(name="inline")]
		public var createElement:Function;
		
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
		
		override public function set viewport(value:Rectangle):void {
			if(value.width != viewport.width)
				invalidate('cached');
			
			super.viewport = value;
		}
		
		override protected function draw():void {
			
			const node:XML = XML(content);
			
			// TODO: Refactor this to use a static TextBlock and TextLine, to
			// pull the TextLine's BitmapData immediately, and only render the
			// lines in the viewport.
			const block:TextBlock = new TextBlock(createElement(node));
			
			const lineHeight:Number = getStyle('lineHeight');
			const leading:Number = getStyle('leading') || 0;
			const textIndent:Number = getStyle('textIndent') || 0;
			
			children = Enumerable.generate(0, K(true), I, I).
				scan([0, null], guard(apply(function(h:Number, last:TextLine):Array {
					
					const w:Number = last == null ? viewport.width - textIndent : viewport.width;
					const line:TextLine = block.createTextLine(last, w);
					
					if(line) {
						
						line.y = h;
						
						if(line.previousLine == null) line.x = textIndent;
						
						if(lineHeight == lineHeight) return [h + lineHeight + leading, line];
						
						return [h + line.textHeight + leading, line];
					}
					
					return [h, null];
				}))).
				map(last).
				takeWhile(function(line:TextLine):Boolean {
					return line != null && block.textLineCreationResult != TextLineCreationResult.COMPLETE;
				}).
				toArray();
			
			const w:Number = max(children, 'width') as Number;
			const h:Number = sum(pluck(children, 'height')) + (leading * (numChildren - 1));
			
			setSizeInternal(w, h, false);
			
			dispatchEvent(validateEvent(true));
		}
	}
}