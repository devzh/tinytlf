package org.tinytlf.fn
{
	/**
	 * @author ptaylor
	 */
	public function wrapTextNodes(node:XML, recurse:Boolean = false):XML {
		if(node.localName() == 'text') return node;
		
		for each(var child:XML in node.*) {
			if(child.localName() == 'text') continue;
			
			else if(child.nodeKind() == 'text') {
				const content:String = child.toString();
				
				if(notWhiteSpace.test(content)) {
					node.replace(child.childIndex(), <text>{content}</text>);
				} else {
					node.replace(child.childIndex(), '');
				}
			}
			
			else if(recurse) wrapTextNodes(child, recurse);
		}
		
		return node;
	}
}

internal const notWhiteSpace:RegExp = /\S/i;