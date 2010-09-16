package org.tinytlf.layout
{
	import flash.display.Sprite;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.direction.IFlowDirectionDelegate;
	import org.tinytlf.layout.direction.LTRHorizontalDirectionDelegate;
	
	public class TextFlowContainer extends TextContainerBase implements IFlowLayout
	{
		public function TextFlowContainer(container:Sprite, explicitWidth:Number=NaN, explicitHeight:Number=NaN)
		{
			super(container, explicitWidth, explicitHeight);
			
			delegate = new LTRHorizontalDirectionDelegate(this);
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
		
		override public function layout(block:TextBlock, previousLine:TextLine):TextLine
		{
			delegate.prepForTextBlock(block);
			
			var line:TextLine = createTextLine(block, previousLine);
			
			while(line)
			{
				addLineToTarget(line);
				
				registerLine(line);
				
				delegate.layoutLine(line);
				
				if(delegate.checkTargetConstraints())
					return line;
				
				line = createTextLine(block, line);
			}
			
			return null;
		}
		
		override protected function createTextLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			var size:Number = delegate.getLineSize(block, previousLine);
			return block.createTextLine(previousLine, size, 0.0, true);
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
			var n:int = elements.length;
			var tmp:Vector.<IFlowLayoutElement> = elements.concat();
			
			for(var i:int = 0; i < n; ++i)
				if(elements[i].textLine === line)
					tmp.splice(tmp.indexOf(elements[i]), 1);
			
			elements = tmp;
		}
	}
}