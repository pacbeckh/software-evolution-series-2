module DataFlowFlattener

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;


//TODO Candiate to delete

data StatementNode = statementRef(Statement statement) |
					 beginBlockNode() |
			 		 endBlockNode();
			 		 
public list[StatementNode] flatten(Statement s) {
	list[StatementNode] res = [];
	//iprintln("1");
	top-down-break visit(s) {
		case \block(sts): {
			//iprintln("In block");
			res += beginBlockNode();
			//iprintln(size(sts));
			for(i <- sts) {
				//iprintln("STS OF block");	
				res += flatten(i);
			}
			res += endBlockNode();
		}
		case \try(b, cts): {
			res += statementRef(\try(\block([]), []));
			res += beginBlockNode();
			res += flatten(b);
			res += endBlockNode();
			for (i <- cts) {
				res += flatten(i);
			}
		}
		case \try(b, cts,f): {
			res += statementRef(\try(\block, [], \block([])));
			res += beginBlockNode();
			res += flatten(b);
			res += endBlockNode();
			for (i <- cts) {
				res += flatten(i);
			}
			res += beginBlockNode();
			res += flatten(f);
			res += endBlockNode();
		}
		case \switch(e, sts) : {
			res += statementRef(\switch(e, []));
			for (i <- sts) {
				res += flatten(i);
			}
		}
		case \while(c,b) : {
			res += statementRef(\while(c,\block([])));
			res += flatten(b);
		}
		case \for(i, u, b) : {
			res += statementRef(\for(i,u,\block([])));
			res += flatten(b);
		}
		case \for(i, c, u, b) : {
			res += statementRef(\for(i,c,u,\block([])));
			res += flatten(b);
		}
		case \foreach(p, c, b) : {
			res += statementRef(\foreach(p, c, \block([])));
			res += flatten(e);
		}
		case \do(b, e) : {
			res += statementRef(\do(\block([]), e));
			res += flatten(e);
		} 
		case \if(ex,t,e): {
			res += statementRef(\if(ex, \block([]), \block([])));
			res += flatten(t);
			res += flatten(e);
		}
		case \if(e,t): {
			res += statementRef(\if(e, \block([])));
			res += flatten(t);
		}
		case Statement s: {
			//println("3 <s>");
			res += statementRef(s);
		}
	};
	return res;
}

