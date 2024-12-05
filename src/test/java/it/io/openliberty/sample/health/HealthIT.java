/*******************************************************************************
 * Copyright (c) 2018, 2020 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - Initial implementation
 *******************************************************************************/

package it.io.openliberty.sample.health;

import java.util.HashMap;
import jakarta.json.JsonArray;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

public class HealthIT {

  private JsonArray servicesstatus;
  private static HashMap<String, String> dataWhenServicesUP, dataWhenServicesDown;

  static {
    dataWhenServicesUP = new HashMap<String, String>();
    dataWhenServicesDown = new HashMap<String, String>();
    dataWhenServicesUP.put("SystemResource", "UP");
    dataWhenServicesDown.put("SystemResource", "DOWN");
  }

  @Test
  public void testIfServicesAreUp() {
    System.out.println("Begin testIfServicesAreUp");
    servicesstatus = HealthUtilIT.connectToHealthEnpoint(200);
    System.out.println("After connectToHealthEnpoint 200");
    checkServicesstatus(dataWhenServicesUP, servicesstatus);
    System.out.println("End testIfServicesAreUp");
  }

  @Test
  public void testIfServicesAreDown() {
    System.out.println("Begin testIfServicesAreUp");
    servicesstatus = HealthUtilIT.connectToHealthEnpoint(200);
    System.out.println("After connectToHealthEnpoint 200");
    checkServicesstatus(dataWhenServicesUP, servicesstatus);
    System.out.println("Before changeProperty");
    HealthUtilIT.changeProperty(HealthUtilIT.INV_MAINTENANCE_FALSE, HealthUtilIT.INV_MAINTENANCE_TRUE);
    System.out.println("After changeProperty");
    servicesstatus = HealthUtilIT.connectToHealthEnpoint(503);
    System.out.println("After connectToHealthEnpoint 503");
    checkServicesstatus(dataWhenServicesDown, servicesstatus);
    System.out.println("End testIfServicesAreDown");
  }

  private void checkServicesstatus(HashMap<String, String> testData, JsonArray servicesstatus) {
    testData.forEach((service, expectedState) -> {
      assertEquals(expectedState, HealthUtilIT.getActualState(service, servicesstatus),
          "The state of " + service + " service is not matching the ");
    });

  }

  @AfterEach
  public void teardown() {
    HealthUtilIT.cleanUp();
  }

}
