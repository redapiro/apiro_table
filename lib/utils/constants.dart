class Constants {
  static const List<String> cellPopupMenuOptions = [
    "Approve",
    "Recalculate",
  ];
  static const String AUDIT_TASK_COLUMN_DATA = """ 
   [{
 		"displayName": "Date",
 		"datafield": "date",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Principal ID",
 		"datafield": "principalId",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Principal Name",
 		"datafield": "principalName",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "UUID",
 		"datafield": "uuid",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Root UUID",
 		"datafield": "rootUuid",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Parent UUID",
 		"datafield": "parentUuid",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Task Type",
 		"datafield": "taskType",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Task Type Name",
 		"datafield": "taskTypeName",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	
 	{
 		"displayName": "m In Meta Data",
 		"datafield": "mInMeta",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "m Out Meta Data",
 		"datafield": "mOutMeta",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Has Logs",
 		"datafield": "hasLogs",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Duration",
 		"datafield": "duration",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "In Meta",
 		"datafield": "inMeta",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	},
 	{
 		"displayName": "Out",
 		"datafield": "outMeta",
 		"type": "",
 		"nested": false,
 		"showFilter": false,
 		"sortable": false,
 		"dataRangeFilter": false,
 		"currentDate": 0
 	}
 ]
 """;

  static const String AUDIT_TASK_DATA = """
{

"totalResults": 1,
	"results": [{
		"date": "06/06/2021 15:27:21",
		"principalId": "Test AIqw5P01It5g7Xd44u8",
		"principalName": "Hard coded Tester",
		"uuid": "ef0aaf7e-54d0-4a94-9c0f-3774de62705e",
		"rootUuid": "a7345144-0d08-4705-8920-d269fbf9c818",
		"parentUuid": "a7345144-0d08-4705-8920-d269fbf9c818",
		"taskType": "IMPORT_FEED",
		"taskTypeName": "IMPORT_FEED",
		"mInMeta": "Name = FEED_CSV_TEST, Id = Cdsw5Px2fdO6VuIYNB",
		"mOutMeta": "Success = 2, Fail = 0, Total = 2, PreWorkMS = 3288",
		"hasLogs": false,
		"duration": 5559,
		"inMeta": "Name = FEED_CSV_TEST, Id = Cdsw5Px2fdO6VuIYNB",
		"outMeta": "Success = 2, Fail = 0, Total = 2, PreWorkMS = 3288"
	}]
}
  """;
}
