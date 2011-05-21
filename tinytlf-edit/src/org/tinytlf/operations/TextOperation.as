package org.tinytlf.operations
{
	import org.tinytlf.ITextEngine;
	import org.tinytlf.conversion.IHTMLNode;
	import org.tinytlf.styles.StyleAwareActor;
	
	public class TextOperation extends StyleAwareActor implements ITextOperation
	{
		public function TextOperation(props:Object = null)
		{
			super(props);
		}
		
		protected var model:IHTMLNode;
		protected var engine:ITextEngine;
		
		public function initialize(model:IHTMLNode):ITextOperation
		{
			this.model = model;
//			this.engine = model.engine;
			return this;
		}
		
		public function execute():void
		{
		}
		
		public function backout():void
		{
		}
		
		public function merge(op:ITextOperation):void
		{
			if(!(op is (this['constructor'] as Class)))
				throw new ArgumentError('Cannot merge operations of different types.');
		}
	}
}