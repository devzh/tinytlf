package org.tinytlf.html
{
	import asx.array.last;
	import asx.array.map;
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
	import flash.text.engine.TextLineValidity;
	
	import org.tinytlf.TTLFContainer;
	import org.tinytlf.events.renderEvent;
	
	import raix.interactive.Enumerable;
	
	import starling.display.Image;
	import starling.textures.Texture;

	public class PerfParagraph extends Block implements TTLFContainer
	{
		public function PerfParagraph()
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
			
			super.children = value;
			
			flatten();
		}
		
		private static const block:TextBlock = new TextBlock();
		private static const mtx:Matrix = new Matrix();
		private static const images:Array = [];
		private static var staticLine:TextLine;
		
		override protected function draw():void {
			
			const node:XML = XML(content);
			
			block.content = createElement(node);
			
			images.length = 0;
			
			const inner:Rectangle = innerBounds;
			const lineHeight:Number = getStyle('lineHeight');
			const leading:Number = getStyle('leading') || 0;
			const textIndent:Number = (getStyle('textIndent') || 0) + inner.x;
			
			var prev:TextLine = null;
			var x:Number = 0;
			var y:Number = inner.y;
			
			while(block.textLineCreationResult != TextLineCreationResult.COMPLETE) {
				
				const w:Number = (block.firstLine == null) ? inner.width - textIndent : inner.width;
				
				const line:TextLine = staticLine ?
					block.recreateTextLine(staticLine, prev, w) :
					block.createTextLine(prev, w);
				
				if(line) {
					line.y = y;
					
					if(line.previousLine == null) line.x = textIndent;
					else line.x = inner.x;
					
					const bmd:BitmapData = new BitmapData(
						Math.ceil(line.specifiedWidth), 
						Math.ceil(Math.max(lineHeight || 0, line.textHeight))
					);
					mtx.createBox(1, 1, 0, 0, line.ascent);
					bmd.draw(line, mtx);
					
					const image:Image = new Image(Texture.fromBitmapData(bmd, false, true));
					image.x = line.x;
					image.y = line.y;
					images.push(image);
					
					y = lineHeight == lineHeight ? 
						y + lineHeight + leading :
						y + line.textHeight + leading;
					
					if(line.previousLine) {
						staticLine = line.previousLine;
						 staticLine.validity = TextLineValidity.STATIC;
					}
				}
				
				prev = line;
			}
			
			block.releaseLineCreationData();
			staticLine = null;
			
			children = images;
			
			super.size(width, calcHeight());
			
			dispatchEvent(renderEvent(true));
		}
		
		override public function size(w:Number, h:Number):void {
			if(w != width) {
				invalidate('cached');
			} else if(h != height) {
				h = calcHeight();
			}
			
			super.size(w, h);
		}
		
		private function calcHeight():Number {
			
			const lineHeight:Number = getStyle('lineHeight');
			const leading:Number = getStyle('leading') || 0;
			
			const spaces:Number = (leading * (numChildren - 1));
			
			if(lineHeight == lineHeight) {
				return (Math.max(children.length, 1) * lineHeight) + leading;
			}
			
			return sum(pluck(children, 'height')) + leading;
		}
	}
}