package org.tinytlf.utils
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
                obj[attr.localName()] = attr.toString();
            }

            return obj;
        }
    }
}