/*
 * generated by Xtext 2.23.0
 */
package org.architecture.cnl;


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
public class ArchcnlStandaloneSetup extends ArchcnlStandaloneSetupGenerated {

	public static void doSetup() {
		new ArchcnlStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}
