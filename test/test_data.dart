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
