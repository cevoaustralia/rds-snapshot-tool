STACK_NAME?=rds-snapshot-tool-demo
REGION?=ap-southeast-2

LOG_LEVEL=INFO
CODE_BUCKET_NAME?=change-me

SOURCE_PROFILE?=change-me
SOURCE_ACCOUNT_ID?=change-me

DST_PROFILE?=change-me-too
DST_ACCOUNT_ID?=change-me

clean:
	aws s3 rb s3://$(CODE_BUCKET_NAME)-$(SOURCE_ACCOUNT_ID) --profile $(SOURCE_PROFILE) --force
	aws s3 rb s3://$(CODE_BUCKET_NAME)-$(DST_ACCOUNT_ID) --profile $(DST_PROFILE) --force

upload:
	aws s3 mb s3://$(CODE_BUCKET_NAME)-$(SOURCE_ACCOUNT_ID) --profile $(SOURCE_PROFILE)
	aws s3 mb s3://$(CODE_BUCKET_NAME)-$(DST_ACCOUNT_ID) --profile $(DST_PROFILE)

	make -C lambda all AWSARGS="--profile $(SOURCE_PROFILE)" S3DEST=$(CODE_BUCKET_NAME)-$(SOURCE_ACCOUNT_ID)
	rm lambda/._*
	make -C lambda all AWSARGS="--profile $(DST_PROFILE)" S3DEST=$(CODE_BUCKET_NAME)-$(DST_ACCOUNT_ID)

deploy-source:
	aws cloudformation deploy \
		--region $(REGION) \
		--template-file cftemplates/snapshots_tool_rds_source.json \
		--stack-name $(STACK_NAME)-source \
		--profile $(SOURCE_PROFILE) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			CodeBucket=$(CODE_BUCKET_NAME)-$(SOURCE_ACCOUNT_ID) \
			DestinationAccount=$(DST_ACCOUNT_ID) \
			LogLevel=$(LOG_LEVEL)


deploy-destination:
	aws cloudformation deploy \
		--region $(REGION) \
		--template-file cftemplates/snapshots_tool_rds_dest.json \
		--stack-name $(STACK_NAME)-dest \
		--profile $(DST_PROFILE) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
		--parameter-overrides \
			CodeBucket=$(CODE_BUCKET_NAME)-$(DST_ACCOUNT_ID) \
			DestinationAccount=$(DST_ACCOUNT_ID) \
			DestinationRegion=$(REGION)

all: upload deploy-source deploy-destination clean