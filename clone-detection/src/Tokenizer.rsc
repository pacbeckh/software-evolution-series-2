module Tokenizer

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;

//TODO Candiate to delete


data Token = assignmentToken() | var() | operator(str op) | ifToken()| blockOpen()| blockEnd()
			| returnToken();

data TokenInfo = tokenInfo(int length);
data VarInfo = varInfo();

anno VarInfo Token@varInfo;
anno TokenInfo Token@tokenInfo;

public list[Token] run() {
	loc projectLoc = |project://hello-world-java/src/nl/simple|;
	M3 model = createM3FromEclipseProject(projectLoc);
	
	for (m <- methods(model), /\/DuplicationWithOneLineRemoved\// := m.path) {
		Declaration d = getMethodASTEclipse(m, model = model);
		iprintln("");
		iprintln("Foo");
		iprintln(m);
		iprintln(tokenize(d));
	}
}

public list[Token] tokenize(value d) {
	//iprintln(d);
	list[Token] front = [];
	list[Token] end = [];
	
	top-down-break visit(d) {
		case \block(sts) : {
			front += blockOpen();
			front += tokenize(sts);
			end = blockEnd() + end;
		}
		case \if(c,t): {
			nt =  tokenize(t);
			f = ifToken();
			f@tokenInfo = tokenInfo(size(nt));
			front = f + nt;
		}
		case \infix(l,op,r): {
			front += tokenWithInfoForRest(
				operator(op),
				[tokenize(l), tokenize(r)]
			);
		}
		case \assignment(l, op, r): {
			front += tokenWithInfoForRest(
				assignmentToken(),
				[tokenize(l), tokenize(r)]
			);
		}
		case \number(n): {
			front += var();
		}
		case \simpleName(_): {
			front += var();
		}
		case \return(e): {
			front += tokenWithInfoForRest(returnToken(), [tokenize(e)]);
		}
		
	}
	return front + end;
}

public list[Token] tokenWithInfoForRest(Token t, list[list[Token]] rest) {
	int s = (0 | it + size(r)| r<-rest);
	t@tokenInfo = tokenInfo(s);
	return t + [*r | r<-rest];
}