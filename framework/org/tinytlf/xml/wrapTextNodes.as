package org.tinytlf.xml
{
	/**
	 * @author ptaylor
	 */
	public function wrapTextNodes(node:XML, recurse:Boolean = false):XML {
		if(node.localName() == 'text') return node;
		
		const children:XML = <_/>;
		
		for each(var child:XML in node.*) {
			if(child.localName() == 'text'){
				children.appendChild(child);
				continue;
			}
			
			else if(child.nodeKind() == 'text') {
				const content:String = child.toString();
				
				if(notWhiteSpace.test(content)) {
					children.appendChild(<text>{content}</text>);
				}
			}
			
			else if(recurse) {
				children.appendChild(wrapTextNodes(child, recurse));
			} else {
				children.appendChild(child);
			}
		}
		
		node.setChildren(children.*);
		
		return node;
	}
}

internal const notWhiteSpace:RegExp = /\S/i;