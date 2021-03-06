Feature: Deployments
  Scenario: Manage application deployments
    Given an application "app1"
    When I create a deployment "v1-works"
    Then the deployment "v1-works" should exist
    And the symbolic link "current" should point to "v1-works"
    When I create a deployment "v2-works"
    Then the deployment "v2-works" should exist
    Then the symbolic link "current" should point to "v2-works"

  Scenario: Activate an old deployment
    Given an application "app1"
    And the following deployments:
      | name |
      | v1   |
      | v2   |
      | v3   |
    When I activate the deployment "v2"
    Then the deployments should be:
      | name |
      | v1   |
      | v3   |
      | v2   |

  Scenario: Prune old deployments
    Given an application "app1"
    And the following deployments:
      | name     |
      | v1-works |
      | v2-works |
      | v3-works |
      | v4-works |
      | v5-works |
    When I prune old deployments keeping the last 3
    Then the deployments should be:
      | name      |
      | v3-works  |
      | v4-works  |
      | v5-works  |
    When I prune old deployments keeping the last 10
    Then the deployments should be:
      | name      |
      | v3-works  |
      | v4-works  |
      | v5-works  |
    When I prune old deployments keeping the last 1
    Then the deployments should be:
      | name      |
      | v5-works  |
  Scenario: Automatic prunning of deployments
    Given an application "app1" with retention 1..2
    And the following deployments:
      | name |
      | v1   |
      | v2   |
    When I create a deployment "v3"
    Then the deployments should be:
      | name |
      | v2   |
      | v3   |
  Scenario: Minimum number of deployments
    Given an application "app1" with retention 3..5
    And the following deployments:
      | name |
      | v1   |
      | v2   |
      | v3   |
      | v4   |
    When I prune old deployments keeping the last 1
    Then the deployments should be:
      | name |
      | v2   |
      | v3   |
      | v4   |
