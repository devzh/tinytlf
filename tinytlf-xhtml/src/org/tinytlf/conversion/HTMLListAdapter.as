package org.tinytlf.conversion
{
    import flash.text.engine.ContentElement;
    
    import org.tinytlf.model.ITLFNode;
    import org.tinytlf.util.fte.ContentElementUtil;
    
    public class HTMLListAdapter extends TLFNodeElementFactory
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
			//Continue parsing the children
            var listElement:ContentElement = super.execute.apply(null, [data].concat(context));
            
			return (data is ITLFNode) ? 
				ContentElementUtil.lineBreakBefore(listElement) :
				listElement;
        }
    }
}