/*******************************************************************************
 * Copyright (c) 2017, 2020 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - Initial implementation
 *******************************************************************************/

package io.openliberty.sample.system;

import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;

import java.util.Properties;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;

@RequestScoped
@Path("/environment")
public class SystemEnvironment {

	@Inject
	SystemConfig systemConfig;

	@GET
	@Produces(MediaType.APPLICATION_JSON)
	public Response getEnvironment() {
		if (!systemConfig.isInMaintenance()) {
			Properties envProps = new Properties();
			envProps.putAll(java.lang.System.getenv());
			return Response.ok(envProps).build();
		} else {
			return Response.status(Response.Status.SERVICE_UNAVAILABLE).entity("ERROR: Service is currently in maintenance.")
					.build();
		}
	}
}
