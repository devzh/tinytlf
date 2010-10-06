package org.tinytlf.layout
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineCreationResult;
	import flash.text.engine.TextLineValidity;
	
	import org.tinytlf.layout.direction.IFlowDirectionDelegate;
	import org.tinytlf.layout.direction.LTRHorizontalDirectionDelegate;
	
	public class TextFlowContainer extends TextContainerBase implements IFlowLayout
	{
		public function TextFlowContainer(container:Sprite, explicitWidth:Number = NaN, explicitHeight:Number = NaN)
		{
			super(container, explicitWidth, explicitHeight);
			
			delegate = new LTRHorizontalDirectionDelegate(this);
			elementFactory = new LayoutElementFactory();
		}
		
		override public function preLayout():void
		{
			super.preLayout();
			
			height = 0;
			width = 0;
			elements.length = 0;
			
			removeOrphanedLines();
			
			delegate.preLayout();
		}
		
		override public function layout(block:TextBlock, oldLine:TextLine):TextLine
		{
			delegate.prepForTextBlock(block, oldLine);
			
			var line:TextLine;
			
			// oldLine can be the previously successfully created line or the 
			// first line in a TextBlock that has been invalidated.
			if(oldLine && oldLine.validity == TextLineValidity.VALID && hasLine(oldLine))
				line = oldLine;
			else
				line = createTextLine(block, oldLine);
			
			while(line)
			{
				addLineToTarget(line);
				
				registerLine(line);
				
				delegate.layoutLine(line);
				
				if(delegate.checkTargetConstraints(line))
				{
					removeOrphanedLines();
					return line;
				}
				
				line = createTextLine(block, line);
			}
			
			removeOrphanedLines();
			
			return null;
		}
		
		override protected function createTextLine(block:TextBlock, line:TextLine):TextLine
		{
			var size:Number = delegate.getLineSize(block, line);
			
			if(line)
			{
				//If this line is invalid, recreate him.
				//This will be true if we're re-creating invalid lines,
				//not rendering all new lines
				if(line.validity === TextLineValidity.INVALID)
				{
//					trace('invalid');
					size = delegate.getLineSize(block, line.previousLine);
					return block.recreateTextLine(line, line.previousLine, size, 0.0, true);
				}
				// Otherwise, if the line is valid, it's acting as a marker for
				// where to render the next line. If there's a valid nextLine, 
				// return it. If the next line isn't valid, recreate it. 
				// If there's no nextLine at all, attempt to continue creating
				// lines.
				else if(line.nextLine)
				{
					if(line.nextLine.validity === TextLineValidity.VALID)
						return line.nextLine;
					
//					trace('next');
					return block.recreateTextLine(line.nextLine, line, size, 0.0, true);
				}
				if(orphanedLines.length)
				{
					var orphan:TextLine = getFirstOrphan(line);
					
					while(orphan && orphan.validity == TextLineValidity.VALID)
					{
						orphan = getFirstOrphan(line);
					}
					
					if(orphan)
					{
//						trace('orphan');
						return block.recreateTextLine(orphan, line, size, 0.0, true);
					}
				}
			}
			
//			trace('new');
			return block.createTextLine(line, size, 0.0, true);
		}
		
		private var delegate:IFlowDirectionDelegate;
		
		public function set direction(directionDelegate:IFlowDirectionDelegate):void
		{
			if(directionDelegate === delegate)
				return;
			
			delegate = directionDelegate;
			delegate.target = this;
		}
		
		public function get direction():IFlowDirectionDelegate
		{
			return delegate;
		}
		
		private var _elementFactory:ILayoutElementFactory;
		
		public function set elementFactory(factory:ILayoutElementFactory):void
		{
			if(factory === _elementFactory)
				return;
			
			_elementFactory = factory;
		}
		
		public function get elementFactory():ILayoutElementFactory
		{
			return _elementFactory;
		}
		
		private var _elements:Vector.<IFlowLayoutElement>;
		
		public function get elements():Vector.<IFlowLayoutElement>
		{
			return _elements ||= new Vector.<IFlowLayoutElement>;
		}
		
		public function set elements(value:Vector.<IFlowLayoutElement>):void
		{
			if(value === _elements)
				return;
			
			_elements = value;
		}
		
		override protected function registerLine(line:TextLine):void
		{
			super.registerLine(line);
			
			associateLayoutElements(line);
		}
		
		override protected function unregisterLine(line:TextLine):void
		{
			super.unregisterLine(line);
			
			deAssociateLayoutElements(line);
		}
		
		protected function associateLayoutElements(line:TextLine):void
		{
			if(!line.hasGraphicElement)
				return;
			
			var n:int = line.atomCount;
			
			//this might be my favorite loop ever
			for(var i:int = 0; i < n; ++i)
				if(line.getAtomGraphic(i))
					if(delegate.registerFlowElement(line, i))
						return;
		}
		
		protected function deAssociateLayoutElements(line:TextLine):void
		{
			if(!line.hasGraphicElement)
				return;
			
			var n:int = elements.length;
			var tmp:Vector.<IFlowLayoutElement> = elements.concat();
			
			for(var i:int = 0; i < n; ++i)
				if(elements[i].textLine === line)
					tmp.splice(tmp.indexOf(elements[i]), 1);
			
			elements = tmp;
		}
		
		protected function removeOrphanedLines():void
		{
			var line:TextLine;
			var n:int = lines.length;
			
			for(var i:int = 0; i < n; ++i)
			{
				line = lines[i];
				
				if(line.validity === TextLineValidity.VALID)
					continue;
				
				removeLineFromTarget(line);
				unregisterLine(line);
				orphanedLines.push(line);
				n = lines.length;
			}
		}
		
		private static const orphanedLines:Vector.<TextLine> = new <TextLine>[];
		
		private static function getFirstOrphan(thatIsNotThisGuy:TextLine):TextLine
		{
			if(orphanedLines.length == 0)
				return null;
			
			var orphan:TextLine = orphanedLines.pop();
			
			if(thatIsNotThisGuy != null)
				while(orphan == thatIsNotThisGuy)
					orphan = orphanedLines.pop();
			
			return orphan;
		}
	}
}

import flash.text.engine.ContentElement;
import flash.text.engine.TextLine;

import org.tinytlf.layout.FlowLayoutElement;
import org.tinytlf.layout.IFlowLayoutElement;
import org.tinytlf.layout.ILayoutElementFactory;
import org.tinytlf.util.fte.TextLineUtil;

internal class LayoutElementFactory implements ILayoutElementFactory
{
	public function getLayoutElement(line:TextLine, atomIndex:int):IFlowLayoutElement
	{
		var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
		return new FlowLayoutElement(element, line);
	}
}
