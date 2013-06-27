package org.tinytlf.xml
{
	/**
	 * @author ptaylor
	 */
	public function wrapTextNodes(node:XML, recurse:Boolean = false, shrinkWhiteSpace:Boolean = true, textNodeNames:Array = null):XML {
		
		if(textNodeNames == null) textNodeNames = [];
		if(textNodeNames.length == 0) textNodeNames.push('text');
		if(textNodeNames.indexOf(node.localName()) > -1) return node;
		
		const children:XML = <_/>;
		var content:String = '';
		var name:String = '';
		
		for each(var child:XML in node.*) {
			
			name = child.localName();
			
			if(textNodeNames.indexOf(name) > -1) {
				content = child.toString();
				if(notOnlyWhiteSpace.test(content)) {
					children.appendChild(child);
				} else {
					delete child.*[0];
					children.appendChild(child);
				}
			} else if(child.nodeKind() == 'text') {
				content = child.toString().replace(whiteSpaceMatcher, shrinkWhiteSpace ? '' : ' ');
				
				// If the first character is a space, lop that off as well.
				content = whiteSpaceMatcher.test(content.charAt(0)) ? content.substr(1) : content;
				
				if(notOnlyWhiteSpace.test(content)) children.appendChild(<text>{content}</text>);
				
			} else if(recurse) {
				children.appendChild(wrapTextNodes.apply([child, recurse, shrinkWhiteSpace].concat(textNodeNames)));
			} else {
				children.appendChild(child);
			}
		}
		
		node.setChildren(children.*);
		
		return node;
	}
}

internal const whiteSpaceMatcher:RegExp = /(\s+){2,3855}+/igs;
internal const notOnlyWhiteSpace:RegExp = /\S/i;