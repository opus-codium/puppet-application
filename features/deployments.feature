Feature: Deployments
  Scenario: Manage application deployments
    Given an application "app1"
    When I create a deployment "v1-works"
    Then the deployment "v1-works" should exist
    And the symbolic link "current" should point to "v1-works"
    When I create a deployment "v2-works"
    Then the deployment "v2-works" should exist
    Then the symbolic link "current" should point to "v2-works"

  Scenario: Prune old deployments
    Up to 5 deployments are kept on disk.  When this limit is reached, least recently used deployments are pruned.
    Given an application "app1"
    And the following deployments:
      | name     |
      | v1-works |
      | v2-works |
      | v3-works |
      | v4-works |
      | v5-works |
    When I create a deployment "v6-broken"
    Then the deployments should be:
      | name      |
      | v2-works  |
      | v3-works  |
      | v4-works  |
      | v5-works  |
      | v6-broken |
    When I activate the deployment "v5-works"
    Then the deployments should be:
      | name      |
      | v2-works  |
      | v3-works  |
      | v4-works  |
      | v6-broken |
      | v5-works  |
    When I create a deployment "v7-broken"
    Then the deployments should be:
      | name      |
      | v3-works  |
      | v4-works  |
      | v6-broken |
      | v5-works  |
      | v7-broken |
    When I activate the deployment "v5-works"
    Then the deployments should be:
      | name      |
      | v3-works  |
      | v4-works  |
      | v6-broken |
      | v7-broken |
      | v5-works  |
    When I create a deployment "v8-broken"
    Then the deployments should be:
      | name      |
      | v4-works  |
      | v6-broken |
      | v7-broken |
      | v5-works  |
      | v8-broken |
    When I activate the deployment "v5-works"
    Then the deployments should be:
      | name      |
      | v4-works  |
      | v6-broken |
      | v7-broken |
      | v8-broken |
      | v5-works  |
    When I create a deployment "v9-broken"
    Then the deployments should be:
      | name      |
      | v6-broken |
      | v7-broken |
      | v8-broken |
      | v5-works  |
      | v9-broken |
    When I activate the deployment "v5-works"
    Then the deployments should be:
      | name      |
      | v6-broken |
      | v7-broken |
      | v8-broken |
      | v9-broken |
      | v5-works  |
    When I create a deployment "v10-broken"
    Then the deployments should be:
      | name       |
      | v7-broken  |
      | v8-broken  |
      | v9-broken  |
      | v5-works   |
      | v10-broken |
    When I activate the deployment "v5-works"
    Then the deployments should be:
      | name       |
      | v7-broken  |
      | v8-broken  |
      | v9-broken  |
      | v10-broken |
      | v5-works   |
