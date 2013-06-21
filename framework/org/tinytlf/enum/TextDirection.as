package org.tinytlf.enum
{
	public class TextDirection
	{
		public static const LTR:String = "ltr";
		public static const RTL:String = "rtl";
		
		public static function isValid(value:String):Boolean
		{
			return value == LTR || value == RTL;
		}
	}
}