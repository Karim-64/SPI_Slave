var setupInfo = { "setupInfo" : [
{ "HOME_0IN" : "C:/QFT_2021.1/QFT_2021.1/QFT/V2021.1/win64" },{ "QHOME" : "C:/QFT_2021.1/QFT_2021.1/QFT/V2021.1/win64" },{ "ZSH" : "" },{ "ZI_RTLD_LIB" : "" }]};
var category = { "category" : [
{ "categoryId" : "0" , "categoryName":"Rtl Design Style" },
{ "categoryId" : "1" , "categoryName":"Simulation" },
{ "categoryId" : "2" , "categoryName":"Synthesis" },
{ "categoryId" : "3" , "categoryName":"Connectivity" },
{ "categoryId" : "4" , "categoryName":"Reset" },
{ "categoryId" : "5" , "categoryName":"Clock" },
{ "categoryId" : "6" , "categoryName":"Testbench" },
{ "categoryId" : "7" , "categoryName":"Nomenclature Style" },
{ "categoryId" : "8" , "categoryName":"Setup Checks" }]};
var severity = { "severity" : [
{ "severityId" : "0" , "severityName":"Error" },
{ "severityId" : "1" , "severityName":"Warning" },
{ "severityId" : "2" , "severityName":"Info" }]};
var statusObj = { "status" : [
{ "statusId" : "0" , "statusName":"uninspected" },
{ "statusId" : "1" , "statusName":"pending" },
{ "statusId" : "2" , "statusName":"waived" },
{ "statusId" : "3" , "statusName":"bug" },
{ "statusId" : "4" , "statusName":"fixed" },
{ "statusId" : "5" , "statusName":"verified" }]} ;
var checks = { "checks":[
{ "checksId":"0", "checksName":"always_signal_assign_large","severityId":"2","categoryId":"0"},
{ "checksId":"1", "checksName":"if_stmt_shares_arithmetic_operator","severityId":"1","categoryId":"0"},
{ "checksId":"2", "checksName":" ","severityId":"3","categoryId":"9"}]};
var schematicStatus = {  
"always_signal_assign_large" : "off",
"if_stmt_shares_arithmetic_operator" : "off"};
var adaptiveModeStatus = {  
"always_signal_assign_large" : "off",
"if_stmt_shares_arithmetic_operator" : "off"};
var checkAliasMap = { };
var argMap = {  
"1":"count",
"2":"limit",
"3":"module",
"4":"file",
"5":"line",
"6":"operand1",
"7":"operand2"};
