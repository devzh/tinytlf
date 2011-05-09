package org.tinytlf.conversion
{
	public class XMLEditableBlockFactory extends HTMLBlockFactory
	{
		public function XMLEditableBlockFactory()
		{
			super();
		}
		
		override public function preRender():void
		{
			// TODO: This is where I should re-validate any nodes that have been
			// modified by editing.
		}
	}
}
