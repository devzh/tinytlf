package org.tinytlf.layout
{
	public class TextBlockProgression
	{
		public static const BTT:String = 'bottomToTop';
		public static const TTB:String = 'topToBottom';
		public static const LTR:String = 'leftToRight';
		public static const RTL:String = 'rightToLeft';
		
		public static function isValid(value:String):Boolean
		{
			return value == TTB || value == BTT || value == LTR || value == RTL;
		}
	}
}