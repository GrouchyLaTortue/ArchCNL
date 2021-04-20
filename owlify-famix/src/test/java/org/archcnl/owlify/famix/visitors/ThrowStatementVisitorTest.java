package org.archcnl.owlify.famix.visitors;

import com.github.javaparser.StaticJavaParser;
import com.github.javaparser.symbolsolver.JavaSymbolSolver;
import com.github.javaparser.symbolsolver.resolution.typesolvers.CombinedTypeSolver;
import com.github.javaparser.symbolsolver.resolution.typesolvers.JavaParserTypeSolver;
import com.github.javaparser.symbolsolver.resolution.typesolvers.ReflectionTypeSolver;
import org.junit.Before;

public class ThrowStatementVisitorTest {

    private String pathToJavaClass = "./src/test/java/examples/ExampleClassWithExceptions.java";

    @Before
    public void initializeVisitor() {

        // set a symbol solver
        CombinedTypeSolver combinedTypeSolver = new CombinedTypeSolver();
        combinedTypeSolver.add(new ReflectionTypeSolver());
        combinedTypeSolver.add(new JavaParserTypeSolver("./src/test/java/examples/"));
        StaticJavaParser.getConfiguration()
                .setSymbolResolver(new JavaSymbolSolver(combinedTypeSolver));
    }

    //    @Test
    //    public void test() throws FileIsNotAJavaClassException, FileNotFoundException {
    //        CompilationUnit unit = CompilationUnitFactory.getFromPath(pathToJavaClass);
    //        InputStream famixOntologyInputStream =
    //                getClass().getResourceAsStream("/ontologies/famix.owl");
    //        FamixOntology ontology = new FamixOntology(famixOntologyInputStream);
    //        JavaTypeVisitor classVisitor = new JavaTypeVisitor(ontology);
    //        unit.accept(classVisitor, null);
    //
    //        Individual currentUnitIndividual = classVisitor.getFamixTypeIndividual();
    //        ThrowStatementVisitor visitor = new ThrowStatementVisitor(ontology,
    // currentUnitIndividual);
    //
    //        unit.accept(visitor, null);
    //
    //        FamixOntClassesAndProperties provider = new FamixOntClassesAndProperties();
    //        OntModel model = ontology.toJenaModel();
    //
    //        Individual throw0 = provider.getThrownExceptionIndividual(model, 0);
    //        Individual throw1 = provider.getThrownExceptionIndividual(model, 1);
    //        Property throwsException = provider.getThrowsExceptionProperty(model);
    //        Property hasType = provider.getHasDefiningClassProperty(model);
    //        Individual exceptionType0 =
    //                ontology.getFamixClassWithName("java.lang.IllegalArgumentException");
    //        Individual exceptionType1 =
    //                ontology.getFamixClassWithName("java.lang.IllegalStateException");
    //
    //        int matchingStatements =
    //                model.listStatements(currentUnitIndividual, throwsException, throw0)
    //                        .toList()
    //                        .size();
    //        assertEquals(1, matchingStatements);
    //
    //        matchingStatements =
    //                model.listStatements(currentUnitIndividual, throwsException, throw1)
    //                        .toList()
    //                        .size();
    //        assertEquals(1, matchingStatements);
    //
    //        matchingStatements = model.listStatements(throw0, hasType,
    // exceptionType0).toList().size();
    //        assertEquals(1, matchingStatements);
    //
    //        matchingStatements = model.listStatements(throw1, hasType,
    // exceptionType1).toList().size();
    //        assertEquals(1, matchingStatements);
    //    }
}
