/*
 * generated by Xtext 2.23.0
 */
package org.architecture.cnl.generator

import org.archcnl.owlcreator.api.APIFactory
import org.archcnl.owlcreator.api.OntologyAPI

import org.archcnl.common.datatypes.RuleType
import java.util.ArrayList
import org.architecture.cnl.archcnl.CanOnlyRuleType
import org.architecture.cnl.archcnl.CardinalityRuleType
import org.architecture.cnl.archcnl.ConceptExpression
import org.architecture.cnl.archcnl.ConditionalRuleType
import org.architecture.cnl.archcnl.DataStatement
import org.architecture.cnl.archcnl.DatatypeRelation
import org.architecture.cnl.archcnl.MustRuleType
import org.architecture.cnl.archcnl.NegationRuleType
import org.architecture.cnl.archcnl.Nothing
import org.architecture.cnl.archcnl.ObjectConceptExpression
import org.architecture.cnl.archcnl.ObjectRelation
import org.architecture.cnl.archcnl.OnlyCanRuleType
import org.architecture.cnl.archcnl.Sentence
import org.architecture.cnl.archcnl.SubConceptRuleType
import org.architecture.cnl.archcnl.ThatExpression
import org.architecture.cnl.archcnl.VariableStatement
import org.architecture.cnl.RuleTypeStorageSingleton;
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.semanticweb.owlapi.model.OWLClassExpression
import org.semanticweb.owlapi.model.OWLDataProperty
import org.semanticweb.owlapi.model.OWLObjectProperty
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.architecture.cnl.archcnl.FactStatement
import org.architecture.cnl.archcnl.ConceptAssertion
import org.architecture.cnl.archcnl.RoleAssertion
import org.architecture.cnl.archcnl.ObjectPropertyAssertion
import org.architecture.cnl.archcnl.DatatypePropertyAssertion
import org.semanticweb.owlapi.model.OWLDataHasValue

/**
 * This class is responsible for the conversion from the (already parsed) CNL to
 * OWL statements.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class ArchcnlGeneratorXtend extends AbstractGenerator {
	
	static final Logger LOG = LogManager.getLogger(AbstractGenerator);
	String namespace
	OntologyAPI api 
	static int id = 0
	Iterable<EObject> resourceIterable
	Iterable<Sentence> sentenceIterable

	/**
	 * "Translates" some parsed CNL sentences to an OWL ontology. The ontology will be stored in
	 * a file. The file's path is './architecture<id>.owl' where '<id>' is a counter which counts
	 * how often this method is called. Thus, the first call will produce a file 'architecture0.owl', 
	 * the second one a file 'architecture1.owl', and so on.
	 * 
	 * The ontology uses the namespace "http://www.arch-ont.org/ontologies/architecture.owl". When
	 * refering to its elements, this namespace/prefix must be used (e.g. when writing architecture-to-code
	 * mapping rules).
	 * 
	 * @param resource The parsed CNL input.
	 * @param fsa ???, but is not used anyway
	 * @param context ???, but is not used anyway
	 */
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		namespace = "http://www.arch-ont.org/ontologies/architecture.owl"

		val filename = RuleTypeStorageSingleton.getInstance().getOutputFile()

		api = APIFactory.get();  
		api.createOntology(filename, namespace)

		// decomposed the dot-notion to simplify debugging
		resourceIterable = resource.allContents.toIterable
		sentenceIterable = resourceIterable.filter(typeof(Sentence))

		LOG.debug("Start compiling CNL sentences ...")
		
		// compile each sentence
		for(Sentence s:sentenceIterable)
		{
			LOG.trace("ID " + id + ": " +"sentence subject: "+s.subject)
			LOG.trace("ID " + id + ": " +"sentence ruletype: "+s.ruletype)
			compile(s);
		}
		
		api.triggerSave()
		
		LOG.debug("... compiled all sentences.")
		
		api.removeOntology();
	}

	/**
	 * Compiles a single CNL sentence.
	 */
	def void compile(Sentence s) {
		val subject = s.subject
		val ruletype = s.ruletype
		val typeStorage = RuleTypeStorageSingleton.getInstance()
		
		LOG.trace("Compiling a new sentence ...")
		LOG.trace("ID " + id + ": " + ruletype)
		
		if (ruletype instanceof MustRuleType) {
			ruletype.compile(subject)
			typeStorage.storeTypeOfRule(id, RuleType.EXISTENTIAL) 
		} else if (ruletype instanceof CanOnlyRuleType) {
			ruletype.compile(subject)
			typeStorage.storeTypeOfRule(id, RuleType.UNIVERSAL) 
		} else if (ruletype instanceof OnlyCanRuleType) {
			ruletype.compile
			typeStorage.storeTypeOfRule(id, RuleType.DOMAIN_RANGE) 
		} else if (ruletype instanceof ConditionalRuleType) {
			ruletype.compile
			typeStorage.storeTypeOfRule(id, RuleType.CONDITIONAL) 
		} else if (ruletype instanceof NegationRuleType) {
			ruletype.compile
			typeStorage.storeTypeOfRule(id, RuleType.NEGATION) 
		} else if (ruletype instanceof SubConceptRuleType) {
			ruletype.compile(subject)
			typeStorage.storeTypeOfRule(id, RuleType.SUB_CONCEPT) 
		} else if (ruletype instanceof CardinalityRuleType) {
			ruletype.compile(subject)
		} else if (ruletype instanceof FactStatement) {
			compile(ruletype as FactStatement)
			typeStorage.storeTypeOfRule(id, RuleType.FACT) 
		}
		
		LOG.debug("Processed sentence with ID " + id)
		id++
	}

	def void compile(SubConceptRuleType subconcept, ConceptExpression subject) 
	{
		LOG.trace("ID " + id + ": " +"compiling SubConceptRuleType ...")
		val subjectConceptExpression = subject.compile
		val object = api.createOWLClass(namespace, subconcept.object.concept.conceptName)

		
		api.addSubClassAxiom(object, subjectConceptExpression)
	}

	def void compile(CardinalityRuleType cardrule, ConceptExpression subject) 
	{
		LOG.trace("ID " + id + ": " +"compiling CardinalityRuleType ...")
		val subjectConceptExpression = subject.compile
		var object = cardrule.object.expression.compile
		val listResult = new ArrayList
		
		
		listResult.add(object)
		for (o : cardrule.object.objectAndList) {
			val result = o.expression.compile
			listResult.add(result)
		}
		if (listResult.size > 1) {
			object = api.createIntersection(listResult)
			listResult.clear
		}

		for (o : cardrule.object.objectOrList) {
			val result = o.expression.compile
			listResult.add(result)
		}
		if (listResult.size > 1) {
			object = api.createUnion( listResult)
			listResult.clear
		}
		
		api.addSubClassAxiom(object,subjectConceptExpression) 
		
	}

	def void compile(NegationRuleType negation) 
	{
		LOG.trace("ID " + id + ": " +"compiling NegationRuleType ...")
		
		if (negation instanceof Nothing) {
			val subject = api.getOWLTop()
			var object = negation.object.expression.compile
			val listResult = new ArrayList
			listResult.add(object)
			for (o : negation.object.objectAndList) {
				val result = o.expression.compile
				listResult.add(result)
			}
			if (listResult.size > 1) {
				object = api.createIntersection(listResult)
				listResult.clear
			}

			for (o : negation.object.objectOrList) {
				val result = o.expression.compile
				listResult.add(result)
			}
			if (listResult.size > 1) {
				object = api.createUnion(listResult)
				listResult.clear
			}

			api.addDisjointAxiom(subject, object)
		} else {
			val subjectConceptExpression = negation.subject.compile
			if (negation.object.anything !== null) {
				val relation = api.createOWLObjectProperty(namespace,
					negation.object.anything.relation.relationName) as OWLObjectProperty
				var object = api.getOWLTop()
				api.addNegationAxiom(subjectConceptExpression, object, relation)
			} else {
				var object = negation.object.expression.compile
				val listResult = new ArrayList
				listResult.add(object)
				for (o : negation.object.objectAndList) {
					val result = o.expression.compile
					listResult.add(result)
				}
				if (listResult.size > 1) {
					object = api.createIntersection(listResult)
					listResult.clear
				}

				for (o : negation.object.objectOrList) {
					val result = o.expression.compile
					listResult.add(result)
				}
				if (listResult.size > 1) {
					object = api.createUnion(listResult)
					listResult.clear
				}

				api.addDisjointAxiom(subjectConceptExpression, object)

			}
		}
	}

	def void compile(ConditionalRuleType conditional) {
		conditional.subject.compile
		conditional.object.compile
		// the CNL permits only object properties
		// reason 1: datatype properties don't make sense here
		// reason 2: sub-properties are only defined when both properites have the same type (datatype or object property)
		//           enforcing this would require larger changes 
		var subProperty = api.createOWLObjectProperty(namespace, conditional.relation.relationName)
		var superProperty = api.createOWLObjectProperty(namespace, conditional.relation2.relationName)
		api.addSubPropertyOfAxiom(subProperty, superProperty)
	}

	def void compile(OnlyCanRuleType onlycan) 
	{
		LOG.trace("ID " + id + ": " +"compiling OnlyCanRuleType ...")
		val subjectConceptExpression = onlycan.subject.compile
		var object = onlycan.object.expression.concept.compile
		var relation = api.createOWLObjectProperty(namespace,
			onlycan.object.expression.relation.relationName) as OWLObjectProperty

		val objectOrList = onlycan.object.objectOrList
		val listResult = new ArrayList

		
		listResult.add(object)

		for (o : objectOrList) {
			val result = o.expression.concept.compile
			listResult.add(result)
		}

		object = api.createUnion(listResult)
		api.addDomainRangeAxiom(subjectConceptExpression, object, relation)

	}

	def void compile(CanOnlyRuleType canonly, ConceptExpression subject) 
	{
		LOG.trace("ID " + id + ": " +"compiling CanOnlyRuleType ...")
		val subjectConceptExpression = subject.compile
		var object = canonly.object.expression.concept.compile
		var relation = api.createOWLObjectProperty(namespace,
			canonly.object.expression.relation.relationName) as OWLObjectProperty

		val objectAndList = canonly.object.objectAndList
		val objectOrList = canonly.object.objectOrList
		val listResult = new ArrayList

		
		object = api.createOnlyRestriction(relation, object)

		listResult.add(object)

		for (o : objectAndList) {
			var result = o.expression.concept.compile
			result = api.createOnlyRestriction(relation,result)
			listResult.add(result)
		}
		if (listResult.size > 1) {
			object = api.createIntersection(listResult)
			listResult.clear
		}

		for (o : objectOrList) {
			var result = o.expression.concept.compile
			result = api.createOnlyRestriction(relation,result)
			listResult.add(result)
		}
		if (listResult.size > 1) {
			object = api.createUnion(listResult)
			listResult.clear
		}

		api.addSubClassAxiom(object, subjectConceptExpression)
	}

	def void compile(MustRuleType must, ConceptExpression subject) 
	{
		LOG.trace("ID " + id + ": " +"compiling MustRuleType ... ")
		val subjectConceptExpression = subject.compile
		var object = must.object.expression.concept.compile
		var relation = api.createOWLObjectProperty(namespace,
			must.object.expression.relation.relationName) as OWLObjectProperty
	
		val objectAndList = must.object.objectAndList
		val objectOrList = must.object.objectOrList
		val listResult = new ArrayList

		object = api.createSomeValuesFrom(relation, object)
		listResult.add(object)
		
		for (o : objectAndList) {
			var result = o.expression.concept.compile
			result = api.createSomeValuesFrom(relation,result)
			listResult.add(result)
		}
		if (listResult.size > 1) {
			object = api.createIntersection(listResult)
			listResult.clear
		}
		for (o : objectOrList) {
			var result = o.expression.concept.compile
			result = api.createSomeValuesFrom(relation,result)
			listResult.add(result)
		}
		if (listResult.size > 1) {
			object = api.createUnion(listResult)
			listResult.clear
		}
		api.addSubClassAxiom(object, subjectConceptExpression)
	}

	def OWLClassExpression compile(ObjectConceptExpression object) 
	{
		LOG.trace("ID " + id + ": " +"compiling ObjectConceptExpression ...")
		val relation = api.createOWLObjectProperty(namespace, object.relation.relationName) as OWLObjectProperty
		val concept = object.concept.compile
		val count = object.number
		
		val typeStorage = RuleTypeStorageSingleton.getInstance();
		
		if(object.cardinality == 'at-most') {
			typeStorage.storeTypeOfRule(id, RuleType.AT_MOST)
			return api.createMaxCardinalityRestrictionAxiom(concept,relation,count)
		}
		else if(object.cardinality == 'at-least') {
			typeStorage.storeTypeOfRule(id, RuleType.AT_LEAST)
			return api.createMinCardinalityRestrictionAxiom(concept,relation,count)
		}
		else if(object.cardinality == 'exactly') {
			typeStorage.storeTypeOfRule(id, RuleType.EXACTLY)
			return api.createExactCardinalityRestrictionAxiom(concept,relation,count)
		}
		else {
			return api.createSomeValuesFrom(relation, concept)			
		}
	}

	def OWLClassExpression compile(ConceptExpression conceptExpression) 
	{
		LOG.trace("ID " + id + ": " +"compiling ConceptExpression ... ")

		val conceptAsOWL = api.createOWLClass(namespace, conceptExpression.concept.conceptName)

		var result = conceptAsOWL as OWLClassExpression
		val thatList = conceptExpression.that
		
		if (thatList.isEmpty) {
			return result
		} else {
			val that = thatList.get(0)
		
			result = that.compile
			var elements = new ArrayList
			elements.add(conceptAsOWL)
			elements.add(result)
			result = api.createIntersection(elements)

			return result
		}

	}

	def OWLClassExpression compile(ThatExpression that) 
	{
		LOG.trace("ID " + id + ": " +"compiling ThatExpression ...")

		var results = new ArrayList<OWLClassExpression>

		for (statements : that.list) {
			val expression = statements.expression
			if (expression instanceof ConceptExpression) {
				val relation = statements.relation as ObjectRelation
				val thatRoleOWL = api.createOWLObjectProperty(namespace, relation.relationName) as OWLObjectProperty
				val owlexpression = expression.compile
				var result = api.createSomeValuesFrom(thatRoleOWL, owlexpression)
				results.add(result)
			// result = api.intersectionOf(namespace, conceptAsOWL, result)
			} else if (expression instanceof DataStatement) {
				LOG.trace(statements.relation)
				val relation = statements.relation as DatatypeRelation
				val thatRoleOWL = api.createOWLDatatypeProperty(namespace, relation.relationName) as OWLDataProperty
				val dataString = expression.stringValue
				if (dataString !== null) {
					val dataHasValue = api.createDataHasValue(dataString, thatRoleOWL)
//					return dataHasValue
					results.add(dataHasValue)
//				result = api.intersectionOf(namespace, conceptAsOWL, dataHasValue)
				} else {
					val dataHasValue = api.createDataHasValue(expression.intValue, thatRoleOWL)
					results.add(dataHasValue)
//					return dataHasValue
//				result = api.intersectionOf(namespace, conceptAsOWL, dataHasValue)
				}
			} else if (expression instanceof VariableStatement) {
				LOG.trace("with Variable")
				return null
			}

		}

		return api.createIntersection(results)

	}
	
	def void compile(FactStatement fact) {
		LOG.trace("ID " + id + ": " +"compiling FactStatement ...")
		
		if (fact.assertion instanceof ConceptAssertion) {
			compile(fact.assertion as ConceptAssertion)
		} else if (fact.assertion instanceof RoleAssertion) {
			compile(fact.assertion as RoleAssertion)
		}
	}
	
	def void compile(ConceptAssertion fact) {
		LOG.trace("ID " + id + ": " +"compiling ConceptAssertion...")
		
		var individual = api.createNamedIndividual(namespace, fact.individual)
		var concept = api.createOWLClass(namespace, fact.concept.conceptName)
		
		api.addClassAssertionAxiom(individual, concept)
	}
	
	def void compile(RoleAssertion fact) {
		LOG.trace("ID " + id + ": " +"compiling RoleAssertion...")
		
		var individual = api.createNamedIndividual(namespace, fact.individual)
		
		if (fact instanceof ObjectPropertyAssertion) {
			compile(fact as ObjectPropertyAssertion)
		}
		else if (fact instanceof DatatypePropertyAssertion) {
			compile(fact as DatatypePropertyAssertion)
		}
	}
	
	def void compile(ObjectPropertyAssertion fact) {
		var individual = api.createNamedIndividual(namespace, fact.individual)
		var relation = api.createOWLObjectProperty(namespace, fact.relation.relationName)
		var otherIndividual = api.createNamedIndividual(namespace, fact.individual2)

		api.addObjectPropertyAssertion(individual, relation, otherIndividual)
	}
	
	def void compile(DatatypePropertyAssertion fact) {
		var individual = api.createNamedIndividual(namespace, fact.individual)
		var relation = api.createOWLDatatypeProperty(namespace, fact.relation.relationName)
			
		if (fact.stringValue !== null) {
			api.addClassAssertionAxiom(individual, api.createDataHasValue(fact.stringValue, relation))
		}
		else {
			api.addClassAssertionAxiom(individual, api.createDataHasValue(fact.intValue, relation))
		}
	}
}