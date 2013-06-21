package org.tinytlf.css.matchers
{
	/**
	 * @author ptaylor
	 */
	public function getMatcher(next:Function, token:String):Function {
		
		// Shortcut for the wildcard token.
		if(token == '*' ) return next;
		
		const id:Object = (/#/).exec(token);
		const cl:Object = (/\./).exec(token);
		
		var ids:String = '';
		var cls:String = '';
		var name:String = '';
		
		// TODO: Support pseudo-class matchers:
		// :hover
		// :active
		// :nth-child(predicate)
		// :not(predicate)
		// etc.
		
		// Token has a class, an ID, and maybe a name.
		if(cl && id) {
			
			ids = id.index < cl.index ?
				token.substring(id.index + 1, cl.index) :
				token.substring(id.index + 1);
			cls = cl.index < id.index ?
				token.substr(cl.index + 1, id.index) :
				token.substring(cl.index + 1);
			
			name = token.substring(0, Math.min(id.index, cl.index));
			
			// see if the id & class name are attached to an element name.
			return (id.index > 0 && cl.index > 0) ?
				namedWithClassAndID(name, cls, ids, next) :
				classedWithID(ids, cls, next);
		}
		
		// Token has an ID, no class, and maybe a name.
		if(id) {
			// has ID but no class attached.
			ids = token.substring(id.index + 1);
			name = token.substring(0, id.index);
			
			return (id.index > 0) ?
				namedWithID(name, cls, next) :
				withID(ids, next);
		}
		
		// Token has a class name, no ID, and maybe a name.
		if(cl) {
			cls = token.substr(cl.index + 1);
			name = token.substr(0, cl.index);
			
			return (cl.index > 0) ?
				namedWithClass(name, cls, next) :
				classed(cls, next);
		}
		
		// Token is just a name.
		return named(token, next);
	}
}