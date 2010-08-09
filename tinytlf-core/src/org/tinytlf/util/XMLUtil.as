package org.tinytlf.util
{
    public class XMLUtil
    {
        public static function buildKeyValueAttributes(attributes:XMLList):Object
        {
            var obj:Object = {};
            var n:int = attributes.length();
            var attr:XML;

            for (var i:int = 0; i < n; ++i)
            {
                attr = attributes[i];
                obj[toCamelCase(attr.localName())] = toCamelCase(attr.toString());
            }

            return obj;
		}
		
		/**
		 * Converts a string from underscore or dash separators
		 * to lower camelCase.
		 */
		public static function toCamelCase(str:String):String
		{
			var s:String = str.replace(/(-|_)(\w)/g, function(...args):String{
				return String(args[2]).toUpperCase();
			});
			
			return s.replace(/(-|_)/g, '');
		}
        
        public static function arrayToString(array:Array):String
        {
            var s:String = '';
            var n:int = array.length;
            for(var i:int = 0; i < n; ++i)
            {
                if(array[i] is XML || array[i] is XMLList)
                    s += toCamelCase(array[i].toXMLString());
                else
                    s += toCamelCase(array[i].toString());
            }
            
            return s;
        }
    }
}