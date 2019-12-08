String source = r"""
{
	"goals": {
		"1": {
			"$": "Goal",
			"id": "1",
			"taskId": "1",
			"projectId": "1",
			"profileId": "1",
			"state": "ASSIGNED"
		}
	},
	"projects": {
		"1": {
			"id": "1",
			"$": "Project",
			"title": "test project 1",
			"description": "description",
			"contributors": ["2"],
			"creatorProfileId": "3",
			"state": "INCOMPLETE"
		},
		"2": {
			"id": "1",
			"$": "Project",
			"title": "test project 2",
			"description": "description",
			"contributors": ["2"],
			"creatorProfileId": "3",
			"state": "INCOMPLETE"
		}
	},
	"tasks": {
		"1": {
			"id": "1",
			"$": "Task",
			"projectId": "123",
			"description": "test desc",
			"closeReason": "",
			"closeReasonDescription": "",
			"creatorProfileId": "123",
			"assigneeProfileId": "123",
			"state": "INCOMPLETE"
		}
	}
}
""";

String getTestData() {
  return source;
}

String getTestRecursiveWhere() {
  return """
  {
    "users": {
      "1": {
        "id": "1",
        "name": "Vinicius",
        "type": "2"
      },
      "2": {
        "id": "2",
        "name": "Vinicius",
        "type": "1"
      },
      "__where__": {
        "name == Vinicius": {
          "1": {
            "id": "1",
            "name": "Vinicius",
            "type": "2"
          },
          "2": {
            "id": "2",
            "name": "Vinicius",
            "type": "1"
          },
          "__where__": {
            "type == 2": {
              "1": {
                "id": "1",
                "name": "Vinicius",
                "type": "2"
              }
            }
          }
        }
      }
    }
  }
  """;
}

String getTestDocumentReference() => """
  {
      "users": {
        "1": {
          "id": "1",
          "name": "Vinicius",
          "type": "2",
          "__ref__login": {
            "username": "v1pi",
            "password": "123"
          }
        }
      }
  }
  """;
String getTestDocumentReferenceNested() => """
  {
      "users": {
        "1": {
          "id": "1",
          "name": "Vinicius",
          "type": "2",
          "__ref__login": {
            "username": "v1pi",
            "password": "123",
            "__ref__address": {
              "address1": "Av unknown"
            }
          }
        }
      }
  }
  """;

String getTestDocumentReferenceArray() => """
  {
      "users": {
        "1": {
          "id": "1",
          "name": "Vinicius",
          "type": "2",
          "__ref__login": {
            "username": "v1pi",
            "password": "123",
            "__ref__telephones": [
              {
                "telephone": "+554269897854"
              },
              {
                "telephone": "+554269897855"
              },
              {
                "telephone": "+554269897836"
              }
            ]
          }
        }
      }
  }
  """;