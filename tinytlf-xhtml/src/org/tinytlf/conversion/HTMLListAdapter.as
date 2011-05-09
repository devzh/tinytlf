package org.tinytlf.conversion
{
    import flash.text.engine.ContentElement;
    
    import org.tinytlf.util.fte.ContentElementUtil;
    
    public class HTMLListAdapter extends HTMLNodeElementFactory
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
			//Continue parsing the children
            var listElement:ContentElement = super.execute.apply(null, [data].concat(context));
            
			return (data is XML) ? 
				ContentElementUtil.lineBreakBefore(listElement) :
				listElement;
        }
    }
}