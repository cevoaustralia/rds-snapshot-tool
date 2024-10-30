STACK_NAME?=rds-snapshot-tool-demo
REGION?=ap-southeast-2

LOG_LEVEL=INFO

SOURCE_PROFILE?=change-me
SOURCE_CODE_BUCKET?=change-me

DST_PROFILE?=change-me-too
DST_ACCOUNT_ID?=change-me


deploy-source:
	aws cloudformation deploy \
		--region $(REGION) \
		--template-file cftemplates/snapshots_tool_rds_source.json \
		--stack-name $(STACK_NAME)-source \
		--profile $(SOURCE_PROFILE) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			CodeBucket=$(SOURCE_CODE_BUCKET) \
			DestinationAccount=$(DST_ACCOUNT_ID) \
			LogLevel=$(LOG_LEVEL)


deploy-destination:
	aws cloudformation deploy \
		--region $(REGION) \
		--template-file cftemplates/snapshots_tool_rds_dest.json \
		--stack-name $(STACK_NAME)-dest \
		--profile $(SOURCE_PROFILE) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			CodeBucket=$(SOURCE_CODE_BUCKET) \
			DestinationAccount=$(DST_ACCOUNT_ID)
