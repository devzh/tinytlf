package org.tinytlf.conversion
{
    import flash.text.engine.ContentElement;
    
    import org.tinytlf.util.fte.ContentElementUtil;
    
    public class HTMLListAdapter extends XMLElementFactory
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
			//Continue parsing the children
            var listElement:ContentElement = super.execute.apply(null, [data].concat(context));
            
			if(data is XML)
			{
				return ContentElementUtil.lineBreakBefore(listElement);
			}
			else
			{
				return listElement;
			}
        }
    }
}