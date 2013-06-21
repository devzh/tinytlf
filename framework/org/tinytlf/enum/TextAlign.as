package org.tinytlf.enum
{
	/**
	 * @author ptaylor
	 */
	public final class TextAlign
	{
		public static const LEFT:String = 'left';
		public static const CENTER:String = 'center';
		public static const RIGHT:String = 'right';
		public static const JUSTIFY:String = 'justify';
		
		public static function isValid(value:String):Boolean
		{
			return value == LEFT || value == CENTER || value == RIGHT || value == JUSTIFY;
		}
		
		public static function throwArgumentError(value:String):void
		{
			throw new ArgumentError('TextAlign ' + value + ' is invalid.');
		}
	}
}