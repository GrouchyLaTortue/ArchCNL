package visitors;

import org.apache.jena.ontology.Individual;

import com.github.javaparser.ast.Modifier;
import com.github.javaparser.ast.body.Parameter;
import com.github.javaparser.ast.expr.AnnotationExpr;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;

import ontology.FamixOntology;

public class ParameterVisitor extends VoidVisitorAdapter<Void> {

	private FamixOntology ontology;
	private Individual parent;

	public ParameterVisitor(FamixOntology ontology, Individual parent) {
		this.ontology = ontology;
		this.parent = parent;
	}
	
	@Override
	public void visit(Parameter n, Void arg) {
		
		DeclaredTypeVisitor visitor = new DeclaredTypeVisitor(ontology);
		n.accept(visitor, null);
		
		Individual parameterIndividual = ontology.getParameterIndividual();
		ontology.setHasNamePropertyForNamedEntity(n.getName().asString(), parameterIndividual);
		
		ontology.setDeclaredTypeForBehavioralOrStructuralEntity(parameterIndividual, visitor.getDeclaredType());
		
		for (AnnotationExpr annotationExpr : n.getAnnotations()) {
			annotationExpr.accept(new MarkerAnnotationExpressionVisitor(ontology, parameterIndividual), null);
			annotationExpr.accept(new SingleMemberAnnotationExpressionVisitor(ontology, parameterIndividual), null);
			annotationExpr.accept(new NormalAnnotationExpressionVisitor(ontology, parameterIndividual), null);
		}
		
		for (Modifier modifier : n.getModifiers()) {
			ontology.setHasModifierForNamedEntity(modifier.asString(), parameterIndividual);
		}
		
		ontology.setDefinesParameterPropertyForBehavioralEntity(parent,parameterIndividual);
		
	}
	
	

}
