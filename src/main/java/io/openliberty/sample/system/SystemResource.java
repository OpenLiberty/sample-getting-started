/*******************************************************************************
 * Copyright (c) 2017, 2018 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - Initial implementation
 *******************************************************************************/

package io.openliberty.sample.system;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.metrics.annotation.Counted;
import org.eclipse.microprofile.metrics.annotation.Timed;

import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

@RequestScoped
@Path("/system")
public class SystemResource {
	
	@Inject
	SystemConfig systemConfig;

  @GET
  @Path("properties")
  @Produces(MediaType.APPLICATION_JSON)
  @Timed(name = "getPropertiesTime",
  description = "Time needed to get the properties of a system")
  @Counted(absolute = true, monotonic = true,
  description = "Number of times the properties of a systems is requested")
  public Response getProperties() {
	  if (!systemConfig.isInMaintenance()) {
	      return Response.ok(System.getProperties()).build();
	    } else {
	      return Response.status(Response.Status.SERVICE_UNAVAILABLE)
	                     .entity("ERROR: Service is currently in maintenance.")
	                     .build();
	}
  }
}
