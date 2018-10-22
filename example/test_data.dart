String getTestData() {
  return """
{
  "goal": {
    "1": {
      "id":"1",
      "taskId": "1",
      "projectId": "2"
    }
  },
  "projects": {
    "1": {
      "id": "1",
      "title": "test project 1"
    },
    "2": {
      "id": "2",
      "title": "test project 2"
    }    
  },
  "tasks": {
    "1": {
      "id": "1",
      "description": "test description 1"
    },
    "2": {
      "id": "2",
      "description": "test description 2"
    }
  }
}
    """;
}
