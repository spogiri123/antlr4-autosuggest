package com.intigua.antlr4.autosuggest;

import org.antlr.runtime.RecognitionException;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.tool.Grammar;
import org.antlr.v4.tool.LexerGrammar;
import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Collection;

import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.junit.Assert.assertThat;

public class HarmonySQLAutoSuggesterTest {

    private final static String DEFAULT_LOG_LEVEL = "WARN";
    private static LexerAndParserFactory lexerAndParserFactory;
    private Collection<String> suggestedCompletions;
    private CasePreference casePreference = null;

    @BeforeClass
    public static void init() {
        lexerAndParserFactory = loadGrammar("/Users/spogiri/antlr_playground/git/antlr4-autosuggest/src/test/resources/HarmonySQL.g4");
    }

    @Test
    public void suggest_From_shouldSuggestTableNames() {
        givenGrammar().whenInput("FROM ").thenExpect("PROFILE_TABLE", "REF_TABLE_1","US_FORT_WORTH_CUSTOMERS","US_DALLAS_CUSTOMERS");
    }

    @Test
    public void suggest_FromTable_shouldSuggestSelect() {
        givenGrammar().whenInput("FROM PROFILE_TABLE ").thenExpect("SELECT");
    }

    @Test
    public void suggest_FromSelect_shouldSuggestColumnNames() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT ").thenExpect("LAST_NAME","FIRST_NAME","REGION","STATE","*");
    }

    @Test
    public void suggest_FromSelectAsterisk_shouldSuggestWhere() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT * ").thenExpect("WHERE");
    }

    @Test
    public void suggest_FromSelectColumnName_shouldSuggestComma() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT FIRST_NAME ").thenExpect(",","WHERE");
    }

    @Test
    public void suggest_FromWhere_shouldSuggestColumnName() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT * WHERE ").thenExpect("LAST_NAME","FIRST_NAME","REGION","STATE");
    }

    @Test
    public void suggest_FromWhereColumn_shouldSuggestOperator() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT * WHERE LAST_NAME ").thenExpect("EQ","=","<=",">=","LT","GT",">","<","LTE","GTE","NEQ","!=","LIKE");
    }

    @Test
    public void suggest_FromWhereColumnOperator_shouldSuggestNothing() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT * WHERE LAST_NAME = ").thenExpect();
    }

    @Test
    public void suggest_FromWhereColumnExpression_shouldSuggestAndOr() {
        givenGrammar().whenInput("FROM PROFILE_TABLE SELECT * WHERE LAST_NAME = SMITH ").thenExpect("AND","OR");
    }

    private static LexerAndParserFactory loadGrammar(String fileLocation) {
        byte[] grammarAsBytes = null;
        try {
            grammarAsBytes = Files.readAllBytes(Paths.get(fileLocation));
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
            return factory;
        } catch (RecognitionException e) {
            throw new IllegalArgumentException(e);
        }
    }

    protected HarmonySQLAutoSuggesterTest givenGrammar() {
        return this;
    }
    private HarmonySQLAutoSuggesterTest withCasePreference(CasePreference casePreference) {
        this.casePreference = casePreference;
        return this;
    }

    private void printGrammarAtnIfNeeded() {
        Logger logger = LoggerFactory.getLogger(this.getClass());
        if (!logger.isDebugEnabled()) {
            return;
        }
        Lexer lexer = this.lexerAndParserFactory.createLexer(null);
        Parser parser = this.lexerAndParserFactory.createParser(null);
        String header = "\n===========  PARSER ATN  ====================\n";
        String middle = "===========  LEXER ATN   ====================\n";
        String footer = "===========  END OF ATN  ====================";
        String parserAtn = AtnFormatter.printAtnFor(parser);
        String lexerAtn = AtnFormatter.printAtnFor(lexer);
        logger.debug(header + parserAtn + middle + lexerAtn + footer);
    }

    private HarmonySQLAutoSuggesterTest whenInput(String input) {
        AutoSuggester suggester = new AutoSuggester(this.lexerAndParserFactory, input);
        suggester.setCasePreference(this.casePreference);
        this.suggestedCompletions = suggester.suggestCompletions();
        return this;
    }

    private void thenExpect(String... expectedCompletions) {
        assertThat(this.suggestedCompletions, containsInAnyOrder(expectedCompletions));
    }


}
