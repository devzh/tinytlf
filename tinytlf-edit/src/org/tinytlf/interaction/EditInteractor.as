package org.tinytlf.interaction
{
	import flash.events.EventDispatcher;
	import flash.text.engine.TextLine;
	import flash.ui.*;
	
	import org.tinytlf.interaction.operations.ITextOperation;
	
	public class EditInteractor extends CascadingTextInteractor implements IEditInteractor
	{
		public function EditInteractor()
		{
			super();
			
			stack = new <ITextOperation>[];
		}
		
		override public function getMirror(element:* = null):EventDispatcher
		{
			if(element is TextLine)
			{
				var line:TextLine = element as TextLine;
				line.parent.contextMenu ||= new ContextMenu();
				
				var menu:ContextMenu = line.parent.contextMenu;
				menu.clipboardMenu = true;
				
				var items:ContextMenuClipboardItems = menu.clipboardItems;
				items.clear = true;
				items.copy = true;
				items.cut = true;
				items.paste = true;
				items.selectAll = true;
			}
			
			return super.getMirror(element);
		}
		
		private var stack:Vector.<ITextOperation>;
		private var pointer:int = -1;
		
		public function push(op:ITextOperation):ITextOperation
		{
			if(pointer != stack.length - 1)
				stack.splice(pointer, stack.length - pointer);
			
			stack.push(op);
			pointer = stack.length;
			
			return op;
		}
		
		public function undo():ITextOperation
		{
			if(pointer > 0)
				return stack[--pointer];
			
			return new NullOperation();
		}
		
		public function redo():ITextOperation
		{
			if(pointer < stack.length)
				return stack[pointer++];
			
			return new NullOperation();
		}
		
		public function clearOperations(num:int = -1):void
		{
			if(num <= -1)
				stack.length = 0;
			else
				stack.splice(stack.length - num, num);
			
			pointer = stack.length - 1;
		}
	}
}
import org.tinytlf.interaction.operations.ITextOperation;
import org.tinytlf.model.ITLFNode;

internal class NullOperation implements ITextOperation
{
	public function initialize(model:ITLFNode):ITextOperation{return this;}
	public function execute():void{}
	public function backout():void{}
	public function merge(op:ITextOperation):void{}
}