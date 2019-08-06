package com.intigua.antlr4.autosuggest;

import org.antlr.runtime.RecognitionException;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.tool.Grammar;
import org.antlr.v4.tool.LexerGrammar;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class HarmonySQLAutoSuggestorMain {

    public static void main(String[] args){
        byte[] grammarAsBytes = null;
        try {
            grammarAsBytes = Files.readAllBytes(Paths.get("/Users/spogiri/antlr_playground/git/antlr4-autosuggest/src/test/resources/HarmonySQL.g4"));
        } catch (IOException e) {
            e.printStackTrace();
        }
        String grammarText = new String(grammarAsBytes);
        try {
            LexerGrammar lg = new LexerGrammar(grammarText);
            Grammar g = new Grammar(grammarText);
            LexerAndParserFactory factory = new LexerAndParserFactory() {

                @Override
                public Parser createParser(TokenStream tokenStream) {
                    return g.createParserInterpreter(tokenStream);
                }

                @Override
                public Lexer createLexer(CharStream input) {
                    return lg.createLexerInterpreter(input);
                }
            };
            //String input = "FROM PROFILE_TABLE SELECT * WHERE FIRST_NAME = ";
            String input = "FROM REF_TABLE_1 SELECT FIRST_NAME " ;
            AutoSuggester suggester = new AutoSuggester(factory, input);
            System.out.println("Suggestion :" + suggester.suggestCompletions());
        } catch (RecognitionException e) {
            throw new IllegalArgumentException(e);
        }
    }

}
